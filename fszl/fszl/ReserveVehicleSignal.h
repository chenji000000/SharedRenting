//
//  ReserveVehicleSignal.h
//  fszl
//
//  Created by huqin on 1/8/15.
//  Copyright (c) 2015 huqin. All rights reserved.
//

#import <Foundation/Foundation.h>


//该类定义了预定消息
@interface ReserveVehicleSignal : NSObject

//单例
+ (instancetype)sharedInstance;

//预定消息中的字段
@property (nonatomic, copy) NSString *networkID;
@property (nonatomic, copy) NSString *vehicleTypeID;
@property (nonatomic, copy) NSString *memberId;
@property (nonatomic, copy) NSString *expectTakeTime;
@property (nonatomic, copy) NSString *expectReturnTime;
@property (nonatomic, copy) NSString *valuationType;
@property (nonatomic, copy) NSString *estimatedCosts;
@property (nonatomic, copy) NSString *account;

@property (nonatomic, copy) NSString *companyID;

//绑定消息中的字段

@property (nonatomic, copy) NSString *deviceModel;
@property (nonatomic, copy) NSString *deviceId;

//显示用的字段
/**
 *  网点名
 */
@property (nonatomic, copy) NSString *networkName;
/**
 *  车型名
 */
@property (nonatomic, copy) NSString *vehicleTypeName;
/**
 *  车牌号
 */
@property (nonatomic, copy) NSString *vehicleNo;
/**
 *  价格策略描述
 */
@property (nonatomic, copy) NSString *valuationTypeDesc;

//政府版
@property (nonatomic, copy) NSString *driver;//司机
@property (nonatomic, copy) NSString *passenger;//同行人
@property (nonatomic, copy) NSString *reason;//用车事由
@property (nonatomic, copy) NSString *deptName;//部门

@end
