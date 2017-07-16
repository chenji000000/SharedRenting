//
//  BalanceRecordVC.h
//  fszl
//
//  Created by YF-IOS on 15/7/9.
//  Copyright (c) 2015年 huqin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BalanceRecordVC : UITableViewController

@property (nonatomic, copy) NSString *accountBalance;//账户余额
@property (nonatomic, strong) NSMutableArray *bizRecord;//交易记录
@property (nonatomic, assign) NSInteger page;//页数
@property (nonatomic, copy) NSString *total;//总数据量
@end
