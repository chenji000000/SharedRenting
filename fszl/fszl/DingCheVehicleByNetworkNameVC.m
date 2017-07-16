//
//  DingCheVehicleByNetworkNameVC.m
//  fszl
//
//  Created by huqin on 1/8/15.
//  Copyright (c) 2015 huqin. All rights reserved.
//

#import "DingCheVehicleByNetworkNameVC.h"
#import "DingCheVehicleByNetworkNameCell.h"
#import "HTTPHelper.h"
#import "ReserveVehicleSignal.h"
#import "HudHelper.h"
#import "DingCheTypeVC.h"

#import "DCBookWithoutPriceVC.h"
#import "DCBookWithPriceVC.h"


@interface DingCheVehicleByNetworkNameVC ()

@property (nonatomic, strong) NSMutableArray *filteredArray;//筛选过后显示的车辆数组

@end

@implementation DingCheVehicleByNetworkNameVC

- (id)initWithStyle:(UITableViewStyle)style{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    //修改返回键样式
    UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Back"] style:UIBarButtonItemStylePlain target:self action:@selector(popToLastViewController)];
    self.navigationItem.leftBarButtonItem = back;
    self.filteredArray = [NSMutableArray arrayWithCapacity:1];
    for (NSDictionary *dict in self.vehicleArray) {
        if ([dict[@"Levels"] integerValue] == self.level || self.level== 0) {
            if ([dict[@"TransmissionType"] integerValue] ==self.transmissionType  || self.transmissionType == 0) {
                [self.filteredArray addObject:dict];
            }
        }
    }
    [self.tableView reloadData];
}
- (void)popToLastViewController {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.filteredArray count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    DingCheVehicleByNetworkNameCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DingCheVehicleByNetworkNameCell" forIndexPath:indexPath];
    cell.typeName.text = [NSString stringWithFormat:@"车型:%@",self.filteredArray[indexPath.row][@"TypeName"]];
    cell.vehicleNo.text = [NSString stringWithFormat:@"车牌:%@",self.filteredArray[indexPath.row][@"VehicleNo"]];
    cell.enduranceMileage.text = [NSString stringWithFormat:@"续航里程:%@公里",self.filteredArray[indexPath.row][@"EnduranceMileageRemain"]];
    cell.SOCRemainLabel.text = [NSString stringWithFormat:@"剩余电量:%@%%",self.filteredArray[indexPath.row][@"SOCRemain"]];
    [HTTPHelper getVehiclePictureWithImageView:cell.picture pictureName:self.filteredArray[indexPath.row][@"Picture"]];
    cell.details.tag = indexPath.row;
    [cell.details addTarget:self action:@selector(showTypeView:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}
//调整session header的高度
- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

//车型详情
- (void) showTypeView:(UIButton *) sender{
    sender.enabled = NO;
    NSString *picture = self.filteredArray[sender.tag][@"Picture"];
    [HTTPHelper getVehicleTypeWithTypeName:self.filteredArray[sender.tag][@"TypeName"] equalsOrlikes:@"1" typeID:@"" companyID:@"" success:^(NSDictionary *jsonResult) {
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
    [ReserveVehicleSignal sharedInstance].vehicleTypeID = self.filteredArray[indexPath.row][@"VehicleTypeID"];
    [ReserveVehicleSignal sharedInstance].vehicleTypeName = self.filteredArray[indexPath.row][@"TypeName"];
    [ReserveVehicleSignal sharedInstance].vehicleNo = self.filteredArray[indexPath.row][@"VehicleNo"];
    [ReserveVehicleSignal sharedInstance].deptName = self.filteredArray[indexPath.row][@"DeptName"];
    
    //进入下一个界面
#if ZFB
    DCBookWithoutPriceVC *yuDingVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Storyboard_DCBookWithoutPrice"];
    [self.navigationController pushViewController:yuDingVC animated:YES];
#else
    DCBookWithPriceVC *yuDingVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Storyboard_DCBookWithPrice"];
    [self.navigationController pushViewController:yuDingVC animated:YES];
#endif
}

@end
