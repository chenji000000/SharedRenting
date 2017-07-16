//
//  UserCenterVC.m
//  fszl
//
//  Created by huqin on 10/5/14.
//  Copyright (c) 2014 huqin. All rights reserved.
//

#import "UserCenterVC.h"
#import "AccountManger.h"
#import "LoginVC.h"
#import "OrderVC.h"
#import "RechargeVC.h"
#import "LoginStatusHelper.h"
#import "EnchashmentVC.h"
#import "ConsumeRecordVC.h"
#import "RMUniversalAlert.h"
#import "HTTPHelper.h"
#import "HudHelper.h"
#import "PaymentAccountVC.h"
#import "BalanceRecordVC.h"
#import "QRCodeVC.h"
#import "InformationVC.h"

@interface UserCenterVC ()<QRCodeVCDelegate>
{
    UIAlertView *_alert;//检查会员是否通过审核返回的内容
}

@property (weak, nonatomic) IBOutlet UILabel *loginNameLabel;

@property (weak, nonatomic) IBOutlet UIButton *loginButton;

@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;



@end

@implementation UserCenterVC

- (id)initWithStyle:(UITableViewStyle)style{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewDidLoad{
    [super viewDidLoad];
    if ([self.navigationController.viewControllers count] >1 ) {//[self.navigationController.viewControllers count]返回导航栈的视图控制器数目
        //修改返回键样式
        UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Back"] style:UIBarButtonItemStylePlain target:self action:@selector(popToLastViewController)];
        self.navigationItem.leftBarButtonItem = back;
        self.tabBarController.tabBar.hidden = YES;
    }

}
- (void)popToLastViewController {
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //显示底部标签栏
//    self.tabBarController.tabBar.hidden = NO;
    //没有登录
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"Password"] == nil && [AccountManger sharedInstance].memberId == nil) {
        [self.photoImageView setImage:[UIImage imageNamed:@"my_login_photo"]];
        self.loginButton.hidden = NO;
        self.loginNameLabel.hidden = YES;
    } else { //已经登录
        [HTTPHelper getMemberInfoWithLoginName:[AccountManger sharedInstance].loginName status:@"" equalsOrlikes:@"1" success:^(NSDictionary *jsonResult) {
            NSDictionary *member = jsonResult[@"Table"][0];
            NSString *personalIMGPath = member[@"PersonalIMGPath"];//个人照片
            if (![personalIMGPath isEqualToString:@""]) {
                [HTTPHelper getUserPictureWithImageView:self.photoImageView pictureName:personalIMGPath];
            }
        } failure:^(NSString *errorMessage) {
            [HudHelper showHudWithMessage:errorMessage toView:self.view];
        }];
        self.loginButton.hidden = YES;
        self.loginNameLabel.hidden = NO;
        self.loginNameLabel.text = [[NSUserDefaults standardUserDefaults] valueForKey:@"LoginName"];
    }
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
#if ZFB
        return 1;
#else
        return 6;
#endif
    }
    if (section == 1) {
        return 1;
    }
    if (section == 2) {
        return 1;
    }
    return 0;
}
//调整session header的高度
- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 2.0;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 2.0;
}
#pragma mark - Actions
//马上登陆按钮，点击进入登录页面
- (IBAction)loginButtonPressed:(UIButton *)sender{
    LoginVC *loginVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Storyboard_Login"];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:loginVC];
    [self presentViewController:navigationController animated:YES completion:nil];
}
//tableView delegate
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //我的资料
    if (indexPath.section == 0 && indexPath.row == 1) {
        [self getMyInformation];
    }
    //余额查询
    if (indexPath.section == 0 && indexPath.row == 2) {
        [self getMemberAccountBalance];
    }
    //充值
    if (indexPath.section == 0 && indexPath.row == 3) {
        [self recharge];
    }
    //提现
    if (indexPath.section == 0 && indexPath.row == 4) {
        [self getPaymentAccount];
    }
    //消费记录查询
//    if (indexPath.section == 0 && indexPath.row == 4) {
//        [self getCusumeRecord];
//    }
    //扫描二维码领取优惠券
    if (indexPath.section == 0 && indexPath.row == 5) {
        [self fetchCoupon];
    }
    //历史订单查询
    if (indexPath.section == 1 && indexPath.row == 0) {
        [self finishedOrderQuery];
    }
    //发票
    if (indexPath.section == 1 && indexPath.row == 1) {
//        [self tuiDing];
//        [HudHelper showAlertViewWithMessage:@"此项功能正在研发中"];
    }
//    //续订
//    if (indexPath.section == 1 && indexPath.row == 2) {
//        [self xuDing];
//    }
}
//检查是否登录
- (BOOL) checkLogin {
    //如果没有登录
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"Password"] == nil && [AccountManger sharedInstance].memberId == nil) {
        LoginVC *loginVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Storyboard_Login"];
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:loginVC];
        [self presentViewController:navigationController animated:YES completion:nil];
        return NO;
    } else {//已经登录
        //判断账号信息是否已经保存到AccountManger,未保存则保存
        if ([AccountManger sharedInstance].memberId == nil) {
            [AccountManger sharedInstance].loginName = [[NSUserDefaults standardUserDefaults] valueForKey:@"LoginName"];
            [AccountManger sharedInstance].memberId = [[NSUserDefaults standardUserDefaults] valueForKey:@"MemberId"];
            [AccountManger sharedInstance].telephone = [[NSUserDefaults standardUserDefaults] valueForKey:@"Telephone"];
            [AccountManger sharedInstance].memberAccount = [[NSUserDefaults standardUserDefaults] valueForKey:@"MemberAccount"];
        }
        return YES;
    }
}
//我的资料
- (void) getMyInformation {
    //检查是否登录
    if (![self checkLogin]) {
        return;
    }
    self.tableView.allowsSelection = NO;
    NSString *loginName = [AccountManger sharedInstance].loginName;
    [HTTPHelper getMemberInfoWithLoginName:loginName status:@"" equalsOrlikes:@"1" success:^(NSDictionary *jsonResult) {
        self.tableView.allowsSelection = YES;
        if ([jsonResult[@"Result"] isEqualToString:@"1"]) {
            InformationVC *information = [self.storyboard instantiateViewControllerWithIdentifier:@"InformationVC"];
            information.member = jsonResult[@"Table"][0];
            [self.navigationController pushViewController:information animated:YES];
        }
    } failure:^(NSString *errorMessage) {
        self.tableView.allowsSelection = YES;
        [HudHelper showHudWithMessage:errorMessage toView:self.view];
    }];
    
}
//余额查询
- (void) getMemberAccountBalance {
    //检查是否登录
    if (![self checkLogin]) {
        return;
    }
    //查看账号是否通过审核
    if ([LoginStatusHelper checkLoginStatus] != nil) {
        _alert = [LoginStatusHelper checkLoginStatus];
        [_alert show];
        return;
    }
    self.tableView.allowsSelection = NO;
    NSString *memberID = [AccountManger sharedInstance].memberId;
    [HTTPHelper getMemberAccountByMemberID:memberID success:^(NSDictionary *jsonResult) {
        if ([jsonResult[@"Result"] isEqualToString:@"1"]) {
            NSDictionary *memberAccount = jsonResult[@"Table"][0];
            NSString *balance = memberAccount[@"Balance"];
            [HTTPHelper getMemberBizRecordByMemberAccount:memberAccount[@"MemberAccount"] startDate:@"2014-01-01 00:00:00" endDate:@"2018-01-01 00:00:00" curPage:@"1" pageSize:@"10" success:^(NSDictionary *jsonResult) {
                self.tableView.allowsSelection = YES;
                BalanceRecordVC *balancerecord = [self.storyboard instantiateViewControllerWithIdentifier:@"BalanceRecordVC"];
                balancerecord.accountBalance = balance;
                if ([jsonResult[@"Result"] isEqualToString:@"1"]) {
                    NSMutableArray *bizArray = [NSMutableArray arrayWithArray:jsonResult[@"Table"]];
                    balancerecord.bizRecord = bizArray;
                    balancerecord.total = jsonResult[@"Table"][0][@"total"];
                } else {
                    balancerecord.bizRecord = [NSMutableArray arrayWithCapacity:0];
                }
                [self.navigationController pushViewController:balancerecord animated:YES];
            } failure:^(NSString *errorMessage) {
                self.tableView.allowsSelection = YES;
                NSLog(@"errorMessage = %@",errorMessage);
            }];
        }
    } failure:^(NSString *errorMessage) {
        self.tableView.allowsSelection = YES;
        [HudHelper showHudWithMessage:errorMessage toView:self.view];
    }];
}
//充值
- (void) recharge {
    //检查是否登录
    if (![self checkLogin]) {
        return;
    }
    //查看账号是否通过审核
    if ([LoginStatusHelper checkLoginStatus] != nil) {
        _alert = [LoginStatusHelper checkLoginStatus];
        [_alert show];
        return;
    }
    self.tableView.allowsSelection = NO;
    [HTTPHelper getPaymentTypeWithSuccess:^(NSDictionary *jsonResult) {
        self.tableView.allowsSelection = YES;
        NSMutableArray *nameArray = [NSMutableArray arrayWithCapacity:10];
        NSArray *array = jsonResult[@"Table"];
        for (NSDictionary *dict in array) {
            NSString *str = dict[@"PaymentTypeName"];
            [nameArray addObject:str];
        }
        //选择充值方式后进入充值页面
        [RMUniversalAlert showActionSheetInViewController:self withTitle:@"请选择充值方式" message:nil cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:nameArray popoverPresentationControllerBlock:nil tapBlock:^(RMUniversalAlert *alert, NSInteger buttonIndex) {
            RechargeVC *rechargeVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Storyboard_Recharge"];
            if (alert.firstOtherButtonIndex == buttonIndex) {
                rechargeVC.paymentType = UnionPay;
                [self.navigationController pushViewController:rechargeVC animated:YES];
            }
            if (alert.firstOtherButtonIndex + 1 == buttonIndex) {
                rechargeVC.paymentType = AliPay;
                [self.navigationController pushViewController:rechargeVC animated:YES];
            }
            if (alert.firstOtherButtonIndex + 2 == buttonIndex) {
                rechargeVC.paymentType = WeChatPay;
                [self.navigationController pushViewController:rechargeVC animated:YES];
            }
        }];
    } failure:^(NSString *errorMessage) {
        self.tableView.allowsSelection = YES;
        [HudHelper showHudWithMessage:errorMessage toView:self.view];
    }];
    
}
//提现
- (void) getPaymentAccount {
    //检查是否登录
    if (![self checkLogin]) {
        return;
    }
    //查看账号是否通过审核
    if ([LoginStatusHelper checkLoginStatus] != nil) {
        _alert = [LoginStatusHelper checkLoginStatus];
        [_alert show];
        return;
    }
    PaymentAccountVC *payment = [self.storyboard instantiateViewControllerWithIdentifier:@"PaymentAccountVC"];
    [self.navigationController pushViewController:payment animated:YES];
//    EnchashmentVC *enchashment = [self.storyboard instantiateViewControllerWithIdentifier:@"Storyboard_Enchashment"];
//    [self.navigationController pushViewController:enchashment animated:YES];
}
//领取优惠券
- (void) fetchCoupon {
    //检查是否登录
    if (![self checkLogin]) {
        return;
    }
    //查看账号是否通过审核
    if ([LoginStatusHelper checkLoginStatus] != nil) {
        _alert = [LoginStatusHelper checkLoginStatus];
        [_alert show];
        return;
    }
    //二维码
    QRCodeVC *qrVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Storyboard_QRCode"];
    qrVC.delegate = self;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:qrVC];
    [self presentViewController:navigationController animated:YES completion:nil];
}
//消费记录查询
- (void) getCusumeRecord {
    //检查是否登录
    if (![self checkLogin]) {
        return;
    }
    //查看账号是否通过审核
    if ([LoginStatusHelper checkLoginStatus] != nil) {
        _alert = [LoginStatusHelper checkLoginStatus];
        [_alert show];
        return;
    }
    //进入消费记录页面
    ConsumeRecordVC *consumeRecordVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ConsumeRecordVC"];
    [self.navigationController pushViewController:consumeRecordVC animated:YES];
}
//历史订单查询
- (void) finishedOrderQuery {
    //检查是否登录
    if (![self checkLogin]) {
        return;
    }
    //查看账号是否通过审核
    if ([LoginStatusHelper checkLoginStatus] != nil) {
        _alert = [LoginStatusHelper checkLoginStatus];
        [_alert show];
        return;
    }
    //进入历史订单页面
    OrderVC *orderVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Storyboard_Order"];
    orderVC.type = OrderVCTypeAll;
    [self.navigationController pushViewController:orderVC animated:YES];
}
//退订
- (void) tuiDing {
    //检查是否登录
    if (![self checkLogin]) {
        return;
    }
    //查看账号是否通过审核
    if ([LoginStatusHelper checkLoginStatus] != nil) {
        _alert = [LoginStatusHelper checkLoginStatus];
        [_alert show];
        return;
    }
    //进入退订页面
    OrderVC *orderVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Storyboard_Order"];
    orderVC.type = OrderVCTypeTuiDing;
    [self.navigationController pushViewController:orderVC animated:YES];
}
//续订
- (void) xuDing {
    //检查是否登录
    if (![self checkLogin]) {
        return;
    }
    //查看账号是否通过审核
    if ([LoginStatusHelper checkLoginStatus] != nil) {
        _alert = [LoginStatusHelper checkLoginStatus];
        [_alert show];
        return;
    }
    //进入续订页面
    OrderVC *orderVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Storyboard_Order"];
    orderVC.type = OrderVCTypeXuDing;
    [self.navigationController pushViewController:orderVC animated:YES];
}
#pragma mark QRCodeVCDelegate method
//处理二维码结果
- (void) didGetStringFromQRCode:(NSString *)str {
    NSArray *coupon = [str componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"#"]];
    NSString *couponName = coupon[0];
    NSString *loginName = [AccountManger sharedInstance].loginName;
    dispatch_async(dispatch_get_main_queue(), ^{
        [RMUniversalAlert showAlertInViewController:self withTitle:@"领取优惠券" message:@"您确定要领取这个优惠券吗？" cancelButtonTitle:@"不领取" destructiveButtonTitle:@"是的，领取" otherButtonTitles:nil tapBlock:^(RMUniversalAlert *alert, NSInteger buttonIndex) {
            if (buttonIndex == alert.destructiveButtonIndex) {
                [HTTPHelper fetchCouponByLoginName:loginName argQRCodeString:str success:^(NSString *result) {
                    if ([result isEqualToString:@"0"]) {
                        [HudHelper showAlertViewWithMessage:@"登录名无效"];
                    }
                    if ([result isEqualToString:@"1"]) {
                        NSString *msg = [NSString stringWithFormat:@"您成功领取到一张%@优惠券",couponName];
                        [HudHelper showAlertViewWithMessage:msg];
                    }
                    if ([result isEqualToString:@"2"]) {
                        [HudHelper showAlertViewWithMessage:@"您已领取过该优惠券"];
                    }
                    if ([result isEqualToString:@"3"]) {
                        [HudHelper showAlertViewWithMessage:@"该优惠券已过期"];
                    }
                    if ([result isEqualToString:@"4"]) {
                        [HudHelper showAlertViewWithMessage:@"系统找不到此优惠券"];
                    }
                    if ([result isEqualToString:@"5"]) {
                        [HudHelper showAlertViewWithMessage:@"非常抱歉，该优惠券已被领完"];
                    }
                    if ([result isEqualToString:@"6"]) {
                        [HudHelper showAlertViewWithMessage:@"系统错误"];
                    }
                } failure:^(NSString *errorMessage) {
                    [HudHelper showHudWithMessage:errorMessage toView:self.view];
                }];
            }
        }];
    });
}
@end
