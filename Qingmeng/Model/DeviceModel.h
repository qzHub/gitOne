//
//  deviceModel.h
//  Qingmeng
//
//  Created by Xcode on 2017/3/6.
//  Copyright © 2017年 Xcode. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EquipModel;


@interface DeviceModel : NSObject

@property (nonatomic, copy) NSString * deviceMac;
@property (nonatomic, copy) NSString * macIP;

@property (nonatomic, strong) NSString * is_online;
@property (nonatomic, strong) NSString * is_useing;
@property (nonatomic, strong) NSString * supplies;

@property (nonatomic, strong) NSArray <EquipModel *> *platform;

@end
