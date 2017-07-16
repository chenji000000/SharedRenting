//
//  RechargeVC.m
//  fszl
//
//  Created by aqin on 4/9/15.
//  Copyright (c) 2015 huqin. All rights reserved.
//  充值

#import "RechargeVC.h"
#import "HudHelper.h"
#import "PaymentHelper.h"
#import "UPPayPlugin.h"
#import "AccountManger.h"

#import "Address.h"

#import "JSenPayEngine.h"

@interface RechargeVC ()<UPPayPluginDelegate>

@property (weak, nonatomic) IBOutlet UITextField *amountTextfield;
@property (weak, nonatomic) IBOutlet UIButton *rechargeButton;//充值按钮

@end

@implementation RechargeVC
{
    NSString *rechargeButtonTitle;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"充值";
    
    //修改返回键样式
    UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Back"] style:UIBarButtonItemStylePlain target:self action:@selector(popToLastViewController)];
    self.navigationItem.leftBarButtonItem = back;
}
- (void)popToLastViewController {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //隐藏底部标签栏  
//    self.tabBarController.tabBar.hidden = YES;
    if (self.paymentType == UnionPay) {
        rechargeButtonTitle = @"银联充值";
    } else if (self.paymentType == AliPay) {
        rechargeButtonTitle = @"支付宝充值";
    } else {
        rechargeButtonTitle = @"微信充值";
    }
    [self.rechargeButton setTitle:rechargeButtonTitle forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

//调整session header的高度
- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 12.0;//CGFLOAT_MIN;
}

//收起键盘
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.amountTextfield resignFirstResponder];
}

//银联支付
- (IBAction)rechargeWithUPPay:(UIButton *)sender{
    [self.amountTextfield resignFirstResponder];
    if (self.paymentType == UnionPay) {
        //检查金额
        if ([self.amountTextfield.text doubleValue] == 0) {
            [HudHelper showHudWithMessage:@"请输入金额" toView:self.view];
            return;
        }
        [HudHelper showProgressHudWithMessage:@"处理中…" toView:self.view];
        NSString *memberAccount = [AccountManger sharedInstance].memberAccount;
        NSLog(@"MemberAccount:%@",memberAccount);
        NSString *memberID = [AccountManger sharedInstance].memberId;
        NSString *loginName = [AccountManger sharedInstance].loginName;
        NSString *amount = self.amountTextfield.text;
        sender.enabled = NO;
        [PaymentHelper getTNfromUPPayWithMemberAccount:memberAccount memberID:memberID loginName:loginName paymentType:@"1" amount:amount success:^(NSString *tn) {
            sender.enabled = YES;
            [HudHelper hideHudToView:self.view];
            //跳转银联支付页面
            [UPPayPlugin startPay:tn mode:@"00" viewController:self delegate:self];
        } failure:^(NSString *errorMessage) {
            sender.enabled = YES;
            [HudHelper showHudWithMessage:errorMessage toView:self.view];
        }];
    }else if (self.paymentType == WeChatPay) {
        if ([WXApi isWXAppInstalled]) {
            if ([self.amountTextfield.text doubleValue] == 0) {
                [HudHelper showHudWithMessage:@"请输入金额" toView:self.view];
                return;
            }
            [HudHelper showHudWithMessage:@"处理中…" toView:self.view];
            NSString *memberAccount = [AccountManger sharedInstance].memberAccount;
            NSLog(@"MemberAccount:%@",memberAccount);
            NSString *memberID = [AccountManger sharedInstance].memberId;
            NSString *loginName = [AccountManger sharedInstance].loginName;
            NSString *amount = self.amountTextfield.text;
            sender.enabled = NO;
            [PaymentHelper getTNfromWXpayWithMemberAccount:memberAccount memberID:memberID loginName:loginName paymentType:@"2" amount:amount success:^(NSString *tn) {
                sender.enabled = YES;
                [HudHelper hideHudToView:self.view];
                //跳转微信支付界面
//                tn = [tn substringFromIndex:2];
                if (!tn || tn.length <= 0) {
                    [HudHelper showHudWithMessage:@"订单创建失败" toView:self.view];
                }else
                {
                    [[JSenPayEngine sharePayEngine] wxPayAction:tn];
                }
                
            } failure:^(NSString *errorMessage) {
                sender.enabled = YES;
                [HudHelper showHudWithMessage:errorMessage toView:self.view];
            }];
        }else
        {
            [HudHelper showHudWithMessage:@"请安装微信应用" toView:self.view];
        }
    }else if (self.paymentType == AliPay) {
        if ([self.amountTextfield.text doubleValue] == 0) {
            [HudHelper showHudWithMessage:@"请输入金额" toView:self.view];
            return;
        }
        [HudHelper showHudWithMessage:@"处理中…" toView:self.view];
        NSString *memberAccount = [AccountManger sharedInstance].memberAccount;
        NSLog(@"MemberAccount:%@", memberAccount);
        NSString *memberID = [AccountManger sharedInstance].memberId;
        NSString *loginName = [AccountManger sharedInstance].loginName;
        NSString *amount = self.amountTextfield.text;
        sender.enabled = NO;
        [PaymentHelper getTNfromAlipayWithMemberAccount:memberAccount memberID:memberID loginName:loginName paymentType:@"3" amount:amount success:^(NSString *tn) {
            //
            sender.enabled = YES;
            [HudHelper hideHudToView:self.view];
            //跳转支付宝支付界面
            if (!tn || tn.length <= 0) {
                [HudHelper showHudWithMessage:@"订单创建失败" toView:self.view];
            }else
            {
                NSString *orderId = tn;
                
                NSDictionary *dict = @{
                                       kOrderID : orderId,
                                       kTotalAmount : self.amountTextfield.text,
                                       kProductDescription:[NSString stringWithFormat:@"%@%@",memberID,loginName],
                                       kProductName:@"账户充值",
                                       kNotifyURL:[NSString stringWithFormat:@"%@EVTPaymentService/payment/handlerRechargeNotify.do",kPictureService]
                                       };
                [JSenPayEngine paymentWithInfo:dict result:^(int statusCode, NSString *statusMessage, NSString *resultString, NSError *error, NSData *data) {
                    NSLog(@"statusCode=%d \n statusMessage=%@ \n resultString=%@ \n err=%@ \n data=%@",statusCode,statusMessage,resultString,error,data);
                }];

            }
        
            
        } failure:^(NSString *errorMessage) {
            //
            sender.enabled = YES;
            [HudHelper showHudWithMessage:errorMessage toView:self.view];
        }];
    }
    else {
        [HudHelper showHudWithMessage:@"目前只实现银联充值" toView:self.view];
    }
    
    /*
    //银联Demo获取tn
    [PaymentHelper getTNfromUPPayDemoWithSuccess:^(NSString *tn)
    {
        //跳转银联支付页面
        [UPPayPlugin startPay:tn mode:@"01" viewController:self delegate:self];
    } failure:^(NSString *errorMessage)
    {
        [HudHelper showHudWithMessage:errorMessage toView:self.view];
    }];
     */
}

#pragma mark UPPayPluginResult 支付结果
//支付结果
- (void)UPPayPluginResult:(NSString *)result{
    self.amountTextfield.text = @"";
    NSLog(@"%@",result);
    
    //支付成功（手机侧？后台处？）
    if ([result isEqualToString:@"success"]) {
        [HudHelper showHudWithMessage:@"付款成功！到账时间可能会有延迟" toView:self.view];
        [self performSelector:@selector(back) withObject:nil afterDelay:1.0f];
    }
    //支付取消
    if ([result isEqualToString:@"cancel"]) {
        [HudHelper showHudWithMessage:@"您取消了充值！" toView:self.view];
    }
    //支付失败
    if ([result isEqualToString:@"fail"]) {
        [HudHelper showHudWithMessage:@"充值失败！" toView:self.view];
    }
}
- (void) back {
    [self.navigationController popViewControllerAnimated:YES];
}



@end
