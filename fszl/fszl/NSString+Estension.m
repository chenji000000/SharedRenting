//
//  NSString+Estension.m
//  fszl
//
//  Created by YF-IOS on 15/7/20.
//  Copyright (c) 2015年 huqin. All rights reserved.
//

#import "NSString+Estension.h"

@implementation NSString (Estension)
- (BOOL) match:(NSString *)pattern {
    NSRegularExpression *regular = [[NSRegularExpression alloc] initWithPattern:pattern options:0 error:nil];
    NSArray *results = [regular matchesInString:self options:0 range:NSMakeRange(0, self.length)];
    return results.count > 0;
}

- (BOOL) isPhoneNumber {
    //1.全部是数字
    //2.11位
    //3.以13/15/17/18开头
    return [self match:@"^1[3578]\\d{9}$"];
}

- (BOOL) isBankCardNo {
    //1.全部是数字
    //2.16/19位
    //3.以62开头
    NSString *pattern = @"^62\\d{14}$|^62\\d{17}$";
    return [self match:pattern];
}
@end
