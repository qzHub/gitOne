//
//  HttpManager.m
//  中盾app
//
//  Created by 一路走一路寻 on 16/8/16.
//  Copyright © 2016年 Xcode. All rights reserved.
//

#import "HttpManager.h"
#import "AFNetworking.h"
NSString const  * stateKey = @"status";
NSString const * messageKey = @"msg";
NSString const * listKey = @"data";

@implementation HttpManager

+(void)getWithURL:(NSString *)url andParams:(NSDictionary *)params returnBlcok:(returnBlock)block{
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    //    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];

    [manager GET:url parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
        
    }
         success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
             
             NSLog(@"这里打印请求成功要做的事");
             NSLog(@"Success: 参数是 %@,接口url是 %@ 请求成功,结果是 %@",params,url,responseObject);
             //成功
             block(nil,responseObject);
         }
     
         failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull   error) {
             
             //这里打印错误信息
             NSLog(@" NET_failure:参数是 %@,接口url是 %@, 网络错误 %@",params,url,error.userInfo);
             //失败
                          block(error,nil);
         }];

}

+(void)postWithURL:(NSString *)url andParams:(id)params returnBlcok:(returnBlock)block{
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];

    [manager POST:url parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {


    } progress:^(NSProgress * _Nonnull uploadProgress) {

        NSLog(@"url = %@",manager.baseURL);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {

        NSLog(@"Success: 参数是 %@,接口url是 %@ 请求成功,结果是 %@",params,url,responseObject);
        //成功
        block(nil,responseObject);

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {

        NSLog(@" NET_failure:参数是 %@,接口url是 %@, 网络错误 %@",params,url,error.userInfo);
        //失败
        block(error,nil);
    }];

}

+ (void)postNotHeadWithURL:(NSString *)url andParams:(id)params returnBlcok:(returnBlock)block {

    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];

    [manager POST:url parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {

        NSLog(@"url = %@",manager.baseURL);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {

        NSLog(@"Success: 参数是 %@,接口url是 %@ 请求成功,结果是 %@",params,url,responseObject);
        //成功
        block(nil,responseObject);

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {

        NSLog(@" NET_failure:参数是 %@,接口url是 %@, 网络错误 %@",params,url,error.userInfo);
        //失败
        block(error,nil);
    }];
}

+(void)postWithURL:(NSString *)url andParams:(NSDictionary *)params imageFiles:(NSArray *)files withFilesName:(NSString *)name returnBlcok:(returnBlock)block {
    
    //1。创建管理者对象
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    //2.上传文件

    [manager POST:url parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        //上传文件参数
        
        for (NSInteger i=0;i<files.count;i++) {

            NSData *data = files[i];
            NSString *Name = [NSString stringWithFormat:@"%@[%zd]",name,i];
            NSString *fileName = [NSString stringWithFormat:@"%@.jpg",Name];
            [formData appendPartWithFileData:data name:Name fileName:fileName mimeType:@"image/png"];
        }

    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
        //打印下上传进度
        NSLog(@"%lf",1.0 *uploadProgress.completedUnitCount / uploadProgress.totalUnitCount);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        //请求成功
        NSLog(@"Success: 参数是 %@,接口url是 %@ 请求成功,结果是 %@",params,url,responseObject);
        //成功
        block(nil,responseObject);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        //请求失败
        NSLog(@" NET_failure:参数是 %@,接口url是 %@, 网络错误 %@",params,url,error.userInfo);
        //失败
        //        block(error,nil);
    }];
    
}


@end
