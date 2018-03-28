//
//  WGS84_TO_GCJ02.h
//  SpeedNow
//
//  Created by 杨翊楷 on 16/2/2.
//  Copyright © 2016年 YK Yang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WGS84_TO_GCJ02 : NSObject

//判断是否已经超出中国范围
+ (BOOL)isLocationOutOfChina:(CLLocationCoordinate2D)location;
//转GCJ-02
+ (CLLocationCoordinate2D)transformFromWGSToGCJ:(CLLocationCoordinate2D)wgsLoc;

@end
