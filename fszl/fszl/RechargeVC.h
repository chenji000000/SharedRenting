//
//  RechargeVC.h
//  fszl
//
//  Created by aqin on 4/9/15.
//  Copyright (c) 2015 huqin. All rights reserved.
//  充值

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, PaymentType) {
    UnionPay     = 1 ,   //银联支付
    WeChatPay    = 2 ,   //微信支付
    AliPay       = 3    //支付宝支付

};

//充值界面
@interface RechargeVC : UITableViewController

@property (nonatomic) PaymentType paymentType;  //用户选择的充值方式

@end
