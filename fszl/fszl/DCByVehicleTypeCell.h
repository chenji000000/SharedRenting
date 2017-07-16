//
//  DCByVehicleTypeCell.h
//  fszl
//
//  Created by YF-IOS on 15/4/7.
//  Copyright (c) 2015年 huqin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DCByVehicleTypeCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *picture1;
@property (weak, nonatomic) IBOutlet UILabel *typeName;
@property (weak, nonatomic) IBOutlet UIButton *details;
@property (weak, nonatomic) IBOutlet UILabel *enduranceMileage;//续航里程

@end
