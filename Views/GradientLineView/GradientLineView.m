//
//  GradientLineView.m
//  SpeedNow
//
//  Created by 杨翊楷 on 16/4/13.
//  Copyright © 2016年 YK Yang. All rights reserved.
//

#import "GradientLineView.h"

/** 坐标轴信息区域宽度 */
static const CGFloat kPadding = 25.0;
/** 坐标系中横线的宽度 */
//static const CGFloat kCoordinateLineWith = 1.0;

@interface GradientLineView()

/** X轴的单位长度 */
@property (nonatomic, assign) CGFloat xAxisSpacing;
/** Y轴的单位长度 */
@property (nonatomic, assign) CGFloat yAxisSpacing;
/** X轴的信息 */
@property (nonatomic, strong) NSMutableArray<NSString *> *xAxisInformationArray;
/** Y轴的信息 */
@property (nonatomic, strong) NSMutableArray<NSString *> *yAxisInformationArray;


/** 渐变背景视图 */
@property (nonatomic, strong) UIView *gradientBackgroundView;
/** 渐变图层 */
@property (nonatomic, strong) CAGradientLayer *gradientLayer;
/** 颜色数组 */
@property (nonatomic, strong) NSMutableArray *gradientLayerColors;


/** 折线图层 */
@property (nonatomic, strong) CAShapeLayer *lineChartLayer;
/** 折线图终点处的标签 */
@property (nonatomic, strong) UIButton *tapButton;

@end

@implementation GradientLineView

// 初始化
- (instancetype)initWithFrame:(CGRect)frame pointData:(NSArray *)pointArray
{
    if (self = [super initWithFrame:frame]) {
        // 设置折线图的背景色
        self.backgroundColor = [UIColor clearColor];
        
        self.pointArray = [NSMutableArray arrayWithArray:pointArray];
//        self.pointArray = [[NSMutableArray alloc] initWithCapacity:0];
//        [self.pointArray addObject:[GradientLinePoint pointWithX:1 andY:1]];
//        [self.pointArray addObject:[GradientLinePoint pointWithX:2 andY:2]];
//        [self.pointArray addObject:[GradientLinePoint pointWithX:3 andY:1.5]];
//        [self.pointArray addObject:[GradientLinePoint pointWithX:4 andY:2]];
//        [self.pointArray addObject:[GradientLinePoint pointWithX:5 andY:4]];
//        [self.pointArray addObject:[GradientLinePoint pointWithX:6 andY:1]];
//        [self.pointArray addObject:[GradientLinePoint pointWithX:7 andY:2]];
        
        [self drawGradientBackgroundView];
        [self setupLineChartLayerAppearance];
    }
    return self;
}

#pragma mark - 设置渐变视图方法的具体实现

- (void)drawGradientBackgroundView {
    // 渐变背景视图（不包含坐标轴）
    self.gradientBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
    [self addSubview:self.gradientBackgroundView];
    /** 创建并设置渐变背景图层 */
    //初始化CAGradientlayer对象，使它的大小为渐变背景视图的大小
    self.gradientLayer = [CAGradientLayer layer];
    self.gradientLayer.frame = self.gradientBackgroundView.bounds;
    //设置渐变区域的起始和终止位置（范围为0-1），即渐变路径
    self.gradientLayer.startPoint = CGPointMake(0, 0.0);
    self.gradientLayer.endPoint = CGPointMake(1.0, 0.0);
    //设置颜色的渐变过程
    self.gradientLayerColors = [NSMutableArray arrayWithArray:
                                @[(__bridge id)[UIColor colorWithRed:0.24f green:0.85f blue:0.82f alpha:1.00f].CGColor,
                                  
                                  (__bridge id)[UIColor colorWithRed:0.59f green:0.94f blue:0.91f alpha:1.00f].CGColor,
                                  
                                  (__bridge id)[UIColor colorWithRed:0.90f green:0.72f blue:0.85f alpha:1.00f].CGColor,
                                  
                                  (__bridge id)[UIColor colorWithRed:0.91f green:0.58f blue:0.82f alpha:1.00f].CGColor,
                                  
                                  (__bridge id)[UIColor colorWithRed:0.72f green:0.19f blue:0.86f alpha:1.00f].CGColor]];
    self.gradientLayer.colors = self.gradientLayerColors;
    //将CAGradientlayer对象添加在我们要设置背景色的视图的layer层
    [self.gradientBackgroundView.layer addSublayer:self.gradientLayer];
}

#pragma mark - 设置折线图层方法的具体实现

- (void)setupLineChartLayerAppearance {
    /** 折线路径 */
    UIBezierPath *path = [UIBezierPath bezierPath];
    [self.pointArray enumerateObjectsUsingBlock:^(GradientLinePoint * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        // 折线
        if (idx == 0) {
            [path moveToPoint:CGPointMake(obj.x, obj.y)];
        } else {
            [path addLineToPoint:CGPointMake(obj.x, obj.y)];
        }
        // 折线起点和终点位置的圆点
        if (idx == 0 || idx == self.pointArray.count - 1) {
            [path addArcWithCenter:CGPointMake(obj.x, obj.y) radius:2.0 startAngle:0 endAngle:2 * M_PI clockwise:YES];
        }
    }];
    /** 将折线添加到折线图层上，并设置相关的属性 */
    self.lineChartLayer = [CAShapeLayer layer];
    self.lineChartLayer.path = path.CGPath;
    self.lineChartLayer.strokeColor = [UIColor whiteColor].CGColor;
    self.lineChartLayer.fillColor = [[UIColor clearColor] CGColor];
    // 默认设置路径宽度为0，使其在起始状态下不显示
    self.lineChartLayer.lineWidth = 0;
    self.lineChartLayer.lineCap = kCALineCapRound;
    self.lineChartLayer.lineJoin = kCALineJoinRound;
    // 设置折线图层为渐变图层的mask
    self.gradientBackgroundView.layer.mask = self.lineChartLayer;
}

#pragma mark - 动画开始

/** 动画开始，绘制折线图 */
- (void)startDrawlineChart {
    // 设置路径宽度为4，使其能够显示出来
    self.lineChartLayer.lineWidth = 6;
    // 移除标签，
    if ([self.subviews containsObject:self.tapButton]) {
        [self.tapButton removeFromSuperview];
    }
    // 设置动画的相关属性
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    pathAnimation.duration = 1;
    pathAnimation.repeatCount = 1;
    pathAnimation.removedOnCompletion = NO;
    pathAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
    pathAnimation.toValue = [NSNumber numberWithFloat:1.0f];
    // 设置动画代理，动画结束时添加一个标签，显示折线终点的信息
    pathAnimation.delegate = self;
    [self.lineChartLayer addAnimation:pathAnimation forKey:@"strokeEnd"];
}

#pragma mark - 动画结束，添加标签

/** 动画结束时，添加一个标签 */
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (self.tapButton == nil) { // 首次添加标签（避免多次创建和计算）
        CGRect tapButtonFrame = CGRectMake(self.xAxisSpacing * 0.5 + ([self.pointArray[self.pointArray.count - 1] x] - 1) * self.xAxisSpacing + 8, self.bounds.size.height - kPadding - [self.pointArray[self.pointArray.count - 1] y] * self.yAxisSpacing - 34, 30, 30);
        
        self.tapButton = [[UIButton alloc] initWithFrame:tapButtonFrame];
        self.tapButton.enabled = NO;
        [self.tapButton setBackgroundImage:[UIImage imageNamed:@"bubble"] forState:UIControlStateDisabled];
        [self.tapButton.titleLabel setFont:[UIFont systemFontOfSize:10]];
        [self.tapButton setTitle:@"Here" forState:UIControlStateDisabled];
    }
    [self addSubview:self.tapButton];
}

@end

