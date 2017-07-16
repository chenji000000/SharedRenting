//
//  QuestionAnswerVC.m
//  fszl
//
//  Created by YF-IOS on 15/6/25.
//  Copyright (c) 2015年 huqin. All rights reserved.
//  验证密保问题

#import "QuestionAnswerVC.h"
#import "HTTPHelper.h"
#import "HudHelper.h"
#import "ActionSheetPicker.h"
#import "ResetPasswordVC.h"
#import "RMUniversalAlert.h"

@interface QuestionAnswerVC ()

@property (weak, nonatomic) IBOutlet UITextField *loginNameTextField;
@property (weak, nonatomic) IBOutlet UILabel *passwordQuestionLabel;
@property (weak, nonatomic) IBOutlet UITextField *answerTextField;
@property (nonatomic, strong) NSArray *questions;//获取到的密保问题
@property (nonatomic, copy) NSString *questionID;
@end

@implementation QuestionAnswerVC

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
    if (indexPath.row == 1) {
        tableView.allowsSelection = NO;
        [HTTPHelper getPasswordQuestionWithLoginName:@"" loginType:@"1" success:^(NSDictionary *jsonResult) {
            tableView.allowsSelection = YES;
            if ([jsonResult[@"Result"] isEqualToString:@"1"]) {
                self.questions = jsonResult[@"Table"];
                NSMutableArray *arr = [NSMutableArray arrayWithCapacity:1];
                for (NSDictionary *dict in self.questions) {
                    [arr addObject:dict[@"QuestionDesc"]];
                }
                [ActionSheetStringPicker showPickerWithTitle:@"密保问题选择" rows:arr initialSelection:0 doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                    self.passwordQuestionLabel.text = selectedValue;
                    self.passwordQuestionLabel.textColor = [UIColor blackColor];
                    self.questionID = self.questions[selectedIndex][@"QuestionId"];
                } cancelBlock:nil origin:self.passwordQuestionLabel];
            } else {
                NSLog(@"密保问题获取失败");
            }
        } failure:^(NSString *errorMessage) {
            tableView.allowsSelection = YES;
            [HudHelper showHudWithMessage:errorMessage toView:self.view];
        }];
    }
}
- (IBAction)nextStepButtonPressed:(UIButton *)sender {
    [self.loginNameTextField resignFirstResponder];
    [self.answerTextField resignFirstResponder];
    if ([self.loginNameTextField.text isEqualToString:@""]) {
        [HudHelper showHudWithMessage:@"请输入您的会员名" toView:self.view];
        return;
    }
    if ([self.answerTextField.text isEqualToString:@""]) {
        [HudHelper showHudWithMessage:@"请输入密保问题的答案" toView:self.view];
        return;
    }
    if ([self.loginNameTextField.text containsString:@" "]||[self.answerTextField.text containsString:@" "]) {
        [HudHelper showHudWithMessage:@"输入信息中不能有空格" toView:self.view];
        return;
    }
    sender.enabled = NO;
    [HTTPHelper isValidPasswordQuestionAnswerWithLoginName:self.loginNameTextField.text questionID:self.questionID answer:self.answerTextField.text loginType:@"1" success:^(NSString *result) {
        sender.enabled = YES;
        if ([result isEqualToString:@"1"]) {
            ResetPasswordVC *resetPassword = [self.storyboard instantiateViewControllerWithIdentifier:@"ResetPasswordVC"];
            resetPassword.memberName = self.loginNameTextField.text;
            [self.navigationController pushViewController:resetPassword animated:YES];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"密保问题与答案不匹配，请检查后重试" delegate:nil cancelButtonTitle:@"好" otherButtonTitles: nil];
            [alert show];
        }
    } failure:^(NSString *errorMessage) {
        sender.enabled = YES;
        [HudHelper showHudWithMessage:errorMessage toView:self.view];
    }];
}


@end
