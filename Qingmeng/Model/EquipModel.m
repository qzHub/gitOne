//
//  EquipModel.m
//  SmartLink
//
//  Created by 一路走一路寻 on 17/2/13.
//  Copyright © 2017年 shengxiao. All rights reserved.
//

#import "EquipModel.h"

@implementation EquipModel

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
    
    
}


@end
