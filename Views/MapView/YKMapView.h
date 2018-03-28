//
//  YKMapView.h
//  SpeedNow
//
//  Created by 杨翊楷 on 15/12/8.
//  Copyright © 2015年 YK Yang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface YKMapView : UIView

@property (nonatomic, strong) MKMapView *mapView;
@property (retain, nonatomic) CLLocationManager *locManager;

/*!
 @brief 轨迹回放动画时间
 */
@property (nonatomic, assign) NSTimeInterval duration;

/*!
 @brief 边界差值
 */
@property (nonatomic, assign) UIEdgeInsets edgeInsets;

@end
