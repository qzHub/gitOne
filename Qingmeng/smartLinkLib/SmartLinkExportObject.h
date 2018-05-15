//
//  SmartLinkExportObject.h
//  SmartLink
//
//  Created by Gicisky on 16/3/2.
//  Copyright © 2016年 GICISKY. All rights reserved.
//

#import <Foundation/Foundation.h>






typedef void (^SmartLinkSuccess) (void);
typedef void (^SmartLinkFailure) (void);


@protocol DeviceScanDelegate <NSObject>
//-(void)onDeviceScaned:(NSDictionary *)deviceDic ;



@end


@interface SmartLinkExportObject : NSObject

@property(nonatomic,copy)
SmartLinkSuccess connectionSuccess;
@property(nonatomic,copy) SmartLinkFailure connectionFailure;

/**
 *  SmartLink 配置
 *
 *  @param ssidName ssid
 *  @param password  psw
 */
- (void)connectWithSSID:(NSString *)ssidName password:(NSString *)password;
- (void)closeConnection;
-(void)doDeviceScan;

@property (nonatomic, assign) id <DeviceScanDelegate> delegate;
@end
