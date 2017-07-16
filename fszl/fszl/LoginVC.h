//
//  LoginVC.h
//  fszl
//
//  Created by huqin on 1/4/15.
//  Copyright (c) 2015 huqin. All rights reserved.
//  登录

#import <UIKit/UIKit.h>

typedef void(^DidLoginBlock)();

//该类是登录界面的VC
@interface LoginVC : UITableViewController

//回调Block
@property (nonatomic, copy) DidLoginBlock didLoginBlock;

@end
