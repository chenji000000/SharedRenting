//
//  DCBookWithoutPriceVC.m
//  fszl
//
//  Created by aqin on 4/8/15.
//  Copyright (c) 2015 huqin. All rights reserved.
//

#import "DCBookWithoutPriceVC.h"
#import "ReserveVehicleSignal.h"
#import "ActionSheetDatePicker.h"
#import "HudHelper.h"
#import "AccountManger.h"
#import "LoginVC.h"
#import "OrderManager.h"
#import "DateHelper.h"
#import "HTTPHelper.h"
#import "AccountManger.h"
#import "LoginStatusHelper.h"
#import "RMUniversalAlert.h"

@interface DCBookWithoutPriceVC ()
{
    UIAlertView *_alert;//检查会员是否通过审核返回的内容
}

@property (weak, nonatomic) IBOutlet UILabel *vehicleTypeNameAndVehicleNoLabel;
@property (weak, nonatomic) IBOutlet UILabel *networkNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *takeTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *returnTimeLabel;


@property (weak, nonatomic) IBOutlet UITextField *driverLabel;
@property (weak, nonatomic) IBOutlet UITextField *passengerLabel;
@property (weak, nonatomic) IBOutlet UITextField *reasonLabel;
@property (weak, nonatomic) IBOutlet UITextField *deptNameLabel;

@property (nonatomic,strong) NSDate *takeTime;
@property (nonatomic,strong) NSDate *returnTime;

@end

@implementation DCBookWithoutPriceVC

- (id)initWithStyle:(UITableViewStyle)style{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.navigationItem.title = @"预定";
    
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
    
    //填入部门名
    self.deptNameLabel.text = [ReserveVehicleSignal sharedInstance].deptName;
    
    //修改返回键样式
    UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Back"] style:UIBarButtonItemStylePlain target:self action:@selector(popToLastViewController)];
    self.navigationItem.leftBarButtonItem = back;
}
- (void)popToLastViewController {
    [self.navigationController popViewControllerAnimated:YES];
}

//取消预订 返回主界面
-(void) cancelButtonPressed:(UIBarButtonItem *)sender{
    [ReserveVehicleSignal sharedInstance].vehicleTypeName = nil;
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 8;
}
//调整session header的高度
- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return CGFLOAT_MIN;
}

//tableView delegate 点击tableViewCell时触发
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDate *date = [[NSDate alloc] init];
    //取车时间
    if (indexPath.row == 2) {
        if (self.takeTime) {
            date = self.takeTime;
        } else {
            date = [NSDate dateWithTimeIntervalSinceNow:900];
        }
        ActionSheetDatePicker *takeTimePicker = [[ActionSheetDatePicker alloc] initWithTitle:@"取车时间" datePickerMode:UIDatePickerModeDateAndTime selectedDate:date target:self action:@selector(timeWasSelected:element:) origin:self.takeTimeLabel];
        [takeTimePicker setCancelButton:[[UIBarButtonItem alloc]initWithTitle:@"取消" style:(UIBarButtonItemStylePlain) target:nil action:nil]];
        [takeTimePicker setDoneButton:[[UIBarButtonItem alloc]initWithTitle:@"确定" style:(UIBarButtonItemStyleDone) target:nil action:nil]];
        [takeTimePicker showActionSheetPicker];
    } else if (indexPath.row == 3){//还车时间
        if (self.takeTime) {
            date = [self.takeTime dateByAddingTimeInterval:3600];
        } else {
            if (self.returnTime) {
                date = self.returnTime;
            } else {
                date = [NSDate dateWithTimeIntervalSinceNow:4500];
            }
        }
        ActionSheetDatePicker *returnTimePicker = [[ActionSheetDatePicker alloc] initWithTitle:@"还车时间" datePickerMode:UIDatePickerModeDateAndTime selectedDate:date target:self action:@selector(timeWasSelected:element:) origin:self.returnTimeLabel];
        [returnTimePicker setCancelButton:[[UIBarButtonItem alloc]initWithTitle:@"取消" style:(UIBarButtonItemStylePlain) target:nil action:nil]];
        [returnTimePicker setDoneButton:[[UIBarButtonItem alloc]initWithTitle:@"确定" style:(UIBarButtonItemStyleDone) target:nil action:nil]];
        [returnTimePicker showActionSheetPicker];
    }
}

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
}

//检查用户输入
- (BOOL) checkInput{
    //检查时间（是否输入时间、是否在将来、还车时间晚于取车时间）
    if (self.takeTime==nil || self.returnTime== nil) {
        [HudHelper showHudWithMessage:@"请选择时间" toView:self.view];
        return NO;
    }
    if ([self.takeTime timeIntervalSinceNow] < 0) {
        [HudHelper showHudWithMessage:@"时间为过去，请修改" toView:self.view];
        return NO;
    }
    if ([self.returnTime timeIntervalSinceDate:self.takeTime] < 0 ) {
        [HudHelper showHudWithMessage:@"还车时间应晚于取车时间" toView:self.view];
        return NO;
    }
    //检查司机
    if ([self.driverLabel.text isEqualToString:@""]) {
        [HudHelper showHudWithMessage:@"请输入司机信息" toView:self.view];
        return NO;
    }
    //检查同行人
    if ([self.passengerLabel.text isEqualToString:@""]) {
        [HudHelper showHudWithMessage:@"请输入同行人信息" toView:self.view];
        return NO;
    }
    //检查用车事由
    if ([self.reasonLabel.text isEqualToString:@""]) {
        [HudHelper showHudWithMessage:@"请输入用车事由" toView:self.view];
        return NO;
    }
    //检查登录
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"Password"] == nil && [AccountManger sharedInstance].memberId == nil) {
        LoginVC *loginVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Storyboard_Login"];
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:loginVC];
        [self presentViewController:navigationController animated:YES completion:nil];
        return NO;
    }
    return YES;
}

//预定
- (IBAction)yuDingButtonPressed:(UIButton *)sender{
    //检查输入的时间、价格、用户名是否正确
    if ([self checkInput] == NO) {
        return;
    }
    //判断账号信息是否已经保存到AccountManger,未保存则保存
    if ([AccountManger sharedInstance].memberId == nil) {
        [AccountManger sharedInstance].loginName = [[NSUserDefaults standardUserDefaults] valueForKey:@"LoginName"];
        [AccountManger sharedInstance].memberId = [[NSUserDefaults standardUserDefaults] valueForKey:@"MemberId"];
        [AccountManger sharedInstance].telephone = [[NSUserDefaults standardUserDefaults] valueForKey:@"Telephone"];
    }
    //查看账号是否通过审核
    if ([LoginStatusHelper checkLoginStatus] != nil) {
        _alert = [LoginStatusHelper checkLoginStatus];
        [_alert show];
        return;
    }
    //记录取车、还车时间
    [ReserveVehicleSignal sharedInstance].expectTakeTime = [DateHelper getStringFromDate:self.takeTime];
    [ReserveVehicleSignal sharedInstance].expectReturnTime = [DateHelper getStringFromDate:self.returnTime];
    //政府版
    [ReserveVehicleSignal sharedInstance].driver = self.driverLabel.text;
    [ReserveVehicleSignal sharedInstance].passenger = self.passengerLabel.text;
    [ReserveVehicleSignal sharedInstance].reason = self.reasonLabel.text;
    [ReserveVehicleSignal sharedInstance].deptName = self.deptNameLabel.text;
    //防止反复发出请求
    sender.enabled = NO;
    //按车型订车  (政府版不执行)
    if ([[ReserveVehicleSignal sharedInstance].vehicleNo isEqualToString:@""]) {
        [HTTPHelper bookVehicleByTypeWithLoginName:[AccountManger sharedInstance].loginName networkName:[ReserveVehicleSignal sharedInstance].networkName vehicleTypeID:[ReserveVehicleSignal sharedInstance].vehicleTypeID valuationType:[ReserveVehicleSignal sharedInstance].valuationType takeTime:[ReserveVehicleSignal sharedInstance].expectTakeTime returnTime:[ReserveVehicleSignal sharedInstance].expectReturnTime orderStatus:@"1" argCouponIdsJsonString:@"" argDeductibleTypeID:@"" success:^(NSDictionary *jsonResult) {
            sender.enabled = YES;
            if ([jsonResult[@"Result"] isEqualToString: @"1"]) {//成功
                if ([jsonResult[@"Table"][0][@"status"] isEqualToString:@"1"]) {//订车成功
                    //保存订单
                    [self saveOrderWithJsonResult:jsonResult];
                    [RMUniversalAlert showAlertInViewController:self withTitle:@"预定成功" message:@"您已预定成功，祝您用车愉快！" cancelButtonTitle:nil destructiveButtonTitle:@"好" otherButtonTitles:nil tapBlock:^(RMUniversalAlert *alert, NSInteger buttonIndex) {
                        if (alert.destructiveButtonIndex == buttonIndex) {
                            [self.navigationController popToRootViewControllerAnimated:YES];
                        }
                    }];
                    return;
                } else {//预定失败
                    [HudHelper showHudWithMessage:@"预定失败" toView:self.view];
                }
            } else{//失败
                [HudHelper showHudWithMessage:@"信息错误" toView:self.view];
            }
        } failure:^(NSString *errorMessage) {
            sender.enabled = YES;
            //网络问题
            [HudHelper showHudWithMessage:errorMessage toView:self.view];
        }];
    } else {//按车牌订车 （政府版执行）//[ReserveVehicleSignal sharedInstance].valuationType
        [HTTPHelper bookVehicleByNoWithargLoginName:[AccountManger sharedInstance].loginName vehicleNo:[ReserveVehicleSignal sharedInstance].vehicleNo valuationType:@"1" takeTime:[ReserveVehicleSignal sharedInstance].expectTakeTime returnTime:[ReserveVehicleSignal sharedInstance].expectReturnTime orderStatus:@"1" success:^(NSDictionary *jsonResult) {
            sender.enabled = YES;
            if ([jsonResult[@"Result"] isEqualToString: @"1"]) {//成功
                if ([jsonResult[@"Table"][0][@"status"] isEqualToString:@"1"]) {//订车成功
                    //保存订单
                    [self saveOrderWithJsonResult:jsonResult];
                    //更新政府版信息
                    [HTTPHelper updateOrderInfoWhenBookVehicleWithArgOrderId:jsonResult[@"Table"][0][@"orderId"] argReason:[ReserveVehicleSignal sharedInstance].reason argApplyDept:[ReserveVehicleSignal sharedInstance].deptName argPassenger:[ReserveVehicleSignal sharedInstance].passenger argDriver:[ReserveVehicleSignal sharedInstance].driver success:^(NSDictionary *jsonResult){
                        if ([jsonResult[@"Result"] isEqualToString: @"1"]) {//成功
                            [RMUniversalAlert showAlertInViewController:self withTitle:@"预定成功" message:@"您已预定成功，祝您用车愉快！" cancelButtonTitle:nil destructiveButtonTitle:@"好" otherButtonTitles:nil tapBlock:^(RMUniversalAlert *alert, NSInteger buttonIndex) {
                                if (alert.destructiveButtonIndex == buttonIndex) {
                                    [self.navigationController popToRootViewControllerAnimated:YES];
                                }
                            }];
                            return ;
                        } else {//失败
                            [HudHelper showHudWithMessage:@"信息更新失败" toView:self.view];
                        }
                    } failure:^(NSString *errorMessage) {
                        [HudHelper showHudWithMessage:errorMessage toView:self.view];
                    }];
                    return;
                } else {//预定失败
                    [HudHelper showHudWithMessage:@"预定失败" toView:self.view];
                }
            } else{//失败
                [HudHelper showHudWithMessage:@"信息错误" toView:self.view];
            }
        } failure:^(NSString *errorMessage) {
            sender.enabled = YES;
            //网络问题
            [HudHelper showHudWithMessage:errorMessage toView:self.view];
        }];
    }
}


/**
 *  保存订单信息
 *
 *  @param jsonResult 订单信息
 */
-(void) saveOrderWithJsonResult:(NSDictionary *)jsonResult{
    NSLog(@"orderStatus = %@",jsonResult[@"Table"][0][@"orderStatus"]);
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
    anOrder.estimatedCosts = @"";
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
