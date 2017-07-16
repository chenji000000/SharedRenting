//
//  DingCheTypeVC.m
//  fszl
//
//  Created by huqin on 1/9/15.
//  Copyright (c) 2015 huqin. All rights reserved.
//

#import "DingCheTypeVC.h"
#import "HTTPHelper.h"
#import "HudHelper.h"
#import "DingChePricePolicyVC.h"
#import "DCBookWithoutPriceVC.h"
#import "ReserveVehicleSignal.h"
#import "DingCheVehicleByNetworkNameVC.h"
#import "DingCheTimeVC.h"

@interface DingCheTypeVC ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *levelsNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *fuelTypeNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *transmissionTypeNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *fuelNoNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *driveModeNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *chairsNameLabel;

@end

@implementation DingCheTypeVC

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Back"] style:UIBarButtonItemStylePlain target:self action:@selector(yuDingButtonPressed:)];
    self.navigationItem.leftBarButtonItem = back;
    [HTTPHelper getVehiclePictureWithImageView:self.imageView pictureName:self.picture];
    self.title = self.typeDict[@"TypeName"];
    self.levelsNameLabel.text = self.typeDict[@"LevelsName"];
    self.fuelTypeNameLabel.text = self.typeDict[@"FuelTypeName"];
    self.transmissionTypeNameLabel.text = self.typeDict[@"TransmissionTypeName"];
    self.fuelNoNameLabel.text = self.typeDict[@"FuelNoName"];
    self.driveModeNameLabel.text = self.typeDict[@"DriveModeName"];
    self.chairsNameLabel.text = self.typeDict[@"ChairsName"];
    
    self.tableView.rowHeight = 44;
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 8;
}
//调整session header的高度
- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return CGFLOAT_MIN;//12.0;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return CGFLOAT_MIN;//12.0;
}
//关闭模态视图
- (IBAction)yuDingButtonPressed:(UIButton *)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
