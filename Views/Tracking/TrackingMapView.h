//
//  TrackingMapView.h
//  SpeedNow
//
//  Created by 杨翊楷 on 15/12/8.
//  Copyright © 2015年 YK Yang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TrackingMapView : UIView

@property (nonatomic, strong) MAMapView *mapView;

@property (nonatomic, strong) Tracking *tracking;

@end
