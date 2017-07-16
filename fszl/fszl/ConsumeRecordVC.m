//
//  ConsumeRecordVC.m
//  fszl
//
//  Created by YF-IOS on 15/5/19.
//  Copyright (c) 2015年 huqin. All rights reserved.
//  消费记录

#import "ConsumeRecordVC.h"

@interface ConsumeRecordVC ()
{
    CGFloat _rowHeight;//高度
}
@property (weak, nonatomic) IBOutlet UILabel *keyLabel;
@property (weak, nonatomic) IBOutlet UILabel *valueLabel;

@property (weak, nonatomic) IBOutlet UILabel *orderID;//OrderId订单号

@property (weak, nonatomic) IBOutlet UILabel *isSettlement;//IsSettlement是否结算(1已结算 0未结算)

@end

@implementation ConsumeRecordVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"消费记录";
    [self showData];
    //数据显示
    if ([self.consumeRecord[@"IsSettlement"] integerValue] == 1) {
        self.isSettlement.text = @"已完成结算";
    } else {
        self.isSettlement.text = @"未完成结算";
    }
    
    //修改返回键样式
    UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Back"] style:UIBarButtonItemStylePlain target:self action:@selector(popToLastViewController)];
    self.navigationItem.leftBarButtonItem = back;
}
- (void)popToLastViewController {
    [self.navigationController popViewControllerAnimated:YES];
}

//MemberDiscount 会员折扣,(暂未使用)
//ScopeAmt 积分兑换后的金额,
//Remark 备注,
//FormulaExpressionChinese 总费用中文公式
//FormulaExpressionValue 总费用数字公式
//IsSettlement是否结算(1已结算 0未结算)
//消费记录数据显示0000000000
- (void) showData {
    self.orderID.text = self.order.orderID;
    NSMutableString *keyString = [NSMutableString string];
    NSMutableString *valueString = [NSMutableString string];
    //BalanceCurrentAvaliable 当前账户余额,//ConsumeTime 消费时间,//MemberAccount 会员帐号,//MemberName 会员姓名,
    [keyString appendString:@"消费时间:\n会员姓名:\n会员账号:\n当前余额(元):\n车型:\n车牌:\n预计取车时间:\n预计还车时间:"];
    [valueString appendString:[NSString stringWithFormat:@"%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@",self.consumeRecord[@"ConsumeTime"],self.consumeRecord[@"MemberName"],self.consumeRecord[@"MemberAccount"],self.consumeRecord[@"BalanceCurrentAvaliable"],self.order.vehicleTypeName,self.order.vehicleNo,self.order.expectTakeTime,self.order.expectReturnTime]];
    if (![self.order.RealTakeTime isEqualToString:@""]) {
        [keyString appendString:@"\n实际取车时间:"];
        [valueString appendFormat:@"\n%@",self.order.RealTakeTime];
    }
    if (![self.order.RealReturnTime isEqualToString:@""]) {
        [keyString appendString:@"\n实际还车时间:"];
        [valueString appendFormat:@"\n%@",self.order.RealReturnTime];
    }
    if ([self.consumeRecord[@"NormalMinutes"] floatValue] != 0) {//NormalMinutes 正常用车时长(分)
        [keyString appendString:@"\n正常用车时长(分):"];
        [valueString appendFormat:@"\n%@",self.consumeRecord[@"NormalMinutes"]];
    }
    if ([self.consumeRecord[@"OverTimeMinutes"] floatValue] != 0) {//OverTimeMinutes 超时用车时长(分)
        [keyString appendString:@"\n超时用车时长(分):"];
        [valueString appendFormat:@"\n%@",self.consumeRecord[@"OverTimeMinutes"]];
    }
    if ([self.consumeRecord[@"VehicleLeaseAmt"] floatValue] != 0) {//VehicleLeaseAmt 租赁费用,
        [keyString appendString:@"\n租赁费用(元):"];
        [valueString appendFormat:@"\n%@",self.consumeRecord[@"VehicleLeaseAmt"]];
    }
    if ([self.consumeRecord[@"DeductibleAmount"] floatValue] != 0) {//DeductibleAmount 不计免赔
        [keyString appendString:@"\n不计免赔(元):"];
        [valueString appendFormat:@"\n%@",self.consumeRecord[@"DeductibleAmount"]];
    }
    if ([self.consumeRecord[@"CouponDiscount"] floatValue] != 0) {//CouponDiscount 优惠金额,
        [keyString appendString:@"\n优惠金额(元):"];
        [valueString appendFormat:@"\n%@",self.consumeRecord[@"CouponDiscount"]];
    }
    if ([self.consumeRecord[@"Discount"] floatValue] != 1) {//Discount 优惠卷总折扣
        [keyString appendString:@"\n优惠卷折扣:"];
        CGFloat discount = [self.consumeRecord[@"Discount"] floatValue] * 100;
        [valueString appendFormat:@"\n%d折",(int)discount];
    }
    if ([self.consumeRecord[@"DamageCompAmt"] floatValue] != 0) {//DamageCompAmt 车损费,
        [keyString appendString:@"\n车损费(元):"];
        [valueString appendFormat:@"\n%@",self.consumeRecord[@"DamageCompAmt"]];
    }
    if ([self.consumeRecord[@"ViolationAmt"] floatValue] != 0) {//ViolationAmt 违章费,
        [keyString appendString:@"\n违章费(元):"];
        [valueString appendFormat:@"\n%@",self.consumeRecord[@"ViolationAmt"]];
    }
    if ([self.consumeRecord[@"CommissionCost"] floatValue] != 0) {//CommissionCost 违章代办费,
        [keyString appendString:@"\n违章代办费(元):"];
        [valueString appendFormat:@"\n%@",self.consumeRecord[@"CommissionCost"]];
    }
    if ([self.consumeRecord[@"MaintenanceCost"] floatValue] != 0) {//MaintenanceCost 维修费,
        [keyString appendString:@"\n维修费(元):"];
        [valueString appendFormat:@"\n%@",self.consumeRecord[@"MaintenanceCost"]];
    }
    if ([self.consumeRecord[@"OverTimeCost"] floatValue] != 0) {//OverTimeCost 超时费用,
        [keyString appendString:@"\n超时费用(元):"];
        [valueString appendFormat:@"\n%@",self.consumeRecord[@"OverTimeCost"]];
    }
    if ([self.consumeRecord[@"OtherAmt"] floatValue] != 0) {//OtherAmt 其他费,
        [keyString appendString:@"\n其他费用(元):"];
        [valueString appendFormat:@"\n%@",self.consumeRecord[@"OtherAmt"]];
    }
    if ([self.consumeRecord[@"TotalConsumeAmt"] floatValue] != 0) {//TotalConsumeAmt 优惠前总金额,
        [keyString appendString:@"\n优惠前总金额(元):"];
        [valueString appendFormat:@"\n%@",self.consumeRecord[@"TotalConsumeAmt"]];
    }
    if ([self.consumeRecord[@"RealConsumeAmt"] floatValue] != 0) {//RealConsumeAmt 实际消费金额,
        [keyString appendString:@"\n实际消费金额(元):"];
        [valueString appendFormat:@"\n%@",self.consumeRecord[@"RealConsumeAmt"]];
    }
    CGSize keyLabelSize = [keyString sizeWithAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:16]}];
    CGSize valueLabelSize = [valueString sizeWithAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:16]}];
    self.keyLabel.frame = CGRectMake(8, 39, 128, keyLabelSize.height);
    self.keyLabel.text = keyString;
    self.valueLabel.frame = CGRectMake(136, 39, 176, valueLabelSize.height);
    self.valueLabel.text = valueString;
    self.valueLabel.textAlignment = NSTextAlignmentRight;
    self.isSettlement.frame = CGRectMake(8, 47+keyLabelSize.height, 304, 21);
    
    _rowHeight = 47+29+keyLabelSize.height;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 1;
}
//调整session header的高度
- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return CGFLOAT_MIN;
}
- (CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return CGFLOAT_MIN;//12.0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return _rowHeight;
}
@end

