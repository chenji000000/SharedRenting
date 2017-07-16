//
//  SetQuestionVC.m
//  fszl
//
//  Created by YF-IOS on 15/6/26.
//  Copyright (c) 2015年 huqin. All rights reserved.
//  设置密保问题

#import "SetQuestionVC.h"
#import "HTTPHelper.h"
#import "HudHelper.h"
#import "AccountManger.h"
#import "ActionSheetPicker.h"
#import "RMUniversalAlert.h"

@interface SetQuestionVC ()

@property (weak, nonatomic) IBOutlet UITextField *answerTextField;//输入密保问题答案
@property (weak, nonatomic) IBOutlet UILabel *questionLabel;//密保问题

@property (nonatomic, copy) NSString *questionID;//用户选择的密保问题的ID
@property (nonatomic, strong) NSArray *questions;//用户可选的密保问题
@end

@implementation SetQuestionVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"密码保护";
//    //初始化
//    self.questions = [NSMutableArray arrayWithCapacity:1];
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
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return CGFLOAT_MIN;//12.0;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
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
                    self.questionLabel.text = selectedValue;
                    self.questionLabel.textColor = [UIColor blackColor];
                    self.questionID = self.questions[selectedIndex][@"QuestionId"];
                } cancelBlock:nil origin:self.questionLabel];
            } else {
                [HudHelper showHudWithMessage:@"密保问题获取失败" toView:self.view];
            }
        } failure:^(NSString *errorMessage) {
            tableView.allowsSelection = YES;
            [HudHelper showHudWithMessage:errorMessage toView:self.view];
        }];
    }
}
- (IBAction)doneButtonPressed:(UIButton *)sender {
    [self.answerTextField resignFirstResponder];
    if ([self.questionLabel.text isEqualToString:@"请选择密保问题"]) {
        [HudHelper showHudWithMessage:@"密保问题为空" toView:self.view];
        return;
    }
    if ([self.answerTextField.text isEqualToString:@""]) {
        [HudHelper showHudWithMessage:@"请输入答案" toView:self.view];
        return;
    }
    if ([self.answerTextField.text containsString:@" "]) {
        [HudHelper showHudWithMessage:@"密保答案中不能有空格" toView:self.view];
        return;
    }
    sender.enabled = NO;
    [HTTPHelper setPasswordQuestionWithLoginName:[AccountManger sharedInstance].loginName password:[[NSUserDefaults standardUserDefaults] valueForKey:@"Password"] questionID:self.questionID answer:self.answerTextField.text loginType:@"1" success:^(NSString *result) {
        sender.enabled = YES;
        if ([result isEqualToString:@"1"]) {
            [RMUniversalAlert showAlertInViewController:self withTitle:nil message:@"您的密保问题及答案设置成功，请记好问题及答案，便于以后您的密码找回" cancelButtonTitle:@"好" destructiveButtonTitle:nil otherButtonTitles:nil tapBlock:^(RMUniversalAlert *alert, NSInteger buttonIndex) {
                [self.navigationController popToRootViewControllerAnimated:YES];
            }];
        } else {
            NSLog(@"密保问题设置失败");
        }
    } failure:^(NSString *errorMessage) {
        sender.enabled = YES;
        [HudHelper showHudWithMessage:errorMessage toView:self.view];
    }];
}

@end
