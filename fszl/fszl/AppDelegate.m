//
//  AppDelegate.m
//  fszl
//
//  Created by huqin on 12/29/14.
//  Copyright (c) 2014 huqin. All rights reserved.
//

#import "AppDelegate.h"
#import "AFNetworking.h"
#import "BMapKit.h"
#import "SocketManager.h"
#import "AccountManger.h"

#import "alipay/AlixPayResult.h"
#import "DataSigner.h"
#import "DataVerifier.h"
#import "alipay/PartnerConfig.h"
#import <AlipaySDK/AlipaySDK.h>

#import "Define.h"
#import "JSenPayEngine.h"

@implementation AppDelegate
{
    BMKMapManager* _mapManager;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSLog(@"%s",__func__);
    //百度地图初始化
    _mapManager = [[BMKMapManager alloc]init];
#if ZFB
    BOOL ret = [_mapManager start:@"8RCsoY6PGvBNyoTKead6i4bF" generalDelegate:nil];
#elif JTB
    BOOL ret = [_mapManager start:@"4Kl5M51BqKqYqm8N89x2uv2f" generalDelegate:nil];
#else
    BOOL ret = [_mapManager start:@"nUYc43KjgFu0oiFf8W4SGxz4" generalDelegate:nil];
#endif
    if (!ret) {
        NSLog(@"manager start failed!");
    }
    
    //微信appID注册
    BOOL wxRet = [WXApi registerApp:kWXAppID withDescription:@"wxpay"];
    if (!wxRet) {
        NSLog(@"微信注册失败");
    }else
    {
        NSLog(@"微信注册成功");
    }
    
    [JSenPayEngine connectAliPayWithSchema:kAppSchema partner:PartnerID seller:SellerID RSAPrivateKey:PartnerPrivKey RSAPublicKey:AlipayPubKey];
    
    //监控网络是否连接
    AFNetworkReachabilityManager *afNetworkReachabilityManager = [AFNetworkReachabilityManager sharedManager];
    [afNetworkReachabilityManager startMonitoring];
    
    // 处理iOS8本地推送不能收到的问题
    NSString * sysVersion=[[UIDevice currentDevice]systemVersion];
    if ([sysVersion floatValue]>=8.0) {
        UIUserNotificationType type=UIUserNotificationTypeBadge | UIUserNotificationTypeAlert | UIUserNotificationTypeSound;
        UIUserNotificationSettings *setting=[UIUserNotificationSettings settingsForTypes:type categories:nil];
        [[UIApplication sharedApplication]registerUserNotificationSettings:setting];
    } else {
        NSString *message = [NSString stringWithFormat:@"您的系统为%@，本APP在iOS8以下系统下运行时会出现闪退，请先升级您的系统再使用",sysVersion];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:message delegate:nil cancelButtonTitle:@"好" otherButtonTitles: nil];
        [alert show];
    }
//    [UINavigationBar appearance].barTintColor = [UIColor colorWithRed:135.0f/255.0f green:206.0f/255.0f blue:235.0f/255.0f alpha:0.8f];//设置导航栏与状态栏背景图片
//    [UITabBar appearance].barTintColor = [UIColor colorWithRed:135.0f/255.0f green:206.0f/255.0f blue:235.0f/255.0f alpha:0.8f];//设置标签栏背景图片
    return YES;
}

-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提醒" message:notification.alertBody delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil];
    [alertView show];
}
    /*
//    UINavigationBar *appearance = [UINavigationBar appearance];
//    // 设置导航条背景颜色，在iOS7才这么用
//    [appearance setBarTintColor:[UIColor colorWithRed:0.291 green:0.607 blue:1.000 alpha:1.000]];
//    // 设置导航条的返回按钮或者系统按钮的文字颜色，在iOS7才这么用
//    [appearance setTintColor:[UIColor whiteColor]];
//    // 设置导航条的title文字颜色，在iOS7才这么用
//    [appearance setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
//                                        [UIColor whiteColor], NSForegroundColorAttributeName,  nil]];//[UIFont systemFontOfSize:17], NSFontAttributeName,
     */
-(BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url{
    return [WXApi handleOpenURL:url delegate:self];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    NSLog(@"source app-%@, des app-%@",sourceApplication,application);
    
    if ([sourceApplication isEqualToString:@"com.tencent.xin"]) {
        return [WXApi handleOpenURL:url delegate:self];
    }
    else if ([sourceApplication isEqualToString:@"com.alipay.safepayclient"]) {
        [self parse:url application:application];
        return YES;
    }
    return YES;
    
}

- (void)parse:(NSURL *)url application:(UIApplication *)application {
    
    //结果处理
    AlixPayResult* result = [self handleOpenURL:url];
    
    if (result)
    {
        
        if (result.statusCode == 9000)
        {
            /*
             *用公钥验证签名 严格验证请使用result.resultString与result.signString验签
             */
            
            //交易成功
            // NSString* key = @"签约帐户后获取到的支付宝公钥";
            id<DataVerifier> verifier;
            verifier = CreateRSADataVerifier(AlipayPubKey);
            
            if ([verifier verifyString:result.resultString withSign:result.signString])
            {
                //验证签名成功，交易结果无篡改
                
            }
            
        }
        else
        {
            //交易失败
        }
    }
    else
    {
        //失败
    }
    
}

- (AlixPayResult *)resultFromURL:(NSURL *)url {
    NSString * query = [[url query] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    return [[AlixPayResult alloc] initWithString:query];
    
}

- (AlixPayResult *)handleOpenURL:(NSURL *)url {
    AlixPayResult * result = nil;
    
    if (url != nil && [[url host] compare:@"safepay"] == 0) {
        result = [self resultFromURL:url];
    }
    
    return result;
}

-(void)onReq:(BaseReq *)req{
    
}


- (void)onResp:(BaseResp *)resp
{
    NSLog(@"%@",resp);
    if ([resp isKindOfClass:[PayResp class]]) {
        
        NSString *strTitle = [NSString stringWithFormat:@"支付结果"];
        NSString *strMsg = [NSString stringWithFormat:@"errcode:%d", resp.errCode];
        if (resp.errCode == 0) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:strTitle message:@"支付成功" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }else
        {
        
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:strTitle
                                                        message:strMsg
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
            [alert show];
        }
        
    }
}



- (void)applicationWillResignActive:(UIApplication *)application{
    NSLog(@"%s",__func__);
    [[SocketManager sharedInstance] disConnect];
}

- (void)applicationDidEnterBackground:(UIApplication *)application{
    NSLog(@"%s",__func__);
    [[SocketManager sharedInstance] disConnect];
}

- (void)applicationWillEnterForeground:(UIApplication *)application{
    NSLog(@"%s",__func__);
}

- (void)applicationDidBecomeActive:(UIApplication *)application{
    NSLog(@"%s",__func__);
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"Password"] != nil) {
        [AccountManger sharedInstance].loginName = [[NSUserDefaults standardUserDefaults] valueForKey:@"LoginName"];
        [[SocketManager sharedInstance] bind];
    }
    //发送通知 在HomeVC接受通知 用于重新开始滚动提示动画
    NSNotification *notification = [NSNotification notificationWithName:@"appDidBecomeActive" object:nil];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

- (void)applicationWillTerminate:(UIApplication *)application{
    NSLog(@"%s",__func__);
    [[SocketManager sharedInstance] disConnect];
}

@end
