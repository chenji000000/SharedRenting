//
//  DingChePricePolicyVC.h
//  fszl
//
//  Created by huqin on 1/9/15.
//  Copyright (c) 2015 huqin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DingChePricePolicyDelegate <NSObject>
@optional
- (void)didChoosePricePolicy;
@end


//该类是价格策略界面的VC
@interface DingChePricePolicyVC : UITableViewController

//初始化用
@property (nonatomic,strong) NSArray *pricePolicyArray;

@property (nonatomic, weak) id <DingChePricePolicyDelegate>delegate;

@end
 