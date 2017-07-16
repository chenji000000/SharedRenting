//
//  DingCheMapVC.m
//  fszl
//
//  Created by huqin on 1/6/15.
//  Copyright (c) 2015 huqin. All rights reserved.
//

#import "DingCheMapVC.h"
#import "BMapKit.h"
#import "HTTPHelper.h"
#import "HudHelper.h"
#import "DingCheVehicleByNetworkNameVC.h"
#import "ReserveVehicleSignal.h"
#import "MyAnnotation.h"
#import "DingCheTypeVC.h"
#import "DingCheTimeVC.h"
#import "DCByVehicleTypeVC.h"
#import <MapKit/MapKit.h>

@interface DingCheMapVC () <BMKMapViewDelegate,BMKLocationServiceDelegate,UIActionSheetDelegate>
{
    BMKMapView * _mapView;
    BMKLocationService* _locService;
    CLLocationCoordinate2D _destination;//导航目的地坐标
    NSString *_destinationName;//目的地名称
}

@property (nonatomic) BOOL moveToUserFlag; //设为YES，将用户位置显示在地图中心

@end

@implementation DingCheMapVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    CGSize screen = [[UIScreen mainScreen] bounds].size;
     _mapView = [[BMKMapView alloc]initWithFrame:CGRectMake(0, 0, screen.width,screen.height-20-44-48)];//20 状态栏 44 导航栏 48 底部标签栏
    //定位初始化
    _locService = [[BMKLocationService alloc]init];
    //初始化地图位置（武汉）
    _mapView.centerCoordinate = CLLocationCoordinate2DMake(30.563702, 114.298973);
    _mapView.zoomLevel = 11;
    _mapView.showMapScaleBar = YES;
    _mapView.delegate = self;
    //将用户位置放在中心
    self.moveToUserFlag = YES;
    [self.view addSubview:_mapView];
    //添加定位及地图放大缩小
    [self addControll];
}

//添加定位及地图放大缩小
- (void) addControll{
    //添加定位按钮
    CGRect buttonFrame = CGRectMake(0, self.view.frame.size.height-170-48, 51, 51);
    UIButton * locationButton = [[UIButton alloc]initWithFrame:buttonFrame];
    [locationButton setImage:[UIImage imageNamed:@"map-location"] forState: UIControlStateNormal];
    [locationButton addTarget:self action:@selector(locationButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:locationButton];
    //地图放大缩小
    UIButton *button1 = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 55, self.view.frame.size.height-170-48, 48, 48)];
    [button1 setImage:[UIImage imageNamed:@"map-zoomin"] forState:UIControlStateNormal];
    [button1 addTarget:self action:@selector(mapZoomIn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button1];
    UIButton *button2 = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 55, self.view.frame.size.height-122-48, 48, 48)];
    [button2 setImage:[UIImage imageNamed:@"map-zoomout"] forState:UIControlStateNormal];
    [button2 addTarget:self action:@selector(mapZoomOut:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button2];
}

//地图放大
- (void) mapZoomIn:(UIButton *) sender{
    if (_mapView.zoomLevel < 19) {
        _mapView.zoomLevel++;
    } else {
        NSLog(@"地图已放大到最大级别。");
    }
}
//地图缩小
- (void) mapZoomOut:(UIButton *) sender{
    if (_mapView.zoomLevel > 3) {
        _mapView.zoomLevel -- ;
    } else {
        NSLog(@"地图已缩小到最小级别。");
    }
}
//定位按钮
- (void)locationButtonPressed{
    self.moveToUserFlag = YES;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //隐藏底部标签栏
//    self.tabBarController.tabBar.hidden = YES;
    [_mapView viewWillAppear];
    [self addPointAnnotation];
    //设置delegate
    _mapView.delegate = self;
    _locService.delegate = self;
    //开始定位
    [self startLocation:self];
}

//开始定位
-(IBAction)startLocation:(id)sender{
    NSLog(@"进入普通定位态");
    [_locService startUserLocationService];
    _mapView.showsUserLocation = NO;//先关闭显示的定位图层
    _mapView.userTrackingMode = BMKUserTrackingModeNone;//设置定位的状态
    _mapView.showsUserLocation = YES;//显示定位图层
}

//停止定位
-(IBAction)stopLocation:(id)sender{
    NSLog(@"停止定位");
    [_locService stopUserLocationService];
    _mapView.showsUserLocation = NO;
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [_mapView viewWillDisappear];
    //停止定位
    [self stopLocation:self];
    //释放delegate
    _mapView.delegate = nil;
    _locService.delegate = nil;
}

//用户位置更新后，会调用此函数
- (void)didUpdateUserLocation:(BMKUserLocation *)userLocation{
//    NSLog(@"%s",__func__);
    //将用户位置显示在地图中心
    if (self.moveToUserFlag == YES) {
        [_mapView setCenterCoordinate:userLocation.location.coordinate animated:YES] ;
        //关闭将用户位置显示在地图中心
        self.moveToUserFlag = NO;
    }
    [_mapView updateLocationData:userLocation];
}

//添加网点标注
- (void)addPointAnnotation{
    NSMutableArray * annotations = [[NSMutableArray alloc]init];

    for (NSInteger i =0; i < [self.networkInfoArray count]; i++) {
        MyAnnotation *annotation = [[MyAnnotation alloc]init];
        annotation.tag = i;
        CLLocationCoordinate2D coor;
        coor.latitude = [self.networkInfoArray[i][@"Latitude"] doubleValue];
        coor.longitude = [self.networkInfoArray[i][@"Longitude"] doubleValue];
        /*
        //转换为百度地图所需要的经纬度
        //NSDictionary *dict = BMKConvertBaiduCoorFrom(coor,BMK_COORDTYPE_GPS);
        //CLLocationCoordinate2D baiduCoor = BMKCoorDictionaryDecode(dict);
        //NSLog(@"baiduCoor: %f %f",baiduCoor.latitude,baiduCoor.longitude);//
        //将百度坐标转化为原始GPS坐标（约有10米的误差）
        NSDictionary *tmpDict = BMKConvertBaiduCoorFrom(baiduCoor,BMK_COORDTYPE_COMMON);
        CLLocationCoordinate2D tmpCoor = BMKCoorDictionaryDecode(tmpDict);
        CLLocationCoordinate2D gpsCoor = CLLocationCoordinate2DMake(2*baiduCoor.latitude-tmpCoor.latitude, 2*baiduCoor.longitude-tmpCoor.longitude);
        annotation.coordinate = baiduCoor;
        */
        annotation.coordinate = coor;
        annotation.title = self.networkInfoArray[i][@"NetworkName"];
        annotation.subtitle = self.networkInfoArray[i][@"NetworkAddress"];
        
        [annotations addObject:annotation];
    }
    [_mapView addAnnotations:annotations];
}

//根据anntation生成对应的View
- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation{
    static NSString *const AnnotationViewID = @"renameMark";
    BMKPinAnnotationView * view = (BMKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:AnnotationViewID];
    view = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewID];
    view.pinColor = BMKPinAnnotationColorGreen;
    view.animatesDrop = NO;
    view.draggable = NO;
    view.canShowCallout = YES;
    view.annotation = annotation;
    view.tag = [(MyAnnotation *)annotation tag];
    //设置弹出气泡图片
    UIView *popView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 260, 56)];
    UIImage *image = [UIImage imageNamed:@"map-icon-up"];
    UIEdgeInsets insets = UIEdgeInsetsMake(10, 10, 10, 10);
    image = [image resizableImageWithCapInsets:insets];
    //黑框
    UIImageView *backgroundView = [[UIImageView alloc]initWithImage:image];
    backgroundView.frame = CGRectMake(0, 0, 260, 46);
    [popView addSubview:backgroundView];
    //角标
    UIImageView *connerView = [[UIImageView alloc] initWithFrame:CGRectMake((260-16)/2, 46, 16, 10)];
    connerView.image = [UIImage imageNamed:@"map-icon-down"];
    [popView addSubview:connerView];
    //网点名
    UILabel *networkNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 5, 195, 20)];
    networkNameLabel.text = self.networkInfoArray[view.tag][@"NetworkName"];
    networkNameLabel.backgroundColor = [UIColor clearColor];
    networkNameLabel.font = [UIFont boldSystemFontOfSize:14];
    networkNameLabel.textColor = [UIColor whiteColor];
    networkNameLabel.textAlignment = NSTextAlignmentCenter;
    [popView addSubview:networkNameLabel];
    //网点地址
    UILabel *networkAddressLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 28, 195, 15)];
    networkAddressLabel.text = self.networkInfoArray[view.tag][@"NetworkAddress"];
    networkAddressLabel.backgroundColor = [UIColor clearColor];
    networkAddressLabel.font = [UIFont systemFontOfSize:11];
    networkAddressLabel.textColor = [UIColor whiteColor];
    networkAddressLabel.textAlignment = NSTextAlignmentCenter;
    [popView addSubview:networkAddressLabel];
    
    //导航按键
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.backgroundColor = [UIColor clearColor];
    rightButton.frame = CGRectMake(195, 0, 65, 46);
    [rightButton setImage:[UIImage imageNamed:@"map-navi"] forState:UIControlStateNormal];
    rightButton.tag = [(MyAnnotation *)annotation tag];
    [rightButton addTarget:self action:@selector(naviButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [popView addSubview:rightButton];
    
    BMKActionPaopaoView *pView = [[BMKActionPaopaoView alloc]initWithCustomView:popView];
    view.paopaoView = nil;
    view.paopaoView = pView;
    return view;
}

- (void) naviButtonPressed:(UIButton *)sender {
    NSDictionary *network = self.networkInfoArray[sender.tag];
    _destinationName = network[@"NetworkName"];
    _destination = CLLocationCoordinate2DMake([network[@"Latitude"] doubleValue], [network[@"Longitude"] doubleValue]);
    NSLog(@"%@",self.networkInfoArray[sender.tag]);
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"导航方式选择" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"苹果导航",@"百度导航", nil];
    [actionSheet showInView:self.view];
}
#pragma mark - UIActionSheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(),^(void){
        if (buttonIndex == 0){
            //转换为百度地图所需要的经纬度
            NSDictionary *dict = BMKConvertBaiduCoorFrom(_destination,BMK_COORDTYPE_GPS);
            CLLocationCoordinate2D baiduCoor = BMKCoorDictionaryDecode(dict);
            //将百度坐标转化为BMK_COORDTYPE_COMMON坐标（约有10米的误差）
            NSDictionary *tmpDict = BMKConvertBaiduCoorFrom(baiduCoor,BMK_COORDTYPE_COMMON);
            CLLocationCoordinate2D tmpCoor = BMKCoorDictionaryDecode(tmpDict);
            CLLocationCoordinate2D commonCoor = CLLocationCoordinate2DMake(2*baiduCoor.latitude-tmpCoor.latitude, 2*baiduCoor.longitude-tmpCoor.longitude);
            //起点和终点
            MKMapItem *currentLocation = [MKMapItem mapItemForCurrentLocation];
            MKMapItem *toLocation = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:commonCoor addressDictionary:nil]];
            //名称
            toLocation.name = _destinationName;
            [MKMapItem openMapsWithItems:[NSArray arrayWithObjects:currentLocation, toLocation, nil]
                           launchOptions:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:MKLaunchOptionsDirectionsModeDriving, [NSNumber numberWithBool:YES], nil] forKeys:[NSArray arrayWithObjects:MKLaunchOptionsDirectionsModeKey, MKLaunchOptionsShowsTrafficKey, nil]]];
        }
        //百度地图
        if (buttonIndex == 1){
            if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"baidumap://map/"]]){
                //转换为百度地图所需要的经纬度
                NSDictionary *dict = BMKConvertBaiduCoorFrom(_destination,BMK_COORDTYPE_GPS);
                CLLocationCoordinate2D baiduCoor = BMKCoorDictionaryDecode(dict);
                //初始化调启导航时的参数管理类
                BMKNaviPara* para = [[BMKNaviPara alloc]init];
                //指定导航类型
                para.naviType = BMK_NAVI_TYPE_NATIVE;
                //初始化终点节点
                BMKPlanNode* end = [[BMKPlanNode alloc]init];
                //指定终点经纬度
                end.pt = baiduCoor;
                //指定终点名称
                end.name = _destinationName;//_nativeEndName.text;
                //指定终点
                para.endPoint = end;
                //指定返回自定义scheme
#if ZFB
                para.appScheme = @"whevtyxgw://com.whevt.fszl";
#else 
                para.appScheme = @"whevtyxyc://com.whevt.fszl-copy-2";
#endif
                //调启百度地图客户端导航
                [BMKNavigation openBaiduMapNavigation:para];
            } else{
                [[[UIAlertView alloc] initWithTitle:@"您未安装\"百度地图\"App" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
            }
        }
    });
}
//点击标注，将屏幕以标注为中心
- (void)mapView:(BMKMapView *)mapView didSelectAnnotationView:(BMKAnnotationView *)view{
    [_mapView setCenterCoordinate:view.annotation.coordinate animated:YES];
}

//当点击annotation view弹出的泡泡时，调用此接口
- (void)mapView:(BMKMapView *)mapView annotationViewForBubble:(BMKAnnotationView *)view{
    //防止反复发出请求
    view.enabled = NO;
    //记录用户的选择
    [ReserveVehicleSignal sharedInstance].networkID = self.networkInfoArray[view.tag][@"NetworkID"];
    [ReserveVehicleSignal sharedInstance].networkName = self.networkInfoArray[view.tag][@"NetworkName"];
    [ReserveVehicleSignal sharedInstance].companyID = self.networkInfoArray[view.tag][@"CompanyID"];
    //进入下一个界面
    DingCheTimeVC *dingCheTimeVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Storyboard_DingCheTime"];
    [self.navigationController pushViewController:dingCheTimeVC animated:YES];
}

@end
