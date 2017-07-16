//
//  CouponViewController.h
//  fszl
//
//  Created by YF-IOS on 15/6/4.
//  Copyright (c) 2015年 huqin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ChooseCouponDelegate <NSObject>
@optional
//- (void)didChooseCoupon:(NSArray *)indexPaths;//(多选改单选)
- (void)didChooseCoupon:(NSIndexPath *)indexPath;
@end

@interface CouponViewController : UITableViewController

@property (nonatomic, strong) NSArray *selectRows;//已选择的优惠券
@property (nonatomic, strong) NSArray *couponArray;//优惠券数组
@property (nonatomic, strong) NSIndexPath *selectRow;//已选择的优惠券


@property (nonatomic, assign) id<ChooseCouponDelegate> delegate;

@end
