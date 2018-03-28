//
//  MapViewSingleton.h
//  SpeedNow
//
//  Created by 杨翊楷 on 15/12/17.
//  Copyright © 2015年 YK Yang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MapViewSingleton : NSObject

@property (nonatomic, strong) MAMapView *mapView;

+ (id)shareInstance;

- (MAMapView *)initializeSingletonMapWithFrame:(CGRect)frame;

@end
