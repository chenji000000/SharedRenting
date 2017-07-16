//
//  OrderManager.m
//  fszl
//
//  Created by huqin on 1/16/15.
//  Copyright (c) 2015 huqin. All rights reserved.
//

#import "OrderManager.h"
#import "DateHelper.h"

@interface OrderManager()

@property (nonatomic,strong) NSMutableArray *orderArray;
//@property (nonatomic,strong) NSString *loginName;

@end

@implementation OrderManager
{
    NSString *_loginName;
}

//单例，用户名为初始化参数
//+ (instancetype)sharedInstanceWithLoginName:(NSString *)loginName
//{
//    static id sharedInstance = nil;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        sharedInstance = [[self alloc] initWithLoginName:loginName];
//    });
//    return sharedInstance;
//}

- (instancetype) initWithLoginName:(NSString *)loginName{
    if ((self = [super init])) {
        _loginName = loginName;
        NSData *serialized = [[NSUserDefaults standardUserDefaults] objectForKey:loginName];
        _orderArray = [[NSKeyedUnarchiver unarchiveObjectWithData:serialized] mutableCopy];
        if (_orderArray == nil) {
            _orderArray = [NSMutableArray arrayWithCapacity:1];
        }
    }
    return self;
}

- (void) saveData{
    NSData *serialized = [NSKeyedArchiver archivedDataWithRootObject:self.orderArray];
    [[NSUserDefaults standardUserDefaults] setObject:serialized forKey:_loginName];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    //设置提醒
    [self setupReminder];
}

//所有订单
-(NSArray *)allOrderArray{
#if ZFB
    //政府版订单具有所有状态
    return [self.orderArray copy];
#else
    //大众版订单不含有OrderStatusUnchecked OrderStatusRejected
    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:1];
    for (Order * anOrder in self.orderArray) {
        if ([anOrder.status integerValue] != OrderStatusUnchecked && [anOrder.status integerValue] != OrderStatusRejected) {
            [arr addObject:anOrder];
        }
    }
    return [arr copy];
#endif
}

//取车用的订单(订单状态为OrderStatusUnchecked)
-(NSArray *)quCheOrderArray{
    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:1];
    for (Order * anOrder in self.orderArray) {
#if ZFB
        if ([anOrder.status integerValue] == OrderStatusUnchecked || [anOrder.status integerValue] == OrderStatusPassed|| [anOrder.status integerValue] == OrderStatusRejected)
#else
        if ([anOrder.status integerValue] == OrderStatusPassed)
#endif
        {
            [arr addObject:anOrder];
        }
    }
    return [arr copy];
}

//退订，与取车订单相同
-(NSArray *)tuiDingOrderArray{
    return [self quCheOrderArray];
}

//还车用的订单(订单状态为OrderStatusDidTakeCar)
-(NSArray *)huanCheOrderArray{
    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:1];
    for (Order * anOrder in self.orderArray) {
        if ([anOrder.status integerValue] == OrderStatusDidTakeCar) {
            [arr addObject:anOrder];
        }
    }
    return [arr copy];
}

//开门用订单 与还车订单相同 订单状态未已取车
- (NSArray *)openDoorOrderArray{
    return [self huanCheOrderArray];
}

//关门用订单 与还车订单相同
- (NSArray *)closeDoorOrderArray{
    return [self huanCheOrderArray];
}

//续订 与还车订单相同 ??(还车订单与取车订单都能续订)
-(NSArray *)xuDingOrderArray{
//    NSMutableArray *quCheArray = [NSMutableArray arrayWithArray:[self quCheOrderArray]];
//    [quCheArray addObjectsFromArray:[self huanCheOrderArray]];
//    return [quCheArray copy];
    return [self huanCheOrderArray];
}

//完成的订单(订单状态为OrderStatusDidReturnCar) //??改为所有订单
-(NSArray *)finishedOrderArray{
    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:1];
    for (Order * anOrder in self.orderArray) {
        if ([anOrder.status integerValue] == OrderStatusDidReturnCar) {
            [arr addObject:anOrder];
        }
    }
    return [arr copy];
}

//预定成功后，添加订单
-(void) addNewOrder:(Order *)newOrder{
    [self.orderArray insertObject:newOrder atIndex:0];
    [self saveData];
}

//取车成功后，根据orderId，将订单状态修改为2订单生效
-(void) takeCar:(NSString *)orderId{
    for (Order * anOrder in self.orderArray) {
        if ([anOrder.orderID isEqualToString:orderId]) {
            anOrder.status = @"2";
            [self saveData];
            return;
        }
    }
}

//退订成功后，根据orderId，将订单状态修改为4退订
-(void)cancelReservation:(NSString *)orderId{
    for (Order * anOrder in self.orderArray) {
        if ([anOrder.orderID isEqualToString:orderId]) {
            anOrder.status = @"4";
            [self saveData];
            return;
        }
    }
}

//还车成功后，根据orderId，将订单状态修改为3订单完成
-(void) returnCar:(NSString *)orderId{
    for (Order * anOrder in self.orderArray) {
        if ([anOrder.orderID isEqualToString:orderId]) {
            anOrder.status = @"3";
            [self saveData];
            return;
        }
    }
}

//续订成功后，根据orderId，修改renewReturnTime和renewCosts（反复续订问题？expectReturnTime？、estimatedCosts？）
-(void) renewCar:(NSString *)orderId withRenewReturnTime:(NSString *)renewReturnTime{
    for (Order *anOrder in self.orderArray) {
        if ([anOrder.orderID isEqualToString:orderId]) {
            anOrder.expectReturnTime = renewReturnTime;
            anOrder.renewReturnTime = renewReturnTime;
            [self saveData];
            return;
        }
    }
}

//删除一条订单
-(void) removeAnOrder:(NSString *)orderId{
    for (Order * anOrder in self.orderArray) {
        if ([anOrder.orderID isEqualToString:orderId]) {
            [self.orderArray removeObject:anOrder];
            [self saveData];
            return;
        }
    }
}

//删除所有订单
-(void) removeAll{
    self.orderArray = [NSMutableArray arrayWithCapacity:1];
    [self saveData];
}

//设置订单提醒
-(void) setupReminder{
    //清空以前设置的提醒
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    //如果打开了提醒功能
    if(!self.disableReminder) {
        UILocalNotification * localNotification;
        NSDate * reminderTime;
        //添加取车提醒、订单过期提醒
        for (Order *order in [self quCheOrderArray]) {
            //取车前15分钟
            reminderTime = [[DateHelper getDateFromString: order.expectTakeTime] dateByAddingTimeInterval: - 15 * 60];
            //提醒时间未到
            if ([reminderTime compare:[NSDate date]] == NSOrderedDescending) {
                localNotification = [[UILocalNotification alloc] init];
#if ZFB  //政府版
                localNotification.alertBody = [NSString stringWithFormat:@"您预计15分钟后取车，请合理安排时间！"];
#else  //大众版和集团版
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"MM月dd日HH时mm分"];
                [formatter setLocale:[NSLocale currentLocale]];
                NSString *time = [formatter stringFromDate:reminderTime];
                localNotification.alertBody = [NSString stringWithFormat:@"【逸享租车】您预订的车牌号为%@的车辆取车时间为%@，根据预定时间段，您可以提前15分钟取车，延时5分钟还车，而不产生其他费用。车辆地址:%@，祝您用车愉快!",order.vehicleNo,time,order.networkName];
#endif
                localNotification.soundName = UILocalNotificationDefaultSoundName;
                localNotification.fireDate = reminderTime;
                [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
            }
            //还车前15分钟
            reminderTime = [[DateHelper getDateFromString: order.expectReturnTime] dateByAddingTimeInterval: - 15 * 60];
            //提醒时间未到
            if ([reminderTime compare:[NSDate date]] == NSOrderedDescending) {
                localNotification = [[UILocalNotification alloc] init];
                localNotification.alertBody = [NSString stringWithFormat:@"您的订单将在15分钟后过期，您还未取车，请合理安排时间，以免造成损失！"];
                localNotification.soundName = UILocalNotificationDefaultSoundName;
                localNotification.fireDate = reminderTime;
                [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
            }
        }
        //添加还车提醒
        for (Order *order in [self huanCheOrderArray]) {
            reminderTime = [[DateHelper getDateFromString: order.expectReturnTime] dateByAddingTimeInterval: - 15 * 60];
            //提醒时间未到
            if ([reminderTime compare:[NSDate date]] == NSOrderedDescending) {
                localNotification = [[UILocalNotification alloc] init];
                localNotification.alertBody = [NSString stringWithFormat:@"还车提醒：您计划将在15分钟后还车"];
                localNotification.soundName = UILocalNotificationDefaultSoundName;
                localNotification.fireDate = reminderTime;
                [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
            }
        }
    }
}

-(void) setDisableReminder:(BOOL)disableReminder{
    _disableReminder = disableReminder;
    [self setupReminder];
}

//更新订单（将服务器下载得到的订单更新到手机）
-(void) downloadOrders:(NSArray *)array{
//    self.orderArray = [NSMutableArray arrayWithCapacity:1];
    [self.orderArray removeAllObjects]; 
    for (NSDictionary *dict in array) {
        Order * anOrder = [[Order alloc]init];
        anOrder.orderID = dict[@"OrderID"];
        anOrder.memberID = dict[@"MemberID"];
        anOrder.generateTime = dict[@"GenerateTime"];
        anOrder.vehicleTypeID = dict[@"VehicleTypeID"];
        anOrder.vehicleNo = dict[@"VehicleNo"];
        anOrder.valuationType = dict[@"ValuationType"];
        anOrder.expectTakeTime = dict[@"ExpectTakeTime"];
        anOrder.expectReturnTime = dict[@"ExpectReturnTime"];
        anOrder.renewReturnTime = dict[@"RenewReturnTime"];
        anOrder.estimatedCosts = dict[@"EstimatedCosts"];
        anOrder.renewCosts = dict[@"RenewCosts"];
        anOrder.status = dict[@"Status"];
        anOrder.vehicleTypeName = dict[@"vehicleTypeName"];
        anOrder.networkName = dict[@"NetworkName"];
        anOrder.realCosts = dict[@"RealCosts"];
        anOrder.systemNO = dict[@"SystemNo"];
        anOrder.RealReturnTime = dict[@"RealReturnTime"];
        anOrder.RealTakeTime = dict[@"RealTakeTime"];
        anOrder.loginName = [[NSUserDefaults standardUserDefaults] valueForKey:@"LoginName"];
        
        [self.orderArray insertObject:anOrder atIndex:0];
    }
    NSComparisonResult (^sortByOrderID)(Order *, Order *) = ^(Order *obj1, Order *obj2) {
        return [obj2.orderID compare:obj1.orderID];
    };
    [self.orderArray sortUsingComparator:sortByOrderID];
    [self saveData];
}


@end