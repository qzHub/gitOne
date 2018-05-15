//
//  ViewController.h
//  SmartLink
//
//  Created by gicisky on 16/3/2.
//  Copyright © 2016年 gicisky. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SmartLinkExportObject.h"


typedef void (^MyBlock) (id result, NSError *err);


@interface NetworkViewController : UIViewController<DeviceScanDelegate>


@end

