//
//  AccountManger.h
//  fszl
//
//  Created by huqin on 1/16/15.
//  Copyright (c) 2015 huqin. All rights reserved.
//

#import <Foundation/Foundation.h>

//该类管理账户信息
@interface AccountManger : NSObject

//单例
+ (instancetype)sharedInstance;

@property (nonatomic,strong) NSString *loginName;

@property (nonatomic,strong) NSString *memberId;

@property (nonatomic,strong) NSString *telephone;

@property (nonatomic,strong) NSString *memberAccount; //会员账号

@property (nonatomic,strong,readonly) NSString *account;//用在Socket连接中：loginName_IOS

@end
