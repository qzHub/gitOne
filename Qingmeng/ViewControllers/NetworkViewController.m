//
//  ViewController.m
//  gicisky
//
//  Created by gicisky on 16/3/1.
//  Copyright © 2016年 gicisky. All rights reserved.
//

#import "NetworkViewController.h"
#import "HUDTools.h"
#import "DeviceListViewController.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import <SystemConfiguration/CaptiveNetwork.h>

#import "UdpCheckUtl.h"

#import "SIAlertView.h"
#import "Masonry.h"
#import "UIColor+RGB.h"

#define kImg_Height 127
#define kImg_Width 171

@interface NetworkViewController ()<UITextFieldDelegate,DeviceUdpScanDelegate>
{
    NSString            *_ssidStr;
    NSString            *_pswStr;
    
    
    UdpCheckUtl* scalDeviceUtl;
    
    Boolean isScaning;
    int  configurationTime;
    SIAlertView * myAlertView;
    SmartLinkExportObject * smartLinkUtl;
    NSMutableArray *deviceArray;//接收所有可控制设备的信息
}

@property (weak, nonatomic) IBOutlet UIButton    *connectionBtn;
@property (weak, nonatomic) IBOutlet UITextField *pswTextField;
@property (weak, nonatomic) IBOutlet UILabel *ssidLabel;

@property (nonatomic, strong) UIView * backgroundView;

@end

@implementation NetworkViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self setupViews];
    
    scalDeviceUtl = [[UdpCheckUtl alloc]init];
    scalDeviceUtl.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(getSSID)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
}

// 返回
- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self getSSID];
}
/**
 *  获取SSID信息
 *
 *  @return id
 */
-(id)fetchSSIDInfo {
    NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
    id info = nil;
    for (NSString *ifnam in ifs) {
        info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        
        if (info && [info count]) {
            break;
        }
    }
    return info;
}


#pragma mark - UI
- (void)setupViews {
//    self.title = @"配置联网";
    
    self.pswTextField.leftView            = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 13, 0)];
    //设置显示模式为永远显示(默认不显示)
    self.pswTextField.leftViewMode        = UITextFieldViewModeAlways;
    
    self.pswTextField.delegate            = self;
    
    UITapGestureRecognizer * tap          = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(endEditTap)];
    [self.view addGestureRecognizer:tap];
}

#pragma mark -- didEdit

- (void)endEditTap {
    
    [self.view endEditing:YES];
}

#pragma mark - Datas
- (void)getSSID {
    _ssidStr = [self fetchSSIDInfo][@"SSID"];
    
    if (_ssidStr == nil || [_ssidStr isEqualToString:@""]) {
        _pswTextField.hidden       = YES;
        _connectionBtn.hidden = YES;
        _ssidLabel.text       = @"请开启手机WiFi后重试";
    }else {
        _pswTextField.hidden       = NO;
        _connectionBtn.hidden = NO;
        _ssidLabel.text       = _ssidStr ? :@"";
    }
}

#pragma mark - Event Response
- (IBAction)connectAction:(id)sender {
    
    NSLog(@"开始配置");
    _pswStr = _pswTextField.text;
    if (_pswStr == nil || _pswStr.length == 0) {
        [HUDTools showText:@"请输入WiFi密码"
                    onView:self.view
                     delay:2
                completion:^{
                    
                }];
        return;
    }
    
    [_pswTextField resignFirstResponder];
    
    
    
    deviceArray = [[NSMutableArray alloc]initWithCapacity:0];
    __block NetworkViewController *mself = self;
    configurationTime = 40;
    NSString *title = [NSString stringWithFormat:@"%@",@"一键联网"];;
    NSString *str = [NSString stringWithFormat:@"配置中，预计用时%d秒",(int)configurationTime];
    NSString*message = [NSString stringWithFormat:@"%@\r\n%@%d个",str,
                        @"已配置设备:",0];
    
    myAlertView = [[SIAlertView alloc] initWithTitle:title andMessage:message];
    
    
    [myAlertView addButtonWithTitle:@"取消配置"
                               type:SIAlertViewButtonTypeCancel
                            handler:^(SIAlertView *alertView) {
                                [mself  stopConfig];
                            }];
    myAlertView.willShowHandler = ^(SIAlertView *alertView) {
        NSLog(@"%@, willShowHandler", alertView);
    };
    myAlertView.didShowHandler = ^(SIAlertView *alertView) {
        NSLog(@"%@, didShowHandler", alertView);
    };
    myAlertView.willDismissHandler = ^(SIAlertView *alertView) {
    };
    myAlertView.didDismissHandler = ^(SIAlertView *alertView) {
        NSLog(@"%@, didDismissHandler", alertView);
        
        
    };
    myAlertView.showIndicator = YES;
    [myAlertView show];
    
    
    
    smartLinkUtl = [[SmartLinkExportObject alloc] init];
    smartLinkUtl.delegate = self;
    [smartLinkUtl connectWithSSID: _ssidStr password:_pswStr];
    //40秒后终止
    isScaning = YES;
    [self performSelector:@selector(stopConfig) withObject:nil afterDelay:40.0f];
    [self doScanDevice];
    [self  updateTitleGap];
    
}
-(void)doScanDevice{
    if (isScaning) {
        //5秒后终止配置，进行搜索
//        [smartLinkUtl doDeviceScan];
        [scalDeviceUtl doScanDevice];
        [self performSelector:@selector(doScanDevice) withObject:nil afterDelay:1.0f];
    }
    
    
}


-(void)stopConfig{
    if (![myAlertView isHidden]) {
        [myAlertView dismissAnimated:YES];
    }
    isScaning = NO;
    [smartLinkUtl closeConnection];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(doScanDevice) object:nil];//可以取消成功。
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateTitleGap) object:nil];//可以取消成功。
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(stopConfig) object:nil];//可以取消成功。
    
    if (deviceArray.count == 0) {
        [self initNetworkfailerView];
    }else {
        UIStoryboard *mainStoryboard =[UIStoryboard storyboardWithName:@"Main" bundle:nil];
        
        DeviceListViewController *vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"DeviceListViewController"];
        
        [self.navigationController pushViewController:vc animated:YES];
    }
    
}
-(void)updateTitleGap{
    if (isScaning) {
        NSString *title = [NSString stringWithFormat:@"%@",@"一键联网"];
        myAlertView.title =title;
        NSString *str = [NSString stringWithFormat:@"配置中，预计用时%d秒",(int)configurationTime];
        NSString*message = [NSString stringWithFormat:@"%@\r\n%@%d个",str,@"已配置设备:",(int)deviceArray.count];
        myAlertView.message = message;
        configurationTime--;
        [self performSelector:@selector(updateTitleGap) withObject:nil afterDelay:1.0f];
    }
    
}
-(void)onDeviceScaned:(NSDictionary *)deviceDic {
    NSString* deviceMac = [deviceDic objectForKey:@"deviceMac"];
    if (![self isScaned:deviceMac]) {
        [deviceArray addObject:deviceDic];
    }
    
//    int deviceCount = (int)deviceArray.count;
//    
//    NSString *str = [NSString stringWithFormat:@"配置中，预计用时%d秒",(int)configurationTime];
//    NSString*message = [NSString stringWithFormat:@"%@\r\n%@%d个",str,@"已配置设备:",deviceCount];
//    myAlertView.message = message;
}

-(Boolean)isScaned:(NSString*)mac{
    Boolean result = false;
    for (NSDictionary*dic in deviceArray) {
        if ([dic[@"deviceMac"] isEqualToString:mac]) {
            result = YES;
            break;
        }
    }
    return result;
}

// 配网失败view
- (void)initNetworkfailerView {

    self.backgroundView = [[UIView alloc] init];
    self.backgroundView.backgroundColor = [UIColor hexStringToColor:@"#f2f2f2"];
    [self.view addSubview:self.backgroundView];
    [self.view bringSubviewToFront:self.backgroundView];
    
    [self.backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.offset(0);
        make.top.offset(0);
        make.right.offset(0);
        make.bottom.offset(0);
        
    }];
    
    UIImageView *imageView = [UIImageView new];
    imageView.image = [UIImage imageNamed:@"Home_WIFi_No"];
    [self.backgroundView addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.offset(136);
        make.centerX.offset(0);
        make.width.offset(108);
        make.height.offset(85);
        
    }];
    
    UILabel *label = [[UILabel alloc] init];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:18];
    label.textColor = [UIColor hexStringToColor:@"#dbdbdb"];
    label.text = @"配网失败";
    [self.backgroundView addSubview:label];
    
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(imageView.mas_bottom).offset(10);
        make.centerX.offset(0);
        make.width.offset(200);
        make.height.offset(20);
        
    }];
    
    UILabel *label1 = [[UILabel alloc] init];
    label1.textAlignment = NSTextAlignmentLeft;
    label1.font = [UIFont systemFontOfSize:15];
    label1.textColor = [UIColor hexStringToColor:@"#333333"];
    label1.text = @"温馨提示";
    [self.backgroundView addSubview:label1];
    
    [label1 mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(label.mas_bottom).offset(60);
        make.left.offset(50);
        make.width.offset(200);
        make.height.offset(20);
        
    }];
    
    
    UILabel *label2 = [[UILabel alloc] init];
    label2.textAlignment = NSTextAlignmentLeft;
    label2.font = [UIFont systemFontOfSize:13];
    label2.numberOfLines = 0;
    label2.textColor = [UIColor hexStringToColor:@"#666666"];
    label2.text = @"请确保设备与手机在同一WI-FI环境内\n请确保设备正确安装开启\n请确保WI-FI密码正确";
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:6];//调整行间距
    [paragraphStyle setLineBreakMode:NSLineBreakByTruncatingTail];
    NSString * contentStr = @"请确保设备与手机在同一WI-FI环境内\n请确保设备正确安装开启\n请确保WI-FI密码正确";
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:contentStr];
    [str addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [contentStr length])];
    label2.attributedText = str;
    
    [self.backgroundView addSubview:label2];
    
    [label2 mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(label1.mas_bottom).offset(20);
        make.left.offset(50);
        make.centerX.offset(0);
        make.height.offset(60);
        
    }];
    
    UIButton * tryBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    tryBtn.layer.cornerRadius = 22.5f;
    tryBtn.layer.masksToBounds = YES;
    [tryBtn setTitle:@"重试" forState:UIControlStateNormal];
    [tryBtn setTintColor:[UIColor whiteColor]];
    [tryBtn setBackgroundColor:[UIColor hexStringToColor:@"#00c2ce"]];
    [tryBtn addTarget:self action:@selector(tryClick) forControlEvents:UIControlEventTouchUpInside];
    [self.backgroundView addSubview:tryBtn];
    
    [tryBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(label2.mas_bottom).offset(70);
        make.centerX.offset(0);
        make.width.offset(180);
        make.height.offset(45);
        
    }];
    
}

- (void)tryClick {
    
    [UIView animateWithDuration:1.0f animations:^{
        
        
        
    } completion:^(BOOL finished) {
        [self.backgroundView removeFromSuperview];
    }];
    
}

@end
