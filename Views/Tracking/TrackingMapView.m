//
//  TrackingMapView.m
//  SpeedNow
//
//  Created by 杨翊楷 on 15/12/8.
//  Copyright © 2015年 YK Yang. All rights reserved.
//

#import "TrackingMapView.h"
#import <MAMapKit/MAMapKit.h>
#import "UIImage+category.h"

@interface TrackingMapView()<MAMapViewDelegate, TrackingDelegate>

@property (nonatomic, strong) PulsingHaloLayer *onceHalo;
@property (nonatomic, strong) PulsingHaloLayer *twiceHalo;

@end

@implementation TrackingMapView
@synthesize mapView  = _mapView;
@synthesize tracking = _tracking;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setupMapView];
        
//        CAGradientLayer *layer = [CAGradientLayer layer];
//        layer.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
//        [layer setStartPoint:CGPointMake(0.0, 0.5)];
//        [layer setEndPoint:CGPointMake(1.0, 0.5)];
//        
//        // Create colors using hues in +5 increments
//        NSMutableArray *colors = [NSMutableArray array];
//        for (NSInteger hue = 0; hue <= 360; hue += 5) {
//
//            UIColor *color;
//            color = [UIColor colorWithHue:1.0 * hue / 360.0
//                               saturation:1.0
//                               brightness:1.0
//                                    alpha:1.0];
//            [colors addObject:(id)[color CGColor]];
//        }
//        [layer setColors:[NSArray arrayWithArray:colors]];
//        [self.layer addSublayer:layer];
    }
    return self;
}

#pragma mark - Setup

/* 构建mapView. */
- (void)setupMapView
{
//    [MAMapServices sharedServices].apiKey = @"1d1e7fbaf24dbd52c5f261835448bb51";
    
    self.mapView = [[MapViewSingleton shareInstance] initializeSingletonMapWithFrame:self.frame];
    self.mapView.frame = self.frame;
    self.mapView.delegate = self;
    [self addSubview:self.mapView];
    
    /*
    self.mapView = [[MAMapView alloc] initWithFrame:self.frame];
    self.mapView.scaleOrigin = CGPointMake(10, self.frame.size.height - 40);
//    self.mapView.centerCoordinate = CLLocationCoordinate2DMake(41.804358, 123.434004);
    self.mapView.showsUserLocation = NO;
    self.mapView.showsLabels    = NO;
    self.mapView.zoomEnabled    = NO;
    self.mapView.scrollEnabled  = NO;
    self.mapView.rotateEnabled  = NO;
    self.mapView.showsCompass   = NO;
    self.mapView.showsScale     = NO;
    self.mapView.userInteractionEnabled = NO;
//    self.mapView.alpha = 0.7;
    [self addSubview:self.mapView];
    
    self.mapView.showsUserLocation = YES;
    self.mapView.userTrackingMode  = MAUserTrackingModeFollow;
    */
     
    
//    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(30, 300, 80, 40)];
//    [btn addTarget:self action:@selector(handleRunAction) forControlEvents:UIControlEventTouchUpInside];
//    [btn setTitleColor:MYBLUECOLOR forState:UIControlStateNormal];
//    [btn setTitle:@"touch" forState:UIControlStateNormal];
//    [self addSubview:btn];

    [self performSelector:@selector(changeMapType) withObject:nil afterDelay:0.1];
    [self performSelector:@selector(handleRunAction) withObject:nil afterDelay:0.6];
}

- (void)changeMapType
{
    self.mapView.mapType = MAMapTypeStandardNight;
}

#pragma mark - Handle Action

- (void)handleRunAction
{
    if (self.tracking == nil)
    {
        [self setupTracking];
    }
    
    [self.tracking execute];
}

/* 构建轨迹回放. */
- (void)setupTracking
{
//    NSString *trackingFilePath = [[NSBundle mainBundle] pathForResource:@"GuGong" ofType:@"tracking"];
//    
//    NSData *trackingData = [NSData dataWithContentsOfFile:trackingFilePath];
//    
//    CLLocationCoordinate2D *coordinates = (CLLocationCoordinate2D *)malloc(trackingData.length);
    
//    NSArray *locationArray = [ConfigData getSaveLocationInfo];
    
//    [ConfigData showWcAlertWithTitle:@"" message:[NSString stringWithFormat:@"--%lu\n--%@",(unsigned long)array.count, array]];
    
    NSArray *locationArray = [[ConfigData shareInstance] speedInfo].locationArray;
    
    CLLocationCoordinate2D points[locationArray.count > 0 ? locationArray.count : 10];
    if(locationArray.count == 0)
    {
        points[0] = CLLocationCoordinate2DMake(41.804358, 123.434004);//Y:41.804358, X:123.434004
        points[1] = CLLocationCoordinate2DMake(41.802358, 123.432004);
        points[2] = CLLocationCoordinate2DMake(41.800358, 123.430004);
        points[3] = CLLocationCoordinate2DMake(41.802358, 123.428004);
        points[4] = CLLocationCoordinate2DMake(41.804358, 123.426004);
        points[5] = CLLocationCoordinate2DMake(41.802358, 123.423004);
        points[6] = CLLocationCoordinate2DMake(41.802958, 123.421004);
        points[7] = CLLocationCoordinate2DMake(41.803558, 123.419004);
        points[8] = CLLocationCoordinate2DMake(41.804058, 123.417004);
        points[9] = CLLocationCoordinate2DMake(41.804558, 123.415004);
    }
    else
    {
        for (int i = 0; i < locationArray.count; i++) {
            
            CLLocation *location = locationArray[i];
            points[i] = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude);
        }
    }
    

    
    /* 提取轨迹原始数据. */
//    [trackingData getBytes:coordinates length:trackingData.length];
    
    /* 构建tracking. */
    self.tracking = [[Tracking alloc] initWithCoordinates:points count:locationArray.count > 0 ? locationArray.count : 10];
    self.tracking.delegate = self;
    self.tracking.mapView  = self.mapView;
    self.tracking.duration = 0.5f;
    self.tracking.edgeInsets = UIEdgeInsetsMake(40, 40, 40, 40);
}

#pragma mark - MAMapViewDelegate

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    if ([annotation.title isEqualToString:@"start"])
    {
        static NSString *trackingReuseIndetifier = @"trackingReuseIndetifier";
        
        MAAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:trackingReuseIndetifier];
        
        if (annotationView == nil)
        {
            annotationView = [[MAAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:trackingReuseIndetifier];
        }
        
        annotationView.canShowCallout = NO;
        annotationView.image = [UIImage createImageWithBgColor:[UIColor whiteColor] size:CGSizeMake(15, 15) cornerRadius:7.5];//[UIImage imageNamed:@"jet_flyaway_1"];
        
        return annotationView;
    }
    else if([annotation.title isEqualToString:@"end"])
    {
        static NSString *trackingReuseIndetifier = @"trackingReuseIndetifier";
        
        MAAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:trackingReuseIndetifier];
        
        if (annotationView == nil)
        {
            annotationView = [[MAAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:trackingReuseIndetifier];
        }
        
        annotationView.canShowCallout = NO;
        annotationView.image = [UIImage createImageWithBgColor:[UIColor clearColor] size:CGSizeMake(15, 15) cornerRadius:7.5];//[UIImage imageNamed:@"jet_flyaway_1"];
        
        return annotationView;
    }
    
    return nil;
}

- (MAOverlayView *)mapView:(MAMapView *)mapView viewForOverlay:(id <MAOverlay>)overlay
{
    if (overlay == self.tracking.polyline)
    {
        MAPolylineView *polylineView = [[MAPolylineView alloc] initWithPolyline:overlay];
        
        polylineView.lineWidth   = 6.f;
//        polylineView.strokeColor = MYBLUECOLOR;
        
        return polylineView;
    }
    
    return nil;
}
  
- (void)mapViewDidFinishLoadingMap:(MAMapView *)mapView dataSize:(NSInteger)dataSize
{
//    self.mapView.mapType = MAMapTypeStandardNight;
}

- (void)mapView:(MAMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    for (UIView *v in views) {

        if([v isKindOfClass:[MAAnnotationView class]])
        {
            MAAnnotationView *annotation = (MAAnnotationView *)v;
            if ([annotation.annotation.title isEqualToString:@"start"])
            {
                [YYAnimation popAppearAnimation:annotation];
            }else if ([annotation.annotation.title isEqualToString:@"end"])
            {
//                [self performSelector:@selector(popEndPoint:) withObject:annotation afterDelay:0.01];
                [self performSelector:@selector(showEndPoint:) withObject:annotation afterDelay:0.3];
            }
        }
    }
}

- (void)popEndPoint:(MAAnnotationView *)view
{
    [YYAnimation popAppearAnimation:view];
}

- (void)showEndPoint:(MAAnnotationView *)view
{
    MAAnnotationView *v = view;
    v.image = [UIImage createImageWithBgColor:[UIColor whiteColor] size:CGSizeMake(15, 15) cornerRadius:7.5];
    [YYAnimation popAppearAnimation:view];
    
    if(!self.onceHalo)
    {
        self.onceHalo = [PulsingHaloLayer layer];
        self.onceHalo.position = CGPointMake(view.center.x, view.center.y);
        [self.layer insertSublayer:self.onceHalo below:view.layer];
        self.onceHalo.radius = 0.2 * 200;
        
        [self performSelector:@selector(showHaloTwice:) withObject:view afterDelay:0.5];
    }
}

- (void)showHaloTwice:(MAAnnotationView *)view
{
    self.twiceHalo = [PulsingHaloLayer layer];
    self.twiceHalo.position = CGPointMake(view.center.x, view.center.y);
    [self.layer insertSublayer:self.twiceHalo below:view.layer];
    self.twiceHalo.radius = 0.2 * 200;
}

@end
