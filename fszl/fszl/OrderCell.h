//
//  OrderCell.h
//  fszl
//
//  Created by huqin on 1/19/15.
//  Copyright (c) 2015 huqin. All rights reserved.
//  订单页面单元格

#import <UIKit/UIKit.h>

@interface OrderCell : UITableViewCell

//@property (weak, nonatomic) IBOutlet UILabel *loginNameLabel;

@property (weak, nonatomic) IBOutlet UILabel *vehicleTypeLabel;

@property (weak, nonatomic) IBOutlet UILabel *vehicleNoLabel;
@property (weak, nonatomic) IBOutlet UILabel *networkNameLabel;

@property (weak, nonatomic) IBOutlet UILabel *orderIdLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@property (weak, nonatomic) IBOutlet UIButton *button;

@property (weak, nonatomic) IBOutlet UILabel *costLabel;


@end
