//
//  DingCheTypeVC.h
//  fszl
//
//  Created by huqin on 1/9/15.
//  Copyright (c) 2015 huqin. All rights reserved.
//

#import <UIKit/UIKit.h>

//该类是车型详情界面VC
@interface DingCheTypeVC : UITableViewController

//初始化用
@property (strong,nonatomic) NSDictionary *typeDict;
@property (nonatomic, copy) NSString *picture;

@end
