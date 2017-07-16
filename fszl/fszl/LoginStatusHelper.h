//
//  LoginStatusHelper.h
//  fszl
//
//  Created by YF-IOS on 15/4/15.
//  Copyright (c) 2015年 huqin. All rights reserved.
//  帮助查看账号是否通过审核

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface LoginStatusHelper : NSObject

//检查账号是否通过审核
+ (UIAlertView *) checkLoginStatus;

@end
