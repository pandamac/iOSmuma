#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <strings.h>
#include <sys/wait.h>
#include <string.h>
#include <sys/stat.h>

#include <sys/types.h>
#include <fcntl.h>
/********************************************************************* 
*filename: tcpserver.c 
*purpose:tcp服务端程序 
********************************************************************/

#define CHUNK_SIZE 512

struct my_data
{
    int type;
    char flag;
    char buf[CHUNK_SIZE];
};
struct file_info
{
    char filename[100];
    int filesize;
};

#define MSG_SendAgain 0x55
#define MSG_SendOver 0x66

void usage()
{
    printf("\nwelcome to my iOS server\n");
    printf("1)command   eg: command ls\n  dpkg --get-selections 显示包\n  dpkg -i xxx.deb\n  dpkg -r xxx\n  dpkg -P xxx\n");
    printf("2)ListApp   List the App\n");
    printf("3)recv more info\n");
    printf("4)sendfile  send file to destination /tmp\n");
    printf("5)downloadfile  download file from destination\n");
    printf("9)quit      exit this connection\n");
    printf("0)help   show this message\n");

}
int main(int argc, char ** argv) 
{ 
    
    int sockfd,new_fd;
    struct sockaddr_in my_addr; /* 本机地址信息 */ 
    struct sockaddr_in their_addr; /* 客户地址信息 */ 
    unsigned int sin_size, myport, lisnum; 
 
 
    memset(&my_addr,0,sizeof(my_addr));
    sockfd=0;
    new_fd=0;
    if(argv[1])  
        myport = atoi(argv[1]); 
    else 
        myport = 8800; 
 
    if(argv[2])  
        lisnum = atoi(argv[2]); 
    else lisnum = 99; 
 
    if ((sockfd = socket(PF_INET, SOCK_STREAM, 0)) == -1) { 
        perror("socket"); 
        exit(1); 
    } 
    printf("socket %d ok \n",myport);

    my_addr.sin_family=PF_INET; 
    my_addr.sin_port=htons(myport); 
    my_addr.sin_addr.s_addr = INADDR_ANY; 
    bzero(&(my_addr.sin_zero), 0); 
    if (bind(sockfd, (struct sockaddr *)&my_addr, sizeof(struct sockaddr)) == -1) { 
        perror("bind"); 
        exit(1); 
    } 

__start:
 printf("bind ok ,wait for listen\n");
    if (listen(sockfd, lisnum) == -1) { 
        perror("listen"); 
        exit(1); 
    }
 printf("listen ok \n");
 
 /*
    while(1) { 
        sin_size = sizeof(struct sockaddr_in); 
        if ((new_fd = accept(sockfd, (struct sockaddr *)&their_addr, &sin_size)) == -1) { 
            perror("accept"); 
            continue; 
        }

        printf("server: got connection from %s\n",inet_ntoa(their_addr.sin_addr)); 
        if (!fork()) { //子进程代码段 
            if (send(new_fd, "Hello, world!\n", 14, 0) == -1) { 
                perror("send"); 
                close(new_fd); 
                exit(0); 
            } 
        } 
        close(new_fd); //父进程不再需要该socket
        waitpid(-1,NULL,WNOHANG);//等待子进程结束，清除子进程所占用资源
    } 
 */

    sin_size = sizeof(struct sockaddr_in); 
    if ((new_fd = accept(sockfd, (struct sockaddr *)&their_addr, &sin_size)) == -1) { 
        //perror("accept"); 
        printf("accept error\n");
  //exit(0); 
    } 
    printf("server: got connection from %s\nplease input data\n",inet_ntoa(their_addr.sin_addr));

 while(1) {
  char  szSnd[100];
while(1)
{
    usage();
   memset(szSnd,0,sizeof(szSnd));
   //scanf("%s",szSnd);
   
   fflush(stdin);
   gets(szSnd);
   if (strcmp(szSnd,"1") == 0 | strcmp(szSnd,"command") == 0)
   {
        strcpy(szSnd,"command");break;
   }
   else if (strcmp(szSnd,"2") == 0 | strcmp(szSnd,"ListApp") == 0)
   {
        strcpy(szSnd,"ListApp");break;
   }
   else if (strcmp(szSnd,"3") == 0 | strcmp(szSnd,"recv") == 0)
   {
        strcpy(szSnd,"recv");break;
   }
   else if (strcmp(szSnd,"4") == 0 | strcmp(szSnd,"sendfile") == 0)
   {
        strcpy(szSnd,"sendfile");break;
   }
   else if (strcmp(szSnd,"5") == 0 | strcmp(szSnd,"downloadfile") == 0)
   {
        strcpy(szSnd,"downloadfile");break;
   }
   else if (strcmp(szSnd,"0") == 0 | strcmp(szSnd,"help") == 0)
   {
        usage();
   }
   else if (strcmp(szSnd,"9") == 0 || strcmp(szSnd,"quit") == 0)
   {
         strcpy(szSnd,"quit");
         break;
   }
   else
   {
        printf("You input wrong :%s\n",szSnd);
        usage();
   }
 }
   printf("send message :%s\n",szSnd);
        if (send(new_fd, szSnd, sizeof(szSnd), 0) == -1) { 
            //perror("send"); 
            printf("send error break :%s\n",szSnd);
            close(new_fd);
            sleep(1);
            goto __start;
        }
     
    if (strcmp(szSnd,"command") == 0)
    {
        printf("You select command! please input the command\n");
         memset(szSnd,0,sizeof(szSnd));
         
         fflush(stdin);
         gets(szSnd);
        printf("send command :%s\n",szSnd);

          if (send(new_fd, szSnd, sizeof(szSnd), 0) == -1) { 
                   printf("send error break :%s\n",szSnd);
             close(new_fd);
              sleep(1);
              goto __start;
            }
        int CommandSize;
        recv(new_fd,(char*)&CommandSize,sizeof(CommandSize),0);
        printf("command size: %d\n",CommandSize);

        int nChunkCount = 0;
        nChunkCount = CommandSize / CHUNK_SIZE;

        if (CommandSize % CHUNK_SIZE != 0)
        {
            nChunkCount++;
        }

        char ok[3];
        strcpy(ok,"ok");
        ok[2]='\0';
        if (send(new_fd,ok,2,0))
        {
            char FileData[CHUNK_SIZE];
            int sum=0;
            for (int i = 0; i < nChunkCount; i++)
            {
              int nLeft;
              if (i+1 == nChunkCount)
              {
                  nLeft = CommandSize - (nChunkCount-1)*CHUNK_SIZE;
                  //printf("last :%d\n", nLeft);
              }
              else
              {
                nLeft = CHUNK_SIZE;
              }
              int idx = 0;
              int nCount = 0;
              while(nLeft > 0)
              {
                  int iRet = recv(new_fd,&FileData[idx],nLeft,0);
                  //printf("iRet = %d\n",iRet );
                  if (-1 == iRet)
                 {
                    printf("recv error\n");
                    return 0;
                 }
                 nLeft -= iRet;
                 idx += iRet;
                 nCount += iRet;
              }
              FileData[nCount]='\0';
              printf("%s",FileData);
            }
        }

/*
        struct my_data data;
        memset(&data,0,sizeof(struct my_data));
        recv(new_fd,(char*)&data,sizeof(struct my_data),0);
        //printf("sizeof(struct my_data): %d\n",sizeof(struct my_data));
        if (data.type == 1)
        {

            if (data.flag == MSG_SendOver)
            {
                printf("You Recveced short message:\n%s\nplease continue input something\n",data.buf);
            }
            else if (data.flag == MSG_SendAgain)
            {
                printf("You Recveced long message:\n");
                while(1)
                {
                   printf("%s", data.buf);
                    if (data.flag == MSG_SendOver)
                    {
                        break;
                    }
                    memset(data.buf,0,sizeof(data.buf));
                    recv(new_fd,(char*)&data,sizeof( struct my_data),0);

                }
                 printf("\nplease continue input something\n");
            }
            else
                printf("my_data flag is error\n");     
        }
        else
        {
            printf("something wrong in command type:\n",data.type);
        }
*/

    }
    else if (strcmp(szSnd,"ListApp") == 0)
    {
        printf("You choose ListApp please wait\n");
        
        int CommandSize;
        recv(new_fd,(char*)&CommandSize,sizeof(CommandSize),0);
        printf("command size: %d\n",CommandSize);

        int nChunkCount = 0;
        nChunkCount = CommandSize / CHUNK_SIZE;

        if (CommandSize % CHUNK_SIZE != 0)
        {
            nChunkCount++;
        }

        char ok[3];
        strcpy(ok,"ok");
        ok[2]='\0';
        if (send(new_fd,ok,2,0))
        {
            char FileData[CHUNK_SIZE];
            int sum=0;
            for (int i = 0; i < nChunkCount; i++)
            {
              int nLeft;
              if (i+1 == nChunkCount)
              {
                  nLeft = CommandSize - (nChunkCount-1)*CHUNK_SIZE;
                  //printf("last :%d\n", nLeft);
              }
              else
              {
                nLeft = CHUNK_SIZE;
              }
              int idx = 0;
              int nCount = 0;
              while(nLeft > 0)
              {
                  int iRet = recv(new_fd,&FileData[idx],nLeft,0);
                  if (-1 == iRet)
                 {
                    printf("recv error\n");
                    return 0;
                 }
                 nLeft -= iRet;
                 idx += iRet;
                 nCount += iRet;
              }
              FileData[nCount]='\0';
              printf("%s",FileData);
            }
        }
        

    }
    else if (strcmp(szSnd,"quit") == 0)
    {
        close(new_fd);
        sleep(1);
        goto __start;
    }
    else if (strcmp(szSnd,"recv") == 0)
    {
        struct my_data data;
        memset(&data,0,sizeof(struct my_data));

      int flags = fcntl(sockfd, F_GETFL, 0);                       //获取文件的flags值。
      fcntl(sockfd, F_SETFL, flags | O_NONBLOCK);   //设置成非阻塞模式；

      recv(new_fd,(char*)&data,sizeof(struct my_data),MSG_DONTWAIT);
      flags  = fcntl(sockfd,F_GETFL,0);
      fcntl(sockfd,F_SETFL,flags&~O_NONBLOCK);    //设置成阻塞模式；

      printf("%s", data.buf);
        if (data.type == 1)
        {
            printf("\ncommnad info:\n%s",data.buf);
        }
        else if (data.type ==2)
        {
            printf("\nlist app info:\n%s",data.buf);
        }
        else
            {printf("\nDon't Know what is it:\n%s", data.buf);}
     
    }
    else if ( strcmp(szSnd,"sendfile") == 0)
    {
        //送放文件->接收->返回块号->确认块号->继续发送
        struct file_info my_file_info;
        memset(&my_file_info,0,sizeof(my_file_info));
        printf("input your full path name < 50 bytes\n");
        fflush(stdin);
        gets(my_file_info.filename);
        while (strcmp(my_file_info.filename,"") == 0 || strlen(my_file_info.filename) > 50)
        {
          printf("input your full path name < 50 bytes\n");
          fflush(stdin);
          gets(my_file_info.filename);
        }
        
        int filefd = open(my_file_info.filename,O_RDONLY);
        if (filefd<0) 
            return -1;
        struct stat my_file_stat;
        fstat(filefd, &my_file_stat);
        //stat.st_size就是文件大小 
        my_file_info.filesize = my_file_stat.st_size;

        int nChunkCount = 0;
        nChunkCount = my_file_info.filesize / CHUNK_SIZE;

        if (my_file_info.filesize % CHUNK_SIZE != 0)
        {
            nChunkCount++;
        }
          if (send(new_fd, (char*)&my_file_info, sizeof(my_file_info), 0) == -1) { 
                //perror("sendfile send"); 
                printf("send error break :%s\n",szSnd);
             close(new_fd);
              sleep(1);
              goto __start;
            }
          char ok[3];
          recv(new_fd,ok,2,0);
          ok[2] = '\0';
          printf("确认指令 %s\n",ok);
          if (strcmp(ok,"ok") == 0)
          {
            printf("ok start to send\n");
              char FileData[CHUNK_SIZE];
              for (int i = 0; i < nChunkCount; i++)
              {
                  int nLeft;
                  if (i+1 == nChunkCount)
                  {
                      nLeft = my_file_info.filesize - CHUNK_SIZE * (nChunkCount - 1);
                  }
                  else
                  {
                      nLeft = CHUNK_SIZE;
                  }
                  int idx = 0;
                  read(filefd,FileData,CHUNK_SIZE);
                  while(nLeft > 0){
                          int iRet = send(new_fd, (char*)&FileData[idx], nLeft, 0);
                          printf("%d bytes\n",iRet);
                          idx += iRet;
                          nLeft -= iRet;
                  }
              }
          }
        close(filefd);
        printf("send file over~\n");
    }
    else if (strcmp(szSnd,"downloadfile") == 0)
    {
        struct file_info my_file_info;
        memset(&my_file_info,0,sizeof(my_file_info));
        printf("input which file you want to download eg: /1.txt\n");
        fflush(stdin);
        gets(my_file_info.filename);
        my_file_info.filesize = 0;
        

        while(strcmp(my_file_info.filename,"") == 0 || strrchr(my_file_info.filename, '/') == NULL)
        {
          printf("input which file you want to download eg: /1.txt\n");fflush(stdin);
          gets(my_file_info.filename);
          char *pLastSlash = strrchr(my_file_info.filename, '/');
        }
        char * pLastSlash = strrchr(my_file_info.filename, '/');

        char *pszBaseName = pLastSlash ? pLastSlash + 1 :pLastSlash;
        printf("Base Name: %s\n", pszBaseName);

          if (send(new_fd, (char*)&my_file_info, sizeof(my_file_info), 0) == -1) { 
                    //perror("sendfile send"); 
                       printf("send error break :%s\n",szSnd);
                 close(new_fd);
                  sleep(1);
                  goto __start;
                   // break;
              }
            memset(&my_file_info,0,sizeof(my_file_info));
             recv(new_fd,(char*)&my_file_info,sizeof(my_file_info),0);
            if (my_file_info.filesize == 0)
            {
                  printf("my_file_info.filesize = 0,error\n");
                  sleep(1);
                  continue;
            }
            int nChunkCount = 0;
            nChunkCount = my_file_info.filesize / CHUNK_SIZE;

            if (my_file_info.filesize % CHUNK_SIZE != 0)
            {
                nChunkCount++;
            }
            printf("recv file size = %d\nnChunkCount = %d\n",my_file_info.filesize,nChunkCount);
            char pathtosore[40];
          printf("input where do you want to store eg: /root/Desktop/ \n");
            fflush(stdin);
              gets(pathtosore);
              if (strcmp(pathtosore,"") == 0)
                  {
                      strcpy(pathtosore,"/root/Desktop/");
                  }      
        
             strcat(pathtosore,pszBaseName);

            int filefd = open(pathtosore,O_CREAT|O_RDWR);
            if (filefd<0) 
                printf("downloadfile error open\n");

        char ok[3];
        strcpy(ok,"ok");
        ok[2]='\0';
        if (send(new_fd,ok,2,0))
        {
            char FileData[CHUNK_SIZE];
            int sum=0;
            for (int i = 0; i < nChunkCount; i++)
            {
              int nLeft;
              if (i+1 == nChunkCount)
              {
                  nLeft = my_file_info.filesize - (nChunkCount-1)*CHUNK_SIZE;
                  printf("last :%d\n", nLeft);
              }
              else
              {
                nLeft = CHUNK_SIZE;
              }
              int idx = 0;
              int nCount = 0;
              while(nLeft > 0)
              {
                  int iRet = recv(new_fd,&FileData[idx],nLeft,0);
                  if (-1 == iRet)
                 {
                    printf("recv error\n");
                    return 0;
                 }
                 nLeft -= iRet;
                 idx += iRet;
                 nCount += iRet;
              }
              printf("write size: %d\n", nCount);
               write(filefd,FileData,nCount);
            }
        }
        
        close(filefd);
        printf("download file over~\n");
    }
    else
        printf("has sent msg: %s \n",szSnd);
sleep(1);

 }

 exit(0); 
}
