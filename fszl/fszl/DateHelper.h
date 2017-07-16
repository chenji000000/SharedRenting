//
//  DateHelper.h
//  fszl
//
//  Created by huqin on 1/26/15.
//  Copyright (c) 2015 huqin. All rights reserved.
//

#import <Foundation/Foundation.h>

//该类是时间格式辅助类
@interface DateHelper : NSObject

+(NSString *) getStringFromDate: (NSDate *) date;

+(NSDate *) getDateFromString: (NSString *) string;

@end
