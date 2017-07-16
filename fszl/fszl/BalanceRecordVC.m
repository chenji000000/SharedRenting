//
//  BalanceRecordVC.m
//  fszl
//
//  Created by YF-IOS on 15/7/9.
//  Copyright (c) 2015年 huqin. All rights reserved.
//

#import "BalanceRecordVC.h"
#import "RecordCell.h"
#import "MJRefresh.h"
#import "HTTPHelper.h"
#import "AccountManger.h"
#import "HudHelper.h"

@interface BalanceRecordVC ()
@property (weak, nonatomic) IBOutlet UILabel *balanceLabel;

@end

@implementation BalanceRecordVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.balanceLabel.text = [NSString stringWithFormat:@"￥%@",self.accountBalance];
    self.page = 1;
    
    __weak typeof(self) weakSelf = self;
    
    // 添加传统的下拉刷新
    // 设置回调（一旦进入刷新状态就会调用这个refreshingBlock）
    [self.tableView addLegendHeaderWithRefreshingBlock:^{
        [weakSelf loadNewData];
    }];
    NSInteger totalPage = [self.total integerValue] / 10;
    if ([self.total integerValue] == [self.bizRecord count]) {
        // 拿到当前的上拉刷新控件，变为没有更多数据的状态
        [self.tableView.footer noticeNoMoreData];
    } else {
        // 添加传统的上拉刷新
        // 设置回调（一旦进入刷新状态就会调用这个refreshingBlock）
        [self.tableView addLegendFooterWithRefreshingBlock:^{
            if (weakSelf.page == totalPage) {
                weakSelf.page ++;
                [weakSelf loadLastData];
            } else {
                weakSelf.page ++;
                [weakSelf loadMoreData];
            }
        }];
    }
    
    //修改返回键样式
    UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Back"] style:UIBarButtonItemStylePlain target:self action:@selector(popToLastViewController)];
    self.navigationItem.leftBarButtonItem = back;
}
- (void)popToLastViewController {
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark 刷新时再次获取余额
- (void) balance {
    [HTTPHelper getMemberAccountByMemberID:[AccountManger sharedInstance].memberId success:^(NSDictionary *jsonResult) {
        if ([jsonResult[@"Result"] isEqualToString:@"1"]) {
            NSDictionary *memberAccount = jsonResult[@"Table"][0];
            NSString *memberAccountBalance = memberAccount[@"Balance"];
            self.balanceLabel.text = [NSString stringWithFormat:@"￥%@",memberAccountBalance];
        }
    } failure:^(NSString *errorMessage) {
        NSLog(@"%s:%@",__func__,errorMessage);
    }];
}
#pragma mark - 数据处理相关
#pragma mark 下拉刷新数据
- (void)loadNewData {
    NSLog(@"loadNewData");
    //刷新时再次获取余额
    [self balance];
    self.page = 1;
    NSString *page = [NSString stringWithFormat:@"%ld",(long)self.page];
    // 0.5秒后刷新数据
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [HTTPHelper getMemberBizRecordByMemberAccount:[AccountManger sharedInstance].memberAccount startDate:@"2014-01-01 00:00:00" endDate:@"2018-01-01 00:00:00" curPage:page pageSize:@"10" success:^(NSDictionary *jsonResult) {
            if ([jsonResult[@"Result"] isEqualToString:@"1"]) {
                NSArray *array = jsonResult[@"Table"];
                self.total = jsonResult[@"Table"][0][@"total"];
                [self.bizRecord removeAllObjects];
                [self.bizRecord addObjectsFromArray:array];
            }
            [self.tableView reloadData];
            // 拿到当前的下拉刷新控件，结束刷新状态
            [self.tableView.header endRefreshing];
            if ([self.bizRecord count] == [self.total integerValue]) {
                [self.tableView.footer noticeNoMoreData];
            } else {
                [self.tableView.footer resetNoMoreData];
            }
        } failure:^(NSString *errorMessage) {
            // 拿到当前的下拉刷新控件，结束刷新状态
            [self.tableView.header endRefreshing];
            [HudHelper showHudWithMessage:errorMessage toView:self.view];
        }];
    });
}
#pragma mark 上拉加载更多数据
- (void)loadMoreData {
    NSLog(@"loadMoreData");
    NSString *page = [NSString stringWithFormat:@"%ld",(long)self.page];
    // 0.5秒后刷新数据
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [HTTPHelper getMemberBizRecordByMemberAccount:[AccountManger sharedInstance].memberAccount startDate:@"2014-01-01 00:00:00" endDate:@"2018-01-01 00:00:00" curPage:page pageSize:@"10" success:^(NSDictionary *jsonResult) {
            if ([jsonResult[@"Result"] isEqualToString:@"1"]) {
                NSArray *array = jsonResult[@"Table"];
                self.total = jsonResult[@"Table"][0][@"total"];
                [self.bizRecord removeAllObjects];
                [self.bizRecord addObjectsFromArray:array];
            }
            [self.tableView reloadData];
            // 拿到当前的下拉刷新控件，结束刷新状态
            [self.tableView.footer endRefreshing];
        } failure:^(NSString *errorMessage) {
            // 拿到当前的下拉刷新控件，结束刷新状态
            [self.tableView.footer endRefreshing];
            [HudHelper showHudWithMessage:errorMessage toView:self.view];
        }];
    });}
#pragma mark 加载最后一份数据
- (void)loadLastData {
    NSLog(@"loadLastData");
    NSString *page = [NSString stringWithFormat:@"%ld",(long)self.page];
    // 0.5秒后刷新数据
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [HTTPHelper getMemberBizRecordByMemberAccount:[AccountManger sharedInstance].memberAccount startDate:@"2014-01-01 00:00:00" endDate:@"2018-01-01 00:00:00" curPage:page pageSize:@"10" success:^(NSDictionary *jsonResult) {
            if ([jsonResult[@"Result"] isEqualToString:@"1"]) {
                NSArray *array = jsonResult[@"Table"];
                self.total = jsonResult[@"Table"][0][@"total"];
                [self.bizRecord addObjectsFromArray:array];
            }
            [self.tableView reloadData];
            // 拿到当前的上拉刷新控件，变为没有更多数据的状态
            [self.tableView.footer noticeNoMoreData];
        } failure:^(NSString *errorMessage) {
            // 拿到当前的下拉刷新控件，结束刷新状态
            [self.tableView.footer endRefreshing];
            [HudHelper showHudWithMessage:errorMessage toView:self.view];
        }];
    });
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.bizRecord count];
}
//调整session header的高度
- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 2.0;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 2.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RecordCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RecordCell" forIndexPath:indexPath];
    NSDictionary *bizRecord = self.bizRecord[indexPath.row];
    // Configure the cell...
    cell.timeLabel.text = bizRecord[@"TxnTime"];
    if ([bizRecord[@"BizType"] isEqualToString:@"1"]) {
        cell.typeLabel.text = @"充值";
    } else {
        cell.typeLabel.text = @"提现";
    }
    cell.amountLabel.text = [NSString stringWithFormat:@"￥%@",bizRecord[@"TxnAmt"]];
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
