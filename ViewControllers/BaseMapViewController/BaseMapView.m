//
//  BaseMapViewController.m
//  iLiaoNing
//
//  Created by 杨翊楷 on 14-8-18.
//  Copyright (c) 2014年 杨翊楷. All rights reserved.
//

#import "BaseMapView.h"

@interface BaseMapView() <AMapLocationManagerDelegate>
{
    int zoomLevel;              //地图显示级别
    double zoomLevels[20];      //地图显示级别集
    int regonIndex;             //据地图中心点最远POI点的下标
    BOOL refreshBegin;          //是否正在刷新
    BOOL isShowLocaltion;       //是否显示中心位置
    
    CLLocationCoordinate2D refreshCenter;
}

@property (nonatomic, strong) AMapLocationManager *locationManager;
@property (nonatomic, copy)   AMapLocatingCompletionBlock completionBlock;

@property (nonatomic, strong) NSTimer *autoRefershTimer;    //触发刷新POI事件后延迟一秒刷新
@property (nonatomic, strong) NSMutableArray *tips;         //搜索结果

@end

@implementation BaseMapView
@synthesize tips = _tips;
@synthesize mapView = _mapView;

#pragma mark - Utility

- (void)clearMapView
{
    self.mapView.showsUserLocation = NO;
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView removeOverlays:self.mapView.overlays];
    self.mapView.delegate = nil;
}

#pragma mark - Handle Action

- (void)returnAction
{
    [self clearMapView];
}

#pragma mark - Life Cycle

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        self.didUpdateLocation = NO;
        
        self.mapView = [[MAMapView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        self.mapView.scaleOrigin = CGPointMake(10, self.frame.size.height - 40);
        self.mapView.showsScale  = NO;
        self.mapView.delegate = self;
        
        self.mapView.showsUserLocation = YES;
        self.mapView.userTrackingMode  = MAUserTrackingModeFollow;
        self.mapView.distanceFilter    = 500.f;
        [self addSubview:self.mapView];
        
        self.eventDataArray = [[NSMutableArray alloc] init];
        self.annotations = [[NSMutableArray alloc] init];
        self.tips = [NSMutableArray array];
        
        
        //界面View
        [self initSubViews];
        [self initCompleteBlock];
        
        //zoom地图放大级别设定
        //double step = (self.mapView.maxZoomLevel - self.mapView.minZoomLevel)/10;
        for (int i = 0; i < 20; i++) {
            zoomLevels[i] = self.mapView.minZoomLevel + i;
        }
        
        zoomLevel = DEFAULT_MAP_ZOOMIN;
        [self.mapView setZoomLevel:zoomLevels[zoomLevel] animated:YES];
        
        regonIndex = 0;
        self.selectedAnn = NO;
        refreshBegin = NO;
        isShowLocaltion = NO;
        
        [self configLocationManager];
    }
    
    return self;
}

-(void)initSubViews
{
    
}

- (void)configLocationManager
{
    self.locationManager = [[AMapLocationManager alloc] init];
    
    [self.locationManager setDelegate:self];
    
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
    
    [self.locationManager setPausesLocationUpdatesAutomatically:NO];
    
//    [self.locationManager setAllowsBackgroundLocationUpdates:YES];
    
    [self.locationManager setLocationTimeout:6];
    
    [self.locationManager setReGeocodeTimeout:3];
}

#pragma mark - Button Action

//点击返回当前位置并刷新周围POI信息
-(void)showLocation:(id)sender
{
    //self.selectedAnn = NO;
    isShowLocaltion = YES;
    [self.mapView setUserTrackingMode:MAUserTrackingModeFollow animated:YES];
}

-(void)showTraffic:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    btn.selected = (btn.selected) ? NO : YES;
    
    self.mapView.showTraffic = (btn.selected) ? YES : NO;
}

-(void)updateMapLocation
{
    
}

- (void)locAction
{
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    [self.locationManager requestLocationWithReGeocode:NO completionBlock:self.completionBlock];
}

#pragma mark - Initialization

- (void)initCompleteBlock
{
    __block BaseMapView *vc = self;
    self.completionBlock = ^(CLLocation *location, AMapLocationReGeocode *regeocode, NSError *error)
    {
        if(error)
        {
            NSLog(@"locError:{%ld - %@};", (long)error.code, error.localizedDescription);
            
            if (error.code == AMapLocationErrorLocateFailed)
            {
                return;
            }
        }
        
        if(location)
        {
//            MAPointAnnotation *annotation = [[MAPointAnnotation alloc] init];
//            [annotation setCoordinate:location.coordinate];
            
            if(vc.getNowLocation)
                vc.getNowLocation(location);
        }
    };
}

/*
#pragma mark - MAMapView Delagete

-(void)mapViewDidStopLocatingUser:(MAMapView *)mapView
{
    
}

- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation
{
    self.myLocation = userLocation;
    [[ConfigData shareInstance] setLocalLongitude:userLocation.location.coordinate.longitude];
    [[ConfigData shareInstance] setLocalLatitude: userLocation.location.coordinate.latitude];
    
    
    if(!_didUpdateLocation && updatingLocation && mapView.userLocation.location.coordinate.longitude != 0 && mapView.userLocation.location.coordinate.latitude != 0)
    {
//        if(self.updateUserLocation)
//            self.updateUserLocation(mapView.centerCoordinate);
        
        zoomLevel = DEFAULT_MAP_ZOOMIN;
        [self.mapView setZoomLevel:zoomLevels[zoomLevel] animated:YES];
        
        self.didUpdateLocation = YES;
        refreshCenter = userLocation.coordinate;
    }
    
    refreshCenter = userLocation.coordinate;
}

- (void)mapView:(MAMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    
}
*/
 
@end
