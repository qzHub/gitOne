//
//  PlatformModel.m
//  SmartLink
//
//  Created by Xcode on 2017/2/17.
//  Copyright © 2017年 shengxiao. All rights reserved.
//

#import "PlatformModel.h"

@implementation PlatformModel

- (void)setValue:(id)value forKey:(NSString *)key {
    
    if([value isKindOfClass:[NSNull class]]) {
        
        [self setValue:@"" forKey:key];
    }else if ([value isKindOfClass:[NSNumber class]]) {
        
        [self setValue:[NSString stringWithFormat:@"%@",value] forKey:key];
    }else {
        
        [super setValue:value forKey:key];
    }
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    
    if([key isEqualToString:@"id"]) {
        
        [self setValue:value forKey:@"myId"];
    }
    
}

@end
