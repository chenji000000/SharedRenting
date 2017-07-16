//
//  AccountManger.m
//  fszl
//
//  Created by huqin on 1/16/15.
//  Copyright (c) 2015 huqin. All rights reserved.
//

#import "AccountManger.h"

@implementation AccountManger

+ (instancetype)sharedInstance
{
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

-(NSString *)account
{
    return [NSString stringWithFormat:@"%@",self.loginName];
}

@end
