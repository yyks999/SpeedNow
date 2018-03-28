//
//  GradientLine.h
//  SpeedNow
//
//  Created by 杨翊楷 on 16/4/13.
//  Copyright © 2016年 YK Yang. All rights reserved.
//

#import <Foundation/Foundation.h>

// 接口
/** 折线图上的点 */
@interface GradientLinePoint : NSObject

/** x轴偏移量 */
@property (nonatomic, assign) float x;
/** y轴偏移量 */
@property (nonatomic, assign) float y;
/** 工厂方法 */
+ (instancetype)pointWithX:(float)x andY:(float)y;

@end
