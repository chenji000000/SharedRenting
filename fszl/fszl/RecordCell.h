//
//  RecordCell.h
//  fszl
//
//  Created by YF-IOS on 15/7/9.
//  Copyright (c) 2015年 huqin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecordCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel *amountLabel;

@end
