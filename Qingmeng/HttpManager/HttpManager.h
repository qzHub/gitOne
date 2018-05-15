//
//  HttpManager.h
//  中盾app
//
//  Created by 一路走一路寻 on 16/8/16.
//  Copyright © 2016年 Xcode. All rights reserved.
//

#import <Foundation/Foundation.h>

#define statusKey  @"status"
#define msgKey  @"msg"
#define dataKey  @"data"
#define codeKey @"code"

@interface HttpManager : NSObject


//主要负责数据的请求
/**
 *  回调的blcok
 *
 *  @param error 错误信息
 *  @param obj   请求到的数据
 */
typedef void (^returnBlock)(NSError *error,id obj);
/**
 *  发起get请求
 *
 *  @param url    url地址
 *  @param params 参数
 *  @param block  回调block
 */
+(void)getWithURL:(NSString *)url andParams:(NSDictionary *)params returnBlcok:(returnBlock)block;
/**
 *  发起post请求
 *
 *  @param url    url地址
 *  @param params 参数
 *  @param block  回调block
 */
+(void)postWithURL:(NSString *)url andParams:(NSDictionary *)params returnBlcok:(returnBlock)block;
//不带头部，请求为json
+ (void)postNotHeadWithURL:(NSString *)url andParams:(id)params returnBlcok:(returnBlock)block;


/**
 *  发起post请求
 *  上传多张图片
 *  @param url    url地址
 *  @param params 参数
 *  @param block  回调block
 */
+(void)postWithURL:(NSString *)url andParams:(NSDictionary *)params imageFiles:(NSArray *)files withFilesName:(NSString *)name returnBlcok:(returnBlock)block;




@end
