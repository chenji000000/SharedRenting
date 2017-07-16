//
//  DCBookWithPriceVC.m
//  fszl
//
//  Created by aqin on 4/8/15.
//  Copyright (c) 2015 huqin. All rights reserved.
//

#import "DCBookWithPriceVC.h"
#import "ReserveVehicleSignal.h"
#import "ActionSheetPicker.h"
#import "HudHelper.h"
#import "AccountManger.h"
#import "LoginVC.h"
#import "OrderManager.h"
#import "DateHelper.h"
#import "HTTPHelper.h"
#import "AccountManger.h"
#import "DingChePricePolicyVC.h"
#import "LoginStatusHelper.h"
#import "RMUniversalAlert.h"
#import "CouponViewController.h"

@interface DCBookWithPriceVC ()<DingChePricePolicyDelegate,ChooseCouponDelegate>
{
    UIAlertView *_alert;//检查会员是否通过审核返回的内容
}
@property (weak, nonatomic) IBOutlet UILabel *vehicleTypeNameAndVehicleNoLabel;
@property (weak, nonatomic) IBOutlet UILabel *networkNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *takeTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *returnTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *pricePolicyLabel;
@property (weak, nonatomic) IBOutlet UILabel *reservationCost;//预定预估费用
@property (weak, nonatomic) IBOutlet UILabel *discountLabel;//优惠券选择
@property (weak, nonatomic) IBOutlet UILabel *insuranceLabel;//不计免赔险选择
@property (weak, nonatomic) IBOutlet UILabel *accountBalance;//账户余额

@property (nonatomic,strong) NSDate *takeTime;
@property (nonatomic,strong) NSDate *returnTime;

@property (nonatomic, copy) NSString *balance;//用于余额判断
@property (nonatomic,strong) NSMutableArray *couponNotUsedArray;//存放未使用优惠券的数组
@property (nonatomic, copy) NSString *couponIDs;//选择使用的优惠券id
@property (nonatomic, copy) NSString *argDeductibleTypeID;//选择使用的不计免赔类型

@end

@implementation DCBookWithPriceVC
{
//    NSArray *_selectIndexPaths;//已选择的优惠券
    NSIndexPath *_selectIndexPath;//选择的优惠券
}

- (void)viewDidLoad{
    [super viewDidLoad];
    self.navigationItem.title = @"预定";
//    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"Password"] != nil) {
//        [self getBalance];//显示余额
//    } else {
//        self.accountBalance.hidden = YES;//未登录隐藏账户余额显示框
//    }
    self.couponNotUsedArray = [NSMutableArray arrayWithCapacity:1];
    //添加”取消预定”按钮，方便快速返回首页
    UIBarButtonItem * cancelButton = [[UIBarButtonItem alloc]initWithTitle:@"取消预定" style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonPressed:)];
    self.navigationItem.rightBarButtonItem = cancelButton;
    
    //车型和车牌
    self.vehicleTypeNameAndVehicleNoLabel.text = [NSString stringWithFormat:@"%@ %@", [ReserveVehicleSignal sharedInstance].vehicleTypeName, [ReserveVehicleSignal sharedInstance].vehicleNo];
    //网点
    self.networkNameLabel.text = [ReserveVehicleSignal sharedInstance].networkName;
    //填入已有时间
    if ([ReserveVehicleSignal sharedInstance].expectTakeTime) {
        [self timeWasSelected:[DateHelper getDateFromString:[ReserveVehicleSignal sharedInstance].expectTakeTime] element:self.takeTimeLabel];
    }
    if ([ReserveVehicleSignal sharedInstance].expectReturnTime) {
        [self timeWasSelected:[DateHelper getDateFromString:[ReserveVehicleSignal sharedInstance].expectReturnTime] element:self.returnTimeLabel];
    }
    //初始化优惠券与不计免赔类型为空
    self.couponIDs = @"";
    self.argDeductibleTypeID = @"";
    
    //修改返回键样式
    UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Back"] style:UIBarButtonItemStylePlain target:self action:@selector(popToLastViewController)];
    self.navigationItem.leftBarButtonItem = back;
}
- (void)popToLastViewController {
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.balance == NULL) {
        if ([AccountManger sharedInstance].memberId != nil) {
            self.accountBalance.hidden = NO;
            [self getBalance];//显示余额
        } else {
            self.accountBalance.hidden = YES;//未登录隐藏账户余额显示框
        }
    }
}

//取消按钮点击事件
-(void) cancelButtonPressed:(UIBarButtonItem *)sender{
    [ReserveVehicleSignal sharedInstance].vehicleTypeName = nil;
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 7;
}
//调整session header的高度
- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return CGFLOAT_MIN;
}

//tableView delegate 点击tableViewCell时触发
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDate *date = [[NSDate alloc] init];
    if (indexPath.row == 2) {//取车时间
        if (self.takeTime) {
            date = self.takeTime;
        } else {
            date = [NSDate dateWithTimeIntervalSinceNow:900];
        }
        ActionSheetDatePicker *takeTimePicker = [[ActionSheetDatePicker alloc] initWithTitle:@"取车时间" datePickerMode:UIDatePickerModeDateAndTime selectedDate:date target:self action:@selector(timeWasSelected:element:) origin:self.takeTimeLabel];
        [takeTimePicker setCancelButton:[[UIBarButtonItem alloc]initWithTitle:@"取消" style:(UIBarButtonItemStylePlain) target:nil action:nil]];
        [takeTimePicker setDoneButton:[[UIBarButtonItem alloc]initWithTitle:@"确定" style:(UIBarButtonItemStyleDone) target:nil action:nil]];
        [takeTimePicker showActionSheetPicker];
    } else if (indexPath.row == 3) {//还车时间
        if (self.takeTime) {
            date = [self.takeTime dateByAddingTimeInterval:60*60*24*3];
        } else {
            if (self.returnTime) {
                date = self.returnTime;
            } else {
                date = [NSDate dateWithTimeIntervalSinceNow:60*60*24*3];
            }
        }
        ActionSheetDatePicker *returnTimePicker = [[ActionSheetDatePicker alloc] initWithTitle:@"还车时间" datePickerMode:UIDatePickerModeDateAndTime selectedDate:date target:self action:@selector(timeWasSelected:element:) origin:self.returnTimeLabel];
        [returnTimePicker setCancelButton:[[UIBarButtonItem alloc]initWithTitle:@"取消" style:(UIBarButtonItemStylePlain) target:nil action:nil]];
        [returnTimePicker setDoneButton:[[UIBarButtonItem alloc]initWithTitle:@"确定" style:(UIBarButtonItemStyleDone) target:nil action:nil]];
        [returnTimePicker showActionSheetPicker];
    } else if (indexPath.row == 4) {//价格策略
        //防止反复发出请求
        self.tableView.allowsSelection = NO;
        [HTTPHelper getPricePolicyWithTypeName:[ReserveVehicleSignal sharedInstance].vehicleTypeName valuationTypeDesc:@"" equals:@"1" vehicleTypeIDandValuationType:@"" companyID:@"" success:^(NSDictionary *jsonResult) {
             self.tableView.allowsSelection = YES;
             if ([jsonResult[@"Result"] isEqualToString: @"1"]) {//成功
                 //进入界面
                 DingChePricePolicyVC *pricePolicyVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Storyboard_DingChePricePolicy"];
                 pricePolicyVC.pricePolicyArray = jsonResult[@"Table"];
                 pricePolicyVC.delegate = self;
                 UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:pricePolicyVC];
                 [self presentViewController:navigationController animated:YES completion:nil];
             } else { //失败
                 [HudHelper showHudWithMessage:@"价格策略请求失败" toView:self.view];
             }
         } failure:^(NSString *errorMessage) {
             self.tableView.allowsSelection = YES;
             //网络问题
             [HudHelper showHudWithMessage:errorMessage toView:self.view];
         }];
    } else if (indexPath.row == 5) {//优惠券
        //检查登录
        if ([[NSUserDefaults standardUserDefaults] valueForKey:@"Password"] == nil && [AccountManger sharedInstance].memberId == nil) {
            LoginVC *loginVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Storyboard_Login"];
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:loginVC];
            [self presentViewController:navigationController animated:YES completion:nil];
            return ;
        }
        //防止反复发出请求
        self.tableView.allowsSelection = NO;
        [HTTPHelper getCouponByLoginName:[AccountManger sharedInstance].loginName success:^(NSDictionary *jsonResult) {
            self.tableView.allowsSelection = YES;
            if ([jsonResult[@"Result"] isEqualToString:@"1"]) {//账号内有优惠券
                [self.couponNotUsedArray removeAllObjects];
                NSArray *array = jsonResult[@"Table"];
                for (NSDictionary *dict in array) {
                    if ([dict[@"CouponStatus"] isEqualToString:@"1"]) {//优惠券未使用
                        [self.couponNotUsedArray addObject:dict];
                    }
                }
                if ([self.couponNotUsedArray count] == 0) {//账号内无可用优惠券
                    [HudHelper showHudWithMessage:@"账号内无可用优惠券！" toView:self.view];
                    return ;
                }
                CouponViewController *coupon = [CouponViewController new];
                coupon.couponArray = self.couponNotUsedArray;
                coupon.selectRow = _selectIndexPath;
                coupon.delegate = self;
                UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:coupon];
                [self presentViewController:nav animated:YES completion:nil];
            } else {//账号内无优惠券
                [HudHelper showHudWithMessage:@"账号内无可用优惠券！" toView:self.view];
            }
        } failure:^(NSString *errorMessage) {
            self.tableView.allowsSelection = YES;
            [HudHelper showHudWithMessage:errorMessage toView:self.view];
        }];
    } else if (indexPath.row == 6) {//不计免赔
        [ActionSheetStringPicker showPickerWithTitle:@"不计免赔险选择" rows:@[@"不购买",@"5元/小时",@"30元/天"] initialSelection:1 doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
            self.insuranceLabel.text = selectedValue;
            self.insuranceLabel.textColor = [UIColor blackColor];
            if (selectedIndex == 0) {
                self.argDeductibleTypeID = @"";
            } else if (selectedIndex == 1) {
                self.argDeductibleTypeID = @"hour";
            } else {
                self.argDeductibleTypeID = @"day";
            }
            if (self.takeTime != nil && self.returnTime != nil && ![self.pricePolicyLabel.text isEqualToString:@"请选择"]) {
                [self getReservationCost];
            }
        } cancelBlock:nil origin:self.insuranceLabel];
    }
}
//选择优惠券delegate（优惠券多选改为单选）
- (void) didChooseCoupon:(NSIndexPath *)indexPath {
//    _selectIndexPaths = indexPaths;
//    if ([indexPaths count]) {
//        NSMutableArray *couponIDs = [NSMutableArray arrayWithCapacity:10];
//        for (NSIndexPath *indexPath in indexPaths) {
//            [couponIDs addObject:self.couponNotUsedArray[indexPath.row][@"CouponID"]];
//        }
//        self.discountLabel.text = [NSString stringWithFormat:@"已选择%ld张优惠券",(long)[couponIDs count]];
//        self.discountLabel.textColor = [UIColor blackColor];
//        //多张优惠券将优惠券id数组转成JSON字符串
//        NSData *data = [NSJSONSerialization dataWithJSONObject:couponIDs options:NSJSONWritingPrettyPrinted error:nil];
//        self.couponIDs = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//    } else {
//        self.discountLabel.text = @"请选择";
//        self.discountLabel.textColor = [UIColor lightGrayColor];
//        self.couponIDs = @"";
//    }
    NSLog(@"%s%@",__func__,indexPath);
    _selectIndexPath = indexPath;
    if (indexPath == NULL) {
        self.discountLabel.text = @"请选择";
        self.discountLabel.textColor = [UIColor lightGrayColor];
        self.couponIDs = @"";
    } else {
        self.discountLabel.text = [NSString stringWithFormat:@"%@",self.couponNotUsedArray[indexPath.row][@"CouponTypeName"]];
        self.discountLabel.textColor = [UIColor blackColor];
        self.couponIDs = self.couponNotUsedArray[indexPath.row][@"CouponID"];
    }
    if (self.takeTime != nil && self.returnTime != nil && ![self.pricePolicyLabel.text isEqualToString:@"请选择"]) {
        [self getReservationCost];
    }
}

//选择时间
-(void)timeWasSelected:(NSDate *)selectedTime element:(id)element{
    UILabel *label = (UILabel *)element;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-M-d a h:mm"];
    [label setText:[dateFormatter stringFromDate:selectedTime]];
    label.textColor = [UIColor blackColor];
    
    if (label == self.takeTimeLabel) {
        self.takeTime = selectedTime;
    }
    if (label == self.returnTimeLabel) {
        self.returnTime = selectedTime;
    }
    if (self.takeTime != nil && self.returnTime != nil && ![self.pricePolicyLabel.text isEqualToString:@"请选择"]) {
        [self getReservationCost];
    }
}

//获取预估价格
- (void) getReservationCost {
    [HTTPHelper getReservationCostWithVehicleType:[ReserveVehicleSignal sharedInstance].vehicleTypeID valuationType:[ReserveVehicleSignal sharedInstance].valuationType kms:@"0" takeTime:[DateHelper getStringFromDate:self.takeTime] returnTime:[DateHelper getStringFromDate:self.returnTime] argCouponIdsJsonString:self.couponIDs argDeductibleTypeId:self.argDeductibleTypeID  success:^(NSDictionary *jsonResult) {
        if ([jsonResult[@"Result"] isEqualToString: @"1"]) {//成功
            NSArray *array = jsonResult[@"Table"];
            [ReserveVehicleSignal sharedInstance].estimatedCosts = array[0][@"cost"];
            self.reservationCost.text = [NSString stringWithFormat:@"预估费用:%@元",array[0][@"cost"]];
        } else {//失败
//            [HudHelper showHudWithMessage:@"预估费用获取失败" toView:self.view];
        }
    } failure:^(NSString *errorMessage) {//网络问题
        NSLog(@"errorMessage = %@",errorMessage);
//        [HudHelper showHudWithMessage:@"网络不给力，获取预估费用失败" toView:self.view];
    }];
}

//已选择价格策略
- (void)didChoosePricePolicy {
    [self.pricePolicyLabel setText:[ReserveVehicleSignal sharedInstance].valuationTypeDesc];
    self.pricePolicyLabel.textColor = [UIColor blackColor];
    if (self.takeTime != nil && self.returnTime != nil) {
        [self getReservationCost];
    }
}

//检查输入
- (BOOL) checkInput {
    //检查时间（是否输入时间、是否在将来、还车时间晚于取车时间）
    if (self.takeTime==nil || self.returnTime== nil) {
        [HudHelper showHudWithMessage:@"请选择时间" toView:self.view];
        return NO;
    }
    if ([self.takeTime timeIntervalSinceNow] < 0){
        [HudHelper showHudWithMessage:@"时间为过去，请修改" toView:self.view];
        return NO;
    }
    if ([self.returnTime timeIntervalSinceDate:self.takeTime] < 0 ){
        [HudHelper showHudWithMessage:@"还车时间应晚于取车时间" toView:self.view];
        return NO;
    }
    if ([self compareOneDay:self.takeTime withAnotherDay:self.returnTime] > 3) {
        [HudHelper showHudWithMessage:@"借车应不超过3天时间" toView:self.view];
        return NO;
    }
    //检查价格策略
    if ([self.pricePolicyLabel.text isEqualToString:@"请选择"]) {
        [HudHelper showHudWithMessage:@"请选择价格策略" toView:self.view];
        return NO;
    }
    //检查登录
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"Password"] == nil && [AccountManger sharedInstance].memberId == nil){
        LoginVC *loginVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Storyboard_Login"];
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:loginVC];
        [self presentViewController:navigationController animated:YES completion:nil];
        return NO;
    }
    return YES;
}

//两个日期之间相差的天数
- (double)compareOneDay:(NSDate *)oneDay withAnotherDay:(NSDate *)anotherDay
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd/MM/yyyy hh:mm"];
    NSString *oneDayStr = [dateFormatter stringFromDate:oneDay];
    NSString *anotherDayStr = [dateFormatter stringFromDate:anotherDay];
    NSDate *dateA = [dateFormatter dateFromString:oneDayStr];
    NSDate *dateB = [dateFormatter dateFromString:anotherDayStr];
    NSTimeInterval result = [dateB timeIntervalSinceDate:dateA];
    return result/(60*60*24);
    
}
//获取余额
- (void) getBalance {
    [HTTPHelper getMemberAccountByMemberID:[AccountManger sharedInstance].memberId success:^(NSDictionary *jsonResult) {
        if ([jsonResult[@"Result"] isEqualToString:@"1"]) {
            NSDictionary *memberAccount = jsonResult[@"Table"][0];
            self.balance = memberAccount[@"Balance"];
            self.accountBalance.text = [NSString stringWithFormat:@"账户余额:%@元",memberAccount[@"Balance"]];
        }
    } failure:^(NSString *errorMessage) {
        NSLog(@"errorMessage = %@",errorMessage);
//        [HudHelper showHudWithMessage:@"网络不给力，请检查网络后重试" toView:self.view];
    }];
}

//预定按键点击事件
- (IBAction)yuDingButtonPressed:(UIButton *)sender {
    //检查输入的时间、价格、用户名是否正确
    if ([self checkInput] == NO) {
        return;
    }
    //判断账号信息是否已经保存到AccountManger,未保存则保存
    if ([AccountManger sharedInstance].memberId == nil) {
        [AccountManger sharedInstance].loginName = [[NSUserDefaults standardUserDefaults] valueForKey:@"LoginName"];
        [AccountManger sharedInstance].memberId = [[NSUserDefaults standardUserDefaults] valueForKey:@"MemberId"];
        [AccountManger sharedInstance].telephone = [[NSUserDefaults standardUserDefaults] valueForKey:@"Telephone"];
        [AccountManger sharedInstance].memberAccount = [[NSUserDefaults standardUserDefaults] valueForKey:@"MemberAccount"];
    }
    //查看账号是否通过审核
    if ([LoginStatusHelper checkLoginStatus] != nil) {
        _alert = [LoginStatusHelper checkLoginStatus];
        [_alert show];
        return;
    }
//    //检查余额
//    if ([self.balance doubleValue] < 3000) {
//        [HudHelper showHudWithMessage:@"余额不足3000元，请充值后再进行订车" toView:self.view];
//        return;
//    }
    
    //记录取车、还车时间
    [ReserveVehicleSignal sharedInstance].expectTakeTime = [DateHelper getStringFromDate:self.takeTime];
    [ReserveVehicleSignal sharedInstance].expectReturnTime = [DateHelper getStringFromDate:self.returnTime];
    //防止反复发出请求
    sender.enabled = NO;
    //按车型订车
    if ([[ReserveVehicleSignal sharedInstance].vehicleNo isEqualToString:@""]) {
        [HTTPHelper bookVehicleByTypeWithLoginName:[AccountManger sharedInstance].loginName networkName:[ReserveVehicleSignal sharedInstance].networkName vehicleTypeID:[ReserveVehicleSignal sharedInstance].vehicleTypeID valuationType:[ReserveVehicleSignal sharedInstance].valuationType takeTime:[ReserveVehicleSignal sharedInstance].expectTakeTime returnTime:[ReserveVehicleSignal sharedInstance].expectReturnTime orderStatus:@"6" argCouponIdsJsonString:@"" argDeductibleTypeID:@"" success:^(NSDictionary *jsonResult) {
            sender.enabled = YES;
            if ([jsonResult[@"Result"] isEqualToString: @"1"]) {//成功
                NSString *status = jsonResult[@"Table"][0][@"status"];
                if ([status isEqualToString:@"1"]) {//订车成功status = 1
                    //保存订单
                    [self saveOrderWithJsonResult:jsonResult];
                    [RMUniversalAlert showAlertInViewController:self withTitle:@"预定成功" message:@"您已预定成功，祝您用车愉快！" cancelButtonTitle:nil destructiveButtonTitle:@"好" otherButtonTitles:nil tapBlock:^(RMUniversalAlert *alert, NSInteger buttonIndex) {
                        if (alert.destructiveButtonIndex == buttonIndex) {
                            [self.navigationController popToRootViewControllerAnimated:YES];
                        }
                    }];
                    return;
                } else if ([status isEqualToString:@"2"]) {//预定失败 status = 2
                    [HudHelper showAlertViewWithMessage:@"预定失败(时间有误)"];
                } else if ([status isEqualToString:@"3"]) { //预定失败status = 3
                    [HudHelper showAlertViewWithMessage:@"预定失败(无效优惠券)"];
                } else if ([status isEqualToString:@"4"]) { //预定失败status = 4
                    [HudHelper showAlertViewWithMessage:@"预定失败(不计免赔无效)"];
                } else if ([status isEqualToString:@"5"]) { //预定失败status = 5
                    NSString *msg = [NSString stringWithFormat:@"预定失败(余额不足%@)",jsonResult[@"Table"][0][@"rechargeAmount"]];
                    [HudHelper showAlertViewWithMessage:msg];
                } else if ([status isEqualToString:@"6"]) { //预定失败status = 6
                    [HudHelper showAlertViewWithMessage:@"预定失败(您无法预订该站点车辆)"];
                } else if ([status isEqualToString:@"7"]) { //预定失败status = 7
                    [HudHelper showAlertViewWithMessage:@"预定失败(预订时间段已有订单)"];
                } else if ([status isEqualToString:@"8"]) {
                    [HudHelper showAlertViewWithMessage:@"预订失败(只能预订3天内的车辆)"];
                } else if ([status isEqualToString:@"9"]) {
                    [HudHelper showAlertViewWithMessage:@"预订失败(车辆已下线,无法被预定)"];
                }
                else {
                    NSString *msg = [NSString stringWithFormat:@"预定失败(%@)",status];
                    [HudHelper showAlertViewWithMessage:msg];
                }
            } else { //失败
                [HudHelper showHudWithMessage:@"网络错误" toView:self.view];
            }
        } failure:^(NSString *errorMessage){//网络问题
            sender.enabled = YES;
            [HudHelper showHudWithMessage:errorMessage toView:self.view];
        }];
    } else {//按车牌订车
        [HTTPHelper bookVehicleByNo2WithargLoginName:[AccountManger sharedInstance].loginName vehicleNo:[ReserveVehicleSignal sharedInstance].vehicleNo valuationType:[ReserveVehicleSignal sharedInstance].valuationType takeTime:[ReserveVehicleSignal sharedInstance].expectTakeTime returnTime:[ReserveVehicleSignal sharedInstance].expectReturnTime orderStatus:@"6" argCouponIds:self.couponIDs argDeductibleTypeID:self.argDeductibleTypeID success:^(NSDictionary *jsonResult) {
            sender.enabled = YES;
            if ([jsonResult[@"Result"] isEqualToString: @"1"]) {//成功
                NSString *status = jsonResult[@"Table"][0][@"status"];
                if ([status isEqualToString:@"1"]) {//订车成功status = 1
                    //保存订单
                    [self saveOrderWithJsonResult:jsonResult];
                    [RMUniversalAlert showAlertInViewController:self withTitle:@"预定成功" message:@"您已预定成功，祝您用车愉快！" cancelButtonTitle:nil destructiveButtonTitle:@"好" otherButtonTitles:nil tapBlock:^(RMUniversalAlert *alert, NSInteger buttonIndex) {
                        if (alert.destructiveButtonIndex == buttonIndex) {
                            [self.navigationController popToRootViewControllerAnimated:YES];
                        }
                    }];
                    return;
                } else if ([status isEqualToString:@"2"]) {//预定失败 status = 2
                    [HudHelper showAlertViewWithMessage:@"预定失败(时间有误)"];
                } else if ([status isEqualToString:@"3"]) { //预定失败status = 3
                    [HudHelper showAlertViewWithMessage:@"预定失败(无效优惠券)"];
                } else if ([status isEqualToString:@"4"]) { //预定失败status = 4
                    [HudHelper showAlertViewWithMessage:@"预定失败(不计免赔无效)"];
                } else if ([status isEqualToString:@"5"]) { //预定失败status = 5
                    NSString *msg = [NSString stringWithFormat:@"预定失败(余额不足%@)",jsonResult[@"Table"][0][@"rechargeAmount"]];
                    [HudHelper showAlertViewWithMessage:msg];
                } else if ([status isEqualToString:@"6"]) { //预定失败status = 6
                    [HudHelper showAlertViewWithMessage:@"预定失败(您无法预订该站点车辆)"];
                } else if ([status isEqualToString:@"7"]) { //预定失败status = 7
                    [HudHelper showAlertViewWithMessage:@"预定失败(预订时间段已有订单)"];
                } else if ([status isEqualToString:@"8"]) {
                    [HudHelper showAlertViewWithMessage:@"预订失败(只能预订3天内的车辆)"];
                } else if ([status isEqualToString:@"9"]) {
                    [HudHelper showAlertViewWithMessage:@"预订失败(车辆已下线,无法被预定)"];
                }
                else {
                    NSString *msg = [NSString stringWithFormat:@"预定失败(%@)",status];
                    [HudHelper showAlertViewWithMessage:msg];
                }
            } else { //失败
                [HudHelper showHudWithMessage:@"网络错误" toView:self.view];
            }
        } failure:^(NSString *errorMessage) { //网络问题
            sender.enabled = YES;
            [HudHelper showHudWithMessage:errorMessage toView:self.view];
        }];
    }
}
//预定成功信息（修改前）
//根据预定时间段，会员可以提前15分钟取车，延时5分钟还车，而不产生任何费用。会员延时还车超过5分钟以后，按延时费用标准收取。超时费用规则：用户超时部分收取双倍时租费用，最小计费刻度为半小时（例如用户超时5到15分钟收取半小时费用，16到30分钟收取1小时，依次类推）；如果您的延时对下一订单的会员造成影响，使之不能按时取车，您还将被收取延时赔偿金最高100元，此费用将作为对受影响会员的补偿。


//保存订单信息
-(void) saveOrderWithJsonResult:(NSDictionary *)jsonResult {
    NSLog(@"status = %@",jsonResult[@"Table"][0][@"orderStatus"]);
    Order *anOrder = [[Order alloc]init];
    anOrder.orderID = jsonResult[@"Table"][0][@"orderId"];
    anOrder.memberID = [AccountManger sharedInstance].memberId;
    //anOrder.generateTime = jsonResult[@"timestamp"];
    anOrder.vehicleTypeID = [ReserveVehicleSignal sharedInstance].vehicleTypeID;
    anOrder.vehicleNo = jsonResult[@"Table"][0][@"vehicleNo"];
    anOrder.valuationType = [ReserveVehicleSignal sharedInstance].valuationType;
    anOrder.expectTakeTime = [ReserveVehicleSignal sharedInstance].expectTakeTime;
    anOrder.expectReturnTime = [ReserveVehicleSignal sharedInstance].expectReturnTime;
    anOrder.renewReturnTime = @"";
    anOrder.estimatedCosts = [ReserveVehicleSignal sharedInstance].estimatedCosts;
    anOrder.renewCosts = @"";
    anOrder.status = jsonResult[@"Table"][0][@"orderStatus"];
    anOrder.loginName = [AccountManger sharedInstance].loginName;
    anOrder.vehicleTypeName = [ReserveVehicleSignal sharedInstance].vehicleTypeName;
    anOrder.networkName = [ReserveVehicleSignal sharedInstance].networkName;
    anOrder.systemNO = jsonResult[@"Table"][0][@"SystemNo"];
    
    OrderManager *orderManager = [[OrderManager alloc]initWithLoginName:[AccountManger sharedInstance].loginName];
    [orderManager addNewOrder:anOrder];
    
    [ReserveVehicleSignal sharedInstance].vehicleTypeName = nil;
}

@end