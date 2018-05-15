//
//  DeviceListViewController.m
//  Qingmeng
//
//  Created by Xcode on 2017/3/2.
//  Copyright © 2017年 Xcode. All rights reserved.
//

#import "DeviceListViewController.h"
#import "SmartLinkExportObject.h"

#import "UIColor+RGB.h"
#import "EquipModel.h"
#import "DeviceModel.h"


#import "HUDTools.h"
#import "Masonry.h"
#include <ifaddrs.h>
#include <arpa/inet.h>

#import "HttpManager.h"
#import "Address.h"

@interface DeviceListViewController ()<DeviceScanDelegate,UIAlertViewDelegate,UITextFieldDelegate,UIGestureRecognizerDelegate,UITableViewDelegate,UITableViewDataSource>
{
    
    SmartLinkExportObject * smartLinkUtl;
    
    dispatch_source_t _timer;
    
    BOOL isGetingCode;
}

@property (nonatomic, strong) NSString * Mymachine_MAC;

@property (nonatomic, strong) NSString * code;

@property (nonatomic, assign) NSInteger indexNum;

@property (nonatomic, assign) BOOL isOnline;
@property (nonatomic, assign) BOOL isbing;
@property (nonatomic, assign) BOOL canOperate;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableArray * platformIdArr;
@property (nonatomic, strong) NSMutableArray * deviceInfoArray;

@property (nonatomic, strong) DeviceModel * devicemodel;
@property (nonatomic, strong) EquipModel * platmformModel;

@property(nonatomic ,strong) UIView *bgView;

@property (nonatomic, strong) UITextField * platmIdTF;
@property (nonatomic, strong) UITextField * codeTF;

@property (nonatomic, strong) UIView * seleView;
@property (nonatomic, strong) UITableView * seleTab;

@property (nonatomic, copy) NSString * platformId;

@property (nonatomic, assign) NSIndexPath *indexPath;

@property (nonatomic, strong) UIButton * codeBtn;

@end

@implementation DeviceListViewController

- (NSMutableArray *)deviceInfoArray {
    
    if (!_deviceInfoArray) {
        _deviceInfoArray = [NSMutableArray new];
    }
    
    return _deviceInfoArray;
}

- (NSMutableArray *)platformIdArr {
    
    if (!_platformIdArr) {
        _platformIdArr = [NSMutableArray new];
    }
    
    return _platformIdArr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    smartLinkUtl = [[SmartLinkExportObject alloc] init];
    smartLinkUtl.delegate = self;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    
    
    
    CGRect bouds = self.view.frame;
    UIWebView* webView = [[UIWebView alloc]initWithFrame:bouds];
    webView.scalesPageToFit = YES;//自动对页面进行缩放以适应屏幕
    
    
    NSURL* url = [NSURL URLWithString:@"http://www.baidu.com"];//创建URL
    NSURLRequest* request = [NSURLRequest requestWithURL:url];//创建NSURLRequest
    [webView loadRequest:request];//加载
    
    webView.hidden = YES;
    [self.view addSubview:webView];
    
    _deviceArray = [[NSMutableArray alloc]initWithCapacity:0];
    [self.tableView reloadData];
    [self doScan];
    
    [self performSelector:@selector(delayMethod) withObject:nil afterDelay:3.0f];
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self.deviceInfoArray removeAllObjects];
    [self.tableView reloadData];
    [self StartScanDevice];

}

//返回
- (IBAction)goback:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)uploadMacinfo:(NSString *)macInfo{
    
}


- (IBAction)doDeviceScan:(id)sender {
    [self StartScanDevice];
    [self.deviceInfoArray removeAllObjects];

}

-(void)StartScanDevice{
    
    [HUDTools showHUDWithLabel:@"请稍后" onView:self.view];
    [HUDTools removeHUDWithDelay:2.0f];
    _deviceArray = [[NSMutableArray alloc]initWithCapacity:0];
//    [self.tableView reloadData];
    [self doScan];
    [self performSelector:@selector(delayMethod) withObject:nil afterDelay:3.0f];
    
}
-(void)doScan{
    [smartLinkUtl doDeviceScan];
    [self performSelector:@selector(doScan) withObject:nil afterDelay:1.0f];
    
}



-(void)delayMethod{
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(doScan) object:nil];//可以取消成功。
    [HUDTools removeHUD];
    
}

-(void)onDeviceScaned:(NSDictionary *)deviceDic {
    NSString* deviceMac = [deviceDic objectForKey:@"deviceMac"];
    
    if (![self isScaned:deviceMac]) {
        [_deviceArray addObject:deviceDic];
//        [self uploadMacinfo:deviceMac];
        [self getBindList:deviceDic];
//        [self.tableView reloadData];
    }
}

-(Boolean)isScaned:(NSString*)mac{
    Boolean result = false;
    for (NSDictionary*dic in _deviceArray) {
        if ([dic[@"deviceMac"] isEqualToString:mac]) {
            result = YES;
            break;
        }
    }
    return result;
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == self.tableView) {
        return [self.deviceInfoArray count];
//        > 0 ? [self.deviceInfoArray count] : _deviceArray.count;
    }else {
    
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.seleTab) {
//        DeviceModel * model = self.deviceInfoArray[section];
//        return [model.platform count];
        return self.platformIdArr.count;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableView) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AreaItem"];
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            UILabel * titleLabel = [UILabel new];
            titleLabel.tag = 20;
            titleLabel.font = [UIFont systemFontOfSize:15];
            titleLabel.textColor = [UIColor blackColor];
            [cell.contentView addSubview:titleLabel];
            [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                
                make.left.offset(15);
                make.top.offset(10);
                make.height.offset(20);
                make.width.offset(125);
            }];
            
            UILabel * onlineLabel = [UILabel new];
            onlineLabel.tag = 21;
            onlineLabel.font = [UIFont systemFontOfSize:10];
            onlineLabel.textColor = [UIColor whiteColor];
            onlineLabel.layer.cornerRadius = 5.0f;
            onlineLabel.layer.masksToBounds = YES;
            onlineLabel.textAlignment = 1;
            onlineLabel.backgroundColor = [UIColor hexStringToColor:@"3ee53e"];
            onlineLabel.text = @"在线";
            [cell.contentView addSubview:onlineLabel];
            [onlineLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                
                make.left.equalTo(titleLabel.mas_right).offset(-5);
                make.centerY.equalTo(titleLabel);
                make.width.offset(30);
                make.height.offset(15);
            }];
            
            UILabel * busyLabel = [UILabel new];
            busyLabel.tag = 22;
            busyLabel.font = [UIFont systemFontOfSize:10];
            busyLabel.textColor = [UIColor whiteColor];
            busyLabel.layer.cornerRadius = 5.0f;
            busyLabel.layer.masksToBounds = YES;
            busyLabel.textAlignment = 1;
            busyLabel.text = @"繁忙";
            [cell.contentView addSubview:busyLabel];
            busyLabel.backgroundColor = [UIColor orangeColor];
            [busyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                
                make.left.equalTo(onlineLabel.mas_right).offset(6);
                make.centerY.equalTo(titleLabel);
                make.width.offset(30);
                make.height.offset(15);
            }];
            
            UILabel * IPLabel = [UILabel new];
            IPLabel.tag = 23;
            IPLabel.font = [UIFont systemFontOfSize:13];
            IPLabel.textColor = [UIColor hexStringToColor:@"#666666"];
            [cell.contentView addSubview:IPLabel];
            [IPLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                
                make.left.offset(15);
                make.right.offset(-120);
                make.top.equalTo(titleLabel.mas_bottom).offset(5);
                make.height.offset(15);
            }];
            
            UILabel * MatLabel = [UILabel new];
            MatLabel.tag = 24;
            MatLabel.font = [UIFont systemFontOfSize:13];
            MatLabel.textColor = [UIColor hexStringToColor:@"#666666"];
            [cell.contentView addSubview:MatLabel];
            [MatLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                
                make.left.offset(15);
                make.right.offset(-120);
                make.top.equalTo(IPLabel.mas_bottom).offset(3);
                make.height.offset(15);
            }];
            
            UILabel * unBindingLabel = [UILabel new];
            unBindingLabel.tag = 40;
            unBindingLabel.font = [UIFont systemFontOfSize:13];
            unBindingLabel.textColor = [UIColor hexStringToColor:@"#E6C6C6"];
            unBindingLabel.text = @"设备未绑定";
            unBindingLabel.hidden = YES;
            [cell.contentView addSubview:unBindingLabel];
            [unBindingLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                
                make.left.offset(15);
                make.right.offset(-120);
                make.top.equalTo(MatLabel.mas_bottom).offset(10);
                make.height.offset(15);
            }];
            
            for (NSInteger i = 0; i < 3; i++) {
                UILabel * useridLabel = [UILabel new];
                useridLabel.font = [UIFont systemFontOfSize:10];
                useridLabel.textColor = [UIColor hexStringToColor:@"#9f9f9f"];
                useridLabel.backgroundColor = [UIColor hexStringToColor:@"f2f2f2"];
                useridLabel.textAlignment = 1;
                useridLabel.layer.cornerRadius = 7.5f;
                useridLabel.layer.masksToBounds = YES;
                useridLabel.tag = 25 + i;
                useridLabel.hidden = YES;
                [cell.contentView addSubview:useridLabel];
                
                [useridLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                    
                    make.left.offset(15);
                    make.top.equalTo(MatLabel.mas_bottom).offset(10 + 20 * i);
                    make.width.offset(100);
                    make.height.offset(15);
                }];
                
                UILabel * platmIDLabel = [UILabel new];
                platmIDLabel.font = [UIFont systemFontOfSize:13];
                platmIDLabel.textColor = [UIColor hexStringToColor:@"#666666"];
                platmIDLabel.tag = 28 + i;
                platmIDLabel.hidden = YES;
                [cell.contentView addSubview:platmIDLabel];
                
                [platmIDLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                    
                    make.left.equalTo(useridLabel.mas_right).offset(5);
                    make.top.equalTo(MatLabel.mas_bottom).offset(10 + 20 * i);
                    make.width.offset(100);
                    make.height.offset(15);
                }];
                
            }
            
            UIButton *Button = [UIButton buttonWithType:UIButtonTypeCustom];
            [Button setBackgroundColor:[UIColor whiteColor]];
            [Button setTitle:@"一键解绑" forState:UIControlStateNormal];
            [Button setTitleColor:[UIColor hexStringToColor:@"00c2ce"] forState:UIControlStateNormal];
            Button.layer.borderWidth = 0.5;
            Button.layer.borderColor = [UIColor hexStringToColor:@"f2f2f2"].CGColor;
            [Button addTarget:self action:@selector(cellLookButtonClick:) forControlEvents:UIControlEventTouchUpInside];
            Button.tag = indexPath.section + 100;
            
            [cell.contentView addSubview:Button];
            [Button mas_makeConstraints:^(MASConstraintMaker *make) {
                
                make.right.offset(0);
                make.top.offset(0);
                make.width.offset(110);
                make.centerY.offset(0);
            }];
        }
        
        UILabel *tiltelabel = [cell.contentView viewWithTag:20];
        UILabel *onlineLabel = [cell.contentView viewWithTag:21];
        UILabel *busyLabel = [cell.contentView viewWithTag:22];
        UILabel *IPlabel = [cell.contentView viewWithTag:23];
        UILabel *MatLabel = [cell.contentView viewWithTag:24];
        UILabel *unbindingLabel = [cell.contentView viewWithTag:40];
        UIButton * button = [cell.contentView viewWithTag:100 + indexPath.section];
        if(self.deviceInfoArray.count) {
            
            DeviceModel * Dmodel = self.deviceInfoArray[indexPath.section];
            //得到词典中所有KEY值
            //        NSString * macAdress = [[_deviceArray objectAtIndex:indexPath.section] objectForKey:@"deviceMac"];
            //        NSString * IP = [[_deviceArray objectAtIndex:indexPath.section] objectForKey:@"deviceIP"];
            
            NSString * macAdress = Dmodel.deviceMac;
            NSString * IP = Dmodel.macIP;
            
            NSMutableString *mString = [NSMutableString stringWithString:macAdress];
            NSString *str = [mString stringByReplacingOccurrencesOfString:@":" withString:@""];
            NSString* text = [NSString stringWithFormat:@"%@",str];
            tiltelabel.text =text;
            
            IPlabel.text = [NSString stringWithFormat:@"设备IP：%@",IP];
            NSRange range = [IPlabel.text rangeOfString:@"设备IP："];
            [self setTextColor:IPlabel FontNumber:[UIFont systemFontOfSize:13] AndRange:range AndColor:[UIColor hexStringToColor:@"#999999"]];
            
            MatLabel.text = [NSString stringWithFormat:@"剩余耗材：%@秒",Dmodel.supplies];
            NSRange matRange = [MatLabel.text rangeOfString:@"剩余耗材："];
            [self setTextColor:MatLabel FontNumber:[UIFont systemFontOfSize:13] AndRange:matRange AndColor:[UIColor hexStringToColor:@"#999999"]];
            
            if ([Dmodel.is_online intValue] == 1) {
                onlineLabel.text = @"在线";
                onlineLabel.backgroundColor = [UIColor hexStringToColor:@"3ee53e"];
                busyLabel.hidden = NO;
            }else {
                onlineLabel.text = @"离线";
                onlineLabel.backgroundColor = [UIColor hexStringToColor:@"9f9f9f"];
                busyLabel.hidden = YES;
            }
            
            if ([Dmodel.is_useing intValue] == 0) {
                busyLabel.text = @"空闲";
                busyLabel.backgroundColor = [UIColor hexStringToColor:@"00c2ce"];
            }else {
                busyLabel.text = @"繁忙";
                busyLabel.backgroundColor = [UIColor orangeColor];
            }
            
            if ([Dmodel.platform count] == 0) {
                unbindingLabel.hidden = NO;
                button.hidden = YES;
                button.enabled = NO;
            }else {
                unbindingLabel.hidden = YES;
                button.hidden = NO;
                button.enabled = YES;
            }
            
            for (NSInteger i = 0; i < Dmodel.platform.count; i++) {
                
                EquipModel * m = [EquipModel new];
                
                [m setValuesForKeysWithDictionary:Dmodel.platform[i]];
                
                UILabel * label = [cell.contentView viewWithTag:25+i];
                label.text = [NSString stringWithFormat:@"主播ID：%@",m.platform_userid];
                label.hidden = NO;
                UILabel * IDLabel = [cell.contentView viewWithTag:28+i];
                IDLabel.text = [NSString stringWithFormat:@"%@",m.pname];
                IDLabel.hidden = NO;
            }
            
        }
//            else {
//
//            //得到词典中所有KEY值
//            NSString * macAdress = [[_deviceArray objectAtIndex:indexPath.section] objectForKey:@"deviceMac"];
//            NSString * IP = [[_deviceArray objectAtIndex:indexPath.section] objectForKey:@"deviceIP"];
//            
//            NSMutableString *mString = [NSMutableString stringWithString:macAdress];
//            NSString *str = [mString stringByReplacingOccurrencesOfString:@":" withString:@""];
//            NSString* text = [NSString stringWithFormat:@"%@",str];
//            tiltelabel.text =text;
//            
//            IPlabel.text = [NSString stringWithFormat:@"设备IP：%@",IP];
//            NSRange range = [IPlabel.text rangeOfString:@"设备IP："];
//            [self setTextColor:IPlabel FontNumber:[UIFont systemFontOfSize:13] AndRange:range AndColor:[UIColor hexStringToColor:@"#999999"]];
//            
//            unbindingLabel.hidden = NO;
//            
//            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//            [button setBackgroundColor:[UIColor hexStringToColor:@"00c2ce"]];
//            
//            button.userInteractionEnabled = NO;
//        }
        
        return cell;
    }else if (tableView == self.seleTab) {
    
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"seleCell"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"seleCell"];
            
        }

        if (self.platformIdArr.count>0) {
        
            EquipModel * model = self.platformIdArr[indexPath.row];
            cell.textLabel.text = model.pname;
            cell.textLabel.textColor = [UIColor lightGrayColor];
            cell.textLabel.font = [UIFont systemFontOfSize:14.0f];
        }
        return cell;
    }else {
        return nil;
    }

}


#pragma mark -- 设置每行高度（每行高度可以不一样）
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (tableView == self.tableView) {
        if (self.deviceInfoArray.count > 0) {
            
            DeviceModel * Amodel = self.deviceInfoArray[indexPath.section];
            
            if ([Amodel.platform count] == 3) {
                return 150;
            }else if ([Amodel.platform count] == 2) {
                return 130;
            }else {
                return 110;
            }
        }else {
            return 110;
        }
    }else {
    
        return 30;
    }

}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (tableView == self.tableView) {
        if (section == 0) {
            return 0.00000001;
        }
        return  10;
    }else {
        return 0.5;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    return 0.00000001;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    if (tableView == self.seleTab) {
        
        self.seleView.hidden = YES;
        
        EquipModel * model = [EquipModel new];
        [model setValuesForKeysWithDictionary:self.devicemodel.platform[indexPath.row]];
        self.platmformModel = model;
        self.seleView.hidden = YES;
        self.platmIdTF.text = model.pname;
        self.platformId = model.platform_id;
        [self.platmIdTF resignFirstResponder];
        
    }
    
}

- (NSString *)getIPAddress
{
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while (temp_addr != NULL) {
            if( temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    // Free memory
    freeifaddrs(interfaces);
    
    return address;
}


#pragma mark -- segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"binding"]) //"goView2"是SEGUE连线的标识
    {
        id theSegue = segue.destinationViewController;
        [theSegue setValue:_deviceArray forKey:@"macArray"];
        
    }
    
}


#pragma mark -- action

// 解绑
- (void)cellLookButtonClick:(UIButton *)btn {
    
    DeviceModel * model = self.deviceInfoArray[btn.tag - 100];
    self.devicemodel = model;
    [self showCancelBindView:model];
    
}

//设置不同字体颜色
-(void)setTextColor:(UILabel *)label FontNumber:(id)font AndRange:(NSRange)range AndColor:(UIColor *)vaColor
{
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:label.text];
    //设置字号
    [str addAttribute:NSFontAttributeName value:font range:range];
    //设置文字颜色
    [str addAttribute:NSForegroundColorAttributeName value:vaColor range:range];
    
    label.attributedText = str;
}

#pragma mark -- 数据相关

- (void)getBindList:(NSDictionary *)macInfo {
    
    if (self.deviceInfoArray.count > 0) {
        
        for (DeviceModel * model in self.deviceInfoArray) {
            
            if ([model.deviceMac isEqualToString:macInfo[@"deviceMac"]]) {
                [self.tableView reloadData];
                return;
            }
            
        }
        
    }
    
    NSDictionary * params = @{@"machine_MAC":macInfo[@"deviceMac"]};
    [HttpManager postWithURL:URL_UPLOADEQPINFO_API andParams:params returnBlcok:^(NSError *error, id obj) {
        
        if (!error) {
//            [self.deviceInfoArray removeAllObjects];
            if ([obj[@"status"] integerValue] == 1) {
                
                if (![obj[@"data"] isKindOfClass:[NSNull class]]) {

                    NSDictionary * dic = obj[@"data"][@"macinfo"];
                    DeviceModel * model = [DeviceModel new];
                    
                    model.deviceMac = macInfo[@"deviceMac"];
                    model.macIP = macInfo[@"deviceIP"];
                    model.is_online = dic[@"is_online"];
                    model.is_useing = dic[@"is_useing"];
                    model.supplies = dic[@"supplies"];
                    model.platform = obj[@"data"][@"platform"];
                    [self.deviceInfoArray addObject:model];
                
                    [self.tableView reloadData];
                    
                }
                
            }else {
//                [self.tableView reloadData];
//                [HUDTools showText:obj[@"msg"] onView:self.view delay:1.0f];
                
            }
            
        }
    }];
    
}

#pragma mark -- 解除绑定

- (void)showCancelBindView:(DeviceModel *)model {
    

    self.bgView = [[UIView alloc]initWithFrame:self.view.bounds];
    self.bgView.backgroundColor = [[UIColor hexStringToColor:@"#000000"]colorWithAlphaComponent:0.5];
    self.bgView.userInteractionEnabled = YES;
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    window.userInteractionEnabled = YES;
    [window addSubview:self.bgView];
    self.bgView.userInteractionEnabled = YES;
    
    UITapGestureRecognizer * tap          = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(endEditTap)];
    tap.delegate = self;
    [self.bgView addGestureRecognizer:tap];

    
    UIView *centerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 250, 240)];
    centerView.center = self.bgView.center;
    centerView.backgroundColor = [UIColor hexStringToColor:@"#ffffff"];
    centerView.layer.masksToBounds = YES;
    centerView.layer.cornerRadius = 5;
    centerView.userInteractionEnabled = YES;
    [self.bgView addSubview:centerView];
    
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, centerView.frame.size.width, 55)];
    
    titleLabel.textAlignment = 1;
    
    titleLabel.textColor = [UIColor hexStringToColor:@"#666666"];
    
    titleLabel.text = [NSString stringWithFormat:@"解绑设备：%@",model.macIP];
    NSRange range = [titleLabel.text rangeOfString:@"解绑设备："];
    [self setTextColor:titleLabel FontNumber:[UIFont systemFontOfSize:15] AndRange:range AndColor:[UIColor hexStringToColor:@"#999999"]];
    
    titleLabel.tag = 999;
    
    titleLabel.font = [UIFont systemFontOfSize:15];
    
    [centerView addSubview:titleLabel];
    
    UITextField * platmIdTF = [[UITextField alloc] initWithFrame:CGRectMake(10, 55, centerView.frame.size.width - 20, 45)];
    platmIdTF.delegate = self;
    platmIdTF.font = [UIFont systemFontOfSize:13];
    platmIdTF.layer.borderColor = [UIColor hexStringToColor:@"dedede"].CGColor;
    platmIdTF.layer.borderWidth = 0.5f;
    platmIdTF.layer.cornerRadius = 5;
    platmIdTF.layer.masksToBounds = YES;
    platmIdTF.placeholder = @"请选择解绑平台";
    platmIdTF.leftView            = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 13, 0)];
    platmIdTF.leftViewMode        = UITextFieldViewModeAlways;
    [centerView addSubview:platmIdTF];
    self.platmIdTF = platmIdTF;
    
    UIImageView * imgView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(platmIdTF.frame) - 30, 15, 18, 15)];
    imgView.image = [UIImage imageNamed:@"Home_triangle"];
    [platmIdTF addSubview:imgView];
    
    UITextField * codeTF = [[UITextField alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(platmIdTF.frame) + 15, centerView.frame.size.width - 20, 45)];
    codeTF.delegate = self;
    codeTF.font = [UIFont systemFontOfSize:13];
    codeTF.layer.borderColor = [UIColor hexStringToColor:@"dedede"].CGColor;
    codeTF.layer.cornerRadius = 5;
    codeTF.layer.masksToBounds = YES;
    codeTF.layer.borderWidth = 0.5f;
    codeTF.keyboardType = UIKeyboardTypeNumberPad;
    codeTF.placeholder = @"请输入验证码";
    codeTF.leftView            = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 13, 0)];
    codeTF.leftViewMode        = UITextFieldViewModeAlways;
    [centerView addSubview:codeTF];
    self.codeTF = codeTF;
    
    UIButton * codeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    codeBtn.frame = CGRectMake(centerView.frame.size.width - 110, CGRectGetMaxY(platmIdTF.frame) + 15, 100, 45);
    codeBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [codeBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
    [codeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    codeBtn.layer.cornerRadius = 5;
    codeBtn.layer.masksToBounds = YES;
    [codeBtn addTarget:self action:@selector(getCodeClick) forControlEvents:UIControlEventTouchUpInside];
    [codeBtn setBackgroundColor:[UIColor hexStringToColor:@"00c2ce"]];
    [centerView addSubview:codeBtn];
    self.codeBtn = codeBtn;
    
    NSArray *titleArr = @[@"取消",@"确定"];
    NSArray *colorArr = @[[UIColor hexStringToColor:@"#999999"],[UIColor hexStringToColor:@"#666666"]];
    CGFloat w = centerView.frame.size.width/2.0;
    
    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetHeight(centerView.frame) - 50, centerView.frame.size.width, 0.5)];
    lineView.backgroundColor = [UIColor hexStringToColor:@"#dedede"];
    
    [centerView addSubview:lineView];
    
    UIView *lineView1 = [[UIView alloc]initWithFrame:CGRectMake(w, CGRectGetHeight(centerView.frame) - 50, 0.5, 50)];
    lineView1.backgroundColor = [UIColor hexStringToColor:@"#dedede"];
    
    [centerView addSubview:lineView1];
    
    for (int i = 0 ; i < 2 ; i++) {
        
        UILabel *tapLabel = [[UILabel alloc]initWithFrame:CGRectMake(w * i, CGRectGetHeight(centerView.frame) - 50, w, 50)];
        
        tapLabel.text = titleArr[i];
        
        tapLabel.textAlignment = 1;
        
        tapLabel.textColor = colorArr[i];
        
        tapLabel.font = [UIFont systemFontOfSize:15];
        
        tapLabel.userInteractionEnabled = YES;
        
        tapLabel.tag = 10000 + i;
        
        [centerView addSubview:tapLabel];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickTapLabel:)];
        
        [tapLabel addGestureRecognizer:tap];
        
    }
    
    self.seleView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(platmIdTF.frame), CGRectGetMaxY(platmIdTF.frame),CGRectGetWidth(platmIdTF.frame), 90)];
    self.seleView.backgroundColor = [UIColor whiteColor];
    [centerView addSubview:self.seleView];
    
    self.seleTab = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.seleView.frame.size.width, 90)];
    self.seleTab.delegate = self;
    self.seleTab.dataSource = self;
//    self.seleTab.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.seleTab.layer.borderColor = [UIColor hexStringToColor:@"dedede"].CGColor;
    self.seleTab.layer.borderWidth = 0.5;
    [self.seleView addSubview:self.seleTab];
    
    self.seleView.hidden = YES;
    
    [self.platformIdArr removeAllObjects];
    for (NSDictionary * dic in model.platform) {
        
        EquipModel * emodel = [EquipModel new];
        [emodel setValuesForKeysWithDictionary:dic];
        [self.platformIdArr addObject:emodel];
    }
    [self.seleTab reloadData];
}


-(void)clickTapLabel:(UITapGestureRecognizer *)tap{
    
    if (isGetingCode) {
        dispatch_source_cancel(_timer);
    }
    
    if (tap.view.tag -10000 == 0) {
        
        [self.bgView removeFromSuperview];
        
    }else{
        
        [self removeBind];
        
    }
}

#pragma mark -- textFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    
    if (textField == self.platmIdTF) {
        
        [self.platmIdTF resignFirstResponder];
        self.seleView.hidden = NO;
    }
    
    
}

#pragma mark -- didEdit

- (void)endEditTap {
    
    [self.bgView endEditing:YES];
    self.seleView.hidden = YES;
}

#pragma mark tapGestureRecgnizerdelegate 解决手势冲突
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isKindOfClass:[UITableView class]]){
        return NO;
    }
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]) {
        return NO;
    }
    return YES;
}

- (void)getCodeClick {
    
    if (!self.platformId) {
        
        return [HUDTools showText:@"请选择解绑平台!" onView:self.bgView delay:1.0f];
        
    }
    
    NSDictionary *params = @{@"platform_userid":self.platmformModel.platform_userid,@"platform_id":self.platmformModel.platform_id,@"machine_MAC":self.devicemodel.deviceMac,@"is_binding":@"0"};
    
    [HttpManager getWithURL:URL_GETCODE_API andParams:params returnBlcok:^(NSError *error, id obj) {
        if (!error) {
            if ([obj[statusKey] integerValue] == 1) {
                
                [self startTime];
                
                [HUDTools showText:obj[@"msg"] onView:self.bgView delay:1.0f];
//                self.code = obj[dataKey][@"machine_code"];

                
            }else {
                [HUDTools showText:obj[@"msg"] onView:self.bgView delay:1.0f];
            }
            
        }
    }];

    
}

- (void)removeBind {
    
    if (!self.platformId) {
        
        return [HUDTools showText:@"请选择解绑平台!" onView:self.bgView delay:1.0f];
        
    }
    
    if (!self.codeTF.text) {
        
        return [HUDTools showText:@"请输入验证码!" onView:self.bgView delay:1.0f];
        
    }
    
    NSDictionary *params = @{@"platform_userid":self.platmformModel.platform_userid,@"platform_id":self.platmformModel.platform_id,@"source":@"Ios",@"machine_MAC":self.devicemodel.deviceMac,@"vcode":self.codeTF.text,@"is_binding":@"0"};
    [HttpManager postWithURL:URL_CANCELBOUND_API andParams:params returnBlcok:^(NSError *error, id obj) {
        if (!error) {
            if ([obj[statusKey] integerValue] == 1) {
                
//                [self StartScanDevice];
                [self updateMacInfo];
                
                [self.bgView removeFromSuperview];
                
            }else{
                
                [HUDTools showText:obj[@"msg"] onView:self.bgView delay:1.0f];
            }
        }
    }];
}

// 更新设备信息
- (void)updateMacInfo {

    NSDictionary * params = @{@"machine_MAC":self.devicemodel.deviceMac};
    [HttpManager postWithURL:URL_UPLOADEQPINFO_API andParams:params returnBlcok:^(NSError *error, id obj) {
        
        if (!error) {
            if ([obj[@"status"] integerValue] == 1) {
                
                if (![obj[@"data"] isKindOfClass:[NSNull class]]) {
                    
                    NSDictionary * dic = obj[@"data"][@"macinfo"];
                    DeviceModel * model = [DeviceModel new];
                    NSInteger index;
                    for (NSInteger i = 0; i < self.deviceInfoArray.count; i++) {
                        DeviceModel * m = self.deviceInfoArray[i];
                        if ([self.devicemodel.deviceMac isEqualToString:m.deviceMac]) {
                            model = m;
                            index = i;
                        }
                    }

                    model.is_online = dic[@"is_online"];
                    model.is_useing = dic[@"is_useing"];
                    model.supplies = dic[@"supplies"];
                    model.platform = obj[@"data"][@"platform"];
                    [self.deviceInfoArray replaceObjectAtIndex:index withObject:model];
                    [self.tableView reloadData];
                    
                }
                
            }else {
                
            }
            
        }
    }];


}

#pragma 倒计时
-(void)startTime{
    
    isGetingCode = YES;
    
    __block int timeout= 60; //倒计时时间
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(_timer, ^{
        if(timeout<=0){ //倒计时结束，关闭
            dispatch_source_cancel(_timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.codeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                
                //设置界面的按钮显示 根据自己需求设置
                [self.codeBtn setTitle:@"重新发送" forState:UIControlStateNormal];
                self.codeBtn.userInteractionEnabled = YES;
                [self.codeBtn setEnabled:YES];
                
                
            });
        }else{
            //            int minutes = timeout / 60;
            int seconds = timeout % 120;
            NSString *strTime = [NSString stringWithFormat:@"%.2d", seconds];
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
                //NSLog(@"____%@",strTime);
                
                
                //                [self.codeBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
                [self.codeBtn setTitle:[NSString stringWithFormat:@"重新发送(%@)",strTime] forState:UIControlStateNormal];
                self.codeBtn.userInteractionEnabled = NO;
                [self.codeBtn setEnabled:NO];
                
                
            });
            timeout--;
        }
        
    });
    dispatch_resume(_timer);
    
}



@end
