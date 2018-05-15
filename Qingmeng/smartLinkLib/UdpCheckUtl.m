//
//  UdpCheckUtl.m
//  SuperSmart
//
//  Created by mqw on 15/10/22.
//  Copyright © 2015年 gicisky. All rights reserved.
//

#import "UdpCheckUtl.h"
#include <ifaddrs.h>
#include <arpa/inet.h>

@interface UdpCheckUtl ()

@end
@implementation UdpCheckUtl
{
}

NSMutableDictionary * scanDeviceDic;




-(void) doScanDevice
{
    
    //初始化udp
    self.socket =[[AsyncUdpSocket alloc] initWithDelegate:self];
  
    

    //绑定端口
    NSError *error = nil;
    [_socket bindToPort:988 error:&error];
    
    //发送广播设置
    [_socket enableBroadcast:YES error:&error];
   	//启动接收线程
    [_socket receiveWithTimeout:-1 tag:0];
    
    
    NSString *localIP =  [self getIPAddress];
    if(localIP != nil &&![localIP isEqualToString:@"error"]){
        NSMutableArray *components =[[NSMutableArray alloc]initWithArray: [localIP componentsSeparatedByString:@"."]];
        if (components.count>0) {
            [components removeLastObject];
            NSString *str = [components componentsJoinedByString:@"."];
            NSString  *UdpIp = [NSString stringWithFormat:@"%@.%@",str,@"255"];
            
            
            //开始发送
            NSLog(@"发送：%@",@"hlkATat+mac=?");
            [_socket sendData:[@"hlkATat+mac=?" dataUsingEncoding:NSUTF8StringEncoding]
                       toHost:@"255.255.255.255" port:988 withTimeout:-1 tag:0];
        }
    }else{
        //NSLog(@"本机IP失败：%@",localIP);
    }
    
    
    
    
    
   
}


- (BOOL)onUdpSocket:(AsyncUdpSocket *)sock didReceiveData:(NSData *)data withTag:(long)tag fromHost:(NSString *)host port:(UInt16)port
{
    [_socket receiveWithTimeout:-1 tag:0];
    NSString *info=[[NSString alloc] initWithData:data encoding: NSUTF8StringEncoding];
    NSLog(@"udpj接收 ：@%@",info);
  
    if (![info hasPrefix:@"hlkATat+mac=?"]) {
        NSArray *aArray = [info componentsSeparatedByString:@","];
        if (aArray.count == 6) {
            NSString *mac = [NSString stringWithFormat:@"%02x:%02x:%02x:%02x:%02x:%02x",
                             [aArray[0] intValue],  [aArray[1] intValue],
                             [aArray[2] intValue],  [aArray[3] intValue],
                             [aArray[4] intValue],  [aArray[5] intValue]];
            
            NSString*IP = host;
           
            //创建多个字典
            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                                 IP, DEVICE_HOST,
                                 mac, DEVICE_MAC,
                                 nil];
            
            [_delegate onDeviceScaned:dic];
            
        }

        
      
    }
    return true;
}


- (NSString *)getIPAddress
{
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while (temp_addr != NULL) {
            if( temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    // Free memory
    freeifaddrs(interfaces);
    
    return address;
}

@end
