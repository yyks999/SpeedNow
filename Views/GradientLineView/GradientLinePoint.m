//
//  GradientLine.m
//  SpeedNow
//
//  Created by 杨翊楷 on 16/4/13.
//  Copyright © 2016年 YK Yang. All rights reserved.
//

#import "GradientLinePoint.h"

@implementation GradientLinePoint

+ (instancetype)pointWithX:(float)x andY:(float)y {
    GradientLinePoint *point = [[self alloc] init];
    point.x = x;
    point.y = y;
    return point;
}

@end
