//
//  UsersClauseVC.m
//  fszl
//
//  Created by YF-IOS on 15/4/20.
//  Copyright (c) 2015年 huqin. All rights reserved.
//  会员协议

#import "UsersClauseVC.h"

@interface UsersClauseVC ()
{
    UIWebView *_webView;//显示PDF
}

@end

@implementation UsersClauseVC

- (void)viewDidLoad {
    [super viewDidLoad];
    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"hyxy" ofType:@"pdf"];
    NSURL *url = [NSURL fileURLWithPath:path];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [_webView loadRequest:request];
    _webView.scalesPageToFit = YES;
    [self.view addSubview:_webView];
    
    //修改返回键样式
    UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Back"] style:UIBarButtonItemStylePlain target:self action:@selector(popToLastViewController)];
    self.navigationItem.leftBarButtonItem = back;
}
- (void)popToLastViewController {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
