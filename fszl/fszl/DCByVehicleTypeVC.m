//
//  DCByVehicleTypeVC.m
//  fszl
//
//  Created by YF-IOS on 15/4/7.
//  Copyright (c) 2015年 huqin. All rights reserved.
//

#import "DCByVehicleTypeVC.h"
#import "DCByVehicleTypeCell.h"
#import "HTTPHelper.h"
#import "HudHelper.h"
#import "DingCheTypeVC.h"
#import "DingCheTimeVC.h"
#import "DCBookWithoutPriceVC.h"
#import "ReserveVehicleSignal.h"
#import "DCBookWithPriceVC.h"


@interface DCByVehicleTypeVC ()


@end

@implementation DCByVehicleTypeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    /*(已修改，改为默认选车牌)
    //选车牌按钮
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithTitle:@"选车牌" style:UIBarButtonItemStylePlain target:self action:@selector(change)];
    self.navigationItem.rightBarButtonItem = buttonItem;
     */
    
    //修改返回键样式
    UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Back"] style:UIBarButtonItemStylePlain target:self action:@selector(popToLastViewController)];
    self.navigationItem.leftBarButtonItem = back;
}
- (void)popToLastViewController {
    [self.navigationController popViewControllerAnimated:YES];
}
/*
//订车类型切换
- (void) change{
    //进入按车牌选车界面
    DingCheTimeVC *dingCheTimeVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Storyboard_DingCheTime"];
    [self.navigationController pushViewController:dingCheTimeVC animated:YES];
}
 */

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.vehicleArray count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DCByVehicleTypeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DCByVehicleTypeCell" forIndexPath:indexPath];
    cell.typeName.text = [NSString stringWithFormat:@"车型:%@",self.vehicleArray[indexPath.row][@"TypeName"]];
    cell.enduranceMileage.text = [NSString stringWithFormat:@"续航里程:%@公里",self.vehicleArray[indexPath.row][@"EnduranceMileage"]];
    [HTTPHelper getVehiclePictureWithImageView:cell.picture1 pictureName:self.vehicleArray[indexPath.row][@"Picture"]];
    cell.details.tag = indexPath.row;
    [cell.details addTarget:self action:@selector(showTypeView:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

//车型详情
- (void) showTypeView:(UIButton *) sender{
    sender.enabled = NO;
    NSString *picture = self.vehicleArray[sender.tag][@"Picture"];
    [HTTPHelper getVehicleTypeWithTypeName:self.vehicleArray[sender.tag][@"TypeName"] equalsOrlikes:@"1" typeID:@"" companyID:@"" success:^(NSDictionary *jsonResult) {
        sender.enabled = YES;
        if ([jsonResult[@"Result"] isEqualToString: @"1"]) {//成功
            NSArray *array = jsonResult[@"Table"];
            NSDictionary *dict = array[0];
            DingCheTypeVC *typeVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Storyboard_DingCheType"];
            typeVC.typeDict = dict;
            typeVC.picture = picture;
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:typeVC];
            [self presentViewController:nav animated:YES completion:nil];
        } else{//失败
            [HudHelper showHudWithMessage:@"信息错误" toView:self.view];
        }
    } failure:^(NSString *errorMessage) {//网络问题
        sender.enabled = YES;
        [HudHelper showHudWithMessage:errorMessage toView:self.view];
    }];
}

//tableView delegate 点击tableViewCell时触发
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //记录用户的选择
    [ReserveVehicleSignal sharedInstance].vehicleTypeID = self.vehicleArray[indexPath.row][@"TypeID"];
    [ReserveVehicleSignal sharedInstance].vehicleTypeName = self.vehicleArray[indexPath.row][@"TypeName"];
    [ReserveVehicleSignal sharedInstance].vehicleNo = @"";
    [ReserveVehicleSignal sharedInstance].deptName = self.vehicleArray[indexPath.row][@"DeptName"];
    //进入下一个界面
    DCBookWithPriceVC *yuDingVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Storyboard_DCBookWithPrice"];
    [self.navigationController pushViewController:yuDingVC animated:YES];
}

//调整session header的高度
- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return CGFLOAT_MIN;
}
@end
