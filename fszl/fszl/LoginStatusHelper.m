//
//  LoginStatusHelper.m
//  fszl
//
//  Created by YF-IOS on 15/4/15.
//  Copyright (c) 2015年 huqin. All rights reserved.
//  

#import "LoginStatusHelper.h"

@implementation LoginStatusHelper
//查看账号验证状态
+ (UIAlertView *) checkLoginStatus {
    NSString *loginStatus = [[NSUserDefaults standardUserDefaults] valueForKey:@"LoginStatus"];//账号验证状态
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提醒" message:nil delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil];
    if ([loginStatus isEqualToString:@"0"]) { // Status = 0 表示未审核
        alert.message = @"您的身份信息还未验证，您可以通过APP上传您的证件照片及个人照片等待后台人员进行验证，也可以携带个人证件前往门店验证身份信息，可在客服中心查看门店地址，若已通过验证请重新登录";
    } else if ([loginStatus isEqualToString:@"1"]) { // Status = 1 表示有效账号
        return nil;
    } else if ([loginStatus isEqualToString:@"2"]) { // Status = 2 表示注销
        alert.message = @"账号已被注销，如有疑问请联系客服";
    } else if ([loginStatus isEqualToString:@"3"]) { // Status = 3 表示黑名单
        alert.message = @"账号已加入黑名单，如有疑问请联系客服";
    } else if ([loginStatus isEqualToString:@"4"]) { // Status = 4 表示身份证审核未通过
        alert.message = @"身份证审核未通过，如有疑问请联系客服";
    } else if ([loginStatus isEqualToString:@"5"]) { // Status = 5 表示驾驶证审核未通过
        alert.message = @"驾驶证审核未通过，如有疑问请联系客服";
    } else { //其他  无效状态
        return nil;
    }
    return alert;
}


@end
