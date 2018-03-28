//
//  YKMapView.m
//  SpeedNow
//
//  Created by 杨翊楷 on 15/12/8.
//  Copyright © 2015年 YK Yang. All rights reserved.
//

#import "YKMapView.h"
#import "KCAnnotation.h"
#import "KCCalloutAnnotationView.h"

@interface YKMapView() <CLLocationManagerDelegate, MKMapViewDelegate>
{
    CLLocation * nowLocation;
    MKPolylineView *routeLineView;
    
    CLLocationCoordinate2D *_coordinates;
    NSUInteger              _count;
    NSArray                *array;
}

@property (nonatomic, strong) CAShapeLayer *shapeLayer;
@property (nonatomic, strong, readwrite) MKPointAnnotation *annotation;

@property (nonatomic, strong) MKPolyline* routeLine;
@property (nonatomic, strong) MKPolylineView* routeLineView;

@end

@implementation YKMapView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initGUI];
        
        self.duration = 2.f;
        self.edgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        
        // 模拟经纬度坐标点
        CLLocation *location0 = [[CLLocation alloc] initWithLatitude:39.954245 longitude:116.312455];
        CLLocation *location1 = [[CLLocation alloc] initWithLatitude:38.954245 longitude:116.512455];
        CLLocation *location2 = [[CLLocation alloc] initWithLatitude:37.954245 longitude:116.612455];
        CLLocation *location3 = [[CLLocation alloc] initWithLatitude:36.954245 longitude:116.712455];
        CLLocation *location4 = [[CLLocation alloc] initWithLatitude:35.954245 longitude:116.812455];
        CLLocation *location5 = [[CLLocation alloc] initWithLatitude:34.954245 longitude:117.312455];
        CLLocation *location6 = [[CLLocation alloc] initWithLatitude:33.954245 longitude:118.312455];
        CLLocation *location7 = [[CLLocation alloc] initWithLatitude:32.954245 longitude:119.312455];
        CLLocation *location8 = [[CLLocation alloc] initWithLatitude:31.954245 longitude:119.612455];
        CLLocation *location9 = [[CLLocation alloc] initWithLatitude:30.247871 longitude:120.127683];
        
        CLLocationCoordinate2D points[10];
        points[0] = CLLocationCoordinate2DMake(39.954245, 116.312455);
        points[1] = CLLocationCoordinate2DMake(39.954245, 116.312455);
        points[2] = CLLocationCoordinate2DMake(39.954245, 116.312455);
        points[3] = CLLocationCoordinate2DMake(39.954245, 116.312455);
        points[4] = CLLocationCoordinate2DMake(39.954245, 116.312455);
        points[5] = CLLocationCoordinate2DMake(39.954245, 116.312455);
        points[6] = CLLocationCoordinate2DMake(39.954245, 116.312455);
        points[7] = CLLocationCoordinate2DMake(39.954245, 116.312455);
        points[8] = CLLocationCoordinate2DMake(39.954245, 116.312455);
        points[9] = CLLocationCoordinate2DMake(39.954245, 116.312455);
        
        _coordinates = points;
        
        array = [NSArray arrayWithObjects:location0, location1,location2,location3,location4,location5,location6,location7,location8,location9, nil];
        
        [self initBaseData];
    }
    return self;
}

#pragma mark - getCurLoction

/*获取位置信息*/
- (void)getCurLoction
{
    if(!_locManager)
    {
        //初始化位置管理器
        _locManager = [[CLLocationManager alloc]init];
        //设置代理
        _locManager.delegate = self;
        //设置位置经度
        _locManager.desiredAccuracy = kCLLocationAccuracyBest;
        //设置每隔5米更新位置
        //    _locManager.distanceFilter = 5;
        if ([_locManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
        {
        [_locManager requestWhenInUseAuthorization];
        }

        //开始定位服务
        [_locManager startUpdatingLocation];
    }

    /*
    CLGeocoder *clGeoCoder = [[CLGeocoder alloc] init];
    CLGeocodeCompletionHandler handle = ^(NSArray *placemarks,NSError *error)
    {
        for (CLPlacemark * placeMark in placemarks)
        {
            [_locManager stopUpdatingHeading];
            
            NSDictionary *addressDic=placeMark.addressDictionary;
            
            NSString *state = [addressDic getStringValueForKey:@"State" defaultValue:@""];
            NSString *city  = [addressDic getStringValueForKey:@"City" defaultValue:@""];

        }
    };
    
    [clGeoCoder reverseGeocodeLocation:nowLocation completionHandler:handle];
     */
}

#pragma mark - CLLocationManagerDelegate

//协议中的方法，作用是每当位置发生更新时会调用的委托方法
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
}

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations
{
    nowLocation = [locations lastObject];
    [self getCurLoction];
    
    CLLocation *location=[locations firstObject];//取出第一个位置
    CLLocationCoordinate2D coordinate=location.coordinate;//位置坐标
    NSLog(@"经度：%f,纬度：%f,海拔：%f,航向：%f,行走速度：%f",coordinate.longitude,coordinate.latitude,location.altitude,location.course,location.speed);
    //如果不需要实时定位，使用完即使关闭定位服务
    [_locManager stopUpdatingLocation];
}

//当位置获取或更新失败会调用的方法
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSString *errorMsg = nil;
    if ([error code] == kCLErrorDenied) {
        errorMsg = @"访问被拒绝";
    }
    if ([error code] == kCLErrorLocationUnknown) {
        errorMsg = @"获取位置信息失败";
    }
}

#pragma mark - 添加地图控件

-(void)initGUI
{
    CGRect rect = [UIScreen mainScreen].bounds;
    _mapView = [[MKMapView alloc]initWithFrame:rect];
    [self addSubview:_mapView];
    //设置代理
    _mapView.delegate = self;
    
    //请求定位服务
    _locManager = [[CLLocationManager alloc]init];
    
    if(![CLLocationManager locationServicesEnabled]||[CLLocationManager authorizationStatus]!=kCLAuthorizationStatusAuthorizedWhenInUse)
    {
        [_locManager requestWhenInUseAuthorization];
    }
    
    //用户位置追踪(用户位置追踪用于标记用户当前位置，此时会调用定位服务)
//    _mapView.userTrackingMode = MKUserTrackingModeFollow;
    
    //设置地图类型
    _mapView.mapType = MKMapTypeStandard;
    
    //添加大头针
    [self addAnnotation];
}

#pragma mark -添加大头针

-(void)addAnnotation
{
    CLLocationCoordinate2D location1 = CLLocationCoordinate2DMake(39.95, 116.35);
    KCAnnotation *annotation1 = [[KCAnnotation alloc]init];
    annotation1.title    = @"CMJ Studio";
    annotation1.subtitle = @"Kenshin Cui's Studios";
    annotation1.coordinate = location1;
    annotation1.image  = [UIImage imageNamed:@"icon_pin_floating.png"];
    annotation1.icon   = [UIImage imageNamed:@"icon_mark1.png"];
    annotation1.detail = @"CMJ Studio...";
    annotation1.rate   = [UIImage imageNamed:@"icon_Movie_Star_rating.png"];
    [_mapView addAnnotation:annotation1];
    
    CLLocationCoordinate2D location2 = CLLocationCoordinate2DMake(39.87, 116.35);
    KCAnnotation *annotation2 = [[KCAnnotation alloc]init];
    annotation2.title      = @"Kenshin&Kaoru";
    annotation2.subtitle   = @"Kenshin Cui's Home";
    annotation2.coordinate = location2;
    annotation2.image  = [UIImage imageNamed:@"icon_paopao_waterdrop_streetscape.png"];
    annotation2.icon   = [UIImage imageNamed:@"icon_mark2.png"];
    annotation2.detail = @"Kenshin Cui...";
    annotation2.rate   = [UIImage imageNamed:@"icon_Movie_Star_rating.png"];
    [_mapView addAnnotation:annotation2];
}

#pragma mark - 地图控件代理方法
/*
//显示大头针时调用，注意方法中的annotation参数是即将显示的大头针对象
-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    //由于当前位置的标注也是一个大头针，所以此时需要判断，此代理方法返回nil使用默认大头针视图
    if ([annotation isKindOfClass:[KCAnnotation class]])
    {
        static NSString *key1 = @"AnnotationKey1";
        MKAnnotationView *annotationView = [_mapView dequeueReusableAnnotationViewWithIdentifier:key1];
        //如果缓存池中不存在则新建
        if (!annotationView)
        {
            annotationView = [[MKAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:key1];
            //            annotationView.canShowCallout=true;//允许交互点击
            annotationView.calloutOffset=CGPointMake(0, 1);//定义详情视图偏移量
            annotationView.leftCalloutAccessoryView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"icon_classify_cafe.png"]];//定义详情左侧视图
        }
        
        //修改大头针视图
        //重新设置此类大头针视图的大头针模型(因为有可能是从缓存池中取出来的，位置是放到缓存池时的位置)
        annotationView.annotation = annotation;
        annotationView.image = ((KCAnnotation *)annotation).image;//设置大头针视图的图片
        
        return annotationView;
        
    }else if([annotation isKindOfClass:[KCCalloutAnnotation class]])
    {
        //对于作为弹出详情视图的自定义大头针视图无弹出交互功能（canShowCallout=false，这是默认值），在其中可以自由添加其他视图（因为它本身继承于UIView）
        KCCalloutAnnotationView *calloutView = [KCCalloutAnnotationView calloutViewWithMapView:mapView];
        calloutView.annotation = annotation;
        return calloutView;
    } else {
        return nil;
    }
}
*/
#pragma mark 选中大头针时触发
/*
//点击一般的大头针KCAnnotation时添加一个大头针作为所点大头针的弹出详情视图
-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    KCAnnotation *annotation=view.annotation;
    if ([view.annotation isKindOfClass:[KCAnnotation class]])
    {
        //点击一个大头针时移除其他弹出详情视图
        //        [self removeCustomAnnotation];
        //添加详情大头针，渲染此大头针视图时将此模型对象赋值给自定义大头针视图完成自动布局
        KCCalloutAnnotation *annotation1=[[KCCalloutAnnotation alloc]init];
        annotation1.icon = annotation.icon;
        annotation1.detail = annotation.detail;
        annotation1.rate = annotation.rate;
        annotation1.coordinate = view.annotation.coordinate;
        [mapView addAnnotation:annotation1];
    }
}
*/
#pragma mark - 取消选中时触发
/*
-(void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view
{
    [self removeCustomAnnotation];
}
*/
#pragma mark - 移除所用自定义大头针

-(void)removeCustomAnnotation
{
    [_mapView.annotations enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
    {
        if ([obj isKindOfClass:[KCCalloutAnnotation class]])
        {
            [_mapView removeAnnotation:obj];
        }
    }];
}


- (void)drawLineWithLocationArray:(NSArray *)locationArray
{
    NSInteger pointCount = [locationArray count];
    CLLocationCoordinate2D *coordinateArray = (CLLocationCoordinate2D *)malloc(pointCount * sizeof(CLLocationCoordinate2D));
    
    for (int i = 0; i < pointCount; ++i) {
        CLLocation *location = [locationArray objectAtIndex:i];
        coordinateArray[i] = [location coordinate];
        // 添加大头针
        MKPointAnnotation *ann = [[MKPointAnnotation alloc] init];
        ann.coordinate = [location coordinate];
        [ann setTitle:[NSString stringWithFormat:@"%i",i]];
        [ann setSubtitle:@""];
        [_mapView addAnnotation:ann];
    }
    
    self.routeLine = [MKPolyline polylineWithCoordinates:coordinateArray count:pointCount];
    [self.mapView setVisibleMapRect:[self.routeLine boundingMapRect]];
    [self.mapView addOverlay:self.routeLine];
    
    free(coordinateArray);
    coordinateArray = NULL;
}

// 画线的委托实现方法
- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id)overlay
{
    if(overlay == self.routeLine) {
        if(nil == self.routeLineView) {
            self.routeLineView = [[MKPolylineView alloc] initWithPolyline:self.routeLine];
            self.routeLineView.fillColor = [UIColor blueColor];
            self.routeLineView.strokeColor = [UIColor redColor];
            self.routeLineView.lineWidth = 5;
        }
        return self.routeLineView;
    }
    return nil;
}
// 添加大头针的委托实现方法
- (MKAnnotationView *)mapView:(MKMapView *)mV viewForAnnotation:(id <MKAnnotation>)annotation
{
    MKPinAnnotationView *pinView = nil;
    
    static NSString *defaultPinID = @"pinId";
    pinView = (MKPinAnnotationView *)[_mapView dequeueReusableAnnotationViewWithIdentifier:defaultPinID];
    if ( pinView == nil ) pinView = [[MKPinAnnotationView alloc]
                                     initWithAnnotation:annotation reuseIdentifier:defaultPinID];
    pinView.pinTintColor = [UIColor redColor];
    pinView.canShowCallout = YES;
    pinView.animatesDrop = YES;
    return pinView;
}

- (void)drawLine
{
    // 如果存在线，移除
    if (self.mapView.annotations.count > 2) {
//        [self.mapView removeAnnotations:_mapView.annotations];
//        [self.mapView removeOverlays:_mapView.overlays];
        return;
    }
    
    [self drawLineWithLocationArray:array];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
//    [self drawLine];
    [self execute];
}




#pragma mark - Interface

- (void)execute
{
    /* 使轨迹在地图可视范围内. */
//    [self.mapView setVisibleMapRect:self.polyline.boundingMapRect edgePadding:self.edgeInsets animated:NO];
//    [self.mapView setVisibleMapRect:self.routeLine.boundingMapRect edgePadding:self.edgeInsets animated:NO];
    
    /* 构建path. */
    CGPoint *points = [self pointsForCoordinates:_coordinates count:array.count];
    CGPathRef path = [self pathForPoints:points count:array.count];
    
    self.shapeLayer.path = path;
    
    [self.mapView.layer insertSublayer:self.shapeLayer atIndex:1];
    
    [self.mapView addAnnotation:self.annotation];
    
    MKAnnotationView *annotationView = [self.mapView viewForAnnotation:self.annotation];
//    if (annotationView != nil)
//    {
        /* Annotation animation. */
        CAAnimation *annotationAnimation = [self constructAnnotationAnimationWithPath:path];
        [annotationView.layer addAnimation:annotationAnimation forKey:@"annotation"];
        
        [annotationView.annotation setCoordinate:_coordinates[_count - 1]];
        
        /* ShapeLayer animation. */
        CAAnimation *shapeLayerAnimation = [self constructShapeLayerAnimation];
        shapeLayerAnimation.delegate = self;
        [self.shapeLayer addAnimation:shapeLayerAnimation forKey:@"shape"];
//    }
    
    free(points),           points  = NULL;
    CGPathRelease(path),    path    = NULL;
}

/* 经纬度转屏幕坐标, 调用者负责释放内存. */
- (CGPoint *)pointsForCoordinates:(CLLocationCoordinate2D *)coordinates count:(NSUInteger)count
{
    if (coordinates == NULL || count <= 1)
    {
        return NULL;
    }
    
    /* 申请屏幕坐标存储空间. */
    CGPoint *points = (CGPoint *)malloc(count * sizeof(CGPoint));
    
    /* 经纬度转换为屏幕坐标. */
    for (int i = 0; i < count; i++)
    {
        points[i] = [self.mapView convertCoordinate:coordinates[i] toPointToView:self.mapView];
    }
    
    return points;
}

/* 构建path, 调用者负责释放内存. */
- (CGMutablePathRef)pathForPoints:(CGPoint *)points count:(NSUInteger)count
{
    if (points == NULL || count <= 1)
    {
        return NULL;
    }
    
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGPathAddLines(path, NULL, points, count);
    
    return path;
}

/* 构建annotationView的keyFrameAnimation. */
- (CAAnimation *)constructAnnotationAnimationWithPath:(CGPathRef)path
{
    if (path == NULL)
    {
        return nil;
    }
    
    CAKeyframeAnimation *thekeyFrameAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    thekeyFrameAnimation.duration        = self.duration;
    thekeyFrameAnimation.path            = path;
    thekeyFrameAnimation.calculationMode = kCAAnimationPaced;
    
    return thekeyFrameAnimation;
}

/* 构建shapeLayer的basicAnimation. */
- (CAAnimation *)constructShapeLayerAnimation
{
    CABasicAnimation *theStrokeAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    theStrokeAnimation.duration         = self.duration;
    theStrokeAnimation.fromValue        = @0.f;
    theStrokeAnimation.toValue          = @1.f;
    
    return theStrokeAnimation;
}

#pragma mark - Initialization

/* 构建shapeLayer. */
- (void)initShapeLayer
{
    self.shapeLayer = [[CAShapeLayer alloc] init];
    self.shapeLayer.lineWidth         = 4;
    self.shapeLayer.strokeColor       = [UIColor redColor].CGColor;
    self.shapeLayer.fillColor         = [UIColor clearColor].CGColor;
    self.shapeLayer.lineJoin          = kCALineCapRound;
}

/* 构建annotation. */
- (void)initAnnotation
{
    self.annotation = [[MKPointAnnotation alloc] init];
    
    self.annotation.coordinate = _coordinates[0];
}

/* 构建annotation. */
- (void)initPolyline
{
    self.routeLine = [MKPolyline polylineWithCoordinates:_coordinates count:_count];
}

- (void)initBaseData
{
    [self initAnnotation];
    
    [self initPolyline];
    
    [self initShapeLayer];
}

@end
