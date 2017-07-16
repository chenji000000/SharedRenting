//
//  QRCodeVC.m
//  fszl
//
//  Created by huqin on 1/9/15.
//  Copyright (c) 2015 huqin. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "QRCodeVC.h"

@interface QRCodeVC () <AVCaptureMetadataOutputObjectsDelegate, UIAlertViewDelegate>


@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) CALayer *targetLayer;
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) NSMutableArray *codeObjects;

@end

@implementation QRCodeVC
{
    UInt32 _soundID;
}
static NSString *UYLSegueToTableView = @"UYLSegueToTableView";

#pragma mark -
#pragma mark === Accessors ===
#pragma mark -

- (NSMutableArray *)codeObjects
{
    if (!_codeObjects)
    {
        _codeObjects = [NSMutableArray new];
    }
    return _codeObjects;
}

- (AVCaptureSession *)captureSession
{
    if (!_captureSession)
    {
        NSError *error = nil;
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        if (device.isAutoFocusRangeRestrictionSupported)
        {
            if ([device lockForConfiguration:&error])
            {
                [device setAutoFocusRangeRestriction:AVCaptureAutoFocusRangeRestrictionNear];
                [device unlockForConfiguration];
            }
        }
        
        // The first time AVCaptureDeviceInput creation will present a dialog to the user
        // requesting camera access. If the user refuses the creation fails.
        // See WWDC 2013 session #610 for details, but note this behaviour does not seem to
        // be enforced on iOS 7 where as it is with iOS 8.
        
        AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
        if (deviceInput)
        {
            _captureSession = [[AVCaptureSession alloc] init];
            if ([_captureSession canAddInput:deviceInput])
            {
                [_captureSession addInput:deviceInput];
            }
            
            AVCaptureMetadataOutput *metadataOutput = [[AVCaptureMetadataOutput alloc] init];
            if ([_captureSession canAddOutput:metadataOutput])
            {
                [_captureSession addOutput:metadataOutput];
                [metadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
                [metadataOutput setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
            }
            
            self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
            self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
            self.previewLayer.frame = self.view.bounds;
            [self.view.layer addSublayer:self.previewLayer];
            
            self.targetLayer = [CALayer layer];
            self.targetLayer.frame = self.view.bounds;
            [self.view.layer addSublayer:self.targetLayer];
            
            /*
            UILabel * labIntroudction= [[UILabel alloc] initWithFrame:CGRectMake(15, 40, 290, 50)];
            labIntroudction.backgroundColor = [UIColor clearColor];
            labIntroudction.numberOfLines=2;
            labIntroudction.textColor=[UIColor whiteColor];
            labIntroudction.text=@"将二维码图像置于矩形方框内，离手机摄像头10CM左右，系统会自动识别。";
            [self.view addSubview:labIntroudction];
            */
            
            UIImageView * imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 300, 300)];
            imageView.center = self.view.center;
            imageView.image = [UIImage imageNamed:@"QRCode_square"];
            [self.view addSubview:imageView];
            
        }
        else
        {
            NSLog(@"Input Device error: %@",[error localizedDescription]);
            [self showAlertForCameraError:error];
        }
    }
    return _captureSession;
}

#pragma mark -
#pragma mark === View Lifecycle ===
#pragma mark -

- (void)viewDidLoad
{
    [super viewDidLoad];
    

    
    //初始化_soundID
    CFBundleRef mainBundle = CFBundleGetMainBundle();
    CFURLRef soundFileURLRef;
    soundFileURLRef = CFBundleCopyResourceURL(mainBundle, (CFStringRef) @"Tink 1", CFSTR ("wav"), NULL);
    AudioServicesCreateSystemSoundID(soundFileURLRef, &_soundID);
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillEnterForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    [self startRunning];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self stopRunning];
}

- (void)applicationDidEnterBackground:(NSNotification *)notification
{
    [self stopRunning];
}

- (void)applicationWillEnterForeground:(NSNotification *)notification
{
    [self startRunning];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//取消
- (IBAction)quXiaoButtonPressed:(UIBarButtonItem *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark -
#pragma mark === Segue ===
#pragma mark -

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([identifier isEqualToString:UYLSegueToTableView])
    {
        return [self.codeObjects count];
    }
    
    return NO;
}

/*
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:UYLSegueToTableView])
    {
        //UYLTableViewController *viewController = segue.destinationViewController;
        //viewController.codeObjects = self.codeObjects;
        NSLog(@"%@",self.codeObjects);
    }
}
 */

#pragma mark -
#pragma mark === AVCaptureMetadataOutputObjectsDelegate ===
#pragma mark -
//扫描到信息
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    [self stopRunning];
    
    self.codeObjects = nil;
    
    for (AVMetadataObject *metadataObject in metadataObjects)
    {
        AVMetadataObject *transformedObject = [self.previewLayer transformedMetadataObjectForMetadataObject:metadataObject];
        [self.codeObjects addObject:transformedObject];
    }
    
    [self clearTargetLayer];
    [self showDetectedObjects];
    
    //延时0.5秒
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
    {
        //发声
        AudioServicesPlaySystemSound(_soundID);
        
        AVMetadataMachineReadableCodeObject *obj = metadataObjects[0];
        NSLog(@"%@",obj.stringValue);
        
        //delegate传值
        [self.delegate didGetStringFromQRCode:obj.stringValue];
        
        [self dismissViewControllerAnimated:YES completion:nil];
    });
}

#pragma mark -
#pragma mark === UIAlertViewDelegate ===
#pragma mark -

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //    if (buttonIndex == 1)
    //    {
    //        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    //        [[UIApplication sharedApplication] openURL:url];
    //    }
    
    /*
     if (&UIApplicationOpenSettingsURLString != NULL) {
     NSURL *appSettings = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
     [[UIApplication sharedApplication] openURL:appSettings];
     }
     */
}

#pragma mark -
#pragma mark === Utility methods ===
#pragma mark -

- (void)showAlertForCameraError:(NSError *)error
{
    NSString *buttonTitle = nil;
    NSString *message = error.localizedFailureReason ? error.localizedFailureReason : error.localizedDescription;
    
    if ((error.code == AVErrorApplicationIsNotAuthorizedToUseDevice))
        //&& UIApplicationOpenSettingsURLString)
    {
        // Starting with iOS 8 we can directly open the settings bundle
        // for this App so add a settings button to the alert view.
        buttonTitle = NSLocalizedString(@"AlertViewSettingsButton", @"Settings");
    }
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"AlertViewTitleCameraError", @"Camera Error")
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"AlertViewCancelButton", @"Cancel")
                                              otherButtonTitles:buttonTitle, nil];
    [alertView show];
}

- (void)startRunning
{
    self.codeObjects = nil;
    [self.captureSession startRunning];
}

- (void)stopRunning
{
    [self.captureSession stopRunning];
    self.captureSession = nil;
}

- (void)clearTargetLayer
{
    NSArray *sublayers = [[self.targetLayer sublayers] copy];
    for (CALayer *sublayer in sublayers)
    {
        [sublayer removeFromSuperlayer];
    }
}

- (void)showDetectedObjects
{
    for (AVMetadataObject *object in self.codeObjects)
    {
        if ([object isKindOfClass:[AVMetadataMachineReadableCodeObject class]])
        {
            CAShapeLayer *shapeLayer = [CAShapeLayer layer];
            shapeLayer.strokeColor = [UIColor redColor].CGColor;
            shapeLayer.fillColor = [UIColor clearColor].CGColor;
            shapeLayer.lineWidth = 2.0;
            shapeLayer.lineJoin = kCALineJoinRound;
            CGPathRef path = createPathForPoints([(AVMetadataMachineReadableCodeObject *)object corners]);
            shapeLayer.path = path;
            CFRelease(path);
            [self.targetLayer addSublayer:shapeLayer];
        }
    }
}

CGMutablePathRef createPathForPoints(NSArray* points)
{
	CGMutablePathRef path = CGPathCreateMutable();
	CGPoint point;
	
	if ([points count] > 0)
    {
		CGPointMakeWithDictionaryRepresentation((CFDictionaryRef)[points objectAtIndex:0], &point);
		CGPathMoveToPoint(path, nil, point.x, point.y);
		
		int i = 1;
		while (i < [points count])
        {
			CGPointMakeWithDictionaryRepresentation((CFDictionaryRef)[points objectAtIndex:i], &point);
			CGPathAddLineToPoint(path, nil, point.x, point.y);
			i++;
		}
		
		CGPathCloseSubpath(path);
	}
	
	return path;
}

@end
