//
//  PaymentAccountVC.m
//  fszl
//
//  Created by YF-IOS on 15/5/21.
//  Copyright (c) 2015年 huqin. All rights reserved.
//  会员支付账号管理

#import "PaymentAccountVC.h"
#import "AccountManger.h"
#import "HudHelper.h"
#import "HTTPHelper.h"
#import "EnchashmentVC.h"
#import "AddPaymentAccountVC.h"

@interface PaymentAccountVC ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *accountTableView;
@property (weak, nonatomic) IBOutlet UIView *addAccountView;
@property (weak, nonatomic) IBOutlet UILabel *addAccountLabel;
@property (nonatomic, strong) NSMutableArray *paymentAccountArray;//存放账号的数组

@end

@implementation PaymentAccountVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"账号管理";
    CGFloat height = self.view.bounds.size.height;
    CGFloat width = self.view.bounds.size.width;
    self.addAccountView.frame = CGRectMake(0, height - 48 - 50 - 2, width, 50);
    self.addAccountLabel.frame = CGRectMake(96, 13, 128, 24);
    self.accountTableView.frame = CGRectMake(0, 64, width, height - 48 - 50 - 2 - 64);
    self.accountTableView.delegate = self;
    self.accountTableView.dataSource = self;
    self.paymentAccountArray = [NSMutableArray arrayWithCapacity:1];
    //编辑按键
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(editButtonPressed)];
    self.navigationItem.rightBarButtonItem = editButton;
    
    //添加手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAddAccountView:)];
    tap.numberOfTapsRequired = 1;
    tap.numberOfTouchesRequired = 1;
    [self.addAccountLabel addGestureRecognizer:tap];
    self.accountTableView.rowHeight = 70;
    
    //修改返回键样式
    UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Back"] style:UIBarButtonItemStylePlain target:self action:@selector(popToLastViewController)];
    self.navigationItem.leftBarButtonItem = back;
}
- (void)popToLastViewController {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)tapAddAccountView:(UITapGestureRecognizer *)recognizer {
    AddPaymentAccountVC *addPayment = [self.storyboard instantiateViewControllerWithIdentifier:@"AddPaymentAccountVC"];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:addPayment];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)editButtonPressed {
    BOOL edit = self.accountTableView.isEditing;
    [self.accountTableView setEditing:!edit animated:YES];
    if (edit == YES) {
        self.addAccountView.userInteractionEnabled = YES;
        [self.navigationItem.rightBarButtonItem setTitle:@"编辑"];
    } else {
        self.addAccountView.userInteractionEnabled = NO;
        [self.navigationItem.rightBarButtonItem setTitle:@"完成"];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self getAccount];//获取已保存的支付账号
}


//获取已保存的支付账号
- (void)getAccount {
    NSString *memberAccount = [AccountManger sharedInstance].memberAccount;
    [HTTPHelper getMemberPaymentAccountByMemberAccount:memberAccount success:^(NSDictionary *jsonResult) {
        if ([jsonResult[@"Result"] isEqualToString: @"1"]) {
            [self.paymentAccountArray removeAllObjects];
            NSArray *arr = jsonResult[@"Table"];
            [self.paymentAccountArray addObjectsFromArray:arr];
            [self.accountTableView reloadData];
        }
    } failure:^(NSString *errorMessage) {
        [HudHelper showHudWithMessage:errorMessage toView:self.view];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.paymentAccountArray count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PaymentAccountCell" forIndexPath:indexPath];
    NSString *paymentType = self.paymentAccountArray[indexPath.row][@"PaymentType"];
    NSString *str = nil;
    UIImage *logo = [[UIImage alloc] init];
    if ([paymentType isEqualToString:@"1"]) {
        str = @"银联卡";
        logo = [UIImage imageNamed:@"UnionPayIcon"];
    }
    if ([paymentType isEqualToString:@"2"]) {
        str = @"支付宝账号";
        logo = [UIImage imageNamed:@"AliPayIcon"];
    }
    if ([paymentType isEqualToString:@"3"]) {
        str = @"微信账号";
        logo = [UIImage imageNamed:@"WeChatPayIcon"];
    }
    cell.textLabel.text = str;
    cell.detailTextLabel.text = self.paymentAccountArray[indexPath.row][@"PaymentAccount"];
    cell.imageView.image = logo;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10.0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 1.0;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *paymentType = self.paymentAccountArray[indexPath.row][@"PaymentType"];
    if ([paymentType isEqualToString:@"1"]) {
        EnchashmentVC *enchashment = [self.storyboard instantiateViewControllerWithIdentifier:@"Storyboard_Enchashment"];
        enchashment.paymentAccount = self.paymentAccountArray[indexPath.row];
        [self.navigationController pushViewController:enchashment animated:YES];
    } else {
        [HudHelper showAlertViewWithMessage:@"目前只支持提现到银联卡"];
        return;
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        NSDictionary *account = self.paymentAccountArray[indexPath.row];
        NSString *memberAccount = [AccountManger sharedInstance].memberAccount;
        [HTTPHelper delMemberPaymentAccountWithMemberAccount:memberAccount paymentType:account[@"PaymentType"] paymentAccount:account[@"PaymentAccount"] success:^(NSString *result) {
            if ([result isEqualToString:@"1"]) {
                [HudHelper showHudWithMessage:@"账号删除成功" toView:self.view];
                [self.paymentAccountArray removeObjectAtIndex:indexPath.row];
                [self.accountTableView reloadData];
            } else {
                [HudHelper showHudWithMessage:@"账号删除失败" toView:self.view];
            }
        } failure:^(NSString *errorMessage) {
            [HudHelper showHudWithMessage:errorMessage toView:self.view];
        }];
    }
}
//此方法能使tableview出现多选框
//-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
//}

@end
