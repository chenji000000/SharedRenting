//
//  SocketManager.h
//  fszl
//
//  Created by huqin on 1/13/15.
//  Copyright (c) 2015 huqin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Order.h"

@protocol SocketManagerDelegate <NSObject>
@optional
//网络错误
- (void)didFailToConnect:(NSString *)failMessage;

//收到取车结果（signalName分别是takeCar、takeCarReply）
//- (void)didGetTakeCarResult:(NSDictionary *)jsonResult;
- (void)didGetAnotherTakeCarResult:(NSDictionary *)jsonResult;

//收到还车结果（signalName是returnCarReply）
- (void)didGetReturnCarResult:(NSDictionary *)jsonResult;

//收到开门结果（signalName是pushDoorReply）
- (void)didGetOpenDoorReply:(NSDictionary *)jsonResult;

//收到关门结果（signalName是shutDownReply）
- (void)didGetCloseDoorReply:(NSDictionary *)jsonResult;
@end


@interface SocketManager : NSObject

//单例
+ (instancetype)sharedInstance;

//delegate
@property (nonatomic, weak) id <SocketManagerDelegate>delegate;
//绑定
- (void) bind;
//断开连接
- (void) disConnect;
//取车
- (void) takeCar:(Order *)order;
//还车
- (void) returnCar:(Order *)order;
//开门
- (void) openDoor:(Order *)order;
//关门
- (void) closeDoor:(Order *)order;
@end
