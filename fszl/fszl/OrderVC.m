//
//  OrderVC.m
//  fszl
//
//  Created by huqin on 1/16/15.
//  Copyright (c) 2015 huqin. All rights reserved.
//

#import "OrderVC.h"
#import "OrderManager.h"
#import "AccountManger.h"
#import "OrderCell.h"
#import "Order.h"
#import "QRCodeVC.h"
#import "HudHelper.h"
#import "SocketManager.h"
#import "HTTPHelper.h"
#import "DateHelper.h"
#import "ActionSheetDatePicker.h"
#import "RMUniversalAlert.h"
#import "InspectionVC.h"
#import <MapKit/MapKit.h>
#import "BMapKit.h"
#import "ConsumeRecordVC.h"
#import "MJRefresh.h"

@interface OrderVC ()<SocketManagerDelegate,UIActionSheetDelegate>
{
    UIView *_headView;
    UILabel *_headViewLabel;
    CLLocationCoordinate2D _destination;//导航目的地坐标
    NSString *_destinationName;//目的地名称
}

@property (nonatomic,strong) NSArray *orderArray;
@property (nonatomic,strong) OrderManager *orderManager;
@property (nonatomic,strong) Order* selectedOrder;
@property (nonatomic ,weak) UIButton * selectedButton;

@property (nonatomic,strong) NSString *xuDingTime;

@end

@implementation OrderVC

- (id)initWithStyle:(UITableViewStyle)style{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    _headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 25)];
    _headViewLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, self.view.frame.size.width, 25)];
    _headViewLabel.text = @"如果您需要导航，您可以点击一个订单";
    _headViewLabel.font = [UIFont systemFontOfSize:13];
    [_headView addSubview:_headViewLabel];
    
    //修改返回键样式
    UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Back"] style:UIBarButtonItemStylePlain target:self action:@selector(popToLastViewController)];
    self.navigationItem.leftBarButtonItem = back;
    //初始化self.orderArray
    NSString *loginName = [AccountManger sharedInstance].loginName;
    self.orderManager = [[OrderManager alloc]initWithLoginName:loginName];
    if (self.type == OrderVCTypeQuChe || self.type == OrderVCTypeHuanChe) {
        self.tableView.allowsSelection = YES;
        self.tableView.tableHeaderView = _headView;
    } else if (self.type == OrderVCTypeAll){
        _headViewLabel.text = @"点击订单查看消费明细";
        self.tableView.tableHeaderView = _headView;
        self.tableView.allowsSelection = YES;
    } else {
        self.tableView.allowsSelection = NO;
    }
    
    //更新按键
    UIBarButtonItem *updateButton = [[UIBarButtonItem alloc] initWithTitle:@"更新" style:UIBarButtonItemStylePlain target:self action:@selector(updateButtonPressed)];
    self.navigationItem.rightBarButtonItem = updateButton;
    if ([HTTPHelper isNetworkConnected] == NO) {
        [HudHelper showHudWithMessage:@"请打开网络连接" toView:self.view];
    }
    [self updateButtonPressed];
}
- (void)popToLastViewController {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //隐藏底部标签栏
//    self.tabBarController.tabBar.hidden = YES;
}


//初始化self.orderArray
-(void) setup{
    if (self.type == OrderVCTypeAll) {
        self.orderArray = [self.orderManager allOrderArray];
        self.navigationItem.title = @"订单";
    } else if(self.type == OrderVCTypeQuChe){
        self.orderArray = [self.orderManager quCheOrderArray];
        self.navigationItem.title = @"取车";
    } else if(self.type == OrderVCTypeHuanChe){
        self.orderArray = [self.orderManager huanCheOrderArray];
        self.navigationItem.title = @"还车";
    } else if(self.type == OrderVCTypeTuiDing){
        self.orderArray = [self.orderManager tuiDingOrderArray];
        self.navigationItem.title = @"退订";
    } else if(self.type == OrderVCTypeXuDing){
        self.orderArray = [self.orderManager xuDingOrderArray];
        self.navigationItem.title = @"续订";
    } else if(self.type == OrderVCTypeFinished){
        self.orderArray = [self.orderManager finishedOrderArray];
        self.navigationItem.title = @"历史订单";
    } else if(self.type == OrderVCTypeOpenDoor){
        self.orderArray = [self.orderManager openDoorOrderArray];
        self.navigationItem.title = @"开门";
    } else if(self.type == OrderVCTypeCloseDoor){
        self.orderArray = [self.orderManager closeDoorOrderArray];
        self.navigationItem.title = @"锁门";
    } else{
        self.orderArray = @[];
    }
}

//下载服务器订单
-(void) updateButtonPressed {
//    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//    [formatter setDateFormat:@"yyyy-MM-dd 23:59:59"];
//    [formatter setLocale:[NSLocale currentLocale]];
//    NSString *starttime = [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:- 7 * 24 * 60 * 60]];
//    if (self.type == OrderVCTypeAll) {
      NSString *starttime = @"2014-11-11 11:11:11";
//    }
    NSString *endtime = @"2111-11-11 11:11:11";
    [HudHelper showProgressHudWithMessage:@"正在获取订单" toView:self.view];
    //查询订单信息
    [HTTPHelper retrieveOrderInfoByLoginNameWithLoginName:[AccountManger sharedInstance].loginName takeTime:starttime returnTime:endtime success:^(NSDictionary * jsonResult){
        [HudHelper hideHudToView:self.view];
        if ([jsonResult[@"Result"] isEqualToString: @"1"]){//成功
            //将订单数据保存到手机
            [self.orderManager downloadOrders:jsonResult[@"Table"]];
            //更新界面
            [self setup];
        } else {
            [self.orderManager removeAll];
            [self setup];
        }
        [self.tableView reloadData];
//        [HudHelper showHudWithMessage:@"更新成功" toView:self.view];
    } failure:^(NSString *errorMessage){ //网络问题
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
    return [self.orderArray count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    OrderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OrderCell" forIndexPath:indexPath];
    Order *order = self.orderArray[indexPath.row];
    cell.orderIdLabel.text = [NSString stringWithFormat:@"订单编号:%@",order.orderID];
    cell.vehicleTypeLabel.text = [NSString stringWithFormat:@"车型:%@",order.vehicleTypeName];
    cell.vehicleNoLabel.text =[NSString stringWithFormat:@"车牌:%@",order.vehicleNo];
    cell.networkNameLabel.text = [NSString stringWithFormat:@"网点:%@",order.networkName];
    if ([order.renewReturnTime isEqualToString:@""]) {
        cell.timeLabel.text = [NSString stringWithFormat:@"有效时间:%@~%@",order.expectTakeTime,order.expectReturnTime];
    } else {
        cell.timeLabel.text = [NSString stringWithFormat:@"有效时间:%@~%@",order.expectTakeTime,order.renewReturnTime];
    }
    cell.costLabel.text = [NSString stringWithFormat:@"预计:%@元",order.estimatedCosts];
    cell.button.tag = indexPath.row;
    NSDateFormatter *formater = [[NSDateFormatter alloc] init];
    [formater setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    NSDate *date = [formater dateFromString:order.expectTakeTime];
    if(self.type == OrderVCTypeQuChe){
        [cell.button setTitle:@"取车" forState:UIControlStateNormal];
        [cell.button addTarget:self action:@selector(quCheButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    } else if(self.type == OrderVCTypeHuanChe){
        [cell.button setTitle:@"还车" forState:UIControlStateNormal];
        [cell.button addTarget:self action:@selector(huanCheButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    } else if (self.type == OrderVCTypeTuiDing){
        if ([date timeIntervalSinceNow] < 0) {
            [cell.button setTitle:@"退订" forState:UIControlStateNormal];
            [cell.button setEnabled:NO];
            [cell.button setBackgroundColor:[UIColor lightGrayColor]];
        } else {
        [cell.button setTitle:@"退订" forState:UIControlStateNormal];
        [cell.button addTarget:self action:@selector(tuiDingButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        }
    } else if (self.type == OrderVCTypeXuDing){
        [HudHelper showHudWithMessage:@"单个订单最多只能续订一次!" toView:self.view];
        if(([order.status isEqualToString:@"2"] || [order.status isEqualToString:@"6"]) && ![order.renewReturnTime isEqualToString:@""]) {
            [cell.button setTitle:@"续订" forState:UIControlStateNormal];
            [cell.button setEnabled:NO];
            [cell.button setBackgroundColor:[UIColor lightGrayColor]];
        } else {
        [cell.button setTitle:@"续订" forState:UIControlStateNormal];
        [cell.button addTarget:self action:@selector(xuDingButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        }
    } else if (self.type == OrderVCTypeOpenDoor){
        [cell.button setTitle:@"开门" forState:UIControlStateNormal];
        [cell.button addTarget:self action:@selector(openDoorButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    } else if (self.type == OrderVCTypeCloseDoor){
        [cell.button setTitle:@"锁门" forState:UIControlStateNormal];
        [cell.button addTarget:self action:@selector(closeDoorButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    } else if (self.type == OrderVCTypeFinished){
        [cell.button setHidden:YES];
    } else{// if (self.type == OrderVCTypeAll)
        cell.button.enabled = NO;
        [cell.button setBackgroundColor:[UIColor lightGrayColor]];
        NSString *buttonTitle = [NSString string];
        if ([order.status integerValue] == OrderStatusUnchecked) {//status = 1
            buttonTitle = @"审核中";
        }
        if ([order.status integerValue] == OrderStatusDidTakeCar) {//status = 2
            buttonTitle = @"已取车";
            cell.costLabel.text = [NSString stringWithFormat:@"预计:%@元",order.estimatedCosts];
        }
        if ([order.status integerValue] == OrderStatusDidReturnCar) {//status = 3
            buttonTitle = @"已还车";
            cell.costLabel.text = [NSString stringWithFormat:@"预计:%@元",order.estimatedCosts];
        }
        if ([order.status integerValue] == OrderStatusDidCancelOrder) {//status = 4
            buttonTitle = @"已退订";
            cell.costLabel.text = [NSString stringWithFormat:@"预计:%@元",order.estimatedCosts];
        }
        if ([order.status integerValue] == OrderStatusRejected) {//status = 5
            buttonTitle = @"不同意";
        }
        if ([order.status integerValue] == OrderStatusPassed) {//status = 6
            buttonTitle = @"未取车";
            cell.costLabel.text = [NSString stringWithFormat:@"预计:%@元",order.estimatedCosts];
        }
        if ([order.status integerValue] == OrderStatusChanged) {//status = 7 已变更
            buttonTitle = @"已变更";
            cell.costLabel.text = [NSString stringWithFormat:@"预计:%@元",order.estimatedCosts];
        }
        [cell.button setTitle:buttonTitle forState:UIControlStateNormal];
    }
    if ([HTTPHelper isNetworkConnected] == NO) {
        cell.button.enabled = NO;
    }
    if ([order.status integerValue] == OrderStatusPassed || [order.status integerValue] == OrderStatusUnchecked) {//只有未取车状态才有过期判断
        //判断订单是否过期
        NSDate *takeTime = [DateHelper getDateFromString:order.expectReturnTime];
        NSTimeInterval time = [takeTime timeIntervalSinceDate:[NSDate new]];
        if (time < 0) {
            [cell.button setTitle:@"已过期" forState:UIControlStateNormal];
            [cell.button setBackgroundColor:[UIColor grayColor]];
            cell.button.enabled = NO;
            cell.costLabel.text = [NSString stringWithFormat:@"预计:%@元",order.estimatedCosts];
        }
    }
#if ZFB
    if (self.type == OrderVCTypeQuChe) {
        cell.costLabel.textAlignment = NSTextAlignmentRight;
        cell.costLabel.textColor = [UIColor redColor];
        cell.costLabel.font = [UIFont systemFontOfSize:14];
        if ([order.status isEqualToString:@"1"]) {
            cell.costLabel.text = @"状态:审核中";
            cell.button.enabled = NO;
        }
        if ([order.status isEqualToString:@"5"]) {
            cell.costLabel.text = @"状态:不同意";
            cell.button.enabled = NO;
        }
        if ([order.status isEqualToString:@"6"]) {
            cell.costLabel.text = @"状态:同意";
        }
    } else {
        cell.costLabel.hidden = YES;
    }
#else

#endif
    return cell;
}

//调整session header的高度
- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return CGFLOAT_MIN;
}
- (CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return CGFLOAT_MIN;//12.0;
}

#pragma mark - Table view delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Order *selectOrder = self.orderArray[indexPath.row];
    if (self.type == OrderVCTypeQuChe || self.type == OrderVCTypeHuanChe) {
//        if ([selectOrder.status integerValue] == OrderStatusPassed || [selectOrder.status integerValue] == OrderStatusUnchecked) {//只有未取车状态才有过期判断
//            //判断订单是否过期(未过期订单能够使用导航)
//            NSDate *takeTime = [DateHelper getDateFromString:selectOrder.expectReturnTime];
//            NSTimeInterval time = [takeTime timeIntervalSinceDate:[NSDate new]];
//            if (time < 0) {
//                return;
//            }
//        }
        NSString *networkName = selectOrder.networkName;
        [HTTPHelper getServiceNetworkInfoWithNetworkName:networkName networkAddress:@"" companyName:@"" equalsOrlikes:@"1" networkID:@"" companyID:@"" success:^(NSDictionary *jsonResult) {
            NSDictionary *network = jsonResult[@"Table"][0];
            _destinationName = network[@"NetworkName"];
            _destination = CLLocationCoordinate2DMake([network[@"Latitude"] doubleValue], [network[@"Longitude"] doubleValue]);
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"您需要导航到预订车辆所在地吗？" delegate:self cancelButtonTitle:@"不使用导航" destructiveButtonTitle:nil otherButtonTitles:@"使用系统导航",@"使用百度导航", nil];
            [actionSheet showInView:self.view];
        } failure:^(NSString *errorMessage) {
            NSLog(@"%@",errorMessage);
        }];
    }
#if DZB
    if (self.type == OrderVCTypeAll) {
//        if ([selectOrder.status integerValue] == 4 || [selectOrder.status integerValue] == 3) {
            [HTTPHelper getConsumeCostHistoryByOrderId:selectOrder.orderID success:^(NSDictionary *jsonResult) {
                if ([jsonResult[@"Result" ] isEqualToString:@"0"]) {
                    [HudHelper showAlertViewWithMessage:@"此订单暂无消费记录"];
                } else if ([jsonResult[@"Result" ] isEqualToString:@"1"]) {
                    //进入消费记录页面
                    ConsumeRecordVC *consumeRecordVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ConsumeRecordVC"];
                    consumeRecordVC.consumeRecord = jsonResult[@"Table"][0];
                    consumeRecordVC.order = selectOrder;
                    [self.navigationController pushViewController:consumeRecordVC animated:YES];
                } else {
                    [HudHelper showAlertViewWithMessage:@"系统错误"];
                }
            } failure:^(NSString *errorMessage) {
                NSLog(@"%s %@",__func__,errorMessage);
            }];
//        } else {
//            [HudHelper showAlertViewWithMessage:@"此订单为未完成状态，无消费记录"];
//        }
    }
#endif
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}
#pragma mark - UIActionSheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(),^(void){
        if (buttonIndex == 0){
            //转换为百度地图所需要的经纬度
            NSDictionary *dict = BMKConvertBaiduCoorFrom(_destination,BMK_COORDTYPE_GPS);
            CLLocationCoordinate2D baiduCoor = BMKCoorDictionaryDecode(dict);
            //将百度坐标转化为BMK_COORDTYPE_COMMON坐标（约有10米的误差）
            NSDictionary *tmpDict = BMKConvertBaiduCoorFrom(baiduCoor,BMK_COORDTYPE_COMMON);
            CLLocationCoordinate2D tmpCoor = BMKCoorDictionaryDecode(tmpDict);
            CLLocationCoordinate2D commonCoor = CLLocationCoordinate2DMake(2*baiduCoor.latitude-tmpCoor.latitude, 2*baiduCoor.longitude-tmpCoor.longitude);
            //起点和终点
            MKMapItem *currentLocation = [MKMapItem mapItemForCurrentLocation];
            MKMapItem *toLocation = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:commonCoor addressDictionary:nil]];
            //名称
            toLocation.name = _destinationName;
            [MKMapItem openMapsWithItems:[NSArray arrayWithObjects:currentLocation, toLocation, nil]
                           launchOptions:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:MKLaunchOptionsDirectionsModeDriving, [NSNumber numberWithBool:YES], nil] forKeys:[NSArray arrayWithObjects:MKLaunchOptionsDirectionsModeKey, MKLaunchOptionsShowsTrafficKey, nil]]];
        }
        //百度地图
        if (buttonIndex == 1){
            if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"baidumap://map/"]]){
                //转换为百度地图所需要的经纬度
                NSDictionary *dict = BMKConvertBaiduCoorFrom(_destination,BMK_COORDTYPE_GPS);
                CLLocationCoordinate2D baiduCoor = BMKCoorDictionaryDecode(dict);
                //初始化调启导航时的参数管理类
                BMKNaviPara* para = [[BMKNaviPara alloc]init];
                //指定导航类型
                para.naviType = BMK_NAVI_TYPE_NATIVE;
                //初始化终点节点
                BMKPlanNode* end = [[BMKPlanNode alloc]init];
                //指定终点经纬度
                end.pt = baiduCoor;
                //指定终点名称
                end.name = _destinationName;//_nativeEndName.text;
                //指定终点
                para.endPoint = end;
                //指定返回自定义scheme
#if ZFB
                para.appScheme = @"whevtyxgw://com.whevt.fszl";
#else
                para.appScheme = @"whevtyxyc://com.whevt.fszl-copy-2";
#endif
                //调启百度地图客户端导航
                [BMKNavigation openBaiduMapNavigation:para];
            } else{
                [[[UIAlertView alloc] initWithTitle:@"您未安装\"百度地图\"App" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
            }
        }
    });
}
#pragma mark - 取车
- (IBAction)quCheButtonPressed:(UIButton *)sender{
    //选择的订单
    self.selectedOrder = self.orderArray[sender.tag];
    self.selectedButton = sender;
    NSDate *takeTime = [DateHelper getDateFromString:self.selectedOrder.expectReturnTime];
    NSTimeInterval time = [takeTime timeIntervalSinceDate:[NSDate new]];
    if (time < 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"订单已过期，无法取车，请点击更新按钮更新订单列表" delegate:nil cancelButtonTitle:@"好" otherButtonTitles: nil];
        [alert show];
        return;
    }
    sender.enabled = NO;
    [HTTPHelper takingCarsLimitsWithOrderID:self.selectedOrder.orderID time:[DateHelper getStringFromDate:[NSDate date]] success:^(NSDictionary *jsonResult) {
        sender.enabled = YES;
        NSDictionary *dict = jsonResult[@"Table"][0];
        if ([jsonResult[@"Result"] isEqualToString:@"1"]) {
            if ([dict[@"IsAllowed"] isEqualToString:@"1"]) {//能够取车
                //验车
                InspectionVC *inspection = [self.storyboard instantiateViewControllerWithIdentifier:@"InspectionVC"];
                inspection.anOrder = self.selectedOrder;
                inspection.orderType = self.type;
                [self.navigationController pushViewController:inspection animated:YES];
            } else {
                NSString *message = [NSString stringWithFormat:@"根据您预订的时间，您可以提前%@分钟取车，现在还无法取车！",dict[@"AdvanceMinutes"]];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:@"好" otherButtonTitles: nil];
                [alert show];
            }
        }
    } failure:^(NSString *errorMessage) {
        sender.enabled = YES;
        [HudHelper showHudWithMessage:errorMessage toView:self.view];
    }];
}
#pragma mark - 还车
- (IBAction)huanCheButtonPressed:(UIButton *)sender{
    //选择的订单
    self.selectedOrder = self.orderArray[sender.tag];
    self.selectedButton = sender;
    [HTTPHelper isAccOffSystemNOWithArgSystemNo:self.selectedOrder.systemNO success:^(NSDictionary *jsonResult) {
        NSString *acc = jsonResult[@"Table"][0][@"Acc"];
        NSString *isOnline = jsonResult[@"Table"][0][@"IsOnline"];
        NSString *status = jsonResult[@"Table"][0][@"Status"];
        if ([status isEqualToString:@"1"] && [isOnline isEqualToString:@"1"] && [acc isEqualToString:@"0"]) {  //成功
            //验车
            InspectionVC *inspection = [self.storyboard instantiateViewControllerWithIdentifier:@"InspectionVC"];
            inspection.anOrder = self.selectedOrder;
            inspection.orderType = self.type;
            [self.navigationController pushViewController:inspection animated:YES];
        }else if ([acc isEqualToString:@"1"]) {
            //[HudHelper showHudWithMessage:@"请将车辆熄火" toView:self.view];
            [[[UIAlertView alloc] initWithTitle:@"注意" message:@"请将车辆熄火" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
        }else if ([acc isEqualToString:@"2"]) {
            //[HudHelper showHudWithMessage:@"状态异常" toView:self.view];
            [[[UIAlertView alloc] initWithTitle:@"注意" message:@"状态异常" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
        }else if ([status isEqualToString:@"2"]) {
            //[HudHelper showHudWithMessage:@"车牌号或系统号不存在" toView:self.view];
            [[[UIAlertView alloc] initWithTitle:@"注意" message:@"车牌号或系统号不存在" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
        }
        
    } failure:^(NSString *errorMessage){
        NSLog(@"%s error:%@",__func__,errorMessage);
    }];
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


#pragma mark - 退订
- (IBAction)tuiDingButtonPressed:(UIButton *)sender{
    //选择的订单
    self.selectedOrder = self.orderArray[sender.tag];
    self.selectedButton = sender;
    [RMUniversalAlert showAlertInViewController:self withTitle:@"是否退订" message:@"根据取消订单规则，您的退订操作可能会收取一定的费用，您是否要退订？" cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@[@"退订"] tapBlock:^(RMUniversalAlert *alert, NSInteger buttonIndex) {
        if (buttonIndex == alert.firstOtherButtonIndex) {
            //防止反复发出请求
            [self.selectedButton setEnabled:NO];
            //退订
            
            [HTTPHelper cancelReservationWithOrderID:self.selectedOrder.orderID cancelTime:[DateHelper getStringFromDate:[NSDate date]] success:^(NSDictionary * jsonResult) {
                [self.selectedButton setEnabled:YES];
                if ([jsonResult[@"Table"][0][@"status"] isEqualToString: @"1"]) {//成功
                    //修改订单状态为退订
                    [self.orderManager cancelReservation:self.selectedOrder.orderID];
                    [HTTPHelper getConsumeCostHistoryByOrderId:self.selectedOrder.orderID success:^(NSDictionary *jsonResult) {
                        NSLog(@"%s",__func__);
                        if ([jsonResult[@"Result"] isEqualToString:@"1"]) {
                            NSString *realConsumeAmt = [NSString stringWithFormat:@"您已退订成功，此次退订将收取%@元",jsonResult[@"Table"][0][@"RealConsumeAmt"]];
                            [RMUniversalAlert showAlertInViewController:self withTitle:@"退订成功" message:realConsumeAmt cancelButtonTitle:@"好" destructiveButtonTitle:nil otherButtonTitles:nil tapBlock:^(RMUniversalAlert *alert, NSInteger buttonIndex) {
                                NSLog(@"%s",__func__);
                                if (buttonIndex == alert.cancelButtonIndex) {
                                    [self.navigationController popToRootViewControllerAnimated:YES];
                                }
                            }];
                        }
                    } failure:^(NSString *errorMessage) {
                        NSLog(@"%s error:%@",__func__,errorMessage);
                    }];
                } else {//失败
                    [HudHelper showHudWithMessage:@"退订失败" toView:self.view];
                }
            } failure:^(NSString *errorMessage) {
                [self.selectedButton setEnabled:YES];
                //网络问题
                [HudHelper showHudWithMessage:errorMessage toView:self.view];
            }];
        }
    }];
}



#pragma mark - 续订
- (IBAction)xuDingButtonPressed:(UIButton *)sender {
    //选择的订单
    self.selectedOrder = self.orderArray[sender.tag];
    self.selectedButton = sender;
    
    ActionSheetDatePicker *datePicker = [[ActionSheetDatePicker alloc] initWithTitle:@"续订时间" datePickerMode:UIDatePickerModeDateAndTime selectedDate:[NSDate date] target:self action:@selector(timeWasSelected:element:) origin:self.selectedButton];
    [datePicker setCancelButton:[[UIBarButtonItem alloc]initWithTitle:@"取消" style:(UIBarButtonItemStylePlain) target:nil action:nil]];
    [datePicker setDoneButton:[[UIBarButtonItem alloc]initWithTitle:@"确定" style:(UIBarButtonItemStyleDone) target:nil action:nil]];
    [datePicker showActionSheetPicker];
}
-(void)timeWasSelected:(NSDate *)selectedTime element:(id)element{
    if ([self compareOneDay:[NSDate date] withAnotherDay:selectedTime] > 6) {
        [HudHelper showHudWithMessage:@"借车应不超过6天时间" toView:self.view];
        return;
    }
    
    self.xuDingTime = [DateHelper getStringFromDate:selectedTime];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-M-d a h:mm"];
    NSString *msg = [NSString stringWithFormat:@"是否续订到 %@ ?",[dateFormatter stringFromDate:selectedTime]];
    [RMUniversalAlert showAlertInViewController:self withTitle:@"续订" message:msg cancelButtonTitle:@"取消" destructiveButtonTitle:@"确定" otherButtonTitles:nil tapBlock:^(RMUniversalAlert *alert, NSInteger buttonIndex){
        if (buttonIndex == alert.destructiveButtonIndex) {
            //防止反复发出请求
            [self.selectedButton setEnabled:NO];
            //续订
            [HTTPHelper renewCarWithOrderID:self.selectedOrder.orderID renewReturnTime:self.xuDingTime renewKMs:@"0" formerKMs:@"0" success:^(NSString * result) {
                [self.selectedButton setEnabled:YES];
                if ([result isEqualToString: @"1"]) {//成功
                    //续订
                    [self.orderManager renewCar:self.selectedOrder.orderID withRenewReturnTime:self.xuDingTime];
                    //返回主界面
                    [HudHelper showHudWithMessage:@"续订成功" toView:self.view];
                    [self performSelector:@selector(backToRootVC) withObject:nil afterDelay:1.2f];
                } else {//失败
                    [HudHelper showHudWithMessage:@"续订失败" toView:self.view];
                }
            } failure:^(NSString *errorMessage) {
                [self.selectedButton setEnabled:YES];
                //网络问题 
                [HudHelper showHudWithMessage:errorMessage toView:self.view];
            }];
        }
    }];
}




#pragma mark - 开门
- (void)openDoorButtonPressed:(UIButton *)sender{
    //选择的订单
    self.selectedOrder = self.orderArray[sender.tag];
    self.selectedButton = sender;
    [RMUniversalAlert showAlertInViewController:self withTitle:@"是否开门" message:nil cancelButtonTitle:@"不开门" destructiveButtonTitle:@"立即开门" otherButtonTitles:nil tapBlock:^(RMUniversalAlert *alert, NSInteger buttonIndex){
        if (alert.destructiveButtonIndex == buttonIndex) {
            [SocketManager sharedInstance].delegate = self;
            [[SocketManager sharedInstance] openDoor:self.selectedOrder];
            [RMUniversalAlert showAlertInViewController:self withTitle:nil message:@"开门指令已发出，请查看车门" cancelButtonTitle:@"好" destructiveButtonTitle:nil otherButtonTitles:nil tapBlock:^(RMUniversalAlert *alert, NSInteger buttonIndex) {
                if (buttonIndex == alert.cancelButtonIndex) {
                    [self.navigationController popToRootViewControllerAnimated:YES];
                }
            }];
        }
    }];
}
//SocketManager delegate
- (void)didFailToConnect:(NSString *)failMessage{
    [HudHelper showAlertViewWithMessage:failMessage];
}
//开门结果(signalName是pushDoorReply)
- (void)didGetOpenDoorReply:(NSDictionary *)jsonResult{
    [HudHelper hideHudToView:self.view];
    if ([jsonResult[@"data"][@"value"] isEqualToString:@"0"]){//成功
        [HudHelper showAlertViewWithMessage:@"开门成功"];
        return;
    } else {//失败
        NSString *error = [NSString stringWithFormat:@"开门失败[%@]",jsonResult[@"data"][@"value"]];
        [HudHelper showAlertViewWithMessage:error];
    }
}
#pragma mark - 关门
- (void)closeDoorButtonPressed:(UIButton *)sender{
    //选择的订单
    self.selectedOrder = self.orderArray[sender.tag];
    self.selectedButton = sender;
    [RMUniversalAlert showAlertInViewController:self withTitle:@"是否锁门" message:nil cancelButtonTitle:@"现在不锁" destructiveButtonTitle:@"立即锁门" otherButtonTitles:nil tapBlock:^(RMUniversalAlert *alert, NSInteger buttonIndex){
        if (alert.destructiveButtonIndex == buttonIndex) {
            [SocketManager sharedInstance].delegate = self;
            [[SocketManager sharedInstance] closeDoor:self.selectedOrder];
            [RMUniversalAlert showAlertInViewController:self withTitle:nil message:@"锁门指令已发出，请查看车门" cancelButtonTitle:@"好" destructiveButtonTitle:nil otherButtonTitles:nil tapBlock:^(RMUniversalAlert *alert, NSInteger buttonIndex) {
                if (buttonIndex == alert.cancelButtonIndex) {
                    [self.navigationController popToRootViewControllerAnimated:YES];
                }
            }];
        }
    }];
}
//关门结果(signalName是shutDownReply)
- (void)didGetCloseDoorReply:(NSDictionary *)jsonResult {
    [HudHelper hideHudToView:self.view];
    if ([jsonResult[@"data"][@"value"] isEqualToString:@"0"]) {//成功
        [HudHelper showAlertViewWithMessage:@"锁门成功"];
        return;
    } else {//失败
        NSString *error = [NSString stringWithFormat:@"锁门失败[%@]",jsonResult[@"data"][@"value"]];
        [HudHelper showAlertViewWithMessage:error];
    }
}

- (void)backToRootVC {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
