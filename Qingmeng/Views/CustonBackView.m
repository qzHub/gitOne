//
//  CustonBackView.m
//  WEvideo
//
//  Created by 极联开发 on 16/12/1.
//  Copyright © 2016年 ZW. All rights reserved.
//

#import "CustonBackView.h"
#import "UIColor+RGB.h"

//获取屏幕宽高
#define kMainScreenWidth [UIScreen mainScreen].bounds.size.width

#define kMainScreenHeight [UIScreen mainScreen].bounds.size.height

#define kImg_Height 166/2.0
#define kImg_Width 166/2.0

@implementation CustonBackView

- (instancetype)initWithFrame:(CGRect)frame withBackImageName:(NSString *)imageName title:(NSString *)title msg:(NSString *)msg {
    
    self = [super initWithFrame:frame];
    if(self) {
        
        self.backgroundColor = [UIColor hexStringToColor:@"f2f2f2"];
        UIImageView *imageView = [[UIImageView alloc] init];
        UIImage *image = [UIImage imageNamed:imageName];
        imageView.image = image;
        imageView.frame = CGRectMake(kMainScreenWidth/2.0 - image.size.width/2.0, 200, image.size.width, image.size.height);

        [self addSubview:imageView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(imageView.frame) + 10, kMainScreenWidth - 20, 20)];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:18];
        label.textColor = [UIColor hexStringToColor:@"dbdbdb"];
        label.text = title;
        
        if ([title isEqualToString:@"绑定成功"]) {
            label.textColor = [UIColor hexStringToColor:@"#41d37b"];
        }
        
        [self addSubview:label];
        
        
        UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(10, kMainScreenHeight - 100, kMainScreenWidth - 20, 20)];
        label1.textAlignment = NSTextAlignmentCenter;
        label1.font = [UIFont systemFontOfSize:13];
        label1.textColor = [UIColor hexStringToColor:@"c2c2c2"];
        label1.text = msg;
        [self addSubview:label1];
    }
    
    return self;
}

@end
