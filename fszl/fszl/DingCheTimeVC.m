//
//  DingCheTimeVC.m
//  fszl
//
//  Created by huqin on 3/10/15.
//  Copyright (c) 2015 huqin. All rights reserved.
//

#import "DingCheTimeVC.h"
#import "ReserveVehicleSignal.h"
#import "ActionSheetPicker.h"
#import "HudHelper.h"
#import "DateHelper.h"
#import "HTTPHelper.h"
#import "DingCheVehicleByNetworkNameVC.h"
#import "DCByVehicleTypeVC.h"

@interface DingCheTimeVC ()

@property (weak, nonatomic) IBOutlet UILabel *takeTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *returnTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *levelLabel;
@property (weak, nonatomic) IBOutlet UILabel *transmissionTypeLabel;

@property (nonatomic,strong) NSDate *takeTime;
@property (nonatomic,strong) NSDate *returnTime;

@property (nonatomic, assign) NSInteger level;//车辆档次
@property (nonatomic, assign) NSInteger transmissionType;//变速箱类型

@end

@implementation DingCheTimeVC

- (id)initWithStyle:(UITableViewStyle)style{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    self.title = @"选择时间";
#if DZB
    //选车型按钮
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithTitle:@"选车型" style:UIBarButtonItemStylePlain target:self action:@selector(change)];
    self.navigationItem.rightBarButtonItem = buttonItem;
#endif
    
    //修改返回键样式
    UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Back"] style:UIBarButtonItemStylePlain target:self action:@selector(popToLastViewController)];
    self.navigationItem.leftBarButtonItem = back;
}
- (void)popToLastViewController {
    [self.navigationController popViewControllerAnimated:YES];
}

//订车类型切换
- (void) change{
    [HTTPHelper getVehicleTypeWithTypeName:@"" equalsOrlikes:@"1" typeID:@"" companyID:[ReserveVehicleSignal sharedInstance].companyID success:^(NSDictionary *jsonResult) {
        if ([jsonResult[@"Result"] isEqualToString: @"1"]) {//成功
            NSArray *array = jsonResult[@"Table"];
            DCByVehicleTypeVC *typeVC = [self.storyboard instantiateViewControllerWithIdentifier:@"DCByVehicleTypeVC"];
            typeVC.vehicleArray = array;
            [self.navigationController pushViewController:typeVC animated:YES];
        } else {//失败
            [HudHelper showHudWithMessage:@"信息错误" toView:self.view];
        }
    } failure:^(NSString *errorMessage) { //网络问题
        [HudHelper showHudWithMessage:errorMessage toView:self.view];
    }];
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 4;
}

//调整session header的高度
- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return CGFLOAT_MIN;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDate *date = [[NSDate alloc] init];
    if (indexPath.row == 0) {//取车时间
        if (self.takeTime) {
            date = self.takeTime;
        } else {
            date = [NSDate dateWithTimeIntervalSinceNow:900];
        }
        ActionSheetDatePicker *takeTimePicker = [[ActionSheetDatePicker alloc] initWithTitle:@"取车时间" datePickerMode:UIDatePickerModeDateAndTime selectedDate:date target:self action:@selector(timeWasSelected:element:) origin:self.takeTimeLabel];
        [takeTimePicker setCancelButton:[[UIBarButtonItem alloc]initWithTitle:@"取消" style:(UIBarButtonItemStylePlain) target:nil action:nil]];
        [takeTimePicker setDoneButton:[[UIBarButtonItem alloc]initWithTitle:@"确定" style:(UIBarButtonItemStyleDone) target:nil action:nil]];
        [takeTimePicker showActionSheetPicker];
    } else if (indexPath.row == 1) {//还车时间
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
        
    } else if (indexPath.row == 2) {//车辆档次
        [ActionSheetStringPicker showPickerWithTitle:@"车辆档次" rows:@[@"全部",@"经济型",@"舒适型",@"商务型",@"豪华型",@"奢华型",] initialSelection:0 doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
            self.levelLabel.text = selectedValue;
            self.levelLabel.textColor = [UIColor blackColor];
            self.level = selectedIndex;
        } cancelBlock:nil origin:self.levelLabel];
    } else if (indexPath.row == 3) {//变速箱类型
        [ActionSheetStringPicker showPickerWithTitle:@"变速箱类型" rows:@[@"全部",@"手动挡",@"自动挡",@"CVT无极变速",@"手自一体",] initialSelection:0 doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
            self.transmissionTypeLabel.text = selectedValue;
            self.transmissionTypeLabel.textColor = [UIColor blackColor];
            self.transmissionType = selectedIndex;
        } cancelBlock:nil origin:self.transmissionTypeLabel];
    }
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
    if ([self.takeTime timeIntervalSinceNow] < -60) {
        [HudHelper showHudWithMessage:@"时间为过去，请修改" toView:self.view];
        return NO;
    }
    if ([self.returnTime timeIntervalSinceDate:self.takeTime] < 0 ) {
        [HudHelper showHudWithMessage:@"还车时间应晚于取车时间" toView:self.view];
        return NO;
    }
    if ([self compareOneDay:self.takeTime withAnotherDay:self.returnTime] > 3) {
        [HudHelper showHudWithMessage:@"借车应不超过3天时间" toView:self.view];
        return NO;
    }
    return YES;
}

//下一步
- (IBAction)nextButtonPressed:(UIButton *)sender{
    //检查输入的时间、价格、用户名是否正确
    if ([self checkInput] == NO) {
        return;
    } 
    //记录取车、还车时间
    [ReserveVehicleSignal sharedInstance].expectTakeTime = [DateHelper getStringFromDate:self.takeTime];
    [ReserveVehicleSignal sharedInstance].expectReturnTime = [DateHelper getStringFromDate:self.returnTime];
    [sender setEnabled:NO];
    [HudHelper showProgressHudWithMessage:@"正在查询..." toView:self.view];
    //获取在该时间段内可以定的车辆
    [HTTPHelper getAvailableVehiclesWithNetworkName:[ReserveVehicleSignal sharedInstance].networkName bookTime:[ReserveVehicleSignal sharedInstance].expectTakeTime returnTime:[ReserveVehicleSignal sharedInstance].expectReturnTime success:^(NSDictionary *jsonResult) {
        [sender setEnabled:YES];
        if ([jsonResult[@"Result"] isEqualToString: @"1"]) {//成功
            [HudHelper hideHudToView:self.view];
            //进入下一个界面
            NSMutableArray *sortedVehicleArray = [NSMutableArray arrayWithArray:jsonResult[@"Table"]];
            //按车牌排序
            NSComparisonResult (^sortByVehicleNo)(NSDictionary *, NSDictionary *) = ^(NSDictionary *obj1, NSDictionary *obj2) {
                return [obj2[@"VehicleNo"] compare:obj1[@"VehicleNo"]];
            };
            [sortedVehicleArray sortUsingComparator:sortByVehicleNo];
            DingCheVehicleByNetworkNameVC *vehicleByNetworkNameVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Storyboard_DingCheVehicleByNetworkName"];
            vehicleByNetworkNameVC.vehicleArray = sortedVehicleArray;
            vehicleByNetworkNameVC.level = self.level;
            vehicleByNetworkNameVC.transmissionType = self.transmissionType;
            [self.navigationController pushViewController:vehicleByNetworkNameVC animated:YES];
        } else if ([jsonResult[@"Result"] isEqualToString: @"0"]){//失败
            [HudHelper showHudWithMessage:@"站点内无可预订车辆" toView:self.view];
        }
    } failure:^(NSString *errorMessage) {//网络问题
        [sender setEnabled:YES];
        [HudHelper showHudWithMessage:errorMessage toView:self.view];
    }];
}

@end
