//
//  InspectionVC.m
//  fszl
//
//  Created by aqin on 3/28/15.
//  Copyright (c) 2015 huqin. All rights reserved.
//

#import "InspectionVC.h"
#import "HTTPHelper.h"
#import "DateHelper.h"
#import "HudHelper.h"
#import "QRCodeVC.h"
#import "SocketManager.h"
#import "RMUniversalAlert.h"
#import "OrderManager.h"



@interface InspectionVC ()<QRCodeVCDelegate,SocketManagerDelegate>

@property (nonatomic,strong) NSArray *inspectionResultArray;
//@property (nonatomic,strong) OrderManager *manager;


@end

@implementation InspectionVC

- (void)viewDidLoad {
    [super viewDidLoad];
    //self.manager = [[OrderManager alloc] initWithLoginName:self.anOrder.loginName];
//    NSLog(@"self.anOrder:%@",self.anOrder);
    self.title = @"验车";
    //修改返回键样式
    UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Back"] style:UIBarButtonItemStylePlain target:self action:@selector(popToLastViewController)];
    self.navigationItem.leftBarButtonItem = back;
}
- (void)popToLastViewController {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)check:(UIButton *)sender{
    NSInteger tag = sender.tag;
    if (tag % 2) {
        [sender setTitle:@"✅完好" forState:UIControlStateNormal];
        sender.enabled = NO;
        UIButton *button =(UIButton *) [self.view viewWithTag:tag + 1];
        button.enabled = YES;
        [button setTitle:@"⚪️损伤" forState:UIControlStateNormal];
    } else {
        [sender setTitle:@"🔴损伤" forState:UIControlStateNormal];
        sender.enabled = NO;
        UIButton *button =(UIButton *) [self.view viewWithTag:tag - 1];
        button.enabled = YES;
        [button setTitle:@"⚪️完好" forState:UIControlStateNormal];
    }
}

- (IBAction)saveInspectionDetails:(UIButton *)sender{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:10];
    for (int i = 1; i < 19; i++) {
        UIButton *button = (UIButton *)[self.view viewWithTag:i];
        if (button.enabled == YES) {
            [array addObject:[NSString stringWithFormat:@"%d",((i + 1) % 2)]];
        }
    }
    if ([array count] > 9) {
        [HudHelper showHudWithMessage:@"您有未检查的部分！" toView:self.view];
        return;
    } else {
        self.inspectionResultArray = [NSArray arrayWithArray:array];
    }
    //获取时间
    NSString *date = [DateHelper getStringFromDate:[NSDate new]];
    //上传验车信息
    [HTTPHelper saveInspecttionInfoWithArgLeftFrontBackDoor:self.inspectionResultArray[0] argFrontLeafboardBothSides:self.inspectionResultArray[1] argLeftRearMirror:self.inspectionResultArray[2] argFrontBar:self.inspectionResultArray[3] argHood:self.inspectionResultArray[4] argRightFrontBackMirror:self.inspectionResultArray[5] argRightFrontDoor:self.inspectionResultArray[6] argBackLeafboardBothSides:self.inspectionResultArray[7] argBackBar:self.inspectionResultArray[8] argOrderId:self.anOrder.orderID argInspectionTime:date argImg1:nil argImg2:nil argImg3:nil argImg4:nil argImg5:nil argImg6:nil success:^(NSString * result) {
        if ([result isEqualToString: @"1"]){
            if (self.orderType == OrderVCTypeQuChe) {
                //二维码
                QRCodeVC *qrVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Storyboard_QRCode"];
                qrVC.delegate = self;
                UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:qrVC];
                [self presentViewController:navigationController animated:YES completion:nil];
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [RMUniversalAlert showAlertInViewController:self withTitle:@"是否还车" message:@"请检查车身，关好门窗，钥匙放在车内" cancelButtonTitle:@"暂时不还车" destructiveButtonTitle:@"立即还车" otherButtonTitles:nil tapBlock:^(RMUniversalAlert *alert, NSInteger buttonIndex){
                        if (alert.destructiveButtonIndex == buttonIndex) {
                            [SocketManager sharedInstance].delegate = self;
                            [[SocketManager sharedInstance] returnCar:self.anOrder];
                            [RMUniversalAlert showAlertInViewController:self withTitle:nil message:@"还车指令已发出，请查看车辆" cancelButtonTitle:@"好" destructiveButtonTitle:nil otherButtonTitles:nil tapBlock:^(RMUniversalAlert *alert, NSInteger buttonIndex) {
                                if (buttonIndex == alert.cancelButtonIndex) {
                                    [self.navigationController popToRootViewControllerAnimated:YES];
                                }
                            }];
                        }
                    }];
                });
            }
        } else {//失败
            [HudHelper showHudWithMessage:@"验车信息上传失败" toView:self.view];
        }
    } failure:^(NSString *errorMessage) { //网络问题
        [HudHelper showHudWithMessage:errorMessage toView:self.view];
    }];
}

#pragma mark QRCodeVCDelegate method
//处理二维码结果
- (void)didGetStringFromQRCode:(NSString *)str{
    NSLog(@"%@",str);
   if ([str isEqualToString:self.anOrder.vehicleNo]) {//二维码内容是车牌号
        dispatch_async(dispatch_get_main_queue(), ^{
            [RMUniversalAlert showAlertInViewController:self withTitle:@"是否取车" message:nil cancelButtonTitle:@"暂不取车" destructiveButtonTitle:@"立即取车" otherButtonTitles:nil tapBlock:^(RMUniversalAlert *alert, NSInteger buttonIndex){
                if (buttonIndex == alert.destructiveButtonIndex) {
                    [SocketManager sharedInstance].delegate = self;
                    self.anOrder.qrCode = str;
                    [[SocketManager sharedInstance] takeCar:self.anOrder];
                    [RMUniversalAlert showAlertInViewController:self withTitle:nil message:@"取车指令已发出，请查看车辆" cancelButtonTitle:@"好" destructiveButtonTitle:nil otherButtonTitles:nil tapBlock:^(RMUniversalAlert *alert, NSInteger buttonIndex) {
                        if (buttonIndex == alert.cancelButtonIndex) {
                            [self.navigationController popToRootViewControllerAnimated:YES];
                        }
                    }];
                }
            }];
        });
    } else {//不是车牌号
        [HudHelper showHudWithMessage:@"二维码不正确" toView:self.view];
    }
}

#pragma mark SocketManagerDelegate method

- (void)didFailToConnect:(NSString *)failMessage{
    [HudHelper showAlertViewWithMessage:failMessage];
}

//取车结果(signalName是takeCarReply)
- (void)didGetAnotherTakeCarResult:(NSDictionary *)jsonResult{
    [HudHelper hideHudToView:self.view];
    if ([jsonResult[@"data"][@"value"] isEqualToString:@"0"]) {//取车成功
        //修改订单状态为取车
        OrderManager *takeManager = [[OrderManager alloc] initWithLoginName:self.anOrder.loginName];
        [takeManager takeCar:self.anOrder.orderID];
        //返回主界面
        [HudHelper showAlertViewWithMessage:@"取车成功，祝您用车愉快！"];
        return;
    } else {//取车失败
        NSString *error = [NSString stringWithFormat:@"取车失败[%@]",jsonResult[@"data"][@"value"]];
        [HudHelper showAlertViewWithMessage:error];
    }
}
- (void)backToRootVC{
    [self.navigationController popToRootViewControllerAnimated:YES];
}
//还车结果
- (void)didGetReturnCarResult:(NSDictionary *)jsonResult{
    [HudHelper hideHudToView:self.view];
    if ([jsonResult[@"data"][@"value"] isEqualToString:@"0"]) {//成功
        //修改订单状态为完成
        OrderManager *returnManager = [[OrderManager alloc] initWithLoginName:self.anOrder.loginName];
        [returnManager returnCar:self.anOrder.orderID];
        [HTTPHelper getConsumeCostHistoryByOrderId:self.anOrder.orderID success:^(NSDictionary *jsonResult) {
            NSLog(@"%s",__func__);
            if ([jsonResult[@"Result"] isEqualToString:@"1"]) {
                NSString *realConsumeAmt = [NSString stringWithFormat:@"您已还车成功，您此次用车消费%@元，违章等其他费用将在7日内结算完成，消费明细可前往历史订单查看。",jsonResult[@"Table"][0][@"RealConsumeAmt"]];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"还车成功" message:realConsumeAmt delegate:nil cancelButtonTitle:@"好" otherButtonTitles: nil];
                [alert show];
            }
        } failure:^(NSString *errorMessage) {
            NSLog(@"%s error:%@",__func__,errorMessage);
        }];
        return;
    } else {//失败
        NSString *error = [NSString stringWithFormat:@"还车失败[%@]",jsonResult[@"data"][@"value"]];
        [HudHelper showAlertViewWithMessage:error];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 9;
}

//调整session header的高度
- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return CGFLOAT_MIN;
}


@end
