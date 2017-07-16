//
//  HTTPHelper.h
//  fszl
//
//  Created by huqin on 1/6/15.
//  Copyright (c) 2015 huqin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Address.h"

//该类管理所有HTTP请求
@interface HTTPHelper : NSObject

//检查网络是否连接
+(BOOL) isNetworkConnected;
//判断 手机号是否重复
+(void) isExistPhoneNumber:(NSString *)phoneNumber
                   success:(void (^)(NSString * result))success
                   failure:(void (^)(NSString * errorMessage))failure;
//判断 用户名是否重复
+(void) isExistLoginName:(NSString *)loginName
                 success:(void (^)(NSString * result))success
                 failure:(void (^)(NSString * errorMessage))failure;
//登录
+(void) loginWithLoginName:(NSString *)loginName
                  passWord:(NSString *)passWord
                 checkType:(NSString *)checkType
              argLeaseType:(NSString *)argLeaseType
                   success:(void (^)(NSDictionary * jsonResult))success
                   failure:(void (^)(NSString * errorMessage))failure;
//查询用户信息
+(void) getMemberInfoWithLoginName:(NSString *)loginName
                            status:(NSString *)status
                     equalsOrlikes:(NSString *)equalsOrlikes
                           success:(void (^)(NSDictionary * jsonResult))success
                           failure:(void (^)(NSString * errorMessage))failure;
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
                              failure:(void (^)(NSString * errorMessage))failure;
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
                            failure:(void (^)(NSString * errorMessage))failure;
//上传证件照片
+(void)uploadPhotoByLogiName:(NSString *)loginName
                       photo:(UIImage *)photo
                   telephone:(NSString *)telephone
                        type:(NSString *)type
                     success:(void (^)(NSString * result))success
                     failure:(void (^)(NSString * errorMessage))failure;
//上传证件照片
+(void)uploadTwoPhotoByLogiName:(NSString *)loginName
                         photo1:(UIImage *)photo1
                         photo2:(UIImage *)photo2
                      telephone:(NSString *)telephone
                           type:(NSString *)type
                        success:(void (^)(NSString * result))success
                        failure:(void (^)(NSString * errorMessage))failure;
//网点信息
+(void) getServiceNetworkInfoWithNetworkName:(NSString *)networkName
                              networkAddress:(NSString *)networkAddress
                                 companyName:(NSString *)companyName
                               equalsOrlikes:(NSString *)equalsOrlikes
                                   networkID:(NSString *)networkID
                                   companyID:(NSString *)companyID
                                     success:(void (^)(NSDictionary * jsonResult))success
                                     failure:(void (^)(NSString * errorMessage))failure;
//网点内的车辆
+(void) getVehiclebyNetworkName:(NSString *)networkName
                        success:(void (^)(NSDictionary * jsonResult))success
                        failure:(void (^)(NSString * errorMessage))failure;
//获取指定时间段内的可预订车辆
+(void) getAvailableVehiclesWithNetworkName:(NSString *)argNetworkName
                                   bookTime:(NSString *)argBookTime
                                 returnTime:(NSString *)argReturnTime
                                    success:(void (^)(NSDictionary * jsonResult))success
                                    failure:(void (^)(NSString * errorMessage))failure;
//车型详情
+(void) getVehicleTypeWithTypeName:(NSString *)typeName
                     equalsOrlikes:(NSString *)equalsOrlikes
                            typeID:(NSString *)typeID
                         companyID:(NSString *)companyID
                           success:(void (^)(NSDictionary * jsonResult))success
                           failure:(void (^)(NSString * errorMessage))failure;
//会员头像
+(void) getUserPictureWithImageView:(UIImageView *)imageView
                        pictureName:(NSString *) pictureName;
//车辆图片
+(void) getVehiclePictureWithImageView:(UIImageView *)imageView
                           pictureName:(NSString *) pictureName;
//价格策略
+(void) getPricePolicyWithTypeName:(NSString *)typeName
                 valuationTypeDesc:(NSString *)valuationTypeDesc
                            equals:(NSString *)equals
     vehicleTypeIDandValuationType:(NSString *)vehicleTypeIDandValuationType
                         companyID:(NSString *)companyID
                           success:(void (^)(NSDictionary * jsonResult))success
                           failure:(void (^)(NSString * errorMessage))failure;
//根据车牌预订车辆
+(void) bookVehicleByNoWithargLoginName:(NSString *)argLoginName
                              vehicleNo:(NSString *)argVehicleNo
                          valuationType:(NSString *)argValuationType
                               takeTime:(NSString *)argTakeTime
                             returnTime:(NSString *)argReturnTime
                            orderStatus:(NSString *)argOrderStatus
                                success:(void (^)(NSDictionary * jsonResult))success
                                failure:(void (^)(NSString * errorMessage))failure;
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
                                failure:(void (^)(NSString * errorMessage))failure;
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
                               failure:(void (^)(NSString * errorMessage))failure;
//预订费⽤
+(void) getReservationCostWithVehicleType:(NSString *)argVehicleType
                            valuationType:(NSString *)argValuationType
                                      kms:(NSString *)argKMs
                                 takeTime:(NSString *)argTakeTime
                               returnTime:(NSString *)argReturnTime
                   argCouponIdsJsonString:(NSString *)couponIds
                      argDeductibleTypeId:(NSString *)deductibleType
                                  success:(void (^)(NSDictionary * jsonResult))success
                                  failure:(void (^)(NSString * errorMessage))failure;
//退订
+(void) cancelReservationWithOrderID:(NSString *)argOrderID
                          cancelTime:(NSString *)argCancelTime
                             success:(void (^)(NSDictionary * jsonResult))success
                             failure:(void (^)(NSString * errorMessage))failure;
//退订费⽤
+(void) getCancelReservationCostWithOrderID:(NSString *)argOrderID
                                    success:(void (^)(NSDictionary * jsonResult))success
                                    failure:(void (^)(NSString * errorMessage))failure;
//续订
+(void) renewCarWithOrderID:(NSString *)argOrderID
            renewReturnTime:(NSString *)argRenewReturnTime
                   renewKMs:(NSString *)argRenewKMs
                  formerKMs:(NSString *)argformerKMs
                    success:(void (^)(NSString * result))success
                    failure:(void (^)(NSString * errorMessage))failure;
//续订费⽤
+(void) getRenewCostWithOrderID:(NSString *)argOrderID
                renewReturnTime:(NSString *)argRenewReturnTime
                       renewKMs:(NSString *)argRenewKMs
                      formerKMs:(NSString *)argformerKMs
                        success:(void (^)(NSDictionary * jsonResult))success
                        failure:(void (^)(NSString * errorMessage))failure;
//客户订单查询
+(void) retrieveOrderInfoByLoginNameWithLoginName:(NSString *)argLoginName
                                         takeTime:(NSString *)argTakeTime
                                       returnTime:(NSString *)argReturnTime
                                          success:(void (^)(NSDictionary * jsonResult))success
                                          failure:(void (^)(NSString * errorMessage))failure;
//更新订单信息
+(void)updateOrderInfoWhenBookVehicleWithArgOrderId:(NSString *)argOrderId
                                          argReason:(NSString *)argReason
                                       argApplyDept:(NSString *)argApplyDept
                                       argPassenger:(NSString *)argPassenger
                                          argDriver:(NSString *)argDriver
                                            success:(void (^)(NSDictionary * jsonResult))success
                                            failure:(void (^)(NSString * errorMessage))failure;
//熄火判断
+ (void)isAccOffSystemNOWithArgSystemNo:(NSString *)argSystemNo
                                success:(void (^)(NSDictionary *jsonResult))success
                                failure:(void (^)(NSString *errorMessage))failure;

//验车信息
+ (void) saveInspecttionInfoWithArgLeftFrontBackDoor:(NSString *) argLeftFrontBackDoor
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
                                             failure:(void (^)(NSString * errorMessage))failure;
//获取订单状态
+ (void) getOrderStatusWithArgOrderId:(NSString *) argOrderId
                              success:(void (^)(NSString * result))success
                              failure:(void (^)(NSString * errorMessage))failure;
#pragma mark 支付相关接口
//获取支付类型数据
+ (void) getPaymentTypeWithSuccess:(void (^)(NSDictionary *jsonResult))success
                           failure:(void (^)(NSString * errorMessage))failure;
//根据会员ID查询会员账号信息
+ (void) getMemberAccountByMemberID:(NSString *)memberID
                            success:(void (^)(NSDictionary *jsonResult))success
                            failure:(void (^)(NSString * errorMessage))failure;
//根据会员账号查询会员支付账号
+ (void) getMemberPaymentAccountByMemberAccount:(NSString *) memberAccount
                                        success:(void (^)(NSDictionary *jsonResult))success
                                        failure:(void (^)(NSString * errorMessage))failure;
//根据会员账号查询交易记录表信息的分页查询
+ (void) getMemberBizRecordByMemberAccount:(NSString *)memberAccount
                                 startDate:(NSString *)start
                                   endDate:(NSString *)end
                                   curPage:(NSString *)page
                                  pageSize:(NSString *)pageSize
                                   success:(void (^)(NSDictionary *jsonResult))success
                                   failure:(void (^)(NSString * errorMessage))failure;
//根据会员账号查询会员账号消费记录的分页查询
+ (void) getMemberConsumeRecordByMemberAccount:(NSString *)memberAccount
                                     startDate:(NSString *)start
                                       endDate:(NSString *)end
                                       curPage:(NSString *)page
                                      pageSize:(NSString *)pageSize
                                       success:(void (^)(NSDictionary *jsonResult))success
                                       failure:(void (^)(NSString * errorMessage))failure;
//消费记录查询
+ (void) getConsumeCostHistoryByOrderId:(NSString *)orderID
                                success:(void (^)(NSDictionary *jsonResult))success
                                failure:(void (^)(NSString * errorMessage))failure;
//添加会员支付账号
+ (void)createMemberPaymentAccountWithMemberAccount:(NSString *)memberAccount
                                        paymentType:(NSString *)paymentType
                                     paymentAccount:(NSString *)paymentAccount
                                            success:(void (^)(NSString * result))success
                                            failure:(void (^)(NSString * errorMessage))failure;
//删除会员支付账号
+ (void)delMemberPaymentAccountWithMemberAccount:(NSString *)memberAccount
                                     paymentType:(NSString *)paymentType
                                  paymentAccount:(NSString *)paymentAccount
                                         success:(void (^)(NSString * result))success
                                         failure:(void (^)(NSString * errorMessage))failure;
//提交提现申请
+ (void)createDrawCashVerifyRecordMemberAccount:(NSString *)memberAccount
                                     memberName:(NSString *)memberName
                                        drawAmt:(NSString *)drawAmt
                                    paymentType:(NSString *)paymentType
                                 paymentAccount:(NSString *)paymentAccount
                                        success:(void (^)(NSString * result))success
                                        failure:(void (^)(NSString * errorMessage))failure;
//提交提现申请
+ (void)applyForDrawCashWithLoginName:(NSString *)loginName
                             argMoney:(NSString *)argMoney
                          paymentType:(NSString *)paymentType
                       paymentAccount:(NSString *)paymentAccount
                            argIDCard:(NSString *)argIDCard
                              success:(void (^)(NSString * result))success
                              failure:(void (^)(NSString * errorMessage))failure;
#pragma mark 优惠券
//根据优惠券ID查询优惠券
+(void) getCouponById:(NSString *)couponID
              success:(void (^)(NSDictionary *jsonResult))success
              failure:(void (^)(NSString * errorMessage))failure;
//根据登录名查询优惠券信息
+(void) getCouponByLoginName:(NSString *)loginName
                     success:(void (^)(NSDictionary *jsonResult))success
                     failure:(void (^)(NSString * errorMessage))failure;
//优惠券是否有效
+(void) isCouponValidWithCouponIDs:(NSString *)couponIDs
                         loginName:(NSString *)loginName
                           success:(void (^)(NSDictionary *jsonResult))success
                           failure:(void (^)(NSString * errorMessage))failure;
//扫描二维码领取优惠券
+(void) fetchCouponByLoginName:(NSString *)loginName
               argQRCodeString:(NSString *)argQRCodeString
                       success:(void (^)(NSString * result))success
                       failure:(void (^)(NSString * errorMessage))failure;
#pragma mark - 密码与密保相关
//获取密保问题（登录名为空则返回全部问题）
+(void)getPasswordQuestionWithLoginName:(NSString *)loginName
                              loginType:(NSString *)loginType
                                success:(void (^)(NSDictionary *jsonResult))success
                                failure:(void (^)(NSString * errorMessage))failure;
//验证某个用户/会员的密保问题是否有效
+(void)isValidPasswordQuestionAnswerWithLoginName:(NSString *)loginName
                                       questionID:(NSString *)questionID
                                           answer:(NSString *)answer
                                        loginType:(NSString *)loginType
                                          success:(void (^)(NSString * result))success
                                          failure:(void (^)(NSString * errorMessage))failure;
//设置密保问题及答案
+(void)setPasswordQuestionWithLoginName:(NSString *)loginName
                               password:(NSString *)password
                             questionID:(NSString *)questionID
                                 answer:(NSString *)answer
                              loginType:(NSString *)loginType
                                success:(void (^)(NSString * result))success
                                failure:(void (^)(NSString * errorMessage))failure;
//重置密码
+(void)resetPasswordWithLoginName:(NSString *)loginName
                            newPwd:(NSString *)newPassword
                         loginType:(NSString *)loginType
                           success:(void (^)(NSString * result))success
                           failure:(void (^)(NSString * errorMessage))failure;
//修改密码
+(void)changePasswordWithLoginName:(NSString *)loginName
                            oldPwd:(NSString *)oldPassword
                            newPwd:(NSString *)newPassword
                         loginType:(NSString *)loginType
                           success:(void (^)(NSString * result))success
                           failure:(void (^)(NSString * errorMessage))failure;
//取车时间限制
+(void)takingCarsLimitsWithOrderID:(NSString *)orderID
                              time:(NSString *)time
                           success:(void (^)(NSDictionary *jsonResult))success
                           failure:(void (^)(NSString * errorMessage))failure;

//车辆信息
 +(void) getVehicleWithVehicleNo:(NSString *)vehicleNo
                     vehicleType:(NSString *)vehicleType
                     networkName:(NSString *)networkName
                   equalsOrlikes:(NSString *)equalsOrlikes
                       vehicleID:(NSString *)vehicleID
                     CompanyName:(NSString *)CompanyName
                         success:(void (^)(NSDictionary * jsonResult))success
                         failure:(void (^)(NSString * errorMessage))failure;

@end
