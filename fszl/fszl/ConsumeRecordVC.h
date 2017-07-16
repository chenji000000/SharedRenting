//
//  ConsumeRecordVC.h
//  fszl
//
//  Created by YF-IOS on 15/5/19.
//  Copyright (c) 2015年 huqin. All rights reserved.
//  消费记录

#import <UIKit/UIKit.h>
#import "Order.h"

@interface ConsumeRecordVC : UITableViewController

@property (nonatomic, strong) NSDictionary *consumeRecord;//一个订单的费用记录
@property (nonatomic, strong) Order *order;//当前订单

@end
