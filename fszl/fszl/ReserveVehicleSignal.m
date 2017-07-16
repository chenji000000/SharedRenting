//
//  ReserveVehicleSignal.m
//  fszl
//
//  Created by huqin on 1/8/15.
//  Copyright (c) 2015 huqin. All rights reserved.
//

#import "ReserveVehicleSignal.h"

@implementation ReserveVehicleSignal

+ (instancetype)sharedInstance
{
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    
    
    return sharedInstance;
}

@end
