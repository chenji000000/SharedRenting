//
//  DingCheVC.m
//  fszl
//
//  Created by huqin on 10/5/14.
//  Copyright (c) 2014 huqin. All rights reserved.
//

#import "DingCheVC.h"
#import "DingCheMapVC.h"
#import "DingCheListVC.h"
#import "ReserveVehicleSignal.h"
#import "DCBookWithoutPriceVC.h"
#import "DCBookWithPriceVC.h"
#import "AccountManger.h"

@interface DingCheVC ()<UIAlertViewDelegate>

@property (nonatomic, assign) BOOL isShowingMap;//YES表示Map，NO表示List
@property (nonatomic,strong) DingCheMapVC *mapVC;
@property (nonatomic,strong) DingCheListVC *listVC;

@end

@implementation DingCheVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    self.mapVC = (DingCheMapVC *)self.childViewControllers[0];
    self.mapVC.networkInfoArray = self.networkInfoArray;
    self.listVC = (DingCheListVC *)[self.storyboard instantiateViewControllerWithIdentifier:@"Storyboard_DingCheList"];
    self.listVC.networkInfoArray = self.networkInfoArray;
    self.isShowingMap = YES;
    NSLog(@"signal %@",[ReserveVehicleSignal sharedInstance].vehicleTypeName);
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"Password"] != nil && [AccountManger sharedInstance].memberId != nil) {
        if (!([ReserveVehicleSignal sharedInstance].vehicleTypeName == NULL)) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"您有未提交成功的订车记录，是否需要使用" delegate:self cancelButtonTitle:@"重新订车" otherButtonTitles:@"立即使用",nil];
            [alertView show];
        }
    }
    
    //修改返回键样式
    UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Back"] style:UIBarButtonItemStylePlain target:self action:@selector(popToLastViewController)];
    self.navigationItem.leftBarButtonItem = back;
}
- (void)popToLastViewController {
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - UIAlertView Delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == alertView.firstOtherButtonIndex) {
        //进入下一个界面
#if ZFB
        DCBookWithoutPriceVC *yuDingVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Storyboard_DCBookWithoutPrice"];
        [self.navigationController pushViewController:yuDingVC animated:YES];
#else
        DCBookWithPriceVC *yuDingVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Storyboard_DCBookWithPrice"];
        [self.navigationController pushViewController:yuDingVC animated:YES];
#endif
    }
    if (buttonIndex == alertView.cancelButtonIndex) {
        [ReserveVehicleSignal sharedInstance].vehicleTypeName = nil ;
    }
}
- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//切换地图界面和列表界面
- (IBAction)switchVC:(UIBarButtonItem *)sender{
    sender.enabled = NO;
    UIViewController *newController;
    UIViewController *oldController;
    //动画效果（左翻、右翻）
    UIViewAnimationOptions animationOption;
    
    if (self.isShowingMap == YES) {
//        self.navigationItem.rightBarButtonItem.image = [UIImage imageNamed:@"map"];
        self.navigationItem.rightBarButtonItem.title = @"地图显示";
        self.isShowingMap = NO;
        newController = self.listVC;
        oldController = self.mapVC;
        animationOption = UIViewAnimationOptionTransitionFlipFromLeft;
    } else {
//        self.navigationItem.rightBarButtonItem.image = [UIImage imageNamed:@"list"];
        self.navigationItem.rightBarButtonItem.title = @"列表显示";
        self.isShowingMap = YES;
        newController = self.mapVC;
        oldController = self.listVC;
        animationOption = UIViewAnimationOptionTransitionFlipFromRight;
    }
    newController.view.frame = oldController.view.frame;
    [oldController willMoveToParentViewController:nil];
    [self addChildViewController:newController];
    
    [self transitionFromViewController:oldController toViewController:newController duration:0.6 options:animationOption animations:^{ } completion:^(BOOL finished) {
        [oldController removeFromParentViewController];
        [newController didMoveToParentViewController:self];
        sender.enabled = YES;
    }];
}

@end
