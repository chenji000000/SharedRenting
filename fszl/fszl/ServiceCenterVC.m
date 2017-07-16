//
//  ServiceCenterVC.m
//  fszl
//
//  Created by YF-IOS on 15/4/24.
//  Copyright (c) 2015年 huqin. All rights reserved.
//

#import "ServiceCenterVC.h"

@interface ServiceCenterVC ()<UIActionSheetDelegate>
{
    NSString *_phoneNumber;//电话号码
}

@end

@implementation ServiceCenterVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"app-logo"]];
//    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:image];
//    self.navigationItem.leftBarButtonItem = item;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)phoneNumber:(UIButton *)sender {
    
    NSString *str = sender.currentTitle;
    _phoneNumber = [str stringByReplacingOccurrencesOfString:@"-" withString:@""];
    NSLog(@"%@",_phoneNumber);
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:str delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"拨打" otherButtonTitles: nil];
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == actionSheet.destructiveButtonIndex) {
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",_phoneNumber]];
        [[UIApplication sharedApplication] openURL:url];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
