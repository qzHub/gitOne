//
//  AppDelegate.h
//  Qingmeng
//
//  Created by Xcode on 2017/3/2.
//  Copyright © 2017年 Xcode. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

