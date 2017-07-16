//
//  OrderVC.h
//  fszl
//
//  Created by huqin on 1/16/15.
//  Copyright (c) 2015 huqin. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, OrderVCType)
{
    OrderVCTypeAll,//显示所有订单
    OrderVCTypeQuChe,//取车界面（显示预定状态的订单)
    OrderVCTypeHuanChe,//还车界面（显示订单生效状态的订单）
    OrderVCTypeTuiDing,//退订界面（显示预定状态的订单)
    OrderVCTypeXuDing,//续订界面（显示预定状态的订单)
    OrderVCTypeFinished,//历史订单界面（显示完成状态的订单)
    OrderVCTypeOpenDoor,//开门
    OrderVCTypeCloseDoor//关门
};

//该类是订单界面VC，包含取车、还车、退订、续订功能
@interface OrderVC : UITableViewController

@property (nonatomic) OrderVCType type;

@end

