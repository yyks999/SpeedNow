//
//  GradientLineViewController.m
//  SpeedNow
//
//  Created by 杨翊楷 on 16/4/13.
//  Copyright © 2016年 YK Yang. All rights reserved.
//

#import "GradientLineViewController.h"
#import "GradientLineView.h"

@interface GradientLineViewController()

@property (nonatomic, strong) GradientLineView *gradientView;

/** 开始绘制折线图按钮 */
@property (nonatomic, strong) UIButton *drawLineChartButton;

@end

@implementation GradientLineViewController

- (void)viewDidLoad
{
    _gradientView = [[GradientLineView alloc] initWithFrame:CGRectMake(30, 60, SCREEN_WIDTH - 30 * 2, 120)];
    [self.view addSubview:_gradientView];
    
    self.drawLineChartButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.drawLineChartButton.frame = CGRectMake(135, CGRectGetMaxY(_gradientView.frame) + 30, 50, 44);
    [self.drawLineChartButton setTitle:@"开始" forState:UIControlStateNormal];
    [self.drawLineChartButton addTarget:self action:@selector(drawLineChart) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.drawLineChartButton];
    
    [self drawLineChart];
}

// 开始绘制折线图
- (void)drawLineChart {
    [_gradientView startDrawlineChart];
}

@end
