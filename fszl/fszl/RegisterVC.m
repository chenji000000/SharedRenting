//
//  RegisterVC.m
//  fszl
//
//  Created by huqin on 1/4/15.
//  Copyright (c) 2015 huqin. All rights reserved.
//  注册

#import "RegisterVC.h"
#import "HTTPHelper.h"
#import "HudHelper.h"
#import "RMUniversalAlert.h"
#import "NSString+Estension.h"

@interface RegisterVC ()<UITextFieldDelegate,UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *phoneNumberTextField;
@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *realNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *password2;//确认密码

@property (weak, nonatomic) IBOutlet UIButton *registerButton;

@property (nonatomic) BOOL phoneNumberCanUse;//手机号可以使用
@property (nonatomic) BOOL loginNameCanUse;//会员名可以使用
@property (nonatomic) BOOL agreeProtocol;//同意会员协议
@property (nonatomic) BOOL gender;//性别（YES男 NO女）

@end

@implementation RegisterVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    //初始化判断条件
    self.phoneNumberCanUse = NO;
    self.loginNameCanUse = NO;
    self.agreeProtocol = NO;
    
    self.registerButton.enabled = NO;
    
    self.phoneNumberTextField.delegate = self;
    self.passwordTextField.delegate = self;
    self.password2.delegate = self;
    self.userNameTextField.delegate = self;
    self.realNameTextField.delegate = self;
    
    self.gender = YES;
    //修改返回键样式
    UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Back"] style:UIBarButtonItemStylePlain target:self action:@selector(popToLastViewController)];
    self.navigationItem.leftBarButtonItem = back;
}
- (void)popToLastViewController {
    [self.navigationController popViewControllerAnimated:YES];
}

//测试注册成功
- (IBAction)barButtonItemPressed:(UIBarButtonItem *)sender{
    [RMUniversalAlert showAlertInViewController:self withTitle:@"预注册成功" message:@"温馨提示：请前往附近的门店网点进行身份证及驾驶证的实名认证并获得通过以后才能进行车辆预定服务" cancelButtonTitle:@"稍后再说" destructiveButtonTitle:@"立即前往" otherButtonTitles:nil tapBlock:^(RMUniversalAlert *alert, NSInteger buttonIndex) {
        if (alert.destructiveButtonIndex == buttonIndex) {
            NSLog(@"立即前往");
        }
        if (alert.cancelButtonIndex == buttonIndex) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //隐藏底部标签栏
//    self.tabBarController.tabBar.hidden = YES;
}

//检查条件判断注册按钮能否使用
-(BOOL) check{
    //信息不完整
    if ([self.phoneNumberTextField.text isEqualToString:@""] || [self.passwordTextField.text isEqualToString:@""] || [self.userNameTextField.text isEqualToString:@""] || [self.realNameTextField.text isEqualToString:@""] || [self.password2.text isEqualToString:@""]) {
        return NO;
    } else {
        if (self.phoneNumberCanUse == YES && self.loginNameCanUse == YES && self.agreeProtocol == YES) {
            return YES;
        }
        return NO;
    }
}
//选择性别
- (IBAction)chooseGender:(UIButton *)sender {
    NSInteger tag = sender.tag;
    if (tag == 100) {
        [sender setTitle:@"✅男" forState:UIControlStateNormal];
        sender.enabled = NO;
        UIButton *button =(UIButton *) [self.view viewWithTag:tag + 1];
        button.enabled = YES;
        [button setTitle:@"⚪️女" forState:UIControlStateNormal];
        self.gender = YES;
    } else {
        [sender setTitle:@"✅女" forState:UIControlStateNormal];
        sender.enabled = NO;
        UIButton *button =(UIButton *) [self.view viewWithTag:tag - 1];
        button.enabled = YES;
        [button setTitle:@"⚪️男" forState:UIControlStateNormal];
        self.gender = NO;
    }
}

//是否同意会议协议
- (IBAction)agreeProtocolButton:(UIButton *)sender{
    if (self.agreeProtocol) {
        [sender setImage:[UIImage imageNamed:@"login_checkbox_no"] forState:UIControlStateNormal];
        self.agreeProtocol = NO;
        self.registerButton.enabled = NO;
        return;
    } else {
        [sender setImage:[UIImage imageNamed:@"login_checkbox_yes"] forState:UIControlStateNormal];
        self.agreeProtocol = YES;
        self.registerButton.enabled = YES;
        return;
    }
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    // Return the number of sections.
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    // Return the number of rows in the section.
    return 9;
}

//调整session header的高度
- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return CGFLOAT_MIN;//12.0;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return CGFLOAT_MIN;//12.0;
}

#pragma mark - Actions
//注册
- (IBAction)registerButtonPressed:(UIButton *)sender{
    if ([self.phoneNumberTextField.text isEqualToString:@""] || [self.passwordTextField.text isEqualToString:@""] || [self.userNameTextField.text isEqualToString:@""] || [self.realNameTextField.text isEqualToString:@""] || [self.password2.text isEqualToString:@""]) {
        [HudHelper showHudWithMessage:@"请将信息填写完整" toView:self.view];
        return;
    }
    if ([self.phoneNumberTextField.text containsString:@" "] || [self.passwordTextField.text containsString:@" "] || [self.userNameTextField.text containsString:@" "] || [self.realNameTextField.text containsString:@" "] || [self.password2.text containsString:@" "]) {
        [HudHelper showHudWithMessage:@"输入信息中不能有空格" toView:self.view];
        return;
    }
    if (![self.phoneNumberTextField.text isPhoneNumber]) {
        [HudHelper showHudWithMessage:@"手机号输入不正确" toView:self.view];
        return;
    }
    if ([self.password2.text length] < 6 || [self.passwordTextField.text length] >14) {
        [HudHelper showHudWithMessage:@"密码长度为6-14位" toView:self.view];
        return;
    }
    if (![self.password2.text isEqualToString:self.passwordTextField.text]) {
        if ([self.passwordTextField.text isEqualToString:@""]) {
            return;
        } else {
            [HudHelper showHudWithMessage:@"两次密码输入不一致" toView:self.view];
            self.password2.text = @"";
            return;
        }
    }
    //防止反复发出请求
    [sender setEnabled:NO];
    //发起注册请求 level = 2 普通会员 status = 0 未审核
    NSString *sex = [NSString stringWithFormat:@"%d",self.gender];
    [HTTPHelper insertMemberInfoWithLoginName:self.userNameTextField.text passWord:self.passwordTextField.text iDCardId:@"" driverLicenseNo:@"" trueName:self.realNameTextField.text sex:sex email:@"" levelID:@"2" status:@"0" telephone:self.phoneNumberTextField.text argIDCardIMGPath:@"" argDriverLicenseIMGPath:@"" bankCardNo:@"" success:^(NSString * result) {
        [sender setEnabled:YES];
        if ([result isEqualToString:@"1"]) {//1为成功 其余均为失败
            [RMUniversalAlert showAlertInViewController:self withTitle:@"注册成功" message:@"您已注册成功，为了保障您的账号安全您需要设置密保问题，您可以通过∙用户中心->设置∙来设置密保问题，设置成功后您就可以通过密保问题找回密码" cancelButtonTitle:@"好" destructiveButtonTitle:nil otherButtonTitles:nil tapBlock:^(RMUniversalAlert *alert, NSInteger buttonIndex) {
                [self.navigationController popViewControllerAnimated:YES];
            }];
        } else if ([result isEqualToString:@"10"]){//手机号：13984679413 loginName：light password：aaaaaa可测试已被注册情况
            [HudHelper showHudWithMessage:@"会员名与手机号均已被使用" toView:self.view];
        } else if ([result isEqualToString:@"20"]) {
            [HudHelper showHudWithMessage:@"手机号已被使用" toView:self.view];
        } else if ([result isEqualToString:@"30"]) {
            [HudHelper showHudWithMessage:@"会员名已被注册" toView:self.view];
        } else if ([result isEqualToString:@"40"]) {
            [HudHelper showHudWithMessage:@"身份证号已被使用" toView:self.view];
        } else {
            [HudHelper showHudWithMessage:@"系统错误" toView:self.view];
        }
    } failure:^(NSString *errorMessage) {
        //网络问题
        [sender setEnabled:YES];
        [HudHelper showHudWithMessage:errorMessage toView:self.view];
    }];
    
}

#pragma mark - TextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}




@end
