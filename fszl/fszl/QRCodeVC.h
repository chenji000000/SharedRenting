//
//  QRCodeVC.h
//  fszl
//
//  Created by huqin on 1/9/15.
//  Copyright (c) 2015 huqin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol QRCodeVCDelegate <NSObject>
- (void)didGetStringFromQRCode:(NSString *)str;
@end

//该类是二维码扫描界面VC
@interface QRCodeVC : UIViewController

@property (nonatomic, weak) id <QRCodeVCDelegate>delegate;

@end
