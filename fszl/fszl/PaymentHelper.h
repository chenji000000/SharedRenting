//
//  PaymentHelper.h
//  fszl
//
//  Created by aqin on 4/9/15.
//  Copyright (c) 2015 huqin. All rights reserved.
//

#import <Foundation/Foundation.h>

//支付接口
@interface PaymentHelper : NSObject

//银联接口，获取tn
+(void) getTNfromUPPayWithMemberAccount:(NSString *)memberAccount
                               memberID:(NSString *)memberID
                              loginName:(NSString *)loginName
                            paymentType:(NSString *)paymentType
                                 amount:(NSString *)amount
                                success:(void (^)(NSString *tn))success
                                failure:(void (^)(NSString * errorMessage))failure;

//银联Demo接口，获取tn
+(void) getTNfromUPPayDemoWithSuccess:(void (^)(NSString *tn))success
                              failure:(void (^)(NSString * errorMessage))failure;

//支付宝接口,获取tn
+(void) getTNfromAlipayWithMemberAccount:(NSString *)memberAccount
                                memberID:(NSString *)memberID
                               loginName:(NSString *)loginName
                             paymentType:(NSString *)paymentType
                                  amount:(NSString *)amount
                                 success:(void (^)(NSString *tn))success
                                 failure:(void (^)(NSString *errorMessage))failure;

//微信接口,获取tn
+(void) getTNfromWXpayWithMemberAccount:(NSString *)memberAccount
                               memberID:(NSString *)memberID
                              loginName:(NSString *)loginName
                            paymentType:(NSString *)paymentType
                                 amount:(NSString *)amount
                                success:(void (^)(NSString *tn))success
                                failure:(void (^)(NSString *errorMessage))failure;


@end
