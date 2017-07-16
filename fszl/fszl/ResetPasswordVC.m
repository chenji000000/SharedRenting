//
//  ResetPasswordVC.m
//  fszl
//
//  Created by YF-IOS on 15/6/25.
//  Copyright (c) 2015年 huqin. All rights reserved.
//  重设密码

#import "ResetPasswordVC.h"
#import "HudHelper.h"
#import "HTTPHelper.h"
#import "RMUniversalAlert.h"

@interface ResetPasswordVC ()<UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *password1;
@property (weak, nonatomic) IBOutlet UITextField *password2;

@end

@implementation ResetPasswordVC

- (void)viewDidLoad {
    [super viewDidLoad];
    //修改返回键样式
    UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Back"] style:UIBarButtonItemStylePlain target:self action:@selector(popToLastViewController)];
    self.navigationItem.leftBarButtonItem = back;
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
    return 3;
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
- (IBAction)doneButtonPressed:(UIButton *)sender {
    [self.password1 resignFirstResponder];
    [self.password2 resignFirstResponder];
    if ([self.password1.text isEqualToString:@""]) {
        [HudHelper showHudWithMessage:@"新密码为空" toView:self.view];
        return;
    }
    if ([self.password2.text isEqualToString:@""]) {
        [HudHelper showHudWithMessage:@"请再次输入新密码" toView:self.view];
        return;
    }
    if ([self.password1.text containsString:@" "]||[self.password2.text containsString:@" "]) {
        [HudHelper showHudWithMessage:@"输入信息中不能有空格" toView:self.view];
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
    sender.enabled = NO;//防止重复发送请求
    [HTTPHelper resetPasswordWithLoginName:self.memberName newPwd:self.password1.text loginType:@"1" success:^(NSString *result) {
        sender.enabled = YES;
        if ([result isEqualToString:@"1"]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"密码重设成功，您现在可以使用新密码登录" delegate:self cancelButtonTitle:@"好" otherButtonTitles: nil];
            [alert show];
        } else {
            NSLog(@"密码重设失败");
        }
    } failure:^(NSString *errorMessage) {
        sender.enabled = YES; 
        [HudHelper showHudWithMessage:errorMessage toView:self.view];
    }];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == alertView.cancelButtonIndex) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

@end
