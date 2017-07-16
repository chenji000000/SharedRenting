//
//  DingChePricePolicyVC.m
//  fszl
//
//  Created by huqin on 1/9/15.
//  Copyright (c) 2015 huqin. All rights reserved.
//

#import "DingChePricePolicyVC.h"
#import "DingChePricePolicyCell.h"
#import "ReserveVehicleSignal.h"


@interface DingChePricePolicyVC ()
{
    NSMutableArray *_stringArray;
    NSMutableArray *_heightArray;
    NSMutableArray *_valuationTypeDescLabelFrame;
    NSMutableArray *_flagFallPriceLabelFrame;
}

@end

@implementation DingChePricePolicyVC

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    _stringArray = [NSMutableArray arrayWithCapacity:1];
    _heightArray = [NSMutableArray arrayWithCapacity:1];
    _valuationTypeDescLabelFrame = [NSMutableArray arrayWithCapacity:1];
    _flagFallPriceLabelFrame = [NSMutableArray arrayWithCapacity:1];
    for (NSDictionary *price in self.pricePolicyArray) {
        NSMutableString *priceString = [NSMutableString string];
        if ([price[@"FlagFallPrice"] doubleValue] != 0) {
            [priceString appendString:[NSString stringWithFormat:@"起步价:%@元",price[@"FlagFallPrice"]]];
            
        }
        if ([price[@"OneHourRent"] doubleValue] != 0) {
            if ([priceString length]) {
                [priceString appendString:[NSString stringWithFormat:@"\n每小时:%@元",price[@"OneHourRent"]]];
            } else {
                [priceString appendString:[NSString stringWithFormat:@"每小时:%@元",price[@"OneHourRent"]]];
            }
        }
        if ([price[@"OneKMRent"] doubleValue] != 0) {
            if ([priceString length]) {
                [priceString appendString:[NSString stringWithFormat:@"\n每公里:%@元",price[@"OneKMRent"]]];
            } else {
                [priceString appendString:[NSString stringWithFormat:@"每公里:%@元",price[@"OneKMRent"]]];
            }
        }
        if ([price[@"OneDayRent"] doubleValue] != 0) {
            if ([priceString length]) {
                [priceString appendString:[NSString stringWithFormat:@"\n一天:%@元",price[@"OneDayRent"]]];
            } else {
                [priceString appendString:[NSString stringWithFormat:@"一天:%@元",price[@"OneDayRent"]]];
            }
        }
        if ([price[@"OneWeekRent"] doubleValue] != 0) {
            if ([priceString length]) {
                [priceString appendString:[NSString stringWithFormat:@"\n一周:%@元",price[@"OneWeekRent"]]];
            } else {
                [priceString appendString:[NSString stringWithFormat:@"一周:%@元",price[@"OneWeekRent"]]];
            }
        }
        [_stringArray addObject:priceString];
        CGSize flagFallPriceLabelSize = [priceString sizeWithAttributes:@{NSFontAttributeName :[UIFont systemFontOfSize:14]}];
        CGSize valuationTypeDescLabelSize = [price[@"ValuationTypeDesc"] sizeWithAttributes:@{NSFontAttributeName :[UIFont systemFontOfSize:17]}];
        CGRect valuationTypeDescLabelFrame = CGRectMake(8, 8, 300, valuationTypeDescLabelSize.height);
        CGRect flagFallPriceLabelFrame = CGRectMake(16, 16+valuationTypeDescLabelSize.height, 300, flagFallPriceLabelSize.height);
        CGFloat rowHeight = flagFallPriceLabelSize.height + valuationTypeDescLabelSize.height + 24;
        [_heightArray addObject:[NSNumber numberWithFloat:rowHeight]];
        [_valuationTypeDescLabelFrame addObject:[NSValue valueWithCGRect:valuationTypeDescLabelFrame]];
        [_flagFallPriceLabelFrame addObject:[NSValue valueWithCGRect:flagFallPriceLabelFrame]];
    }
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.pricePolicyArray count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    DingChePricePolicyCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DingChePricePolicyCell" forIndexPath:indexPath];
    cell.valuationTypeDescLabel.text = self.pricePolicyArray[indexPath.row][@"ValuationTypeDesc"];
    cell.flagFallPriceLabel.text = _stringArray[indexPath.row];
    cell.flagFallPriceLabel.font = [UIFont systemFontOfSize:14];
    cell.valuationTypeDescLabel.frame = [_valuationTypeDescLabelFrame[indexPath.row] CGRectValue];
    cell.flagFallPriceLabel.frame = [_flagFallPriceLabelFrame[indexPath.row] CGRectValue];
    return cell;
}

//调整session header的高度
- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return CGFLOAT_MIN;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [_heightArray[indexPath.row] floatValue];
}

- (IBAction)cancelButtonPressed:(UIBarButtonItem *)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

//tableView delegate 点击tableViewCell时触发
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //记录用户的选择
    [ReserveVehicleSignal sharedInstance].valuationType = self.pricePolicyArray[indexPath.row][@"ValuationType"];
    [ReserveVehicleSignal sharedInstance].valuationTypeDesc = self.pricePolicyArray[indexPath.row][@"ValuationTypeDesc"];
    if ([self.delegate respondsToSelector:@selector(didChoosePricePolicy)]) {
        [self.delegate didChoosePricePolicy];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
