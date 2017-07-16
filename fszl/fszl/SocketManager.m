//
//  SocketManager.m
//  fszl
//
//  Created by huqin on 1/13/15.
//  Copyright (c) 2015 huqin. All rights reserved.
//

#import "SocketManager.h"
#import "GCDAsyncSocket.h"
#import "AccountManger.h"
#import "ReserveVehicleSignal.h"
#import "Address.h"
#import "AppDelegate.h"
#import "LoginVC.h"

NSString *const socketQueueName = @"socketQueue";

@interface SocketManager()<GCDAsyncSocketDelegate,UIAlertViewDelegate>

@property (nonatomic,strong) GCDAsyncSocket *asyncSocket;

@property (nonatomic) BOOL bindStatus;
@property (nonatomic) BOOL willBind;

@property (nonatomic) BOOL willTakeCar;
@property (nonatomic,strong) Order *takeCarOrder;

@property (nonatomic) BOOL willReturnCar;
@property (nonatomic,strong) Order *returnCarOrder;

@property (nonatomic) BOOL willOpenDoor;
@property (nonatomic, strong) Order *openDoorOrder;

@property (nonatomic) BOOL willCloseDoor;
@property (nonatomic, strong) Order *closeDoorOrder;

@end


@implementation SocketManager

//单例
+ (instancetype)sharedInstance{
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

//lazy loading
- (GCDAsyncSocket *)asyncSocket {
    if (! _asyncSocket) {
        dispatch_queue_t socketQueue = dispatch_get_main_queue();//dispatch_queue_create([socketQueueName UTF8String], NULL);
        _asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:socketQueue];
    }
    return _asyncSocket;
}

//连接
- (void) connect{
    NSString *host = HOST;
    uint16_t port = PORT;
    
    NSLog(@"Connecting to \"%@\" on port %hu...", host, port);
    
    NSError *error = nil;
    if (![self.asyncSocket connectToHost:host onPort:port withTimeout:10.0f error:&error]){
        NSLog(@"Error connecting: %@", [error localizedDescription]);
    }
}
//断开连接
- (void) disConnect {
    if ([self.asyncSocket isConnected]) {
        [self.asyncSocket disconnect];
    }
}
//绑定
- (void) bind{
    self.willBind = YES;
    
    //已经连接
    if ([self.asyncSocket isConnected]) {
        [self sendBindMessage];
    } else {//未连接
        [self connect];
    }
}

//取车
- (void) takeCar:(Order *)order{
    self.willTakeCar = YES;
    self.takeCarOrder = order;
    
    //已经绑定
    if (self.bindStatus) {
        [self sendTakeCarMessage];
    } else {//未绑定
        self.willBind = YES;
        [self bind];
    }
}

//还车
- (void) returnCar:(Order *)order{
    self.willReturnCar = YES;
    self.returnCarOrder = order;
    
    //已经绑定
    if (self.bindStatus) {
        [self sendReturnCarMessage];
    } else {//未绑定
        self.willBind = YES;
        [self bind];
    }
}

//开门
- (void) openDoor:(Order *)order{
    self.willOpenDoor = YES;
    self.openDoorOrder = order;
    
    //已经绑定
    if (self.bindStatus) {
        [self sendOpenDoorMessage];
    } else {//未绑定
        self.willBind = YES;
        [self bind];
    }
}

//关门
- (void) closeDoor:(Order *)order{
    self.willCloseDoor = YES;
    self.closeDoorOrder = order;
    
    //已经绑定
    if (self.bindStatus) {
        [self sendCloseDoorMessage];
    } else {//未绑定
        self.willBind = YES;
        [self bind];
    }
}

//绑定消息
- (void) sendBindMessage{
    self.willBind = NO;
    self.bindStatus = YES;
    
    NSString * str = [NSString stringWithFormat:@"{\"key\":\"client_bind\",\"sender\":\"\",\"sendType\":\"1\",\"receiver\":\"null\",\"timestamp\":\"%ld\",\"identifying\":\"\",\"data\":{\"deviceModel\":\"%@\",\"channel\":\"IOS\",\"account\":\"%@\",\"deviceId\":\"%@\"}}\b",
                      (long)[[NSDate date] timeIntervalSince1970],
                      [UIDevice currentDevice].model,
                      [AccountManger sharedInstance].account,
                      [[UIDevice currentDevice].identifierForVendor UUIDString]];
    NSLog(@"%s %@",__func__,[[UIDevice currentDevice].identifierForVendor UUIDString]);
    NSData* aData= [str dataUsingEncoding: NSUTF8StringEncoding];
    [self.asyncSocket writeData:aData withTimeout:-1 tag:1];
    [self.asyncSocket readDataWithTimeout:-1 tag:0];
}

//取车消息
- (void) sendTakeCarMessage{
    NSString * str = [NSString stringWithFormat:@"{\"key\":\"client_message_lease\",\"sender\":\"\",\"sendType\":\"1\",\"receiver\":\"Data Insert Service\",\"timestamp\":\"%ld\",\"identifying\":\"\",\"data\":{\"signalName\":\"takeCar\",\"qrCode\":\"%@\",\"vehicleNo\":\"%@\",\"orderId\":\"%@\",\"account\":\"%@\"}}\b",
                      (long)[[NSDate date] timeIntervalSince1970],
                      self.takeCarOrder.qrCode,
                      self.takeCarOrder.vehicleNo,
                      self.takeCarOrder.orderID,
                      [AccountManger sharedInstance].account ];
    
    NSData* aData= [str dataUsingEncoding: NSUTF8StringEncoding];
    [self.asyncSocket writeData:aData withTimeout:-1 tag:1];
    
    self.willTakeCar = NO;
    
    [self.asyncSocket readDataWithTimeout:-1 tag:0];
}

//还车消息
- (void) sendReturnCarMessage{
    NSString * str = [NSString stringWithFormat:@"{\"key\":\"client_message_lease\",\"sender\":\"\",\"sendType\":\"1\",\"receiver\":\"Data Insert Service\",\"timestamp\":\"%ld\",\"identifying\":\"\",\"data\":{\"signalName\":\"returnCar\",\"vehicleNo\":\"%@\",\"orderId\":\"%@\",\"account\":\"%@\"}}\b",
                      (long)[[NSDate date] timeIntervalSince1970],
                      self.returnCarOrder.vehicleNo,
                      self.returnCarOrder.orderID,
                      [AccountManger sharedInstance].account ];
    
    NSData* aData= [str dataUsingEncoding: NSUTF8StringEncoding];
    [self.asyncSocket writeData:aData withTimeout:-1 tag:1];
    
    self.willReturnCar = NO;
    
    [self.asyncSocket readDataWithTimeout:-1 tag:0];
}

//开门消息
- (void) sendOpenDoorMessage{
    NSString * str = [NSString stringWithFormat:@"{\"key\":\"client_message_lease\",\"sender\":\"\",\"sendType\":\"1\",\"receiver\":\"Data Insert Service\",\"timestamp\":\"%ld\",\"identifying\":\"\",\"data\":{\"signalName\":\"openDoor\",\"vehicleNo\":\"%@\",\"account\":\"%@\"}}\b",
                      (long)[[NSDate date] timeIntervalSince1970],
                      self.openDoorOrder.vehicleNo,
                      [AccountManger sharedInstance].account ];
    
    NSData* aData= [str dataUsingEncoding: NSUTF8StringEncoding];
    [self.asyncSocket writeData:aData withTimeout:-1 tag:1];
    
    self.willOpenDoor = NO;
    
    [self.asyncSocket readDataWithTimeout:-1 tag:0];
}

//关门消息
- (void) sendCloseDoorMessage{
    NSString * str = [NSString stringWithFormat:@"{\"key\":\"client_message_lease\",\"sender\":\"\",\"sendType\":\"1\",\"receiver\":\"Data Insert Service\",\"timestamp\":\"%ld\",\"identifying\":\"\",\"data\":{\"signalName\":\"closeDoor\",\"vehicleNo\":\"%@\",\"account\":\"%@\"}}\b",
                      (long)[[NSDate date] timeIntervalSince1970],
                      self.closeDoorOrder.vehicleNo,
                      [AccountManger sharedInstance].account ];
    
    NSData* aData= [str dataUsingEncoding: NSUTF8StringEncoding];
    [self.asyncSocket writeData:aData withTimeout:-1 tag:1];
    
    self.willCloseDoor = NO;
    
    [self.asyncSocket readDataWithTimeout:-1 tag:0];
}

#pragma mark socket delegate method

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port{
	NSLog(@"socket:%p didConnectToHost:%@ port:%hu", sock, host, port);
    
    //是否需要发送绑定消息
    if (self.willBind) {
        [self sendBindMessage];
    }
}


//网络错误
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err{
    //绑定状态设置为未绑定
    self.bindStatus = NO;
    
	NSLog(@"socketDidDisconnect:%p withError: %@", sock, err);
    
    NSString *errorMessage = [NSString stringWithFormat:@"网络错误[%ld]",(long)err.code];
    if (err.code == 4) {
        errorMessage = @"未收到指定车辆的响应回复,操作超时";
    }
    [self.asyncSocket disconnect];
    if ([self.delegate respondsToSelector:@selector(didFailToConnect:)]) {
        [self.delegate didFailToConnect:errorMessage];
    }
    
}

//发送消息
- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag{
	NSLog(@"socket:%p didWriteDataWithTag:%ld", sock, tag);
    
    //是否需要发送取车消息
    if (self.willTakeCar) {
        [self sendTakeCarMessage];
    }
    //是否需要发送还车消息
    if (self.willReturnCar) {
        [self sendReturnCarMessage];
    }
    //是否需要发送开门消息
    if (self.willOpenDoor) {
        [self sendOpenDoorMessage];
    }
    //是否需要发送关门消息
    if (self.willCloseDoor) {
        [self sendCloseDoorMessage];
    }
}

//收到消息
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
	NSLog(@"socket:%p didReadData:withTag:%ld", sock, tag);
    //解析Socket消息
    NSString *dataToString = [[NSString alloc] initWithData:data  encoding:NSUTF8StringEncoding];
    //NSLog(@"dataToString:%@",dataToString);
    /*
    NSArray *array = [dataToString componentsSeparatedByString:@"\b"];
    NSLog(@"array:%@",array);
    NSString *jsonString;
    NSDictionary *jsonResult;
    for (int i = 0; i<[array count]-1; i ++) {
        jsonString = array[i];
        NSLog(@"jsonString:%@",jsonString);
        NSData *newData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        jsonResult = [NSJSONSerialization JSONObjectWithData:newData options:0 error:nil];
        NSLog(@"jsonResult:%@",jsonResult);
    }
    [self performSelectorWithJSON:jsonResult];
    */
    
    NSRange aRange = NSMakeRange(0, [dataToString length] -1);
    NSString *jsonString = [dataToString substringWithRange:aRange];
    NSLog(@"jsonString:%@",jsonString);
    NSData *newData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonResult = [NSJSONSerialization JSONObjectWithData:newData options:0 error:nil];
    NSLog(@"jsonResult:%@",jsonResult);
    [self performSelectorWithJSON:jsonResult];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self.asyncSocket readDataWithTimeout:-1 tag:0];
    });
}


-(void) performSelectorWithJSON:(NSDictionary *)jsonResult{
    NSString *result = jsonResult[@"data"][@"signalName"];
//    //如果收到取车结果消息
//    if ([jsonResult[@"data"][@"signalName"] isEqualToString:@"takeCar"])
//    {
//        if ([self.delegate respondsToSelector:@selector(didGetTakeCarResult:)])
//        {
//            [self.delegate didGetTakeCarResult:jsonResult];
//        }
//    }
    if ([result isEqualToString:@"client_bind"]) {
        if ([jsonResult[@"data"][@"value"] isEqualToString:@"1"]) {
            [self.asyncSocket disconnect];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"HH点mm分"];
            [dateFormatter setLocale:[NSLocale currentLocale]];
            NSString *time = [dateFormatter stringFromDate:[NSDate date]];
            NSString *message = [NSString stringWithFormat:@"您的账号于%@在另一个设备中登录，如非您本人操作，则密码可能已泄露，请尽快修改密码！",time];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"下线通知" message:message delegate:self cancelButtonTitle:@"退出" otherButtonTitles:nil];
            [alert show];
        }
    }
    //取车情况2
    if ([result containsString:@"takeCar"]) {
        if ([self.delegate respondsToSelector:@selector(didGetAnotherTakeCarResult:)]) {
            [self.delegate didGetAnotherTakeCarResult:jsonResult];
        }
    }
    //如果收到还车结果消息
    if ([result containsString:@"returnCar"]) {
        if ([self.delegate respondsToSelector:@selector(didGetReturnCarResult:)]) {
            [self.delegate didGetReturnCarResult:jsonResult];
        }
    }
    //如果收到开门结果消息
    if ([result isEqualToString:@"pushDoorReply"] || [result isEqualToString:@"openDoor"]) {
        if ([self.delegate respondsToSelector:@selector(didGetOpenDoorReply:)]) {
            [self.delegate didGetOpenDoorReply:jsonResult];
        }
    }
    //如果收到关门结果消息
    if ([result isEqualToString:@"shutDownReply"] || [result isEqualToString:@"closeDoor"]) {
        if ([self.delegate respondsToSelector:@selector(didGetCloseDoorReply:)]) {
            [self.delegate didGetCloseDoorReply:jsonResult];
        }
    }
}
#pragma mark alertView delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == alertView.cancelButtonIndex) {
        //删除登录信息
        [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"LoginName"];
        [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"Password"];
        [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"MemberId"];
        [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"Telephone"];
        [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"LoginStatus"];
        [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"MemberAccount"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [AccountManger sharedInstance].memberId = nil;
        [AccountManger sharedInstance].telephone = nil;
        [AccountManger sharedInstance].loginName = nil;
        [AccountManger sharedInstance].memberAccount = nil;


        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        LoginVC *loginVC = [sb instantiateViewControllerWithIdentifier:@"Storyboard_Login"];
//        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:loginVC];
        AppDelegate *app = [UIApplication sharedApplication].delegate;
        UIWindow *window = app.window;
        window.rootViewController = loginVC;
        
//        [UIView animateWithDuration:1.0f animations:^{
//            window.alpha = 0.5;
//            window.frame = CGRectMake(window.bounds.size.width, 0, 0, 0);
//        } completion:^(BOOL finished) {
//            exit(0);
//        }];
    }
}
@end

