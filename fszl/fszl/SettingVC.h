//
//  SettingVC.h
//  fszl
//
//  Created by huqin on 2/26/15.
//  Copyright (c) 2015 huqin. All rights reserved.
//  设置

#import <UIKit/UIKit.h>

//该类是设置界面的VC
@interface SettingVC : UITableViewController

@end

/* 调用方法

 SettingVC *settingVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Storyboard_Setting"];
 [self.navigationController pushViewController:settingVC animated:YES];

 */