//
//  HudHelper.h
//  fszl
//
//  Created by huqin on 1/6/15.
//  Copyright (c) 2015 huqin. All rights reserved.
//

#import <Foundation/Foundation.h>

//该类提供显示HUD消息的方法
@interface HudHelper : NSObject
+(void) showAlertViewWithMessage:(NSString *)message;

//显示会自动隐藏的HUD
+(void) showHudWithMessage:(NSString *) message toView:(UIView *)view;

//显示带有旋转图案的HUD，需要通过调用hideHudForView来隐藏HUD
+(void) showProgressHudWithMessage:(NSString *) message toView:(UIView *)view;

//隐藏Hud
+(void) hideHudToView:(UIView *)view;

@end
