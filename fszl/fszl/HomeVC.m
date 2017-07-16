//
//  HomeVC.m
//  fszl
//
//  Created by huqin on 1/4/15.
//  Copyright (c) 2015 huqin. All rights reserved.
//

#import "HomeVC.h"
#import "HTTPHelper.h"
#import "HudHelper.h"
#import "DingCheVC.h"
#import "AccountManger.h"
#import "LoginVC.h"
#import "OrderVC.h"
#import "LoginStatusHelper.h"
#import "RegisterVC.h"
#import "UserCenterVC.h"
#import "RMUniversalAlert.h"

#define ZFBPlistURL      @"https://github.com/whevtapp/fszl-zfb/raw/master/fszl-zfb.plist"
#define ZFBDownloadURL   @"http://tinyurl.com/n9tmnh3"
//#define DZBPlistURL      @"https://github.com/whevtapp/fszldzb/raw/master/fszl-dzb.plist"
#define DZBPlistURL      @"https://github.com/whevtapp/fszldzb/raw/master/fszl-dzb.plist"
#define DZBDownloadURL   @"http://tinyurl.com/odfwd85"

@interface HomeVC ()<NSURLConnectionDataDelegate,NSURLConnectionDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIView *middleView;
@property (weak, nonatomic) IBOutlet UIView *downView;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *logo;
@property (nonatomic) BOOL isNetWorkAvailable;
@end

@implementation HomeVC
{
    UIAlertView *_alert;//检查会员是否通过审核返回的内容
    NSMutableData *_versionData;//检查版本返回的数据
    UITapGestureRecognizer *_tap;//手势
    NSString *_markWords;//提示信息
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewDidLoad{
    [super viewDidLoad];
    NSLog(@"%@",NSStringFromCGSize(self.view.bounds.size));
    UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"app-logo"]];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:image];
    self.navigationItem.leftBarButtonItem = item;
    
    _tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapMiddleViewToRegisterVC:)];
    _tap.numberOfTapsRequired = 1;
    _tap.numberOfTouchesRequired = 1;
    //版本区分
#if ZFB //政府版
    self.imageView.image = [UIImage imageNamed:@"home-background"];
    self.middleView.backgroundColor = [UIColor colorWithRed:205.0f/255.0f green:85.0f/255.0f blue:85.0f/255.0f alpha:1.0f];
    self.navigationItem.title = @"分时租赁";
#elif JTB //集团版
    self.imageView.image = [UIImage imageNamed:@"home-dzb-background"];
    self.navigationItem.title = @"分时租赁";
#else //大众版
    self.imageView.image = [UIImage imageNamed:@"home-dzb-background"];
    self.navigationItem.title = @"分时租赁";
#endif
    //适配3.5寸屏幕
    if (self.view.frame.size.height == 480) {
        self.imageView.frame = CGRectMake(0, 64, 320, 180);
        self.middleView.frame = CGRectMake(0, 244, 320, 40);
        self.downView.frame = CGRectMake(0, 284, 320, 148);
#if ZFB
        self.imageView.image = [UIImage imageNamed:@"home-background-small"];
#elif JTB
        self.imageView.image = [UIImage imageNamed:@"home-dzb-background-small"];
#else
        self.imageView.image = [UIImage imageNamed:@"home-dzb-background-small"];
#endif
    }
    //检测版本及版本更新
    [self performSelector:@selector(checkVersion) withObject:nil afterDelay:0.5];
    //动画效果
    self.middleView.center  = CGPointMake(self.middleView.center.x, self.middleView.center.y + 200);
    self.downView.center  = CGPointMake(self.downView.center.x, self.downView.center.y + 200);
    [UIView animateWithDuration:1.0 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.middleView.center  = CGPointMake(self.middleView.center.x, self.middleView.center.y-200);
        self.downView.center  = CGPointMake(self.downView.center.x, self.downView.center.y-200);
    } completion:^(BOOL finished) {
        if (finished) {
            //检查是否自动登录，并将账号信息保存
            [self saveAccountInformation];
        }
    }];
}

//检测版本及版本更新
- (void) checkVersion {
    if ([HTTPHelper isNetworkConnected]) {
#if ZFB
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:ZFBPlistURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:15.0];
#else
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:DZBPlistURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:15.0];
#endif
        [NSURLConnection connectionWithRequest:request delegate:self];
    } else {
        NSLog(@"%s 无网络连接",__func__);
    }
}
#pragma mark - NSURLConnectionDataDelegate,NSURLConnectionDelegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    _versionData = [NSMutableData data];
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_versionData appendData:data];
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSString *appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSError *error = nil;
#if ZFB
    NSURL *downloadURL = [NSURL URLWithString:ZFBDownloadURL];
#else 
    NSURL *downloadURL = [NSURL URLWithString:DZBDownloadURL];
#endif
    NSDictionary *plist = [NSPropertyListSerialization propertyListWithData:_versionData options:NSPropertyListImmutable format:nil error:&error];
    NSDictionary *dict = plist[@"items"][0][@"metadata"];
    NSString *remoteVersion = dict[@"bundle-version"];
    NSString *message = dict[@"message"];
    NSString *msg = [message stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
    NSString *versionMessage = [NSString stringWithFormat:@"发现新版本v%@\n%@",remoteVersion,msg];
    NSLog(@"appVersion = %@ remoteVersion = %@ message: %@",appVersion,remoteVersion,versionMessage);
    if ([remoteVersion compare:appVersion] > 0) {
        [RMUniversalAlert showAlertInViewController:self withTitle:versionMessage message:nil cancelButtonTitle:@"暂不更新" destructiveButtonTitle:@"现在更新" otherButtonTitles:nil tapBlock:^(RMUniversalAlert *alert, NSInteger buttonIndex) {
            if (buttonIndex == alert.destructiveButtonIndex) {
                [[UIApplication sharedApplication] openURL:downloadURL];
            }
        }];
    }
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"error %@",[error localizedDescription]);
}

//单击手势，进入注册页面
-(void)tapMiddleViewToRegisterVC:(UITapGestureRecognizer *)recognizer {
    RegisterVC *registerVC = [self.storyboard instantiateViewControllerWithIdentifier:@"RegisterVC"];
    [self.navigationController pushViewController:registerVC animated:YES];
}
//点击右侧导航按钮进入用户中心
- (IBAction)pushToLoginVC:(UIBarButtonItem *)sender{
    LoginVC *loginVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Storyboard_Login"];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:loginVC];
    [self presentViewController:navigationController animated:YES completion:nil];
}
- (void) pushToUserCenter {
    UserCenterVC *userCenter = [self.storyboard instantiateViewControllerWithIdentifier:@"UserCenterVC"];
    [self.navigationController pushViewController:userCenter animated:YES];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //显示底部标签栏
    self.tabBarController.tabBar.hidden = NO;
    
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"Password"] == nil && [AccountManger sharedInstance].memberId == nil) {
        //登录按键
        UIBarButtonItem *loginButton = [[UIBarButtonItem alloc] initWithTitle:@"登录" style:UIBarButtonItemStylePlain target:self action:@selector(pushToLoginVC:)];
        self.navigationItem.rightBarButtonItem = loginButton;
    } else {
        UIBarButtonItem *rigthItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"home-my"] style:UIBarButtonItemStylePlain target:self action:@selector(pushToUserCenter)];
        self.navigationItem.rightBarButtonItem = rigthItem;
    }
    //注册通知  在appDidBecomeActive时重新开始提示信息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(markedWords) name:@"appDidBecomeActive" object:nil];
    [self markedWords];
}

//- (void)dealloc
//{
//    //移除通知
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"appDidBecomeActive" object:nil];
//}
//滚动提示信息
- (void) markedWords {
    NSString *str = [NSString string];
    //如果未登陆提示注册，已登录未审核提示需要审核，已审核通过提示优惠活动
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"Password"] == nil && [AccountManger sharedInstance].memberId == nil) {
        //提示用户注册
        str = @"您需要登录及完成身份信息验证后才能进行车辆预定服务(点击可进行注册)";
        [self.middleView addGestureRecognizer:_tap];
    } else if (![[[NSUserDefaults standardUserDefaults] valueForKey:@"LoginStatus"] isEqualToString:@"1"]){
        str = @"您可以上传照片或携带证件前往门店完成身份验证后才能进行车辆预定及使用";
        [self.middleView removeGestureRecognizer:_tap];
    } else {
        str = @"您可以开始进行车辆预定及使用";
        [self.middleView removeGestureRecognizer:_tap];
    }
    UIFont *font = [UIFont systemFontOfSize:16.0];
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    self.messageLabel.text = str;
    CGSize size = [self.messageLabel.text sizeWithAttributes:@{NSFontAttributeName: font}];
    CGFloat labelHeight = (self.middleView.frame.size.height-size.height) / 2;
    self.messageLabel.frame = CGRectMake(10, labelHeight, size.width, size.height);
    self.messageLabel.font = font;
    self.messageLabel.textAlignment = NSTextAlignmentLeft;
    CGRect frame = self.messageLabel.frame;
    frame.origin.x = screenSize.width;
    self.messageLabel.frame = frame;
    [UIView beginAnimations:@"testAnimation" context:NULL];
    [UIView setAnimationDuration:6.6];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationRepeatAutoreverses:NO];
    [UIView setAnimationRepeatCount:MAXFLOAT];
    frame = self.messageLabel.frame;
    frame.origin.x = -size.width;
    self.messageLabel.frame = frame;
    [UIView commitAnimations];
}
//重新打开滑动返回效果
-(void)viewWillLayoutSubviews{
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
}
- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//订车按键
- (IBAction)dingCheButtonPressed:(UIButton *)sender{
    //防止反复发出请求
    [sender setEnabled:NO];
    //显示正在加载
    [HudHelper showProgressHudWithMessage:@"正在加载..." toView:self.view];
#if ZFB
    NSString *leaseTypeID = @"2";
#else
    NSString *leaseTypeID = @"2";
#endif
    //查询网点信息
    [HTTPHelper getServiceNetworkInfoWithNetworkName:@"" networkAddress:@"" companyName:@"" equalsOrlikes:@"" networkID:@"" companyID:@"" success:^(NSDictionary * jsonResult) {
        [sender setEnabled:YES];
        NSLog(@"%@",jsonResult);
        if ([jsonResult[@"Result"] isEqualToString: @"1"]) {//成功
            [HudHelper hideHudToView:self.view];
            //进入下一个界面
            DingCheVC *dingCheVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Storyboard_DingChe"];
            NSMutableArray *arr = [NSMutableArray arrayWithCapacity:1];
            for (NSDictionary *network in jsonResult[@"Table"]) {
                if ([network[@"LeaseTypeID"] isEqualToString:leaseTypeID]) {
                    [arr addObject:network];
                }
            }
            dingCheVC.networkInfoArray = arr;
//            dingCheVC.networkInfoArray = jsonResult[@"Table"];
            [self.navigationController pushViewController:dingCheVC animated:YES];
        } else {//失败
            [HudHelper showHudWithMessage:@"网点信息错误" toView:self.view];
        }
    } failure:^(NSString *errorMessage) {//网络问题
        [sender setEnabled:YES];
        [HudHelper showHudWithMessage:errorMessage toView:self.view];
    }];
}
//取车按键
- (IBAction)quCheButtonPressed:(UIButton *)sender{
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
    OrderVC *orderVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Storyboard_Order"];
    orderVC.type = OrderVCTypeQuChe;
    [self.navigationController pushViewController:orderVC animated:YES];
}
//还车按键
- (IBAction)huanCheButtonPressed:(UIButton *)sender {
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
    OrderVC *orderVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Storyboard_Order"];
    orderVC.type = OrderVCTypeHuanChe;
    [self.navigationController pushViewController:orderVC animated:YES];
}
//更多操作按键
- (IBAction)gengduoButtonPressed:(UIButton *)sender {
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
    [RMUniversalAlert showAlertInViewController:self withTitle:@"操作列表" message:nil cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@[@"开门", @"锁门", @"退订", @"续订"] tapBlock:^(RMUniversalAlert *alert, NSInteger buttonIndex) {
        OrderVC *orderVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Storyboard_Order"];
        if (alert.firstOtherButtonIndex == buttonIndex) {
            orderVC.type = OrderVCTypeOpenDoor;
            [self.navigationController pushViewController:orderVC animated:YES];
        }
        if (alert.firstOtherButtonIndex + 1 == buttonIndex) {
            orderVC.type = OrderVCTypeCloseDoor;
            [self.navigationController pushViewController:orderVC animated:YES];
        }
        if (alert.firstOtherButtonIndex + 2 == buttonIndex) {
            orderVC.type = OrderVCTypeTuiDing;
            [self.navigationController pushViewController:orderVC animated:YES];
        }
        if (alert.firstOtherButtonIndex + 3 == buttonIndex) {
            orderVC.type = OrderVCTypeXuDing;
            [self.navigationController pushViewController:orderVC animated:YES];
        }
    }];
}
//检查是否登录
- (BOOL) checkLogin{
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
//检查是否自动登录，并将账号信息保存
- (void) saveAccountInformation{
    //密码已经保存到NSUserDefaults则表示用户选择记住密码并自动登录
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"Password"] != nil) {
        //账号信息保存到AccountManger
        [AccountManger sharedInstance].loginName = [[NSUserDefaults standardUserDefaults] valueForKey:@"LoginName"];
        [AccountManger sharedInstance].memberId = [[NSUserDefaults standardUserDefaults] valueForKey:@"MemberId"];
        [AccountManger sharedInstance].telephone = [[NSUserDefaults standardUserDefaults] valueForKey:@"Telephone"];
        [AccountManger sharedInstance].memberAccount = [[NSUserDefaults standardUserDefaults] valueForKey:@"MemberAccount"];
    }
}

@end
