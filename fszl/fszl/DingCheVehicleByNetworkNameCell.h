//
//  DingCheVehicleByNetworkNameCell.h
//  fszl
//
//  Created by huqin on 1/8/15.
//  Copyright (c) 2015 huqin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DingCheTypeVC.h"
//
//该类是按车牌选车界面TableViewCell
@interface DingCheVehicleByNetworkNameCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *picture;
@property (weak, nonatomic) IBOutlet UILabel *typeName;
@property (weak, nonatomic) IBOutlet UILabel *vehicleNo;
@property (weak, nonatomic) IBOutlet UIButton *details;
@property (weak, nonatomic) IBOutlet UILabel *enduranceMileage;//续航里程

@property (weak, nonatomic) IBOutlet UILabel *SOCRemainLabel;//剩余电量

@end
