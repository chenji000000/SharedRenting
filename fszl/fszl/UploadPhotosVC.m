//
//  UploadPhotosVC.m
//  fszl
//
//  Created by huqin on 1/23/15.
//  Copyright (c) 2015 huqin. All rights reserved.
//  上传证件

#import "UploadPhotosVC.h"
#import "HTTPHelper.h"
#import "HudHelper.h"
#import "AccountManger.h"
#import "LoginVC.h"

typedef NS_ENUM(NSInteger, PhotoType) {
    PhotoTypeSFZ = 1,//选择身份证的照片
    PhotoTypeJSZ = 2,//选择驾驶者的照片
    PhotoTypeBRZP = 3  //选择本人照片
};

@interface UploadPhotosVC ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate,UIActionSheetDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;
@property (weak, nonatomic) IBOutlet UIImageView *sfzImageView;
@property (weak, nonatomic) IBOutlet UIImageView *jszImageView;
@property (weak, nonatomic) IBOutlet UIButton *sfzButton;
@property (weak, nonatomic) IBOutlet UIButton *brzpButton;
@property (weak, nonatomic) IBOutlet UIButton *jszButton;
@property (weak, nonatomic) IBOutlet UILabel *sfzLabel;
@property (weak, nonatomic) IBOutlet UILabel *brzpLabel;
@property (weak, nonatomic) IBOutlet UILabel *jszLabel;

@property (weak, nonatomic) IBOutlet UIView *photoView;
@property (weak, nonatomic) IBOutlet UIView *sfzContainerView;
@property (weak, nonatomic) IBOutlet UIView *jszContainerView;

@property (nonatomic) PhotoType type;

@end

@implementation UploadPhotosVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
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
    // Do any additional setup after loading the view.
    //修改返回键样式
    UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Back"] style:UIBarButtonItemStylePlain target:self action:@selector(popToLastViewController)];
    self.navigationItem.leftBarButtonItem = back;
    NSString *loginStatus = [[NSUserDefaults standardUserDefaults] valueForKey:@"LoginStatus"];//账号验证状态
    if ([loginStatus isEqualToString:@"1"]) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
        self.sfzContainerView.userInteractionEnabled = NO;
        self.jszContainerView.userInteractionEnabled = NO;
    }
}
- (void)popToLastViewController {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //隐藏底部标签栏
    //    self.tabBarController.tabBar.hidden = YES;
    [HTTPHelper getMemberInfoWithLoginName:[AccountManger sharedInstance].loginName status:@"" equalsOrlikes:@"1" success:^(NSDictionary *jsonResult) {
        NSDictionary *member = jsonResult[@"Table"][0];
        self.photoImageView.hidden = YES;
        self.sfzImageView.hidden = YES;
        self.jszImageView.hidden = YES;
        NSString *personalIMGPath = member[@"PersonalIMGPath"];//个人照片
        NSString *IDCardIMGPath = member[@"IDCardIMGPath"];//身份证照片
        NSString *driverLicenseIMGPath = member[@"DriverLicenseIMGPath"];//驾驶证照片
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
        if (![driverLicenseIMGPath isEqualToString:@""]) {
            self.jszImageView.hidden = NO;
            self.jszButton.hidden = YES;
            [HTTPHelper getVehiclePictureWithImageView:self.jszImageView pictureName:driverLicenseIMGPath];
        }
    } failure:^(NSString *errorMessage) {
        
    }];
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)brzpButtonPressed:(UIButton *)sender {
    [[[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"拍照" otherButtonTitles:@"从相册选择",nil] showInView:self.view];
    self.type = PhotoTypeBRZP;
}

//选择身份证照片
- (IBAction)sfzButtonPressed:(UIButton *)sender{
    [[[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"拍照" otherButtonTitles:@"从相册选择",nil] showInView:self.view];
    self.type = PhotoTypeSFZ;
}

//选择驾驶证照片
- (IBAction)jszButtonPressed:(UIButton *)sender{
    [[[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"拍照" otherButtonTitles:@"从相册选择",nil] showInView:self.view];
    self.type = PhotoTypeJSZ;
}
//上传本人照片
- (IBAction)uploadBrzp:(UIButton *)sender {
    //没图片
    if (!self.photoImageView.image) {
        [HudHelper showHudWithMessage:@"请选择照片后上传" toView:self.view];
        return;
    }
    //如果没有登录
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"Password"] == nil && [AccountManger sharedInstance].memberId == nil) {
        LoginVC *loginVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Storyboard_Login"];
        //loginVC.didLoginBlock = ^(){[self uploadButtonPressed:sender];};
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:loginVC];
        [self presentViewController:navigationController animated:YES completion:nil];
        return;
    } else {
        [sender setEnabled:NO];
        [HudHelper showProgressHudWithMessage:@"正在上传..." toView:self.view];
        [HTTPHelper uploadPhotoByLogiName:[AccountManger sharedInstance].loginName photo:self.photoImageView.image telephone:[AccountManger sharedInstance].telephone type:@"2" success:^(NSString * result) {
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

//上传
- (IBAction)uploadButtonPressed:(UIBarButtonItem *)sender{
    //没图片
    if (!self.sfzImageView.image && !self.jszImageView.image) {
        [HudHelper showHudWithMessage:@"请选择照片后上传" toView:self.view];
        return;
    }
    //如果没有登录
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"Password"] == nil && [AccountManger sharedInstance].memberId == nil) {
        LoginVC *loginVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Storyboard_Login"];
        //loginVC.didLoginBlock = ^(){[self uploadButtonPressed:sender];};
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:loginVC];
        [self presentViewController:navigationController animated:YES completion:nil];
        return;
    } else {//已经登录
        //判断账号信息是否已经保存到AccountManger,未保存则保存
        if ([AccountManger sharedInstance].memberId == nil) {
            [AccountManger sharedInstance].loginName = [[NSUserDefaults standardUserDefaults] valueForKey:@"LoginName"];
            [AccountManger sharedInstance].memberId = [[NSUserDefaults standardUserDefaults] valueForKey:@"MemberId"];
            [AccountManger sharedInstance].telephone = [[NSUserDefaults standardUserDefaults] valueForKey:@"Telephone"];
        }
        [HudHelper showProgressHudWithMessage:@"正在上传..." toView:self.view];
        //只上传身份证
        if (self.sfzImageView.image && !self.jszImageView.image) {
            //防止反复发出请求
            [sender setEnabled:NO];
            [HTTPHelper uploadPhotoByLogiName:[AccountManger sharedInstance].loginName photo:self.sfzImageView.image telephone:[AccountManger sharedInstance].telephone type:@"0" success:^(NSString * result) {
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
        //只上传驾驶证
        if (!self.sfzImageView.image && self.jszImageView.image) {
            //防止反复发出请求
            [sender setEnabled:NO];
            [HTTPHelper uploadPhotoByLogiName:[AccountManger sharedInstance].loginName photo:self.jszImageView.image telephone:[AccountManger sharedInstance].telephone type:@"1" success:^(NSString * result) {
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
        //上传两证
        if (self.sfzImageView.image && self.jszImageView.image){
            //防止反复发出请求
            [sender setEnabled:NO];
            [HTTPHelper uploadPhotoByLogiName:[AccountManger sharedInstance].loginName photo:self.sfzImageView.image telephone:[AccountManger sharedInstance].telephone type:@"0" success:^(NSString * result) {
                [sender setEnabled:YES];
                if (![result isEqualToString: @"0"]) {//成功
                    [HTTPHelper uploadPhotoByLogiName:[AccountManger sharedInstance].loginName photo:self.jszImageView.image telephone:[AccountManger sharedInstance].telephone type:@"1" success:^(NSString * result) {
                        [sender setEnabled:YES];
                        if (![result isEqualToString: @"0"]) {//成功
                            [HudHelper showHudWithMessage:@"上传成功" toView:self.view];
                        } else{//失败
                            [HudHelper showHudWithMessage:@"只成功上传一张照片" toView:self.view];
                        }
                    } failure:^(NSString *errorMessage) {
                        [sender setEnabled:YES];
                        [HudHelper showHudWithMessage:errorMessage toView:self.view];
                    }];
                } else{//失败
                    //防止反复发出请求
                    [sender setEnabled:NO];
                    [HudHelper showHudWithMessage:@"上传失败" toView:self.view];
                }
            } failure:^(NSString *errorMessage) {
                [sender setEnabled:YES];
                [HudHelper showHudWithMessage:errorMessage toView:self.view];
            }];
        }
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
        self.sfzImageView.contentMode = UIViewContentModeScaleAspectFit;
        self.sfzButton.hidden = YES;
//        self.sfzLabel.hidden = YES;
    }
    //驾驶证
    if (self.type == PhotoTypeJSZ) {
        self.jszImageView.hidden = NO;
        self.jszImageView.image = newImage;
        self.jszImageView.contentMode = UIViewContentModeScaleAspectFit;
        self.jszButton.hidden = YES;
//        self.jszLabel.hidden = YES;
    }
    //本人照片
    if (self.type == PhotoTypeBRZP) {
        self.photoImageView.hidden = NO;
        self.photoImageView.image = newImage;
        self.photoImageView.contentMode = UIViewContentModeScaleAspectFit;
        self.brzpButton.hidden = YES;
//        self.brzpLabel.hidden = YES;
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
