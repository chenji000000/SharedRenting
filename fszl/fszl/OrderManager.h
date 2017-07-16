//
//  OrderManager.h
//  fszl
//
//  Created by huqin on 1/16/15.
//  Copyright (c) 2015 huqin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Order.h"

//该类管理订单信息
@interface OrderManager : NSObject

//单例，用户名为初始化参数
//+ (instancetype)sharedInstanceWithLoginName:(NSString *)loginName;

//初始化方法
- (instancetype) initWithLoginName:(NSString *)loginName;

//所有订单
@property (nonatomic,strong,readonly) NSArray *allOrderArray;

//取车用的订单(订单状态为OrderStatusUnchecked)
@property (nonatomic,strong,readonly) NSArray *quCheOrderArray;

//退订用的订单(订单状态为1预定)，和取车用的订单相同   ##需要修改
@property (nonatomic,strong,readonly) NSArray *tuiDingOrderArray;

//还车用的订单(订单状态为OrderStatusDidTakeCar)
@property (nonatomic,strong,readonly) NSArray *huanCheOrderArray;

//续订用的订单(订单状态为OrderStatusDidTakeCar)，和还车用的订单相同
@property (nonatomic,strong,readonly) NSArray *xuDingOrderArray;

//完成的订单(订单状态为OrderStatusDidReturnCar)
@property (nonatomic,strong,readonly) NSArray *finishedOrderArray;

//开门的订单 与还车订单相同
@property (nonatomic,strong,readonly) NSArray *openDoorOrderArray;

//关门的订单 与还车订单相同
@property (nonatomic,strong,readonly) NSArray *closeDoorOrderArray;

//预定成功后，添加订单
-(void) addNewOrder:(Order *)newOrder;

//取车成功后，根据orderId，将订单状态修改为2订单生效
-(void) takeCar:(NSString *)orderId;

//退订成功后，根据orderId，将订单状态修改为4退订
-(void)cancelReservation:(NSString *)orderId;

//还车成功后，根据orderId，将订单状态修改为3订单完成
-(void) returnCar:(NSString *)orderId;

//续订成功后，根据orderId，修改renewReturnTime和renewCosts（反复续订问题？expectReturnTime？、estimatedCosts？）
-(void) renewCar:(NSString *)orderId withRenewReturnTime:(NSString *)renewReturnTime;

//删除一条订单
-(void) removeAnOrder:(NSString *)orderId;

//删除所有订单
-(void) removeAll;

//关闭订单提醒功能
@property (nonatomic) BOOL disableReminder;

//更新订单（将服务器下载得到的订单更新到手机）
-(void) downloadOrders:(NSArray *)array;

@end
