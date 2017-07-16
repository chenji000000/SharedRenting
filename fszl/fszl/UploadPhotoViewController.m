//
//  UploadPhotoViewController.m
//  fszl
//
//  Created by YF-IOS on 15/7/31.
//  Copyright (c) 2015年 huqin. All rights reserved.
//

#import "UploadPhotoViewController.h"
#import "HTTPHelper.h"
#import "HudHelper.h"
#import "AccountManger.h"
#import "LoginVC.h"
#import "UIImageView+AFNetworking.h"

typedef NS_ENUM(NSInteger, PhotoType) {
    PhotoTypeSFZ = 1,//选择身份证的照片1
    PhotoTypeSFZ2 = 2,//选择身份证的照片2
    PhotoTypeJSZ = 3,//选择驾驶证的照片1
//    PhotoTypeJSZ2 = 4,//选择驾驶证的照片2
    PhotoTypeBRZP = 5  //选择本人照片
};

@interface UploadPhotoViewController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate,UIActionSheetDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;
@property (weak, nonatomic) IBOutlet UIImageView *sfzImageView;
@property (weak, nonatomic) IBOutlet UIImageView *jszImageView;
@property (weak, nonatomic) IBOutlet UIButton *sfzButton;
@property (weak, nonatomic) IBOutlet UIButton *brzpButton;
@property (weak, nonatomic) IBOutlet UIButton *jszButton;
@property (weak, nonatomic) IBOutlet UILabel *sfzLabel;
@property (weak, nonatomic) IBOutlet UILabel *brzpLabel;
@property (weak, nonatomic) IBOutlet UILabel *jszLabel;

@property (weak, nonatomic) IBOutlet UIButton *sfzButton2;
@property (weak, nonatomic) IBOutlet UIImageView *sfzImageView2;


//@property (weak, nonatomic) IBOutlet UIButton *jszButton2;
//@property (weak, nonatomic) IBOutlet UIImageView *jszImageView2;


@property (weak, nonatomic) IBOutlet UIView *photoView;
@property (weak, nonatomic) IBOutlet UIView *sfzContainerView;
@property (weak, nonatomic) IBOutlet UIView *jszContainerView;

@property (nonatomic) PhotoType type;

@end

@implementation UploadPhotoViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    //给没个imageview添加手势
    [self initImageViews];
    //修改返回键样式
    UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Back"] style:UIBarButtonItemStylePlain target:self action:@selector(popToLastViewController)];
    self.navigationItem.leftBarButtonItem = back;
    //如果没有登录
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"Password"] != nil) {
        //是否通过审核的判断
        NSString *loginStatus = [[NSUserDefaults standardUserDefaults] valueForKey:@"LoginStatus"];//账号验证状态
        if ([loginStatus isEqualToString:@"1"]) {
            self.sfzContainerView.userInteractionEnabled = NO;
            self.jszContainerView.userInteractionEnabled = NO;
        }else if ([loginStatus isEqualToString:@"4"]) {
            [HudHelper showAlertViewWithMessage:@"身份证身份证审核不合格,请重新上传"];
            self.jszContainerView.userInteractionEnabled = NO;
        }else if ([loginStatus isEqualToString:@"5"]) {
            [HudHelper showAlertViewWithMessage:@"驾驶证身份证审核不合格,请重新上传"];
            self.sfzContainerView.userInteractionEnabled = NO;
        }
        //获取已上传的图片信息
        [self getImagePaths];
    }
    
}
- (void) initImageViews {
    self.sfzImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.photoImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.jszImageView.contentMode = UIViewContentModeScaleAspectFit;
    //self.jszImageView2.contentMode = UIViewContentModeScaleAspectFit;
    self.sfzImageView2.contentMode = UIViewContentModeScaleAspectFit;
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(brzpButtonPressed:)];
    tap1.numberOfTapsRequired = 1;
    tap1.numberOfTouchesRequired = 1;
    [self.photoImageView addGestureRecognizer:tap1];
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sfzButtonPressed:)];
    tap2.numberOfTapsRequired = 1;
    tap2.numberOfTouchesRequired = 1;
    [self.sfzImageView addGestureRecognizer:tap2];
    UITapGestureRecognizer *tap3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(jszButtonPressed:)];
    tap3.numberOfTapsRequired = 1;
    tap3.numberOfTouchesRequired = 1;
    [self.jszImageView addGestureRecognizer:tap3];
//    UITapGestureRecognizer *tap4 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(jszButton2Pressed:)];
//    tap4.numberOfTapsRequired = 1;
//    tap4.numberOfTouchesRequired = 1;
//    [self.jszImageView2 addGestureRecognizer:tap4];
    UITapGestureRecognizer *tap5 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sfzButton2Pressed:)];
    tap5.numberOfTapsRequired = 1;
    tap5.numberOfTouchesRequired = 1;
    [self.sfzImageView2 addGestureRecognizer:tap5];
    self.photoImageView.hidden = YES;
    self.sfzImageView.hidden = YES;
    self.jszImageView.hidden = YES;
    //self.jszImageView2.hidden = YES;
    self.sfzImageView2.hidden = YES;
}
- (void) getImagePaths {
    [HTTPHelper getMemberInfoWithLoginName:[AccountManger sharedInstance].loginName status:@"" equalsOrlikes:@"1" success:^(NSDictionary *jsonResult) {
        NSDictionary *member = jsonResult[@"Table"][0];
        NSString *personalIMGPath = member[@"PersonalIMGPath"];//个人照片
        NSString *IDCardIMGPath = member[@"IDCardIMGPath"];//身份证照片
        NSString *IDCardIMGPath2 = member[@"IDCardIMGPath2"];//身份证照片背面
        NSString *driverLicenseIMGPath = member[@"DriverLicenseIMGPath"];//驾驶证照片
        //NSString *driverLicenseIMGPath2 = member[@"DriverLicenseIMGPath2"];//驾驶证照片背面
        if (![personalIMGPath isEqualToString:@""]) {
            self.brzpButton.hidden = YES;
            self.photoImageView.hidden = NO;
            [HTTPHelper getVehiclePictureWithImageView:self.photoImageView pictureName:personalIMGPath];
        }
        if (![IDCardIMGPath isEqualToString:@""]) {
            self.sfzImageView.hidden = NO;
            self.sfzButton.hidden = YES;
            [HTTPHelper getVehiclePictureWithImageView:self.sfzImageView pictureName:IDCardIMGPath];
        }
        if (![IDCardIMGPath2 isEqualToString:@""]) {
            self.sfzImageView2.hidden = NO;
            self.sfzButton2.hidden = NO;
            [HTTPHelper getVehiclePictureWithImageView:self.sfzImageView2 pictureName:IDCardIMGPath2];
        }
        if (![driverLicenseIMGPath isEqualToString:@""]) {
            self.jszImageView.hidden = NO;
            self.jszButton.hidden = YES;
            [HTTPHelper getVehiclePictureWithImageView:self.jszImageView pictureName:driverLicenseIMGPath];
        }
//        if (![driverLicenseIMGPath2 isEqualToString:@""]) {
//            self.jszImageView2.hidden = NO;
//            self.jszButton2.hidden = YES;
//            [HTTPHelper getVehiclePictureWithImageView:self.jszImageView2 pictureName:driverLicenseIMGPath2];
//        }
    } failure:^(NSString *errorMessage) {
        [HudHelper showHudWithMessage:errorMessage toView:self.view];
    }];
}
- (void)popToLastViewController {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //隐藏底部标签栏
    //    self.tabBarController.tabBar.hidden = YES;
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 1.0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 1.0;
}
//选择本人照片
- (IBAction)brzpButtonPressed:(UIButton *)sender {
    [self showActionSheet];
    self.type = PhotoTypeBRZP;
}
//选择身份证照片1
- (IBAction)sfzButtonPressed:(UIButton *)sender{
    [self showActionSheet];
    self.type = PhotoTypeSFZ;
}
//选择身份证照片2
- (IBAction)sfzButton2Pressed:(UIButton *)sender {
    [self showActionSheet];
    self.type = PhotoTypeSFZ2;
}
//选择驾驶证照片1
- (IBAction)jszButtonPressed:(UIButton *)sender{
    [self showActionSheet];
    self.type = PhotoTypeJSZ;
}
////选择驾驶证照片2
//- (IBAction)jszButton2Pressed:(UIButton *)sender {
//    [self showActionSheet];
//    self.type = PhotoTypeJSZ2;
//}
- (void) showActionSheet{
    [[[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"拍照" otherButtonTitles:@"从相册选择",nil] showInView:self.view];
}
//上传本人照片
- (IBAction)uploadBrzp:(UIButton *)sender {
    NSLog(@"上传本人照片");
    //没图片
    if (!self.photoImageView.image) {
        [HudHelper showAlertViewWithMessage:@"请选择照片或拍照后再上传"];
        return;
    }
    //如果没有登录
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"Password"] == nil && [AccountManger sharedInstance].memberId == nil) {
        LoginVC *loginVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Storyboard_Login"];
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:loginVC];
        [self presentViewController:navigationController animated:YES completion:nil];
        return;
    } else {//已经登录
        [sender setEnabled:NO];
        [HudHelper showProgressHudWithMessage:@"正在上传..." toView:self.view];
        [HTTPHelper uploadPhotoByLogiName:[AccountManger sharedInstance].loginName photo:self.photoImageView.image telephone:[AccountManger sharedInstance].telephone type:@"2" success:^(NSString *result) {
            [sender setEnabled:YES];
            if (![result isEqualToString: @"0"]) {//成功
                [HudHelper showHudWithMessage:@"本人照片上传成功" toView:self.view];
                
            } else{//失败
                [HudHelper showHudWithMessage:@"本人照片上传失败" toView:self.view];
            }
        } failure:^(NSString *errorMessage) {
            [sender setEnabled:YES];
            [HudHelper showHudWithMessage:errorMessage toView:self.view];
        }];

    }
}

//上传身份证
- (IBAction)uploadSfz:(UIButton *)sender{
    //没图片
    NSLog(@"上传身份证照片");
    if (!self.sfzImageView.image || !self.sfzImageView2.image) {
        [HudHelper showAlertViewWithMessage:@"请选择身份证正反面照片或拍照后再上传"];
        return;
    }
    //如果没有登录
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"Password"] == nil && [AccountManger sharedInstance].memberId == nil) {
        LoginVC *loginVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Storyboard_Login"];
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:loginVC];
        [self presentViewController:navigationController animated:YES completion:nil];
        return;
    } else {//已经登录
        [sender setEnabled:NO];
        [HudHelper showProgressHudWithMessage:@"正在上传..." toView:self.view];
        [HTTPHelper uploadTwoPhotoByLogiName:[AccountManger sharedInstance].loginName photo1:self.sfzImageView.image photo2:self.sfzImageView2.image telephone:[AccountManger sharedInstance].telephone type:@"0" success:^(NSString *result) {
            [sender setEnabled:YES];
            if (![result isEqualToString: @"0"]) {//成功
                [HudHelper showHudWithMessage:@"身份证照片上传成功" toView:self.view];
            } else{//失败
                [HudHelper showHudWithMessage:@"身份证照片上传失败" toView:self.view];
            }
        } failure:^(NSString *errorMessage) {
            [sender setEnabled:YES];
            [HudHelper showHudWithMessage:errorMessage toView:self.view];
        }];
    }
}
//上传驾驶证图片
- (IBAction)uploadJsz:(UIButton *)sender {
    //没图片
    if (!self.jszImageView.image) {
        [HudHelper showAlertViewWithMessage:@"请选择驾驶证正面照片或拍照后再上传"];
        return;
    }
    //如果没有登录
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"Password"] == nil && [AccountManger sharedInstance].memberId == nil) {
        LoginVC *loginVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Storyboard_Login"];
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:loginVC];
        [self presentViewController:navigationController animated:YES completion:nil];
        return;
    } else {//已经登录
        [HudHelper showProgressHudWithMessage:@"正在上传..." toView:self.view];
        //防止反复发出请求
        [sender setEnabled:NO];
        [HTTPHelper uploadPhotoByLogiName:[AccountManger sharedInstance].loginName photo:self.jszImageView.image telephone:[AccountManger sharedInstance].telephone type:@"1" success:^(NSString *result) {
            [sender setEnabled:YES];
            if (![result isEqualToString: @"0"]) {//成功
                [HudHelper showHudWithMessage:@"驾驶证照片上传成功" toView:self.view];
            } else{//失败
                [HudHelper showHudWithMessage:@"驾驶证照片上传失败" toView:self.view];
            }
        } failure:^(NSString *errorMessage) {
            [sender setEnabled:YES];
            [HudHelper showHudWithMessage:errorMessage toView:self.view];
        }];

    }
}

//imagePickerController delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    
    NSInteger reduceFactor = (image.size.height > image.size.width) ? image.size.height / 200 : image.size.width / 200;
    //缩小尺寸
    CGSize newSize = CGSizeMake(image.size.width/reduceFactor,image.size.height/reduceFactor);
    UIGraphicsBeginImageContextWithOptions(newSize, YES, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //身份证
    if (self.type == PhotoTypeSFZ) {
        self.sfzImageView.hidden = NO;
        self.sfzImageView.image = newImage;
        self.sfzButton.hidden = YES;
    }
    //身份证2
    if (self.type == PhotoTypeSFZ2) {
        self.sfzImageView2.hidden = NO;
        self.sfzImageView2.image = newImage;
        self.sfzButton2.hidden = YES;
    }
    //驾驶证
    if (self.type == PhotoTypeJSZ) {
        self.jszImageView.hidden = NO;
        self.jszImageView.image = newImage;
        self.jszButton.hidden = YES;
    }
//    //驾驶证2
//    if (self.type == PhotoTypeJSZ2) {
//        self.jszImageView2.hidden = NO;
//        self.jszImageView2.image = newImage;
//        self.jszButton2.hidden = YES;
//    }
    //本人照片
    if (self.type == PhotoTypeBRZP) {
        self.photoImageView.hidden = NO;
        self.photoImageView.image = newImage;
        self.brzpButton.hidden = YES;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

//actionSheet delegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    //选择拍照
    if (buttonIndex == 0) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        }
    }
    //选择选照片
    else if (buttonIndex == 1) {
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    else {
        return;
    }
    imagePicker.delegate = self;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

@end