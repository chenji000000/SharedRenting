//
//  DingCheListVC.m
//  fszl
//
//  Created by huqin on 1/6/15.
//  Copyright (c) 2015 huqin. All rights reserved.
//

#import "DingCheListVC.h"
#import "HTTPHelper.h"
#import "HudHelper.h"
#import "ReserveVehicleSignal.h"
#import "DingCheTypeVC.h"
#import "DingCheTimeVC.h"
#import "DCByVehicleTypeVC.h"

@interface DingCheListVC ()

@end

@implementation DingCheListVC

- (id)initWithStyle:(UITableViewStyle)style{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    // Return the number of sections.
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.networkInfoArray count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DingCheListCell" forIndexPath:indexPath];
    cell.textLabel.text = self.networkInfoArray[indexPath.row][@"NetworkName"];
    cell.detailTextLabel.text = self.networkInfoArray[indexPath.row][@"NetworkAddress"];
    return cell;
}

//调整session header的高度
- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return CGFLOAT_MIN;
}

//tableView delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //记录用户的选择
    [ReserveVehicleSignal sharedInstance].networkID = self.networkInfoArray[indexPath.row][@"NetworkID"];
    [ReserveVehicleSignal sharedInstance].networkName = self.networkInfoArray[indexPath.row][@"NetworkName"];
    [ReserveVehicleSignal sharedInstance].companyID = self.networkInfoArray[indexPath.row][@"CompanyID"];
    //进入下一个界面
    DingCheTimeVC *dingCheTimeVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Storyboard_DingCheTime"];
    [self.navigationController pushViewController:dingCheTimeVC animated:YES];
}

@end
