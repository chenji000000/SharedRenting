//
//  LoginVC.m
//  fszl
//
//  Created by huqin on 1/4/15.
//  Copyright (c) 2015 huqin. All rights reserved.
//  登录

#import "LoginVC.h"
#import "HTTPHelper.h"
#import "HudHelper.h"
#import "AccountManger.h"
#import "SocketManager.h"

@interface LoginVC () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *loginNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;

@property (nonatomic, assign) BOOL savePassword;//是否保存密码

@end

@implementation LoginVC

- (void)viewDidLoad{
    [super viewDidLoad];
    self.loginNameTextField.delegate = self;
    self.passwordTextField.delegate = self;
    self.savePassword = YES;
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //隐藏底部标签栏
//    self.tabBarController.tabBar.hidden = YES;
    //是否已经记录用户名及密码
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"LoginName"]) {
        self.loginNameTextField.text = [[NSUserDefaults standardUserDefaults] valueForKey:@"LoginName"];
    }
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"Password"]) {
        self.passwordTextField.text = [[NSUserDefaults standardUserDefaults] valueForKey:@"Password"];
    }
}
- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//tableView data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    // Return the number of sections.
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    // Return the number of rows in the section.
    return 2;
}

//调整session header的高度
- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 12.0;//CGFLOAT_MIN;
}

//登录
- (IBAction)loginButtonPressed:(UIButton *)sender{
    [self.loginNameTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    //用户名或密码为空
    if ([self.loginNameTextField.text isEqualToString:@""] || [self.passwordTextField.text isEqualToString:@""]){
        [HudHelper showHudWithMessage:@"请将信息填写完整" toView:self.view];
        return;
    }
    //防止反复发出请求
    [sender setEnabled:NO];
#if ZFB
    NSString *leaseType = @"2";
#else
    NSString *leaseType = @"2";
#endif
    //发起请求
    [HTTPHelper loginWithLoginName:self.loginNameTextField.text passWord:self.passwordTextField.text checkType:@"1" argLeaseType:leaseType success:^(NSDictionary * jsonResult) {
        [sender setEnabled:YES];
        if ([jsonResult[@"Result"] isEqualToString:@"1"]) {//成功
            if ([jsonResult[@"Table"] count] > 1) {
                [HudHelper showHudWithMessage:@"该账户存在重名问题" toView:self.view];
                return;
            }
            NSDictionary *account = jsonResult[@"Table"][0];
            [HTTPHelper getMemberAccountByMemberID:account[@"MemberId"] success:^(NSDictionary *jsonResult) {
                if ([jsonResult[@"Result"] isEqualToString:@"1"]) {
                    NSDictionary *memberAccount = jsonResult[@"Table"][0];
                    [[NSUserDefaults standardUserDefaults] setValue:memberAccount[@"MemberAccount"] forKey:@"MemberAccount"];
                    [AccountManger sharedInstance].memberAccount = memberAccount[@"MemberAccount"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
            } failure:^(NSString *errorMessage) {
                [HudHelper showHudWithMessage:errorMessage toView:self.view];
            }];
            //保存账号审核状态
            [[NSUserDefaults standardUserDefaults] setValue:account[@"Status"] forKey:@"LoginStatus"];
            //按用户选择保存相关信息，方便下次登录
            if (self.savePassword) {
                [[NSUserDefaults standardUserDefaults] setValue:account[@"LoginName"] forKey:@"LoginName"];
                [[NSUserDefaults standardUserDefaults] setValue:account[@"Password"] forKey:@"Password"];
            } else {
                [[NSUserDefaults standardUserDefaults] setValue:account[@"LoginName"] forKey:@"LoginName"];
                [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"Password"];
            }
            [[NSUserDefaults standardUserDefaults] setValue:account[@"MemberId"] forKey:@"MemberId"];
            [[NSUserDefaults standardUserDefaults] setValue:account[@"Telephone"] forKey:@"Telephone"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            //记录LoginName、MemberId
            [AccountManger sharedInstance].loginName = account[@"LoginName"];
            [AccountManger sharedInstance].memberId = account[@"MemberId"];
            [AccountManger sharedInstance].telephone = account[@"Telephone"];
            [[SocketManager sharedInstance] bind];
            [HudHelper showHudWithMessage:@"登录成功" toView:self.presentingViewController.view];
            //退出登录界面
            [self dismissViewControllerAnimated:YES completion:nil];
        } else{ //失败
            [HudHelper showHudWithMessage:@"用户名或密码错误" toView:self.view];
        }
    } failure:^(NSString *errorMessage) {//网络问题
        [sender setEnabled:YES];
        [HudHelper showHudWithMessage:errorMessage toView:self.view];
    }];
}
//是否保存密码
- (IBAction)checkboxButtonPressed:(UIButton *)sender{
    if (self.savePassword) {
        [sender setImage:[UIImage imageNamed:@"login_checkbox_no"] forState:UIControlStateNormal];
        self.savePassword = NO;
        return;
    } else {
        [sender setImage:[UIImage imageNamed:@"login_checkbox_yes"] forState:UIControlStateNormal];
        self.savePassword = YES;
        return;
    }
}

- (IBAction)backButtonPressed:(UIBarButtonItem *)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

//textField delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.loginNameTextField) {
        [self.passwordTextField becomeFirstResponder];
    } else if (textField == self.passwordTextField) {
        [textField resignFirstResponder];
        [self loginButtonPressed:self.loginButton];
    }
    return YES;
}
@end
