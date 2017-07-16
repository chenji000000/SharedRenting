//
//  PaymentHelper.m
//  fszl
//
//  Created by aqin on 4/9/15.
//  Copyright (c) 2015 huqin. All rights reserved.
//

#import "PaymentHelper.h"
#import "AFNetworking.h"
#import "Address.h"

@implementation PaymentHelper

+(void)getTNfromWXpayWithMemberAccount:(NSString *)memberAccount memberID:(NSString *)memberID loginName:(NSString *)loginName paymentType:(NSString *)paymentType amount:(NSString *)amount success:(void (^)(NSString *))success failure:(void (^)(NSString *))failure
{
    if ([[AFNetworkReachabilityManager sharedManager] isReachable] == NO) {
        if (failure) {
            failure(@"请打开网络请求");
        }
        return;
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer.timeoutInterval = 10;
    
    NSInteger money = [amount doubleValue] * 100;
    NSString *param = [NSString stringWithFormat:@"{memberAccount:\"%@\",paymentType:\"%@\",txnAmt:\"%ld\",memberID:\"%@\",loginName:\"%@\"}",memberAccount,paymentType,(long)money,memberID,loginName];
    
    NSDictionary *post = @{
                           @"param" : param
                           };
    [manager POST:UPPayURL parameters:post success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
        NSLog(@"json :%@", json);
        NSString *tn = nil;
        NSArray *arr = [json allKeys];
        for (NSString *str in arr) {
            if ([str isEqualToString:@"tn"]) {
                tn = json[str];
            }
        }
        NSLog(@"tn = %@", tn);
        success(tn);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error: %@", error);
        NSData *errorData = error.userInfo[@"com.alamofire.serialization.response.error.data"];
        NSString *errorString = [[NSString alloc] initWithData:errorData encoding:NSUTF8StringEncoding];
        NSLog(@"failure: %@ %@", error, errorString);
        
        NSString * errorMessage;
        if (error.code == -1001)
        {
            errorMessage = @"请求超时";
        }
        else if(error.code == -1004)
        {
            errorMessage = @"未能连接到服务器";
        }
        else
        {
            errorMessage = [NSString stringWithFormat:@"连接失败[%ld]",(long)error.code];
        }
        
        if (failure) {
            failure(errorMessage);
        }
        
    }];

}

//支付宝接口,获取TN
+(void)getTNfromAlipayWithMemberAccount:(NSString *)memberAccount memberID:(NSString *)memberID loginName:(NSString *)loginName paymentType:(NSString *)paymentType amount:(NSString *)amount success:(void (^)(NSString *))success failure:(void (^)(NSString *))failure
{
    if ([[AFNetworkReachabilityManager sharedManager] isReachable] == NO) {
        if (failure) {
            failure(@"请打开网络连接");
        }
        return;
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer.timeoutInterval = 10;
    
    NSInteger money = [amount doubleValue] * 100;
    NSString *param = [NSString stringWithFormat:@"{memberAccount:\"%@\",paymentType:\"%@\",txnAmt:\"%ld\",memberID:\"%@\",loginName:\"%@\"}",memberAccount,paymentType,(long)money,memberID,loginName];
    
    NSDictionary *post = @{
                           @"param" : param
                           };
    [manager POST:UPPayURL parameters:post success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
        NSLog(@"json :%@", json);
        NSString *tn = nil;
        NSArray *arr = [json allKeys];
        for (NSString *str in arr) {
            if ([str isEqualToString:@"tn"]) {
                tn = json[str];
            }
        }
        NSLog(@"tn = %@", tn);
        success(tn);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error: %@", error);
        NSData *errorData = error.userInfo[@"com.alamofire.serialization.response.error.data"];
        NSString *errorString = [[NSString alloc] initWithData:errorData encoding:NSUTF8StringEncoding];
        NSLog(@"failure: %@ %@", error, errorString);
        
        NSString * errorMessage;
        if (error.code == -1001)
        {
            errorMessage = @"请求超时";
        }
        else if(error.code == -1004)
        {
            errorMessage = @"未能连接到服务器";
        }
        else
        {
            errorMessage = [NSString stringWithFormat:@"连接失败[%ld]",(long)error.code];
        }
        
        if (failure) {
            failure(errorMessage);
        }

    }];
}

//银联接口，获取TN
+(void) getTNfromUPPayWithMemberAccount:(NSString *)memberAccount
                               memberID:(NSString *)memberID
                              loginName:(NSString *)loginName
                            paymentType:(NSString *)paymentType
                                 amount:(NSString *)amount
                                success:(void (^)(NSString *tn))success
                                failure:(void (^)(NSString * errorMessage))failure
{
    if ([[AFNetworkReachabilityManager sharedManager] isReachable] == NO)
    {
        if (failure) {
            failure(@"请打开网络连接");
        }
        return;
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer.timeoutInterval = 10;
    
    NSInteger money = [amount doubleValue] * 100;
    NSString *param = [NSString stringWithFormat:@"{memberAccount:\"%@\",paymentType:\"%@\",txnAmt:\"%ld\",memberID:\"%@\",loginName:\"%@\"}",memberAccount,paymentType,(long)money,memberID,loginName];
    
    NSDictionary *post = @{
                           @"param" : param
                           };
    
    [manager POST:UPPayURL
       parameters:post
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSDictionary *json = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
              NSLog(@"json :%@",json);
              NSString *tn = nil;
              NSArray *arr = [json allKeys];
              for (NSString *str in arr) {
                  if ([str isEqualToString:@"tn"]) {
                      tn = json[str];
                  }
              }
              NSLog(@"tn = %@",tn);
              success(tn);
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"error: %@",error);
              NSData *errorData = error.userInfo[@"com.alamofire.serialization.response.error.data"];
              NSString *errorString = [[NSString alloc]initWithData:errorData encoding:NSUTF8StringEncoding];
              NSLog(@"failure: %@ %@",error,errorString);
              
              NSString * errorMessage;
              if (error.code == -1001)
              {
                  errorMessage = @"请求超时";
              }
              else if(error.code == -1004)
              {
                  errorMessage = @"未能连接到服务器";
              }
              else
              {
                  errorMessage = [NSString stringWithFormat:@"连接失败[%ld]",(long)error.code];
              }
              
              if (failure) {
                  failure(errorMessage);
              }
          }];
}

//银联Demo接口，获取tn
+(void) getTNfromUPPayDemoWithSuccess:(void (^)(NSString *tn))success
                              failure:(void (^)(NSString * errorMessage))failure
{
    if ([[AFNetworkReachabilityManager sharedManager] isReachable] == NO)
    {
        if (failure) {
            failure(@"请打开网络连接");
        }
        return;
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer.timeoutInterval = 10;
    
    [manager GET:UPPayDemoURL
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSString * tn = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
             NSLog(@"tn = %@",tn);
             if (success) {
                 success(tn);
             }
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"error: %@",error);
             NSData *errorData = error.userInfo[@"com.alamofire.serialization.response.error.data"];
             NSString *errorString = [[NSString alloc]initWithData:errorData encoding:NSUTF8StringEncoding];
             NSLog(@"failure: %@ %@",error,errorString);
             
             NSString * errorMessage;
             if (error.code == -1001)
             {
                 errorMessage = @"请求超时";
             }
             else if(error.code == -1004)
             {
                 errorMessage = @"未能连接到服务器";
             }
             else
             {
                 errorMessage = [NSString stringWithFormat:@"连接失败[%ld]",(long)error.code];
             }
             if (failure) {
                 failure(errorMessage);
             }

         }];
}

@end
