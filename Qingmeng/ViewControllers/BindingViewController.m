//
//  BindingViewController.m
//  Qingmeng
//
//  Created by Xcode on 2017/3/3.
//  Copyright © 2017年 Xcode. All rights reserved.
//

#import "BindingViewController.h"
#import "CustonBackView.h"

#import "HttpManager.h"
#import "Address.h"
#import "HUDTools.h"

#import "PlatformModel.h"

#define KMainScreenWidth [UIScreen mainScreen].bounds.size.width

#define KMainScreenHeight [UIScreen mainScreen].bounds.size.height

@interface BindingViewController () <UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *devicemacTextField;
@property (weak, nonatomic) IBOutlet UITextField *platmId;
@property (weak, nonatomic) IBOutlet UITextField *platmuserid;
@property (weak, nonatomic) IBOutlet UITextField *codeTF;
@property (weak, nonatomic) IBOutlet UIButton *codeBtn;
@property (weak, nonatomic) IBOutlet UIButton *bindingBtn;

@property (nonatomic, copy) NSString * code;
@property (nonatomic, copy) NSString * platformId;


// platformList
@property (nonatomic, copy) NSMutableArray * platformListArr;

@property (nonatomic, strong) UIView * seleView1;
@property (nonatomic, strong) UITableView * seleTab1;

@property (nonatomic, strong) UIView * seleView2;
@property (nonatomic, strong) UITableView * seleTab2;
@property (nonatomic, copy) NSString * macString;

// 绑定提示页
@property (nonatomic, strong) CustonBackView * backView;

@end

@implementation BindingViewController

- (NSArray *)macArray {

    if (!_macArray) {
        _macArray = [NSArray new];
    }
    
    return _macArray;
}

- (NSMutableArray *)platformListArr {
    
    if (!_platformListArr) {
        _platformListArr = [NSMutableArray new];
    }
    
    return _platformListArr;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self setupViews];
    
    [self getPlatformList];
    NSLog(@"self.macArray == %@",self.macArray);
}

#pragma mark - UI
- (void)setupViews {
    
    self.devicemacTextField.leftView            = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 13, 0)];
    //设置显示模式为永远显示(默认不显示)
    self.devicemacTextField.leftViewMode        = UITextFieldViewModeAlways;
    
    self.platmId.leftView            = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 13, 0)];
    //设置显示模式为永远显示(默认不显示)
    self.platmId.leftViewMode        = UITextFieldViewModeAlways;
    
    self.platmuserid.leftView            = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 13, 0)];
    //设置显示模式为永远显示(默认不显示)
    self.platmuserid.leftViewMode        = UITextFieldViewModeAlways;
    
    self.codeTF.leftView            = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 13, 0)];
    //设置显示模式为永远显示(默认不显示)
    self.codeTF.leftViewMode        = UITextFieldViewModeAlways;
    
    UITapGestureRecognizer * tap          = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(endEditTap)];
    tap.delegate = self;
    [self.view addGestureRecognizer:tap];
    
    self.seleView1 = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.devicemacTextField.frame), CGRectGetMaxY(self.devicemacTextField.frame),CGRectGetWidth(self.devicemacTextField.frame), 120)];
    self.seleView1.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.seleView1];
    
    self.seleTab1 = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.seleView1.frame.size.width, 120)];
    self.seleTab1.delegate = self;
    self.seleTab1.dataSource = self;
    self.seleTab1.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.seleView1 addSubview:self.seleTab1];
    
    self.seleView1.hidden = YES;
    
    
    self.seleView2 = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.platmId.frame), CGRectGetMaxY(self.platmId.frame),CGRectGetWidth(self.platmId.frame), 120)];
    self.seleView2.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.seleView2];
    
    self.seleTab2 = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.seleView2.frame.size.width, 120)];
    self.seleTab2.delegate = self;
    self.seleTab2.dataSource = self;
    self.seleTab2.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.seleView2 addSubview:self.seleTab2];
    
    self.seleView2.hidden = YES;
    
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


#pragma mark -- textFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    if (textField == self.devicemacTextField) {
        
        [self.devicemacTextField resignFirstResponder];
        
        if (self.macArray.count == 0) {
            
            return [HUDTools showText:@"暂无可以绑定的设备!" onView:self.view delay:1.0f];
        }
        
        [self showSelectionView1];
        
    }
    
    if (textField == self.platmId) {

        [self.platmId resignFirstResponder];
        
        [self getPlatformList];
        
        if (self.platformListArr.count == 0) {
            
            return [HUDTools showText:@"暂无可以绑定的平台!" onView:self.view delay:1.0f];
            
        }
        [self showSelectionView2];
    }
    
}

- (void)showSelectionView1 {
    
    self.seleView1.hidden = NO;
}

- (void)showSelectionView2 {
    
    self.seleView2.hidden = NO;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if (tableView == self.seleTab1) {
        return self.macArray.count;
    }else {
        return self.platformListArr.count;
    }

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"seleCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"seleCell"];
        
    }
    
    if (tableView == self.seleTab1) {
        if (self.macArray.count > 0) {
            
            //得到词典中所有KEY值
            NSString * macAdress = [[self.macArray objectAtIndex:indexPath.row] objectForKey:@"deviceMac"];
//            NSString*IP = [[self.macArray objectAtIndex:indexPath.row] objectForKey:@"deviceIP"];
            NSString* text = [NSString stringWithFormat:@"设备(%@)",macAdress];
            cell.textLabel.textColor = [UIColor lightGrayColor];
            cell.textLabel.text =text;
            
        }
    }else {
        if (self.platformListArr.count>0) {
            
            PlatformModel * model = self.platformListArr[indexPath.row];
            cell.textLabel.text = model.platform_name;
            cell.textLabel.textColor = [UIColor lightGrayColor];
            cell.textLabel.font = [UIFont systemFontOfSize:14.0f];
        }
    }


    
    return cell;
}


#pragma mark 设置每行高度（每行高度可以不一样）
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 30;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (tableView == self.seleTab1) {
        
        self.seleView1.hidden = YES;
        NSString * macAdress = [[self.macArray objectAtIndex:indexPath.row] objectForKey:@"deviceMac"];
        self.devicemacTextField.text = macAdress;
        self.macString = macAdress;
        [self.devicemacTextField resignFirstResponder];
        
    }else {
        
        PlatformModel * model = self.platformListArr[indexPath.row];
        self.seleView2.hidden = YES;
        self.platmId.text = model.platform_name;
        self.platformId = model.platform_id;
        [self.platmId resignFirstResponder];
        
    }
    
}


#pragma mark -- didEdit

- (void)endEditTap {
    
    [self.view endEditing:YES];
    self.seleView1.hidden = YES;
    self.seleView2.hidden = YES;

}

#pragma mark -- 按钮Action
// 绑定
- (IBAction)bindingAction:(id)sender {
    
    if (!self.macString) {
        return [HUDTools showText:@"请选择设备!" onView:self.view delay:1.0f];
    }
    
    if (!self.platformId || !self.platmuserid.text) {
        
        return [HUDTools showText:@"请输入平台信息!" onView:self.view delay:1.0f];
        
    }
    
    NSDictionary *params = @{@"platform_userid":self.platmuserid.text,@"platform_id":self.platformId,@"source":@"Ios",@"machine_MAC":self.macString,@"vcode":self.codeTF.text?self.codeTF.text:@"",@"is_binding":@"1"};
    [HttpManager postWithURL:URL_CANCELBOUND_API andParams:params returnBlcok:^(NSError *error, id obj) {
        if (!error) {
            if ([obj[statusKey] integerValue] == 1) {
                
                self.backView = [[CustonBackView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) withBackImageName:@"Home_ok" title:@"绑定成功" msg:@"3S后自动跳转到设备列表"];
                
                [self.view addSubview:self.backView];
                
                [self performSelector:@selector(goback:) withObject:nil afterDelay:3.0f];
                
            }else{
                
                self.backView = [[CustonBackView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) withBackImageName:@"Home_No" title:@"绑定失败" msg:obj[@"msg"]];
                
                [self.view addSubview:self.backView];
                
                [self performSelector:@selector(removeSubViews) withObject:nil afterDelay:3.0f];
                
            }
        }
    }];
    
    
}

// 获取验证码
- (IBAction)getCodeAction:(id)sender {
    
    [self getCode];
}

//返回
- (IBAction)goback:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

// remove
- (void)removeSubViews {

    [UIView animateWithDuration:1.0f animations:^{
        
        
        
    } completion:^(BOOL finished) {
        [self.backView removeFromSuperview];
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma 倒计时
-(void)startTime{
    
    __block int timeout= 60; //倒计时时间
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
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


- (void)getCode {
    
    if (!self.macString) {
        return [HUDTools showText:@"请选择设备!" onView:self.view delay:1.0f];
    }
    
    if (!self.platformId || !self.platmuserid.text || !self.macString) {
        
        return [HUDTools showText:@"请输入平台信息!" onView:self.view delay:1.0f];
        
    }
    
    NSDictionary *params = @{@"platform_userid":self.platmuserid.text,@"platform_id":self.platformId,@"machine_MAC":self.macString,@"is_binding":@"1"};
    
    [HttpManager getWithURL:URL_GETCODE_API andParams:params returnBlcok:^(NSError *error, id obj) {
        if (!error) {
            if ([obj[statusKey] integerValue] == 1) {
                
                [self startTime];
                
                [HUDTools showText:obj[@"msg"] onView:self.view delay:1.0f];
//                self.code = obj[dataKey][@"machine_code"];
                //                self.myModel = model;
                //                self.isBind = bind;
                //                self.codeTF.text = self.code;
                
            }else {
                [HUDTools showText:obj[@"msg"] onView:self.view delay:1.0f];
            }
            
        }
    }];
}


#pragma mark -- 数据相关
- (void)getPlatformList {
    
    [HttpManager postWithURL:URL_PLATFORM_API andParams:nil returnBlcok:^(NSError *error, id obj) {
        if (!error) {
            if ([obj[statusKey] integerValue] == 1) {
                [self.platformListArr removeAllObjects];
                for (NSDictionary * dic in obj[@"data"]) {
                    
                    PlatformModel * model = [PlatformModel new];
                    [model setValuesForKeysWithDictionary:dic];
                    
                    [self.platformListArr addObject:model];
                    
                }
                [self.seleTab2 reloadData];
                
            }else{
                [HUDTools showText:obj[@"msg"] onView:self.view delay:1.0f];
                
            }
        }
    }];
    
}

@end
