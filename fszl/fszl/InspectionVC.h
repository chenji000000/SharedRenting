//
//  InspectionVC.h
//  fszl
//
//  Created by aqin on 3/28/15.
//  Copyright (c) 2015 huqin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Order.h"
#import "OrderVC.h"

@interface InspectionVC : UITableViewController

@property (weak, nonatomic) Order *anOrder;

@property (nonatomic, assign) OrderVCType orderType;

@end
