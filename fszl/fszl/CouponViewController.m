//
//  CouponViewController.m
//  fszl
//
//  Created by YF-IOS on 15/6/4.
//  Copyright (c) 2015年 huqin. All rights reserved.
//

#import "CouponViewController.h"

@interface CouponViewController ()

@end

@implementation CouponViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //取消按键(无需取消按键 以后可改为全选按键)（改单选后变更为不使用优惠券）
    UIBarButtonItem *cancleButton = [[UIBarButtonItem alloc] initWithTitle:@"不使用优惠券" style:UIBarButtonItemStylePlain target:self action:@selector(cancleButtonPressed)];
    self.navigationItem.rightBarButtonItem = cancleButton;
    //确定按键
//    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(doneButtonPressed)];
//    self.navigationItem.rightBarButtonItem = doneButton;
//    [self.tableView setEditing:YES animated:YES];
//    if ([self.selectRows count]) {
//        for (NSIndexPath *indexPath in self.selectRows) {
//            [self.tableView selectRowAtIndexPath:self.selectRow animated:YES scrollPosition:UITableViewScrollPositionNone];
//        }
//    }
    self.tableView.rowHeight = 60;//单元格高度
    self.tableView.allowsMultipleSelection = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//取消按键(无需取消按键 以后可改为全选按键)（改单选后变更为不使用优惠券）
- (void)cancleButtonPressed {
    if ([self.delegate respondsToSelector:@selector(didChooseCoupon:)]) {
        [self.delegate didChooseCoupon:nil];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}
////确定按键
//- (void)doneButtonPressed {
//    if ([self.delegate respondsToSelector:@selector(didChooseCoupon:)]) {
//        [self.delegate didChooseCoupon:self.tableView.indexPathForSelectedRow];
//    }
//    [self dismissViewControllerAnimated:YES completion:nil];
//}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.couponArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * cellID = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
    }
    // Configure the cell...
    cell.textLabel.text = self.couponArray[indexPath.row][@"CouponTypeName"];
    NSString *details = self.couponArray[indexPath.row][@"PeriodValidityEnd"];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"优惠券截止日期：%@",details];
    if (self.selectRow == indexPath) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(didChooseCoupon:)]) {
        [self.delegate didChooseCoupon:indexPath];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
}

@end
