//
//  AddPaymentAccountVC.m
//  fszl
//
//  Created by YF-IOS on 15/5/21.
//  Copyright (c) 2015年 huqin. All rights reserved.
//

#import "AddPaymentAccountVC.h"
#import "ActionSheetPicker.h"
#import "AccountManger.h"
#import "HTTPHelper.h"
#import "HudHelper.h"
#import "NSString+Estension.h"

@interface AddPaymentAccountVC ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UILabel *paymentTypeLabel;//用户选择支付方式
@property (weak, nonatomic) IBOutlet UITextField *paymentAccountTextField;//输入账号的文本框
@property (nonatomic, strong) NSString *paymentType;//用户选择的支付类型
@end

@implementation AddPaymentAccountVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"添加账号";
    //取消按键
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Back"] style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonPressed)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    self.paymentAccountTextField.delegate = self;
}
//左导航取消按键
- (void)cancelButtonPressed {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//点击添加
- (IBAction)addPaymentAccount:(UIButton *)sender {
    [self.paymentAccountTextField resignFirstResponder];
    if ([self.paymentTypeLabel.text isEqualToString:@"请选择"]) {
        [HudHelper showHudWithMessage:@"请选择类型" toView:self.view];
        return;
    }
    if ([self.paymentAccountTextField.text isEqualToString:@""]) {
        [HudHelper showHudWithMessage:@"请输入账号" toView:self.view];
        return;
    }
    if ([self.paymentTypeLabel.text isEqualToString:@"银联卡"]) {
        if (![self.paymentAccountTextField.text isBankCardNo]) {
            [HudHelper showHudWithMessage:@"请输入正确的银联卡号" toView:self.view];
            return;
        }
    }
    sender.enabled = NO;
    NSString *memberAccount = [AccountManger sharedInstance].memberAccount;
    [HTTPHelper createMemberPaymentAccountWithMemberAccount:memberAccount paymentType:self.paymentType paymentAccount:self.paymentAccountTextField.text success:^(NSString *result) {
        sender.enabled = YES;
        if ([result isEqualToString:@"1"]) {
            [HudHelper showHudWithMessage:@"添加账号成功" toView:self.presentingViewController.view];
            [self dismissViewControllerAnimated:YES completion:nil];
        } else {
            [HudHelper showHudWithMessage:@"添加账号失败" toView:self.view];
        }
    } failure:^(NSString *errorMessage) {
        sender.enabled = YES;
        [HudHelper showHudWithMessage:errorMessage toView:self.view];
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 3;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        [ActionSheetStringPicker showPickerWithTitle:@"账号类型选择" rows:@[@"银联卡",@"支付宝",@"微信支付"] initialSelection:0 doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
            self.paymentTypeLabel.text = selectedValue;
            self.paymentTypeLabel.textColor = [UIColor blackColor];
            self.paymentType = [NSString stringWithFormat:@"%ld",(long)(selectedIndex + 1)];
        } cancelBlock:nil origin:self.paymentTypeLabel];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10.0;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}



@end
