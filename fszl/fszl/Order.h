//
//  Order.h
//  fszl
//
//  Created by huqin on 1/16/15.
//  Copyright (c) 2015 huqin. All rights reserved.
//

typedef NS_ENUM(NSInteger, OrderStatus) {
    OrderStatusUnchecked = 1, //政府版未审核
    OrderStatusDidTakeCar = 2,//已经取车，订单生效
    OrderStatusDidReturnCar = 3,//已经还车，订单完成
    OrderStatusDidCancelOrder = 4,//退订
    OrderStatusRejected = 5,//政府版审核未通过
    OrderStatusPassed = 6,//普通版已经预订可取车 政府版审核通过可取车 OrderStatusUnpayed = 7,//普通版未支付
    OrderStatusChanged = 7
};


#import <Foundation/Foundation.h>

//该类定义了订单
@interface Order : NSObject

@property (nonatomic,strong) NSString * orderID;
@property (nonatomic,strong) NSString * memberID;;
@property (nonatomic,strong) NSString * generateTime;
@property (nonatomic,strong) NSString * vehicleTypeID;
@property (nonatomic,strong) NSString * vehicleNo;
@property (nonatomic,strong) NSString * valuationType;
@property (nonatomic,strong) NSString * expectTakeTime;
@property (nonatomic,strong) NSString * expectReturnTime;
@property (nonatomic,strong) NSString * renewReturnTime;
@property (nonatomic,strong) NSString * estimatedCosts;//预计费用
@property (nonatomic,strong) NSString * renewCosts;
@property (nonatomic,strong) NSString * status;
@property (nonatomic,strong) NSString * realCosts;//实际消费
@property (nonatomic,strong) NSString * systemNO;//系统编号
@property (nonatomic,strong) NSString * RealTakeTime;
@property (nonatomic,strong) NSString * RealReturnTime;


@property (nonatomic,strong) NSString *qrCode;
//显示用
@property (nonatomic,strong) NSString *loginName;
@property (nonatomic,strong) NSString *vehicleTypeName;
@property (nonatomic,strong) NSString *networkName;

@end

//{"OrderID":"20150306165046859","MemberID":"106","GenerateTime":"2015-3-6 16:51:33","FailureTime":"1900-1-1 0:00:00","VehicleTypeID":"6","VehicleNo":"鄂ASF888","ValuationType":"1","ExpectTakeTime":"2015-3-6 16:51:33","ExpectReturnTime":"2015-3-6 16:51:33","RenewReturnTime":"1900-1-1 0:00:00","RealTakeTime":"2015-3-6 16:51:33","RealReturnTime":"2015-3-6 17:31:56","EstimatedCosts":"12.00","RenewCosts":"","RealCosts":"0.00","Status":"2","UnsubscribeSubmitTime":"","UnsubscribeFinishTime":""},
