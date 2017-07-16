//
//  MyAnnotation.h
//  zncd
//
//  Created by huqin on 12/18/14.
//  Copyright (c) 2014 whevt. All rights reserved.
//

#import "BMKPointAnnotation.h"

//该类为BMKPointAnnotation增加tag，方便消息传递
@interface MyAnnotation : BMKPointAnnotation

//增加tag
@property (nonatomic) NSInteger tag;

@end
