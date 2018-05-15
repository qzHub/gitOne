//
//  UIColor+RGB.h
//  MeasureApp
//
//  Created by 极联开发 on 16/8/23.
//  Copyright © 2016年 Xcode. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (RGB)

+(UIColor *) hexStringToColor: (NSString *) stringToConvert;

+(UIImage*) createImageWithColor:(UIColor*) color;

@end
