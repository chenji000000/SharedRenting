//
//  HTTPHelper.m
//  fszl
//
//  Created by huqin on 1/6/15.
//  Copyright (c) 2015 huqin. All rights reserved.
//

#import "HTTPHelper.h"
#import "AFNetworking.h"
#import "UIImageView+AFNetworking.h"
#import "XMLParser.h"

@interface HTTPHelper ()

@end

@implementation HTTPHelper

//检查网络是否连接
+(BOOL) isNetworkConnected{
    return [[AFNetworkReachabilityManager sharedManager] isReachable];
}

//发起HTTP请求，返回值为JSON（NSDictionary）
+(void) HTTPWithUrl:(NSString *) url
               post:(NSDictionary *)post
            success:(void (^)(NSDictionary * jsonResult))success
            failure:(void (^)(NSString * errorMessage))failure
{
    if ([HTTPHelper isNetworkConnected] == NO)
    {
        if (failure) {
            failure(@"请打开网络连接");
        }
        return;
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFXMLParserResponseSerializer serializer];
    //manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
    manager.requestSerializer.timeoutInterval = 10;
    [manager POST:url
       parameters:post
          success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         XMLParser *parser = [[XMLParser alloc]init];
         NSDictionary *json = [parser parseToJson:responseObject];
         NSLog(@"%@",json);
         if (success) {
             success(json);
         }
     }
          failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSData *errorData = error.userInfo[@"com.alamofire.serialization.response.error.data"];
         NSString *errorString = [[NSString alloc]initWithData:errorData encoding:NSUTF8StringEncoding];
         NSLog(@"failure: error:%@ errorString:%@",error,errorString);
         
         NSString * errorMessage;
         if (error.code == -1001)
         {
             errorMessage = @"请求超时";
         }
         else if(error.code == -1004)
         {
             errorMessage = @"网络不通";
         }
         else
         {
             errorMessage = [NSString stringWithFormat:@"服务器未响应[%ld]",(long)error.code];
         }
         
         if (failure) {
             failure(errorMessage);
         }
     }];
}

//发起HTTP请求，返回值为NSString
+(void) HTTPWithUrl:(NSString *) url
               post:(NSDictionary *)post
  successWithString:(void (^)(NSString * result))success
            failure:(void (^)(NSString * errorMessage))failure
{
    if ([HTTPHelper isNetworkConnected] == NO)
    {
        if (failure) {
            failure(@"请打开网络连接");
        }
        return;
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFXMLParserResponseSerializer serializer];
    manager.requestSerializer.timeoutInterval = 10;
    [manager POST:url
       parameters:post
          success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         XMLParser *parser = [[XMLParser alloc]init];
         NSString *resultString = [parser parseToString:responseObject];
         NSLog(@"%@",resultString);
         if (success) {
             success(resultString);
         }
     }
          failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
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
             errorMessage = @"网络不通";
         }
         else
         {
             errorMessage = [NSString stringWithFormat:@"服务器未响应[%ld]",(long)error.code];
         }
         
         if (failure) {
             failure(errorMessage);
         }
     }];
}
//判断 手机号是否重复
+(void) isExistPhoneNumber:(NSString *)phoneNumber
                   success:(void (^)(NSString * result))success
                   failure:(void (^)(NSString * errorMessage))failure
{
    NSString *url = [kWebService stringByAppendingString:@"IsExistPhoneNumber"];
    NSDictionary *post = @{@"phoneNumber" : phoneNumber};
    [HTTPHelper HTTPWithUrl:url
                       post:post
          successWithString:^(NSString *result) {
              if (success) {
                  success(result);
              }
          }
                    failure:^(NSString *errorMessage) {
                        if (failure) {
                            failure(errorMessage);
                        }
                    }];
}

//判断 用户名是否重复
+(void) isExistLoginName:(NSString *)loginName
                 success:(void (^)(NSString * result))success
                 failure:(void (^)(NSString * errorMessage))failure
{
    
    NSString *url = [kWebService stringByAppendingString:@"IsExistLoginName"];
    NSDictionary *post = @{@"loginName" : loginName};
    [HTTPHelper HTTPWithUrl:url
                       post:post
          successWithString:^(NSString *result) {
              if (success) {
                  success(result);
              }
          }
                    failure:^(NSString *errorMessage) {
                        if (failure) {
                            failure(errorMessage);
                        }
                    }];
}

//登录
+(void) loginWithLoginName:(NSString *)loginName
                  passWord:(NSString *)passWord
                 checkType:(NSString *)checkType
              argLeaseType:(NSString *)argLeaseType
                   success:(void (^)(NSDictionary * jsonResult))success
                   failure:(void (^)(NSString * errorMessage))failure
{
    NSString *url = [kWebService stringByAppendingString:@"Login"];
    
    NSDictionary *post = @{
                           @"loginName" : loginName,
                           @"passWord" : passWord,
                           @"checkType" : checkType,
                           @"argLeaseType":argLeaseType
                           };
    
    [HTTPHelper HTTPWithUrl:url
                       post:post
                    success:^(NSDictionary *jsonResult){
                        if (success) {
                            success(jsonResult);
                        }
                    }
                    failure:^(NSString *errorMessage) {
                        if (failure) {
                            failure(errorMessage);
                        }
                    }];
}

//查询用户信息
+(void) getMemberInfoWithLoginName:(NSString *)loginName
                            status:(NSString *)status
                     equalsOrlikes:(NSString *)equalsOrlikes
                           success:(void (^)(NSDictionary * jsonResult))success
                           failure:(void (^)(NSString * errorMessage))failure
{
    NSString *url = [kWebService stringByAppendingString:@"GetMemberInfo"];
    
    NSDictionary *post = @{
                           @"loginName" : loginName,
                           @"status" : status,
                           @"equalsOrlikes" : equalsOrlikes,
                           };
    
    [HTTPHelper HTTPWithUrl:url
                       post:post
                    success:^(NSDictionary *jsonResult){
                        if (success) {
                            success(jsonResult);
                        }
                    }
                    failure:^(NSString *errorMessage) {
                        if (failure) {
                            failure(errorMessage);
                        }
                    }];
}

//注册
+(void) insertMemberInfoWithLoginName:(NSString *)loginName
                             passWord:(NSString *)passWord
                             iDCardId:(NSString *)iDCardId
                      driverLicenseNo:(NSString *)driverLicenseNo
                             trueName:(NSString *)trueName
                                  sex:(NSString *)sex
                                email:(NSString *)email
                              levelID:(NSString *)levelID
                               status:(NSString *)status
                            telephone:(NSString *)telephone
                     argIDCardIMGPath:(NSString *)argIDCardIMGPath
              argDriverLicenseIMGPath:(NSString *)argDriverLicenseIMGPath
                           bankCardNo:(NSString *)bankCardNo
                              success:(void (^)(NSString * result))success
                              failure:(void (^)(NSString * errorMessage))failure
{
    NSString *url = [kWebService stringByAppendingString:@"InsertMemberInfo"];
    
    NSDictionary *post = @{
                           @"loginName" : loginName,
                           @"passWord" : passWord,
                           @"iDCardId" : iDCardId,
                           @"driverLicenseNo" : driverLicenseNo,
                           @"trueName" : trueName,
                           @"sex" : sex,
                           @"email" : email,
                           @"levelID" : levelID,
                           @"status" : status,
                           @"telephone" : telephone,
                           @"argIDCardIMGPath" :argIDCardIMGPath,
                           @"argDriverLicenseIMGPath" :argDriverLicenseIMGPath,
                           @"BankCardNo":bankCardNo
                           };
    
    [HTTPHelper HTTPWithUrl:url
                       post:post
          successWithString:^(NSString *result){
              if (success) {
                  success(result);
              }
          }
                    failure:^(NSString *errorMessage){
                        if (failure) {
                            failure(errorMessage);
                        }
                    }];
}
//修改会员信息
+(void) updateMemberInfoByLoginName:(NSString *)loginName
                           passWord:(NSString *)passWord
                           iDCardId:(NSString *)iDCardId
                    driverLicenseNo:(NSString *)driverLicenseNo
                           trueName:(NSString *)trueName
                                sex:(NSString *)sex
                              email:(NSString *)email
                            levelID:(NSString *)levelID
                             status:(NSString *)status
                          telephone:(NSString *)telephone
                   argIDCardIMGPath:(NSString *)argIDCardIMGPath
            argDriverLicenseIMGPath:(NSString *)argDriverLicenseIMGPath
                         bankCardNo:(NSString *)bankCardNo
                            success:(void (^)(NSString * result))success
                            failure:(void (^)(NSString * errorMessage))failure
{
    NSString *url = [kWebService stringByAppendingString:@"UpdateMemberInfoByLoginName"];
    
    NSDictionary *post = @{
                           @"loginName" : loginName,
                           @"passWord" : passWord,
                           @"iDCardId" : iDCardId,
                           @"driverLicenseNo" : driverLicenseNo,
                           @"trueName" : trueName,
                           @"sex" : sex,
                           @"email" : email,
                           @"levelID" : levelID,
                           @"status" : status,
                           @"telephone" : telephone,
                           @"argIDCardIMGPath" :argIDCardIMGPath,
                           @"argDriverLicenseIMGPath" :argDriverLicenseIMGPath,
                           @"BankCardNo":bankCardNo
                           };
    
    [HTTPHelper HTTPWithUrl:url
                       post:post
          successWithString:^(NSString *result){
              if (success) {
                  success(result);
              }
          }
                    failure:^(NSString *errorMessage){
                        if (failure) {
                            failure(errorMessage);
                        }
                    }];
}

//网点信息
+(void) getServiceNetworkInfoWithNetworkName:(NSString *)networkName
                              networkAddress:(NSString *)networkAddress
                                 companyName:(NSString *)companyName
                               equalsOrlikes:(NSString *)equalsOrlikes
                                   networkID:(NSString *)networkID
                                   companyID:(NSString *)companyID
                                     success:(void (^)(NSDictionary * jsonResult))success
                                     failure:(void (^)(NSString * errorMessage))failure;
{
    NSString *url = [kWebService stringByAppendingString:@"GetServiceNetworkInfo"];
    
    NSDictionary *post = @{
                           @"networkName" : networkName,
                           @"networkAddress" : networkAddress,
                           @"companyName" : companyName,
                           @"equalsOrlikes" : equalsOrlikes,
                           @"networkID" : networkID,
                           @"companyID" : companyID
                           };
    
    [HTTPHelper HTTPWithUrl:url
                       post:post
                    success:^(NSDictionary *jsonResult){
                        if (success) {
                            success(jsonResult);
                        }
                    }
                    failure:^(NSString *errorMessage) {
                        if (failure) {
                            failure(errorMessage);
                        }
                    }];
}

//网点内车辆信息
+(void) getVehiclebyNetworkName:(NSString *)networkName
                        success:(void (^)(NSDictionary * jsonResult))success
                        failure:(void (^)(NSString * errorMessage))failure
{
    NSString *url = [kWebService stringByAppendingString:@"GetVehiclebyNetworkName"];
    
    NSDictionary *post = @{
                           @"networkName" : networkName,
                           };
    
    [HTTPHelper HTTPWithUrl:url
                       post:post
                    success:^(NSDictionary *jsonResult){
                        if (success) {
                            success(jsonResult);
                        }
                    }
                    failure:^(NSString *errorMessage) {
                        if (failure) {
                            failure(errorMessage);
                        }
                    }];
}

//获取指定时间段内的可预订车辆
+(void) getAvailableVehiclesWithNetworkName:(NSString *)argNetworkName
                                   bookTime:(NSString *)argBookTime
                                 returnTime:(NSString *)argReturnTime
                                    success:(void (^)(NSDictionary * jsonResult))success
                                    failure:(void (^)(NSString * errorMessage))failure
{
    NSString *url = [kWebService stringByAppendingString:@"GetAvailableVehicles"];
    
    NSDictionary *post = @{
                           @"argNetworkName" : argNetworkName,
                           @"argBookTime" : argBookTime,
                           @"argReturnTime" : argReturnTime,
                           };
    
    [HTTPHelper HTTPWithUrl:url
                       post:post
                    success:^(NSDictionary *jsonResult){
                        if (success) {
                            success(jsonResult);
                        }
                    }
                    failure:^(NSString *errorMessage) {
                        if (failure) {
                            failure(errorMessage);
                        }
                    }];
}

//车型详情
+(void) getVehicleTypeWithTypeName:(NSString *)typeName
                     equalsOrlikes:(NSString *)equalsOrlikes
                            typeID:(NSString *)typeID
                         companyID:(NSString *)companyID
                           success:(void (^)(NSDictionary * jsonResult))success
                           failure:(void (^)(NSString * errorMessage))failure
{
    NSString *url = [kWebService stringByAppendingString:@"GetVehicleType"];
    
    NSDictionary *post = @{
                           @"typeName" : typeName,
                           @"equalsOrlikes" : equalsOrlikes,
                           @"typeID" : typeID,
                           @"companyID" : companyID
                           };
    
    [HTTPHelper HTTPWithUrl:url
                       post:post
                    success:^(NSDictionary *jsonResult){
                        if (success) {
                            success(jsonResult);
                        }
                    }
                    failure:^(NSString *errorMessage) {
                        if (failure) {
                            failure(errorMessage);
                        }
                    }];
}

//价格策略
+(void) getPricePolicyWithTypeName:(NSString *)typeName
                 valuationTypeDesc:(NSString *)valuationTypeDesc
                            equals:(NSString *)equals
     vehicleTypeIDandValuationType:(NSString *)vehicleTypeIDandValuationType
                         companyID:(NSString *)companyID
                           success:(void (^)(NSDictionary * jsonResult))success
                           failure:(void (^)(NSString * errorMessage))failure
{
    NSString *url = [kWebService stringByAppendingString:@"GetPricePolicy"];
    
    NSDictionary *post = @{
                           @"typeName" : typeName,
                           @"valuationTypeDesc" : valuationTypeDesc,
                           @"equals" : equals,
                           @"vehicleTypeIDandValuationType" : vehicleTypeIDandValuationType,
                           @"companyID" : companyID
                           };
    
    [HTTPHelper HTTPWithUrl:url
                       post:post
                    success:^(NSDictionary *jsonResult){
                        if (success) {
                            success(jsonResult);
                        }
                    }
                    failure:^(NSString *errorMessage) {
                        if (failure) {
                            failure(errorMessage);
                        }
                    }];
}

//会员头像

+(void) getUserPictureWithImageView:(UIImageView *)imageView
                           pictureName:(NSString *) pictureName
{
    //如果开头有空格，去掉空格
    if ([pictureName hasSuffix:@" "]) {
        pictureName = [pictureName substringToIndex:(pictureName.length-1)];
    }
    NSString *str = [kPictureService stringByAppendingString:pictureName];
    NSURL *url = [NSURL URLWithString:[str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSLog(@"%@  %@",pictureName, url);
    [imageView setImageWithURL:url placeholderImage:[UIImage imageNamed:@"Camera"]];
    imageView.layer.cornerRadius = imageView.frame.size.width / 2 ;
    imageView.clipsToBounds = YES;
    imageView.layer.borderWidth = 3.0f;
    imageView.layer.borderColor = [UIColor whiteColor].CGColor;
}



//车型图片
+(void) getVehiclePictureWithImageView:(UIImageView *)imageView
                           pictureName:(NSString *) pictureName
{
    //如果开头有空格，去掉空格
    if ([pictureName hasSuffix:@" "]) {
        pictureName = [pictureName substringToIndex:(pictureName.length-1)];
    }
    NSString *str = [kPictureService stringByAppendingString:pictureName];
    NSURL *url = [NSURL URLWithString:[str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSLog(@"%@  %@",pictureName, url);
    [imageView setImageWithURL:url placeholderImage:[UIImage imageNamed:@"camera"]];
}

//上传证件照片(一张图片)
+(void)uploadPhotoByLogiName:(NSString *)loginName
                       photo:(UIImage *)photo
                   telephone:(NSString *)telephone
                        type:(NSString *)type
                     success:(void (^)(NSString * result))success
                     failure:(void (^)(NSString * errorMessage))failure {
    NSString *url = [kWebService stringByAppendingString:@"SaveFileIOS"];
    //将图片转化为base64格式编码的字符串
    NSString *base64EncodedImage = [UIImagePNGRepresentation(photo) base64EncodedStringWithOptions:0];
    
    NSDictionary *post = @{
                           @"loginName" : loginName,
                           @"img" : base64EncodedImage,
                           @"telephone" : telephone,
                           @"type" : type
                           };

    [HTTPHelper HTTPWithUrl:url post:post successWithString:^(NSString *result){
        if (success) {
            success(result);
        }
    } failure:^(NSString *errorMessage){
        if (failure) {
            failure(errorMessage);
        }
    }];
}
//上传证件照片(上传2张)
+(void)uploadTwoPhotoByLogiName:(NSString *)loginName
                    photo1:(UIImage *)photo1
                    photo2:(UIImage *)photo2
                 telephone:(NSString *)telephone
                      type:(NSString *)type
                   success:(void (^)(NSString * result))success
                   failure:(void (^)(NSString * errorMessage))failure {
    NSString *url = [kWebService stringByAppendingString:@"SaveFileIOS2"];
    //将图片转化为base64格式编码的字符串
    NSString *base64EncodedImage1 = [UIImagePNGRepresentation(photo1) base64EncodedStringWithOptions:0];
    NSString *base64EncodedImage2 = [UIImagePNGRepresentation(photo2) base64EncodedStringWithOptions:0];
    
    NSDictionary *post = @{
                           @"loginName" : loginName,
                           @"img1" : base64EncodedImage1,
                           @"img2" : base64EncodedImage2,
                           @"telephone" : telephone,
                           @"type" : type
                           };
    
    [HTTPHelper HTTPWithUrl:url post:post successWithString:^(NSString *result){
        if (success) {
            success(result);
        }
    } failure:^(NSString *errorMessage){
        if (failure) {
            failure(errorMessage);
        }
    }];
}
//根据车牌预订车辆
+(void) bookVehicleByNoWithargLoginName:(NSString *)argLoginName
                              vehicleNo:(NSString *)argVehicleNo
                          valuationType:(NSString *)argValuationType
                               takeTime:(NSString *)argTakeTime
                             returnTime:(NSString *)argReturnTime
                            orderStatus:(NSString *)argOrderStatus
                                success:(void (^)(NSDictionary * jsonResult))success
                                failure:(void (^)(NSString * errorMessage))failure
{
    NSString *url = [kWebService stringByAppendingString:@"BookVehicleByNo"];
    
    NSDictionary *post = @{
                           @"argLoginName" : argLoginName,
                           @"argVehicleNo" : argVehicleNo,
                           @"argValuationType" : argValuationType,
                           @"argTakeTime" : argTakeTime,
                           @"argReturnTime" : argReturnTime,
                           @"argOrderStatus": argOrderStatus
                           };
    
    [HTTPHelper HTTPWithUrl:url post:post success:^(NSDictionary *jsonResult){
        if (success) {
            success(jsonResult);
        }
    } failure:^(NSString *errorMessage) {
        if (failure) {
            failure(errorMessage);
        }
    }];
}
//根据车牌预订车辆2
+(void) bookVehicleByNo2WithargLoginName:(NSString *)argLoginName
                               vehicleNo:(NSString *)argVehicleNo
                           valuationType:(NSString *)argValuationType
                                takeTime:(NSString *)argTakeTime
                              returnTime:(NSString *)argReturnTime
                             orderStatus:(NSString *)argOrderStatus
                            argCouponIds:(NSString *)argCouponIds
                     argDeductibleTypeID:(NSString *)argDeductibleTypeID
                                 success:(void (^)(NSDictionary * jsonResult))success
                                 failure:(void (^)(NSString * errorMessage))failure {
    NSString *url = [kWebService stringByAppendingString:@"BookVehicleByNo2"];
    
    NSDictionary *post = @{
                           @"argLoginName" : argLoginName,
                           @"argVehicleNo" : argVehicleNo,
                           @"argValuationType" : argValuationType,
                           @"argTakeTime" : argTakeTime,
                           @"argReturnTime" : argReturnTime,
                           @"argOrderStatus": argOrderStatus,
                           @"argCouponIdsJsonString" :argCouponIds,
                           @"argDeductibleTypeID":argDeductibleTypeID
                           };
    [HTTPHelper HTTPWithUrl:url post:post success:^(NSDictionary *jsonResult) {
        if (success) {
            success(jsonResult);
        }
    } failure:^(NSString *errorMessage) {
        if (failure) {
            failure(errorMessage);
        }
    }];
}
//根据车型预订车辆
+(void) bookVehicleByTypeWithLoginName:(NSString *)argLoginName
                           networkName:(NSString *)argNetworkName
                         vehicleTypeID:(NSString *)argVehicleTypeID
                         valuationType:(NSString *)argValuationType
                              takeTime:(NSString *)argTakeTime
                            returnTime:(NSString *)argReturnTime
                           orderStatus:(NSString *)argOrderStatus
                argCouponIdsJsonString:(NSString *)argCouponIdsJsonString
                   argDeductibleTypeID:(NSString *)argDeductibleTypeID
                               success:(void (^)(NSDictionary * jsonResult))success
                               failure:(void (^)(NSString * errorMessage))failure {
    NSString *url = [kWebService stringByAppendingString:@"BookVehicleByType2"];
    NSDictionary *post = @{
                           @"argLoginName" : argLoginName,
                           @"argNetworkName" : argNetworkName,
                           @"argVehicleTypeID" : argVehicleTypeID,
                           @"argValuationType" : argValuationType,
                           @"argTakeTime" : argTakeTime,
                           @"argReturnTime" : argReturnTime,
                           @"argOrderStatus": argOrderStatus,
                           @"argCouponIdsJsonString": argCouponIdsJsonString,
                           @"argDeductibleTypeID": argDeductibleTypeID
                           };
    [HTTPHelper HTTPWithUrl:url post:post success:^(NSDictionary *jsonResult){
        if (success) {
            success(jsonResult);
        }
    } failure:^(NSString *errorMessage) {
        if (failure) {
            failure(errorMessage);
        }
    }];
}


//预订费⽤
+(void) getReservationCostWithVehicleType:(NSString *)argVehicleType
                            valuationType:(NSString *)argValuationType
                                      kms:(NSString *)argKMs
                                 takeTime:(NSString *)argTakeTime
                               returnTime:(NSString *)argReturnTime
                   argCouponIdsJsonString:(NSString *)couponIds
                      argDeductibleTypeId:(NSString *)deductibleType
                                  success:(void (^)(NSDictionary * jsonResult))success
                                  failure:(void (^)(NSString * errorMessage))failure {
    NSString *url = [kWebService stringByAppendingString:@"GetReservationCost"];
    NSDictionary *post = @{
                           @"argVehicleType" : argVehicleType,
                           @"argValuationType" : argValuationType,
                           @"argKMs" : argKMs,
                           @"argTakeTime" : argTakeTime,
                           @"argReturnTime" : argReturnTime,
                           @"argCouponIdsJsonString" :couponIds,
                           @"argDeductibleTypeId" :deductibleType
                           };
    [HTTPHelper HTTPWithUrl:url post:post success:^(NSDictionary *jsonResult){
        if (success) {
            success(jsonResult);
        }
    } failure:^(NSString *errorMessage) {
        if (failure) {
            failure(errorMessage);
        }
    }];
}
//退订
+(void) cancelReservationWithOrderID:(NSString *)argOrderID
                          cancelTime:(NSString *)argCancelTime
                             success:(void (^)(NSDictionary * jsonResult))success
                             failure:(void (^)(NSString * errorMessage))failure {
    NSString *url = [kWebService stringByAppendingString:@"CancelReservation"];
    NSDictionary *post = @{
                           @"argOrderID" : argOrderID,
                           @"argCancelTime" : argCancelTime
                           };
    [HTTPHelper HTTPWithUrl:url post:post success:^(NSDictionary *jsonResult){
        if (success) {
            success(jsonResult);
        }
    } failure:^(NSString *errorMessage) {
        if (failure) {
            failure(errorMessage);
        }
    }];
}

//退订费⽤
+(void) getCancelReservationCostWithOrderID:(NSString *)argOrderID
                                    success:(void (^)(NSDictionary * jsonResult))success
                                    failure:(void (^)(NSString * errorMessage))failure
{
    NSString *url = [kWebService stringByAppendingString:@"GetCancelReservationCost"];
    
    NSDictionary *post = @{
                           @"argOrderID" : argOrderID
                           };
    
    [HTTPHelper HTTPWithUrl:url
                       post:post
                    success:^(NSDictionary *jsonResult){
                        if (success) {
                            success(jsonResult);
                        }
                    }
                    failure:^(NSString *errorMessage) {
                        if (failure) {
                            failure(errorMessage);
                        }
                    }];
}

//续订
+(void) renewCarWithOrderID:(NSString *)argOrderID
            renewReturnTime:(NSString *)argRenewReturnTime
                   renewKMs:(NSString *)argRenewKMs
                  formerKMs:(NSString *)argformerKMs
                    success:(void (^)(NSString * result))success
                    failure:(void (^)(NSString * errorMessage))failure
{
    NSString *url = [kWebService stringByAppendingString:@"RenewCar"];
    
    NSDictionary *post = @{
                           @"argOrderID" : argOrderID,
                           @"argRenewReturnTime" : argRenewReturnTime,
                           @"argRenewKMs" : argRenewKMs,
                           @"argformerKMs" : argformerKMs
                           };
    
    [HTTPHelper HTTPWithUrl:url
                       post:post
          successWithString:^(NSString *result){
              if (success) {
                  success(result);
              }
          }
                    failure:^(NSString *errorMessage){
                        if (failure) {
                            failure(errorMessage);
                        }
                    }];
}

//续订费⽤
+(void) getRenewCostWithOrderID:(NSString *)argOrderID
                renewReturnTime:(NSString *)argRenewReturnTime
                       renewKMs:(NSString *)argRenewKMs
                      formerKMs:(NSString *)argformerKMs
                        success:(void (^)(NSDictionary * jsonResult))success
                        failure:(void (^)(NSString * errorMessage))failure
{
    NSString *url = [kWebService stringByAppendingString:@"GetRenewCost"];
    
    NSDictionary *post = @{
                           @"argOrderID" : argOrderID,
                           @"argRenewReturnTime" : argRenewReturnTime,
                           @"argRenewKMs" : argRenewKMs,
                           @"argformerKMs" : argformerKMs
                           };
    
    [HTTPHelper HTTPWithUrl:url
                       post:post
                    success:^(NSDictionary *jsonResult){
                        if (success) {
                            success(jsonResult);
                        }
                    }
                    failure:^(NSString *errorMessage) {
                        if (failure) {
                            failure(errorMessage);
                        }
                    }];
}

//客户订单查询
+(void) retrieveOrderInfoByLoginNameWithLoginName:(NSString *)argLoginName
                                         takeTime:(NSString *)argTakeTime
                                       returnTime:(NSString *)argReturnTime
                                          success:(void (^)(NSDictionary * jsonResult))success
                                          failure:(void (^)(NSString * errorMessage))failure
{
    NSString *url = [kWebService stringByAppendingString:@"RetrieveOrderInfoByLoginName"];
    
    NSDictionary *post = @{
                           @"argLoginName" : argLoginName,
                           @"argTakeTime" : argTakeTime,
                           @"argReturnTime" : argReturnTime
                           };
    
    [HTTPHelper HTTPWithUrl:url
                       post:post
                    success:^(NSDictionary *jsonResult){
                        if (success) {
                            success(jsonResult);
                        }
                    }
                    failure:^(NSString *errorMessage) {
                        if (failure) {
                            failure(errorMessage);
                        }
                    }];
}

//更新订单信息
+(void)updateOrderInfoWhenBookVehicleWithArgOrderId:(NSString *)argOrderId
                                          argReason:(NSString *)argReason
                                       argApplyDept:(NSString *)argApplyDept
                                       argPassenger:(NSString *)argPassenger
                                          argDriver:(NSString *)argDriver
                                            success:(void (^)(NSDictionary * jsonResult))success
                                            failure:(void (^)(NSString * errorMessage))failure
{
    NSString *url = [kWebServiceGov stringByAppendingString:@"UpdateOrderInfoWhenBookVehicle"];
    
    NSDictionary *post = @{
                           @"argOrderId" : argOrderId,
                           @"argReason" : argReason,
                           @"argApplyDept" : argApplyDept,
                           @"argPassenger" : argPassenger,
                           @"argDriver":argDriver
                           };
    
    [HTTPHelper HTTPWithUrl:url
                       post:post
                    success:^(NSDictionary *jsonResult){
                        if (success) {
                            success(jsonResult);
                        }
                    }
                    failure:^(NSString *errorMessage) {
                        if (failure) {
                            failure(errorMessage);
                        }
                    }];
}

//熄火判断
+(void)isAccOffSystemNOWithArgSystemNo:(NSString *)argSystemNo success:(void (^)(NSDictionary *))success failure:(void (^)(NSString *))failure
{
    NSString *url = [WebServiceBasis stringByAppendingString:@"IsAccOffBySystemNo"];

    NSDictionary *post = @{@"argSystemNo": argSystemNo};
    
    [HTTPHelper HTTPWithUrl:url post:post success:^(NSDictionary *jsonResult) {
        if (success) {
            success(jsonResult);
        }
    } failure:^(NSString *errorMessage) {
        if (failure) {
            failure(errorMessage);
        }
    }];

}

//验车信息
+(void)saveInspecttionInfoWithArgLeftFrontBackDoor:(NSString *) argLeftFrontBackDoor
                        argFrontLeafboardBothSides:(NSString *) argFrontLeafboardBothSides
                                 argLeftRearMirror:(NSString *) argLeftRearMirror
                                       argFrontBar:(NSString *) argFrontBar
                                           argHood:(NSString *) argHood
                           argRightFrontBackMirror:(NSString *) argRightFrontBackMirror
                                 argRightFrontDoor:(NSString *) argRightFrontDoor
                         argBackLeafboardBothSides:(NSString *) argBackLeafboardBothSides
                                        argBackBar:(NSString *) argBackBar
                                        argOrderId:(NSString *) argOrderId
                                 argInspectionTime:(NSString *) argInspectionTime
                                           argImg1:(UIImage *) argImg1
                                           argImg2:(UIImage *) argImg2
                                           argImg3:(UIImage *) argImg3
                                           argImg4:(UIImage *) argImg4
                                           argImg5:(UIImage *) argImg5
                                           argImg6:(UIImage *) argImg6
                                           success:(void (^)(NSString * result))success
                                           failure:(void (^)(NSString * errorMessage))failure
{
    NSString *url = [kWebServiceGov stringByAppendingString:@"SaveInspectionInfo"];
    
    NSString *img1 = [UIImagePNGRepresentation(argImg1) base64EncodedStringWithOptions:0];
    NSString *img2 = [UIImagePNGRepresentation(argImg2) base64EncodedStringWithOptions:0];
    NSString *img3 = [UIImagePNGRepresentation(argImg3) base64EncodedStringWithOptions:0];
    NSString *img4 = [UIImagePNGRepresentation(argImg4) base64EncodedStringWithOptions:0];
    NSString *img5 = [UIImagePNGRepresentation(argImg5) base64EncodedStringWithOptions:0];
    NSString *img6 = [UIImagePNGRepresentation(argImg6) base64EncodedStringWithOptions:0];
    
    NSDictionary *post = @{@"argLeftFrontBackDoor": argLeftFrontBackDoor,
                           @"argFrontLeafboardBothSides": argFrontLeafboardBothSides,
                           @"argLeftRearMirror": argLeftRearMirror,
                           @"argFrontBar": argFrontBar,
                           @"argHood": argHood,
                           @"argRightFrontBackMirror": argRightFrontBackMirror,
                           @"argRightFrontDoor": argRightFrontDoor,
                           @"argBackLeafboardBothSides": argBackLeafboardBothSides,
                           @"argBackBar": argBackBar,
                           @"argOrderId": argOrderId,
                           @"argInspectionTime": argInspectionTime,
                           @"argImg1": (img1==nil) ? @"" : img1,
                           @"argImg2": (img2==nil) ? @"" : img2,
                           @"argImg3": (img3==nil) ? @"" : img3,
                           @"argImg4": (img4==nil) ? @"" : img4,
                           @"argImg5": (img5==nil) ? @"" : img5,
                           @"argImg6": (img6==nil) ? @"" : img6};
    
    [HTTPHelper HTTPWithUrl:url
                       post:post
                    successWithString:^(NSString * result) {
                        if (success) {
                            success(result);
                        }
                    }
                    failure:^(NSString *errorMessage) {
                        if (failure) {
                            failure(errorMessage);
                        }
                    }];
}

//获取订单状态
+ (void) getOrderStatusWithArgOrderId:(NSString *) argOrderId
                              success:(void (^)(NSString * result))success
                              failure:(void (^)(NSString * errorMessage))failure
{
    NSString *url = [kWebService stringByAppendingString:@"GetOrderStatus"];
    
    NSDictionary *post = @{
                           @"argOrderId" : argOrderId
                           };
    
    [HTTPHelper HTTPWithUrl:url
                       post:post
          successWithString:^(NSString * result){
              if (success) {
                  success(result);
              }
          }
                    failure:^(NSString *errorMessage) {
                        if (failure) {
                            failure(errorMessage);
                        }
                    }];
}
#pragma mark 支付相关接口
//获取支付类型数据
+ (void) getPaymentTypeWithSuccess:(void (^)(NSDictionary *jsonResult))success
                           failure:(void (^)(NSString * errorMessage))failure {
    NSString *url = [kWebService stringByAppendingString:@"GetPaymentTypeForApp"];
    [HTTPHelper HTTPWithUrl:url post:nil success:^(NSDictionary *jsonResult) {
        if (success) {
            success(jsonResult);
        }
    } failure:^(NSString *errorMessage) {
        if (failure) {
            failure(errorMessage);
        }
    }];
}

//根据会员ID查询会员账号信息
+ (void) getMemberAccountByMemberID:(NSString *)memberID
                            success:(void (^)(NSDictionary *jsonResult))success
                            failure:(void (^)(NSString * errorMessage))failure {
    NSString *url = [kWebService stringByAppendingString:@"GetMemberAccountByMemberIDForApp"];
    NSDictionary *dict = @{@"memberID":memberID};
    [HTTPHelper HTTPWithUrl:url post:dict success:^(NSDictionary *jsonResult) {
        if (success) {
            success(jsonResult);
        }
    } failure:^(NSString *errorMessage) {
        if (failure) {
            failure(errorMessage);
        }
    }];
}
//根据会员账号查询会员支付账号
+ (void) getMemberPaymentAccountByMemberAccount:(NSString *) memberAccount
                                        success:(void (^)(NSDictionary *jsonResult))success
                                        failure:(void (^)(NSString * errorMessage))failure {
    NSString *url = [kWebService stringByAppendingString:@"GetMemberPaymentAccountByMemberAccountForApp"];
    NSDictionary *dict = @{@"memberAccount":memberAccount};
    [HTTPHelper HTTPWithUrl:url post:dict success:^(NSDictionary *jsonResult) {
        if (success) {
            success(jsonResult);
        }
    } failure:^(NSString *errorMessage) {
        if (failure) {
            failure(errorMessage);
        }
    }];
}
//根据会员账号查询交易记录表信息的分页查询
+ (void) getMemberBizRecordByMemberAccount:(NSString *)memberAccount
                                 startDate:(NSString *)start
                                   endDate:(NSString *)end
                                   curPage:(NSString *)page
                                  pageSize:(NSString *)pageSize
                                   success:(void (^)(NSDictionary *jsonResult))success
                                   failure:(void (^)(NSString * errorMessage))failure {
    NSString *url = [kWebService stringByAppendingString:@"GetMemberBizRecordByMemberAccountForApp"];
    NSDictionary *dict = @{@"memberAccount":memberAccount,
                           @"startTime":start,
                           @"endTime":end,
                           @"curPage":page,
                           @"pageSize":pageSize};
    [HTTPHelper HTTPWithUrl:url post:dict success:^(NSDictionary *jsonResult) {
        if (success) {
            success(jsonResult);
        }
    } failure:^(NSString *errorMessage) {
        if (failure) {
            failure(errorMessage);
        }
    }];
}
//根据会员账号查询会员账号消费记录的分页查询
+ (void) getMemberConsumeRecordByMemberAccount:(NSString *)memberAccount
                                     startDate:(NSString *)start
                                       endDate:(NSString *)end
                                       curPage:(NSString *)page
                                      pageSize:(NSString *)pageSize
                                       success:(void (^)(NSDictionary *jsonResult))success
                                       failure:(void (^)(NSString * errorMessage))failure {
    NSString *url = [kWebService stringByAppendingString:@"GetMemberConsumeRecordByMemberAccountForApp"];
    NSDictionary *dict = @{@"memberAccount":memberAccount,
                           @"startTime":start,
                           @"endTime":end,
                           @"curPage":page,
                           @"pageSize":pageSize};
    [HTTPHelper HTTPWithUrl:url post:dict success:^(NSDictionary *jsonResult) {
        if (success) {
            success(jsonResult);
        }
    } failure:^(NSString *errorMessage) {
        if (failure) {
            failure(errorMessage);
        }
    }];
}
//消费记录查询
+ (void) getConsumeCostHistoryByOrderId:(NSString *)orderID
                                success:(void (^)(NSDictionary *jsonResult))success
                                failure:(void (^)(NSString * errorMessage))failure {
    NSString *url = [kWebService stringByAppendingString:@"GetConsumeCostHistoryByOrderId"];
    NSDictionary *dict = @{@"argOrderId":orderID};
    [HTTPHelper HTTPWithUrl:url post:dict success:^(NSDictionary *jsonResult) {
        if (success) {
            success(jsonResult);
        }
    } failure:^(NSString *errorMessage) {
        if (failure) {
            failure(errorMessage);
        }
    }];
}
//添加会员支付账号
+ (void)createMemberPaymentAccountWithMemberAccount:(NSString *)memberAccount
                                        paymentType:(NSString *)paymentType
                                     paymentAccount:(NSString *)paymentAccount
                                            success:(void (^)(NSString *result))success
                                            failure:(void (^)(NSString * errorMessage))failure {
    NSString *url = [kWebService stringByAppendingString:@"CreateMemberPaymentAccountForApp"];
    NSDictionary *dict = @{@"memberAccount":memberAccount,
                           @"paymentType":paymentType,
                           @"paymentAccount":paymentAccount};
    [HTTPHelper HTTPWithUrl:url post:dict successWithString:^(NSString *result) {
        if (success) {
            success(result);
        }
    } failure:^(NSString *errorMessage) {
        if (failure) {
            failure(errorMessage);
        }
    }];
}
//删除会员支付账号
+ (void)delMemberPaymentAccountWithMemberAccount:(NSString *)memberAccount
                                     paymentType:(NSString *)paymentType
                                  paymentAccount:(NSString *)paymentAccount
                                         success:(void (^)(NSString *result))success
                                         failure:(void (^)(NSString * errorMessage))failure {
    NSString *url = [kWebService stringByAppendingString:@"DelMemberPaymentAccountForApp"];
    NSDictionary *dict = @{@"memberAccount":memberAccount,
                           @"paymentType":paymentType,
                           @"paymentAccount":paymentAccount};
    [HTTPHelper HTTPWithUrl:url post:dict successWithString:^(NSString *result) {
        if (success) {
            success(result);
        }
    } failure:^(NSString *errorMessage) {
        if (failure) {
            failure(errorMessage);
        }
    }];
}
//提交提现申请
+ (void)createDrawCashVerifyRecordMemberAccount:(NSString *)memberAccount
                                     memberName:(NSString *)memberName
                                        drawAmt:(NSString *)drawAmt
                                    paymentType:(NSString *)paymentType
                                 paymentAccount:(NSString *)paymentAccount
                                        success:(void (^)(NSString * result))success
                                        failure:(void (^)(NSString * errorMessage))failure {
    NSString *url = [kWebService stringByAppendingString:@"CreateDrawCashVerifyRecordForApp"];
    NSDictionary *dict = @{@"memberAccount":memberAccount,
                           @"memberName":memberName,
                           @"drawAmt":drawAmt,
                           @"paymentType":paymentType,
                           @"paymentAccount":paymentAccount};
    [HTTPHelper HTTPWithUrl:url post:dict successWithString:^(NSString *result) {
        if (success) {
            success(result);
        }
    } failure:^(NSString *errorMessage) {
        if (failure) {
            failure(errorMessage);
        }
    }];
}
//提交提现申请
+ (void)applyForDrawCashWithLoginName:(NSString *)loginName
                             argMoney:(NSString *)argMoney
                          paymentType:(NSString *)paymentType
                       paymentAccount:(NSString *)paymentAccount
                            argIDCard:(NSString *)argIDCard
                              success:(void (^)(NSString * result))success
                              failure:(void (^)(NSString * errorMessage))failure {
    NSString *url = [kWebService stringByAppendingString:@"ApplyForDrawCash"];
    NSDictionary *dict = @{@"argLoginName":loginName,
                           @"argMoney":argMoney,
                           @"argPaymentType":paymentType,
                           @"argPaymentAccount":paymentAccount,
                           @"argIDCard":argIDCard};
    [HTTPHelper HTTPWithUrl:url post:dict successWithString:^(NSString *result) {
        if (success) {
            success(result);
        }
    } failure:^(NSString *errorMessage) {
        if (failure) {
            failure(errorMessage);
        }
    }];
}
#pragma mark 优惠券
//根据优惠券ID查询优惠券
+(void) getCouponById:(NSString *)couponID
        success:(void (^)(NSDictionary *jsonResult))success
        failure:(void (^)(NSString * errorMessage))failure {
    NSString *url = [kWebService stringByAppendingString:@"GetCouponById"];
    NSDictionary *dict = @{@"argCouponId":couponID};
    [HTTPHelper HTTPWithUrl:url post:dict success:^(NSDictionary *jsonResult) {
        if (success) {
            success(jsonResult);
        }
    } failure:^(NSString *errorMessage) {
        if (failure) {
            failure(errorMessage);
        }
    }];
}
//根据登录名查询优惠券信息
+(void) getCouponByLoginName:(NSString *)loginName
                     success:(void (^)(NSDictionary *jsonResult))success
                     failure:(void (^)(NSString * errorMessage))failure {
    NSString *url = [kWebService stringByAppendingString:@"GetCouponByLoginName"];
    NSDictionary *dict = @{@"argLoginName":loginName};
    [HTTPHelper HTTPWithUrl:url post:dict success:^(NSDictionary *jsonResult) {
        if (success) {
            success(jsonResult);
        }
    } failure:^(NSString *errorMessage) {
        if (failure) {
            failure(errorMessage);
        }
    }];
}
//优惠券是否有效
+(void) isCouponValidWithCouponIDs:(NSString *)couponIDs
                         loginName:(NSString *)loginName
                           success:(void (^)(NSDictionary *jsonResult))success
                           failure:(void (^)(NSString * errorMessage))failure {
    NSString *url = [kWebService stringByAppendingString:@"IsCouponValid"];
    NSDictionary *dict = @{@"argCouponIdsJsonString":couponIDs,
                                     @"argLoginName":loginName};
    [HTTPHelper HTTPWithUrl:url post:dict success:^(NSDictionary *jsonResult) {
        if (success) {
            success(jsonResult);
        }
    } failure:^(NSString *errorMessage) {
        if (failure) {
            failure(errorMessage);
        }
    }];
}
//扫描二维码领取优惠券
+(void) fetchCouponByLoginName:(NSString *)loginName
               argQRCodeString:(NSString *)argQRCodeString
                       success:(void (^)(NSString * result))success
                       failure:(void (^)(NSString * errorMessage))failure {
    NSString *url = [kWebService stringByAppendingString:@"FetchCouponByLoginName"];
    NSDictionary *dict = @{@"argLoginName":loginName,
                           @"argQRCodeString":argQRCodeString};
    [HTTPHelper HTTPWithUrl:url post:dict successWithString:^(NSString *result) {
        if (success) {
            success(result);
        }
    } failure:^(NSString *errorMessage) {
        if (failure) {
            failure(errorMessage);
        }
    }];
}
#pragma mark - 密码与密保相关
//获取密保问题（登录名为空则返回全部问题）
+(void)getPasswordQuestionWithLoginName:(NSString *)loginName
                              loginType:(NSString *)loginType
                                success:(void (^)(NSDictionary *jsonResult))success
                                failure:(void (^)(NSString * errorMessage))failure {
    NSString *url = [kWebService stringByAppendingString:@"GetPasswordQuestion"];
    NSDictionary *dict = @{@"argLoginName":loginName,
                           @"argLoginType":loginType};
    [HTTPHelper HTTPWithUrl:url post:dict success:^(NSDictionary *jsonResult) {
        if (success) {
            success(jsonResult);
        }
    } failure:^(NSString *errorMessage) {
        if (failure) {
            failure(errorMessage);
        }
    }];
}
//验证某个用户/会员的密保问题是否有效
+(void)isValidPasswordQuestionAnswerWithLoginName:(NSString *)loginName
                                       questionID:(NSString *)questionID
                                           answer:(NSString *)answer
                                        loginType:(NSString *)loginType
                                          success:(void (^)(NSString * result))success
                                          failure:(void (^)(NSString * errorMessage))failure{
    NSString *url = [kWebService stringByAppendingString:@"IsValidPasswordQuestionAnswer"];
    NSDictionary *dict = @{@"argLoginName":loginName,
                           @"argQuestionId":questionID,
                           @"argAnswer":answer,
                           @"argLoginType":loginType};
    [HTTPHelper HTTPWithUrl:url post:dict successWithString:^(NSString *result) {
        if (success) {
            success(result);
        }
    } failure:^(NSString *errorMessage) {
        if (failure) {
            failure(errorMessage);
        }
    }];
}
//设置密保问题及答案
+(void)setPasswordQuestionWithLoginName:(NSString *)loginName
                               password:(NSString *)password
                             questionID:(NSString *)questionID
                                 answer:(NSString *)answer
                              loginType:(NSString *)loginType
                                success:(void (^)(NSString * result))success
                                failure:(void (^)(NSString * errorMessage))failure{
    NSString *url = [kWebService stringByAppendingString:@"SetPasswordQuestion"];
    NSDictionary *dict = @{@"argLoginName":loginName,
                           @"argPwd":password,
                           @"argQuestionId":questionID,
                           @"argAnswer":answer,
                           @"argLoginType":loginType};
    [HTTPHelper HTTPWithUrl:url post:dict successWithString:^(NSString *result) {
        if (success) {
            success(result);
        }
    } failure:^(NSString *errorMessage) {
        if (failure) {
            failure(errorMessage);
        }
    }];
}
//重置密码
+(void)resetPasswordWithLoginName:(NSString *)loginName
                           newPwd:(NSString *)newPassword
                        loginType:(NSString *)loginType
                          success:(void (^)(NSString * result))success
                          failure:(void (^)(NSString * errorMessage))failure{
    NSString *url = [kWebService stringByAppendingString:@"ResetPassword"];
    NSDictionary *dict = @{@"argLoginName":loginName,
                           @"argNewPwd":newPassword,
                           @"argLoginType":loginType};
    [HTTPHelper HTTPWithUrl:url post:dict successWithString:^(NSString *result) {
        if (success) {
            success(result);
        }
    } failure:^(NSString *errorMessage) {
        if (failure) {
            failure(errorMessage);
        }
    }];
}
//修改密码
+(void)changePasswordWithLoginName:(NSString *)loginName
                            oldPwd:(NSString *)oldPassword
                            newPwd:(NSString *)newPassword
                         loginType:(NSString *)loginType
                           success:(void (^)(NSString * result))success
                           failure:(void (^)(NSString * errorMessage))failure{
    NSString *url = [kWebService stringByAppendingString:@"ChangePassword"];
    NSDictionary *dict = @{@"argLoginName":loginName,
                           @"argOldPwd":oldPassword,
                           @"argNewPwd":newPassword,
                           @"argLoginType":loginType};
    [HTTPHelper HTTPWithUrl:url post:dict successWithString:^(NSString *result) {
        if (success) {
            success(result);
        }
    } failure:^(NSString *errorMessage) {
        if (failure) {
            failure(errorMessage);
        }
    }];
}
//取车时间限制
+(void)takingCarsLimitsWithOrderID:(NSString *)orderID
                              time:(NSString *)time
                           success:(void (^)(NSDictionary *jsonResult))success
                           failure:(void (^)(NSString * errorMessage))failure {
    NSString *url = [kWebService stringByAppendingString:@"TakingCarsLimits"];
    NSDictionary *dict = @{@"argOrderId":orderID,
                           @"argCurrentClientTime":time};
    [HTTPHelper HTTPWithUrl:url post:dict success:^(NSDictionary *jsonResult) {
        if (success) {
            success(jsonResult);
        }
    } failure:^(NSString *errorMessage) {
        if (failure) {
            failure(errorMessage);
        }
    }];
}

//车辆信息
+(void) getVehicleWithVehicleNo:(NSString *)vehicleNo
                    vehicleType:(NSString *)vehicleType
                    networkName:(NSString *)networkName
                  equalsOrlikes:(NSString *)equalsOrlikes
                      vehicleID:(NSString *)vehicleID
                    CompanyName:(NSString *)CompanyName
                        success:(void (^)(NSDictionary * jsonResult))success
                        failure:(void (^)(NSString * errorMessage))failure{
    NSString *url = [kWebService stringByAppendingString:@"GetVehicle"];
    NSDictionary *dict = @{@"vehicleNo":vehicleNo,
                           @"vehicleType":vehicleType,
                           @"networkName":networkName,
                           @"equalsOrlikes":equalsOrlikes,
                           @"vehicleID":vehicleID,
                           @"CompanyName":CompanyName};
    [HTTPHelper HTTPWithUrl:url post:dict success:^(NSDictionary *jsonResult) {
        if (success) {
            success(jsonResult);
        }
    } failure:^(NSString *errorMessage) {
        if (failure) {
            failure(errorMessage);
        }
    }];

}


@end

