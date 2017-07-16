//
//  SettingVC.m
//  fszl
//
//  Created by huqin on 2/26/15.
//  Copyright (c) 2015 huqin. All rights reserved.
//  设置

#import "SettingVC.h"
#import "AccountManger.h"
#import "HudHelper.h"
#import "ChangePasswordVC.h"
#import "SetQuestionVC.h"
#import "LoginVC.h"
#import "HTTPHelper.h"
#import "RMUniversalAlert.h"
#import "SocketManager.h"

#define ZFBPlistURL      @"https://github.com/whevtapp/fszl-zfb/raw/master/fszl-zfb.plist"
#define ZFBDownloadURL   @"http://tinyurl.com/n9tmnh3"
//#define DZBPlistURL      @"https://github.com/whevtapp/fszldzb/raw/master/fszl-dzb.plist"
#define DZBPlistURL      @"https://github.com/whevtapp/fszldzb/raw/master/fszl-dzb.plist"
#define DZBDownloadURL   @"http://tinyurl.com/odfwd85"

@interface SettingVC ()<NSURLConnectionDataDelegate,NSURLConnectionDelegate>
@property (weak, nonatomic) IBOutlet UIButton *logoutButton;

@end

@implementation SettingVC
{
    NSMutableData *_versionData;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad]; 

    //设置按键样式
    self.logoutButton.backgroundColor = [UIColor clearColor];
    self.logoutButton.layer.backgroundColor = [UIColor whiteColor].CGColor;
    //self.logoutButton.layer.cornerRadius = 8;
    self.logoutButton.layer.borderColor = [UIColor redColor].CGColor;
    self.logoutButton.layer.borderWidth = 1;
    self.logoutButton.layer.masksToBounds = NO;
    
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
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 3;
}
//调整session header的高度
- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 12.0;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return CGFLOAT_MIN;//12.0;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {//设置或修改密保问题
        [self updatePasswordQuestion];
    }
    if (indexPath.row == 1) {//修改密码
        [self changePassword];
    }
    if (indexPath.row == 2) {//检查更新
        [self versionUpdate];
    }
}
//设置或修改密保问题
- (void)updatePasswordQuestion {
    if (![self checkLogin]) {
        return;
    }
    SetQuestionVC *set = [self.storyboard instantiateViewControllerWithIdentifier:@"SetQuestionVC"];
    [self.navigationController pushViewController:set animated:YES];
}
//修改密码
- (void)changePassword {
    if (![self checkLogin]) {
        return;
    }
    ChangePasswordVC *change = [self.storyboard instantiateViewControllerWithIdentifier:@"ChangePasswordVC"];
    [self.navigationController pushViewController:change animated:YES];
}
//版本检查更新
- (void) versionUpdate {
    if ([HTTPHelper isNetworkConnected]) {
        [HudHelper showProgressHudWithMessage:@"检查中..." toView:self.view];
#if ZFB
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:ZFBPlistURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:15.0];
#else
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:DZBPlistURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:15.0];
#endif
        [NSURLConnection connectionWithRequest:request delegate:self];
    } else {
        [HudHelper showHudWithMessage:@"无网络连接" toView:self.view];
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
    [HudHelper hideHudToView:self.view];
    if ([remoteVersion compare:appVersion] > 0) {
        [RMUniversalAlert showAlertInViewController:self withTitle:versionMessage message:nil cancelButtonTitle:@"暂不更新" destructiveButtonTitle:@"现在更新" otherButtonTitles:nil tapBlock:^(RMUniversalAlert *alert, NSInteger buttonIndex) {
            if (buttonIndex == alert.destructiveButtonIndex) {
                [[UIApplication sharedApplication] openURL:downloadURL];
            }
        }];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"当前已是最新版本v%@",remoteVersion] delegate:nil cancelButtonTitle:@"好" otherButtonTitles: nil];
        [alertView show];
    }
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [HudHelper hideHudToView:self.view];
    NSLog(@"error %@",[error localizedDescription]);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"没有获取到版本信息，请稍后再试" delegate:nil cancelButtonTitle:@"好" otherButtonTitles: nil];
    [alert show];
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
//登出,退出登录
- (IBAction)logoutButtonPressed:(UIButton *)sender{
    if ([AccountManger sharedInstance].memberId == nil) {
        [HudHelper showHudWithMessage:@"您还未登录" toView:self.view];
        return;
    } else {
        //删除登录信息
        [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"LoginName"];
        [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"Password"];
        [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"MemberId"];
        [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"Telephone"];
        [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"LoginStatus"];
        [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"MemberAccount"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [AccountManger sharedInstance].memberId = nil;
        [AccountManger sharedInstance].telephone = nil;
        [AccountManger sharedInstance].loginName = nil;
        [AccountManger sharedInstance].memberAccount = nil;
        [[SocketManager sharedInstance] disConnect];
        [self performSelector:@selector(back) withObject:nil afterDelay:1.2f];
        [HudHelper showHudWithMessage:@"您已退出登录" toView:self.view];
    }
}
- (void) back {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
