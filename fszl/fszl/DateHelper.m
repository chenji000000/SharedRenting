//
//  DateHelper.m
//  fszl
//
//  Created by huqin on 1/26/15.
//  Copyright (c) 2015 huqin. All rights reserved.
//

#import "DateHelper.h"

@implementation DateHelper

+(NSString *) getStringFromDate: (NSDate *) date{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:00"];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    return  [dateFormatter stringFromDate:date];
}

+(NSDate *) getDateFromString: (NSString *) string{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    //[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:00"];???
    //[dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    return [dateFormatter dateFromString:string];
}

@end
