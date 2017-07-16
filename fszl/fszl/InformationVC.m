//
//  InformationVC.m
//  fszl
//
//  Created by YF-IOS on 15/7/31.
//  Copyright (c) 2015年 huqin. All rights reserved.
//

#import "InformationVC.h"
#import "HTTPHelper.h"
#import "HudHelper.h"
#import "RMUniversalAlert.h"
#import "AccountManger.h"
@interface InformationVC ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *userPicImageView;
@property (weak, nonatomic) IBOutlet UILabel *loginName;
@property (weak, nonatomic) IBOutlet UITextField *trueName;
@property (weak, nonatomic) IBOutlet UIButton *man;
@property (weak, nonatomic) IBOutlet UIButton *woman;
@property (weak, nonatomic) IBOutlet UITextField *phoneName;//电话号码

@property (weak, nonatomic) IBOutlet UITextField *email;
@property (weak, nonatomic) IBOutlet UITextField *idCardNo;
@property (weak, nonatomic) IBOutlet UITextField *driverCardNo;
@property (weak, nonatomic) IBOutlet UILabel *photo;
@property (weak, nonatomic) IBOutlet UILabel *sfzLabel;
@property (weak, nonatomic) IBOutlet UILabel *jszLabel;
@property (nonatomic) BOOL gender;//性别
@end

@implementation InformationVC

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *personalIMGPath = self.member[@"PersonalIMGPath"];//个人照片
    [HTTPHelper getUserPictureWithImageView:self.userPicImageView pictureName:personalIMGPath];
    self.loginName.text = self.member[@"LoginName"];
    self.trueName.text = self.member[@"TrueName"];
    self.trueName.delegate = self;
    self.phoneName.delegate = self;
    self.email.delegate = self;
    self.idCardNo.delegate = self;
    self.driverCardNo.delegate = self;
    NSLog(@"%s %@",__func__,self.member[@"Sex"]);
    if ([self.member[@"Sex"] isEqualToString:@"True"]) {
        [self.man setTitle:@"✅男" forState:UIControlStateNormal];
        self.man.enabled = NO;
        [self.woman setTitle:@"⚪️女" forState:UIControlStateNormal];
        self.woman.enabled = YES;
        self.gender = YES;
    } else {
        [self.man setTitle:@"⚪️男" forState:UIControlStateNormal];
        self.man.enabled = YES;
        [self.woman setTitle:@"✅女" forState:UIControlStateNormal];
        self.woman.enabled = NO;
        self.gender = NO;
    }
    self.phoneName.text = self.member[@"Telephone"];
    self.email.text = self.member[@"Email"];
    self.idCardNo.text = self.member[@"IDCardID"];
    self.driverCardNo.text = self.member[@"DriverLicenseNo"];
    if ([self.member[@"PersonalIMGPath"] isEqualToString:@""]) {
        self.photo.text = @"未上传";
    } else {
        self.photo.text = @"已上传";
    }
    if ([self.member[@"IDCardIMGPath"] isEqualToString:@""]) {
        self.sfzLabel.text = @"未上传";
    } else {
        self.sfzLabel.text = @"已上传";
    }
    if ([self.member[@"DriverLicenseIMGPath"] isEqualToString:@""]) {
        self.jszLabel.text = @"未上传";
    } else {
        self.jszLabel.text = @"已上传";
    }
    NSString *loginStatus = [[NSUserDefaults standardUserDefaults] valueForKey:@"LoginStatus"];//账号验证状态
    if ([loginStatus isEqualToString:@"1"]) {
        self.idCardNo.userInteractionEnabled = NO;
        self.driverCardNo.userInteractionEnabled = NO;
    }
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
- (IBAction)saveInformation:(UIButton *)sender {
    [self.trueName resignFirstResponder];
    [self.phoneName resignFirstResponder];
    [self.email resignFirstResponder];
    [self.idCardNo resignFirstResponder];
    [self.driverCardNo resignFirstResponder];
    if (![self validateIdentityCard:self.idCardNo.text]) {
        [HudHelper showHudWithMessage:@"请输入正确身份证号码!" toView:self.view];
        return;
    }
    if (![self driverCardCard:self.driverCardNo.text]) {
        [HudHelper showHudWithMessage:@"请输入正确驾驶证号码!" toView:self.view];
        return;
    }
    if([self.member[@"PersonalIMGPath"] isEqualToString:@""]) {
        [HudHelper showHudWithMessage:@"请上传个人照片!" toView:self.view];
        return;
    }
    if([self.member[@"IDCardIMGPath"] isEqualToString:@""]) {
        [HudHelper showHudWithMessage:@"请上传身份证照片!" toView:self.view];
        return;
    }
    if([self.member[@"DriverLicenseIMGPath"] isEqualToString:@""]) {
        [HudHelper showHudWithMessage:@"请上传驾驶证照片!" toView:self.view];
        return;
    }
    sender.enabled = NO;
    NSString *sex = [NSString stringWithFormat:@"%ld",(long)self.gender];
    [HTTPHelper updateMemberInfoByLoginName:self.loginName.text passWord:self.member[@"Password"] iDCardId:self.idCardNo.text driverLicenseNo:self.driverCardNo.text trueName:self.trueName.text sex:sex email:self.email.text levelID:self.member[@"LevelID"] status:self.member[@"Status"] telephone:self.phoneName.text argIDCardIMGPath:self.member[@"IDCardIMGPath"] argDriverLicenseIMGPath:self.member[@"DriverLicenseIMGPath"] bankCardNo:self.member[@"BankCardNo"] success:^(NSString *result) {
        sender.enabled = YES;
        if ([result isEqualToString:@"1"]) {
            [RMUniversalAlert showAlertInViewController:self withTitle:nil message:@"保存成功" cancelButtonTitle:@"好" destructiveButtonTitle:nil otherButtonTitles:nil tapBlock:^(RMUniversalAlert *alert, NSInteger buttonIndex) {
                if (buttonIndex == alert.cancelButtonIndex) {
                    [self.navigationController popViewControllerAnimated:YES];
                }
            }];
        } else if ([result isEqualToString:@"20"]) {
            [HudHelper showHudWithMessage:@"手机号已被使用" toView:self.view];
        } else if ([result isEqualToString:@"40"]) {
            [HudHelper showHudWithMessage:@"身份证已被使用" toView:self.view];
        }
        else {
            [HudHelper showHudWithMessage:@"系统错误" toView:self.view];
        }
    } failure:^(NSString *errorMessage) {
        sender.enabled = YES;
        [HudHelper showHudWithMessage:errorMessage toView:self.view];
    }];
}
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
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 11;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 1.0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 1.0;
}

#pragma mark textField delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark 身份证验证
- (BOOL) validateIdentityCard: (NSString *)value
{
    BOOL flag;
    if (value.length <= 0) {
        flag = NO;
        return flag;
    }
    NSString *regex2 = @"^(\\d{14}|\\d{17})(\\d|[xX])$";
    NSPredicate *identityCardPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex2];
    return [identityCardPredicate evaluateWithObject:value];
}
#pragma mark 驾驶证验证
- (BOOL) driverCardCard: (NSString *)value
{
    BOOL flag;
    if (value.length <= 0) {
        flag = NO;
        return flag;
    }
    NSString *regex2 = @"^(\\d{14}|\\d{17})(\\d|[xX])$";
    NSPredicate *identityCardPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex2];
    return [identityCardPredicate evaluateWithObject:value];
}
@end
