//
//  GradientLineView.h
//  SpeedNow
//
//  Created by 杨翊楷 on 16/4/13.
//  Copyright © 2016年 YK Yang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GradientLinePoint.h"

// 接口
/** 折线图视图 */
@interface GradientLineView : UIView

/** 折线转折点数组 */
@property (nonatomic, strong) NSMutableArray<GradientLinePoint *> *pointArray;
/** 开始绘制折线图 */
- (void)startDrawlineChart;

- (instancetype)initWithFrame:(CGRect)frame pointData:(NSArray *)pointArray;

@end
