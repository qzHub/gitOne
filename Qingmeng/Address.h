//
//  Address.h
//  SmartLink
//
//  Created by Xcode on 2017/2/10.
//  Copyright © 2017年 shengxiao. All rights reserved.
//

#ifndef Address_h
#define Address_h


//获取屏幕宽高
#define KMainScreenWidth [UIScreen mainScreen].bounds.size.width

#define KMainScreenHeight [UIScreen mainScreen].bounds.size.height

//主服务器
#define HOST @"http://op.qmeng.me/index.php?m=Api&c=User&a="

// 测试服务器
//#define HOST @"http://123.56.124.20/qingmeng-PHP/index.php?m=Api&c=User&a="

//#define NEWHOST @"http://192.168.1.129"
#define NEWHOST @"http://120.25.103.13:8080"

#define GET_URL(a) [NSString stringWithFormat:@"%@%@",HOST,(a)]
#define POST_URL(a) [NSString stringWithFormat:@"%@%@",HOST,(a)]


// 绑定mac和解除绑定
#define URL_CANCELBOUND_API GET_URL(@"binding")

// 测试设备
#define URL_TEST_API GET_URL(@"handle")

// 设置语音关键字
#define URL_SETVIOCE_API GET_URL(@"setkeyword")

// 语音操作设备
#define URL_VIOCE_API GET_URL(@"keyword")

// 操作设备
#define URL_HANDLE_API GET_URL(@"handle")

// 获取操作菜单列表
#define URL_PLAYMEUN_API  GET_URL(@"playmeun")

// 获取设备信息
#define URL_GETDEVICEINFO_API GET_URL(@"getmymac")

//  设备历史信息
#define URL_GETMACHISTORY_API GET_URL(@"gethistory")

// 查询主播绑定设备信息
#define URL_GETMACSTATUS_API  GET_URL(@"getmacstatus")

// 设备升级检测
#define URL_UPLOADEQUIP_API  GET_URL(@"checkupgrade")

// 绑定列表
#define URL_BINDINGLIST_API  GET_URL(@"getmacstatus")

// 上传设备信息
#define URL_UPLOADEQPINFO_API  GET_URL(@"getmymac")

// 获取验证码
#define URL_GETCODE_API  GET_URL(@"getVcode")

// 获取平台ID列表
#define URL_PLATFORM_API  GET_URL(@"getallplatform")

#endif /* Address_h */
