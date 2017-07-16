//
//  ChangePasswordVC.m
//  fszl
//
//  Created by YF-IOS on 15/6/24.
//  Copyright (c) 2015年 huqin. All rights reserved.
//  修改密码

#import "ChangePasswordVC.h"
#import "HudHelper.h"
#import "HTTPHelper.h"
#import "AccountManger.h"
#import "LoginVC.h"
#import "SocketManager.h"

@interface ChangePasswordVC ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *memberName;//旧密码输入框
@property (weak, nonatomic) IBOutlet UITextField *password1;//新密码输入框
@property (weak, nonatomic) IBOutlet UITextField *password2;//确认密码输入框
@property (weak, nonatomic) IBOutlet UIButton *doneButton;//确定按钮

@end

@implementation ChangePasswordVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.memberName.delegate = self;
    self.password1.delegate = self;
    self.password2.delegate = self;
    
    //修改返回键样式
    UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Back"] style:UIBarButtonItemStylePlain target:self action:@selector(popToLastViewController)];
    self.navigationItem.leftBarButtonItem = back;
//    self.view.userInteractionEnabled = NO;
}
- (void)popToLastViewController {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}
//调整session header的高度
- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 12.0;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return CGFLOAT_MIN;//12.0;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
- (IBAction)changePassword:(UIButton *)sender {
    [self.memberName resignFirstResponder];
    [self.password1 resignFirstResponder];
    [self.password2 resignFirstResponder];
    if ([self.memberName.text isEqualToString:@""]) {
        [HudHelper showHudWithMessage:@"请输入旧密码" toView:self.view];
        return;
    }
    if ([self.password1.text isEqualToString:@""]) {
        [HudHelper showHudWithMessage:@"请输入新密码" toView:self.view];
        return;
    }
    if ([self.password2.text isEqualToString:@""]) {
        [HudHelper showHudWithMessage:@"请输入确认密码" toView:self.view];
        return;
    }
    if (![self.password1.text isEqualToString:self.password2.text]) {
        [HudHelper showHudWithMessage:@"密码输入不一致" toView:self.view];
        return;
    }
    if ([self.password1.text length]<6 ||[self.password1.text length]>14||[self.password2.text length]<6||[self.password2.text length]>14) {
        [HudHelper showHudWithMessage:@"密码长度为6-14位" toView:self.view];
        return;
    }
    sender.enabled = NO;
    [HTTPHelper changePasswordWithLoginName:[AccountManger sharedInstance].loginName oldPwd:self.memberName.text newPwd:self.password1.text loginType:@"1" success:^(NSString *result) {
        sender.enabled = YES;
        if ([result isEqualToString:@"1"]) {
            [HudHelper showHudWithMessage:@"修改成功，请重新登录" toView:self.view];
            //删除登录信息
            [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"Password"];
            [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"MemberId"];
            [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"Telephone"];
            [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"LoginStatus"];
            [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"MemberAccount"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [AccountManger sharedInstance].memberId = nil;
            [AccountManger sharedInstance].telephone = nil;
            [AccountManger sharedInstance].loginName = nil;
            [AccountManger sharedInstance].memberAccount = nil;
            [[SocketManager sharedInstance] disConnect];
            [self performSelector:@selector(backToRootVC) withObject:nil afterDelay:0.8f];
        } else if ([result isEqualToString:@"2"]) {
            [HudHelper showHudWithMessage:@"修改失败，密码错误" toView:self.view];
        } else {
            [HudHelper showHudWithMessage:@"系统错误" toView:self.view];
        }
    } failure:^(NSString *errorMessage) {
        sender.enabled = YES;
        [HudHelper showHudWithMessage:errorMessage toView:self.view];
    }];
}
-(void)backToRootVC {
    [self.navigationController popToRootViewControllerAnimated:YES];
}
#pragma mark - TextField delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}


@end
