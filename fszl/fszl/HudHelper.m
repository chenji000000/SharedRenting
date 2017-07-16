//
//  HudHelper.m
//  fszl
//
//  Created by huqin on 1/6/15.
//  Copyright (c) 2015 huqin. All rights reserved.
//

#import "HudHelper.h"
#import "MBProgressHUD.h"

@implementation HudHelper
+(void) showAlertViewWithMessage:(NSString *)message {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:message message:nil delegate:nil cancelButtonTitle:@"好" otherButtonTitles: nil];
    [alert show];
}

+(void) showHudWithMessage:(NSString *) message toView:(UIView *)view{
    //首先隐藏之前的Hud
    [MBProgressHUD hideAllHUDsForView:view animated:YES];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = message;
    hud.labelFont = [UIFont systemFontOfSize:14];
    hud.margin = 10.0f;
    hud.removeFromSuperViewOnHide = YES;
    //hud.dimBackground = YES;
    //hud.square = YES;
    [hud hide:YES afterDelay:1.2f];
}

//显示带有旋转图案的HUD，需要通过调用hideHudForView来隐藏HUD
+(void) showProgressHudWithMessage:(NSString *) message toView:(UIView *)view{
    MBProgressHUD *hud = [[MBProgressHUD alloc]initWithView:view];
    [view addSubview:hud];
    
    //延时0.1秒显示
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
    {
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.labelText = message;
        hud.labelFont = [UIFont systemFontOfSize:14];
        hud.margin = 10.f;
        hud.removeFromSuperViewOnHide = YES;
        //hud.dimBackground = YES;
        hud.square = YES;
        [hud show:YES];
    });
}

//隐藏Hud
+(void) hideHudToView:(UIView *)view{
    [MBProgressHUD hideAllHUDsForView:view animated:YES];
}

@end
