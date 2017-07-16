//
//  EnchashmentVC.m
//  fszl
//
//  Created by YF-IOS on 15/4/16.
//  Copyright (c) 2015年 huqin. All rights reserved.
//  提现

#import "EnchashmentVC.h"
#import "AccountManger.h"
#import "HTTPHelper.h"
#import "HudHelper.h"
#import "PaymentAccountVC.h"
#import "RMUniversalAlert.h"

@interface EnchashmentVC ()<UITextFieldDelegate,UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *moneyTextField;//输入金额的文本框
@property (weak, nonatomic) IBOutlet UILabel *paymentAccountLabel;//显示账号的标签
@property (weak, nonatomic) IBOutlet UILabel *paymentTypeLabel;//显示账号类型的标签
@property (weak, nonatomic) IBOutlet UILabel *accountBalance;//显示可提现余额
@property (nonatomic, strong) NSString *balance;//会员账号余额

@end

@implementation EnchashmentVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"提现";
    self.moneyTextField.delegate = self;
    self.paymentAccountLabel.text = self.paymentAccount[@"PaymentAccount"];
    
    NSString *str = self.paymentAccount[@"PaymentType"];
    if ([str isEqualToString:@"1"]) {
        self.paymentTypeLabel.text = @"银联";
    }
    if ([str isEqualToString:@"2"]) {
        self.paymentTypeLabel.text = @"支付宝";
    }
    if ([str isEqualToString:@"3"]) {
        self.paymentTypeLabel.text = @"微信";
    }
//    //获取用户充值过的银行卡号
//    [self getMemberInfo];
//    self.paymentTypeLabel.text = @"银联";
    [self balanceOfAccount];//获取账户余额
    self.moneyTextField.text = @"";
    //修改返回键样式
    UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Back"] style:UIBarButtonItemStylePlain target:self action:@selector(popToLastViewController)];
    self.navigationItem.leftBarButtonItem = back;
}
- (void) getMemberInfo {
    [HTTPHelper getMemberInfoWithLoginName:[AccountManger sharedInstance].loginName status:@"" equalsOrlikes:@"1" success:^(NSDictionary *jsonResult) {
        NSDictionary *member = jsonResult[@"Table"][0];
        self.paymentAccountLabel.text = member[@"BankCardNo"];
    } failure:^(NSString *errorMessage) {
        NSLog(@"%s %@",__func__,errorMessage);
    }];
}
- (void)popToLastViewController {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)getAllBalance:(id)sender {
    self.moneyTextField.text = self.balance;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //隐藏底部标签栏
    //    self.tabBarController.tabBar.hidden = YES;
}
//获取账户余额
- (void)balanceOfAccount {
    NSString *memberID = [AccountManger sharedInstance].memberId;
    [HTTPHelper getMemberAccountByMemberID:memberID success:^(NSDictionary *jsonResult) {
        if ([jsonResult[@"Result"] isEqualToString:@"1"]) {
            NSDictionary *memberAccount = jsonResult[@"Table"][0];
            self.balance = memberAccount[@"Balance"];
            self.accountBalance.text = [NSString stringWithFormat:@"可提现余额：%@元",self.balance];
        }
    } failure:^(NSString *errorMessage) {
        [HudHelper showHudWithMessage:errorMessage toView:self.view];
    }];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 2;
    }
    return 3;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10.0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 1.0;
}

- (IBAction)doneButtonPressed:(id)sender {
    [self.moneyTextField resignFirstResponder];
    if ([self.balance doubleValue] == 0) {
        [HudHelper showAlertViewWithMessage:@"您的账户余额为0"];
        return;
    }
//    if ([self.paymentAccountLabel.text isEqualToString:@""]) {
//        [HudHelper showAlertViewWithMessage:@"您还未充值过，无法使用提现功能"];
//        return;
//    }
    if ([self.moneyTextField.text isEqualToString:@""]) {
        [HudHelper showHudWithMessage:@"请输入提现金额" toView:self.view];
        return;
    }
    UIButton *button = sender;
    button.enabled = NO;
//    NSString *memberAccount = [AccountManger sharedInstance].memberAccount;
    NSString *loginName = [AccountManger sharedInstance].loginName;
    [HTTPHelper applyForDrawCashWithLoginName:loginName argMoney:self.moneyTextField.text paymentType:self.paymentAccount[@"PaymentType"] paymentAccount:self.paymentAccountLabel.text argIDCard:@"" success:^(NSString *result) {
        button.enabled = YES;
        if ([result isEqualToString:@"1"]) {
            [RMUniversalAlert showAlertInViewController:self withTitle:@"提现" message:@"提现申请提交成功，请等待后台人员处理" cancelButtonTitle:@"好" destructiveButtonTitle:nil otherButtonTitles:nil tapBlock:^(RMUniversalAlert *alert, NSInteger buttonIndex) {
                [self.navigationController popViewControllerAnimated:YES];
            }];
        } else {
            NSString *msg = [NSString stringWithFormat:@"提现申请提交失败(%@)",result];
            [HudHelper showHudWithMessage:msg toView:self.view];
        }
    } failure:^(NSString *errorMessage) {
        button.enabled = YES;
        [HudHelper showHudWithMessage:errorMessage toView:self.view];
    }];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField == self.moneyTextField) {
        if ([self.moneyTextField.text doubleValue] > [self.balance doubleValue]) {
            textField.text = self.balance;
        }
    }
}

@end
