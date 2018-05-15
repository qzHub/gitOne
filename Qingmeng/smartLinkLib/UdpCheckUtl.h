//
//  UdpCheckUtl.h
//  SuperSmart
//
//  Created by mqw on 15/10/22.
//  Copyright © 2015年 gicisky. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AsyncUdpSocket.h"

#define DEVICE_HOST                       @"deviceIP"
#define DEVICE_MAC                   @"deviceMac"
@protocol DeviceUdpScanDelegate <NSObject>
-(void)onDeviceScaned:(NSDictionary *)deviceDic ;
@end



@interface UdpCheckUtl : NSObject
{

    
}

@property (nonatomic, assign) id <DeviceUdpScanDelegate> delegate;
@property (nonatomic, strong) AsyncUdpSocket *socket;

-(void)doScanDevice;


@end
