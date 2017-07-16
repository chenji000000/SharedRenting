//
//  DingCheVehicleByNetworkNameVC.h
//  fszl
//
//  Created by huqin on 1/8/15.
//  Copyright (c) 2015 huqin. All rights reserved.
//

#import <UIKit/UIKit.h>

//该类是按车牌选车界面VC
@interface DingCheVehicleByNetworkNameVC : UITableViewController

//初始化用
@property (nonatomic,strong) NSArray * vehicleArray;

@property (nonatomic, assign) NSInteger level;
@property (nonatomic, assign) NSInteger transmissionType;

@end
