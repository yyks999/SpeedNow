//
//  MapViewSingleton.m
//  SpeedNow
//
//  Created by 杨翊楷 on 15/12/17.
//  Copyright © 2015年 YK Yang. All rights reserved.
//

#import "MapViewSingleton.h"

static MapViewSingleton *_instance;

@implementation MapViewSingleton

#pragma mark - ********************** INITIALIZE  *********************

/* 初始化单例对象 */
+ (id)shareInstance
{
    if (!_instance) {
        _instance = [[MapViewSingleton alloc] init];
    }
    return _instance;
}

- (MAMapView *)initializeSingletonMapWithFrame:(CGRect)frame
{
    if(!self.mapView)
    {
        self.mapView = [[MAMapView alloc] initWithFrame:frame];
        self.mapView.scaleOrigin = CGPointMake(10, frame.size.height - 40);
        self.mapView.showsUserLocation = NO;
        self.mapView.zoomEnabled    = NO;
        self.mapView.scrollEnabled  = NO;
        self.mapView.showsCompass   = NO;
        self.mapView.showsScale     = NO;
        self.mapView.userInteractionEnabled = NO;
        
        self.mapView.showsUserLocation = NO;
        self.mapView.userTrackingMode  = MAUserTrackingModeNone;
    }
    
    return self.mapView;
}

@end
