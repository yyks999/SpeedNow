//
//  Tracking.m
//  Tracking
//
//  Created by xiaojian on 14-7-30.
//  Copyright (c) 2014年 Tab. All rights reserved.
//

#import "Tracking.h"
#import "GradientLinePoint.h"

@interface Tracking ()
{
    CLLocationCoordinate2D *_coordinates;
    NSUInteger              _count;
}

@property (nonatomic, strong, readwrite) MAPointAnnotation *annotation;
@property (nonatomic, strong, readwrite) MAPolyline *polyline;

@property (nonatomic, strong) CAShapeLayer *shapeLayer;

/** 渐变背景视图 */
@property (nonatomic, strong) UIView          *gradientBackgroundView;
/** 渐变图层 */
@property (nonatomic, strong) CAGradientLayer *gradientLayer;
/** 颜色数组 */
@property (nonatomic, strong) NSMutableArray  *gradientLayerColors;

@property (nonatomic, strong) NSArray *pointArray;

@property (nonatomic, readonly, getter=isAnimating) BOOL animating;

@end

@implementation Tracking
@synthesize mapView     = _mapView;
@synthesize shapeLayer  = _shapeLayer;
@synthesize gradientLayer = _gradientLayer;

@synthesize annotation  = _annotation;
@synthesize polyline    = _polyline;

#pragma mark - init

- (instancetype)initWithCoordinates:(CLLocationCoordinate2D *)coordinates count:(NSUInteger)count
{
    if (self = [super init])
    {
        if (coordinates == NULL || count <= 1)
        {
            return nil;
        }
        
        self.duration = 0;
        
        self.edgeInsets = UIEdgeInsetsMake(-100, -100, -100, -100);
        
        _count = count;
        
        _coordinates = (CLLocationCoordinate2D *)malloc(count * sizeof(CLLocationCoordinate2D));
        
        if (_coordinates == NULL)
        {
            return nil;
        }
        
        /* 内存拷贝. */
        memcpy(_coordinates, coordinates, count * sizeof(CLLocationCoordinate2D));
        
        [self initBaseData];
    }
    
    return self;
}

#pragma mark - Initialization

- (void)initBaseData
{
    _animating = NO;
    
    [self initAnnotation];
    
    [self initPolyline];
    
    /*
    [self initGradientLayer];

    [self initShapeLayer];
     */
}

/* 构建shapeLayer. */
- (void)initShapeLayer
{
    self.shapeLayer = [[CAShapeLayer alloc] init];
    self.shapeLayer.lineWidth         = 6;
    self.shapeLayer.strokeColor       = MYBLUECOLOR.CGColor;
    self.shapeLayer.fillColor         = [UIColor clearColor].CGColor;
    self.shapeLayer.lineJoin          = kCALineCapRound;
}

/* 构建annotation. */
- (void)initAnnotation
{
    self.annotation = [[MAPointAnnotation alloc] init];
    self.annotation.title = @"end";
    
    self.startAnnotation = [[MAPointAnnotation alloc] init];
    self.startAnnotation.title = @"start";
    
    self.annotation.coordinate = _coordinates[0];
    self.startAnnotation.coordinate = _coordinates[0];
}

/* 构建polyline. */
- (void)initPolyline
{
    self.polyline = [MAPolyline polylineWithCoordinates:_coordinates count:_count];
}

#pragma mark - 设置渐变视图方法的具体实现

- (void)drawGradientBackgroundView {
    // 渐变背景视图（不包含坐标轴）
    self.gradientBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.mapView.bounds.size.width, self.mapView.bounds.size.height)];
//    [self.gradientLineView addSubview:_gradientBackgroundView];
//    [self.mapView addSubview:self.gradientBackgroundView];
    /** 创建并设置渐变背景图层 */
    //初始化CAGradientlayer对象，使它的大小为渐变背景视图的大小
    self.gradientLayer = [CAGradientLayer layer];
    self.gradientLayer.frame = self.gradientBackgroundView.bounds;
    //设置渐变区域的起始和终止位置（范围为0-1），即渐变路径
    self.gradientLayer.startPoint = CGPointMake(0.0, 0.0);
    self.gradientLayer.endPoint = CGPointMake(1.0, 0.0);
    //设置颜色的渐变过程
    _gradientLayerColors = [NSMutableArray arrayWithArray:
                            @[(__bridge id)[UIColor colorWithRed:1.00f green:0.50f blue:0.49f alpha:1.00f].CGColor,
                              (__bridge id)[UIColor colorWithRed:1.00f green:0.59f blue:0.70f alpha:1.00f].CGColor,
                              (__bridge id)[UIColor colorWithRed:0.93f green:0.73f blue:0.73f alpha:1.00f].CGColor,
                              (__bridge id)[UIColor colorWithRed:0.96f green:0.94f blue:0.66f alpha:1.00f].CGColor,
                              (__bridge id)[UIColor colorWithRed:0.94f green:0.96f blue:0.75f alpha:1.00f].CGColor,
                              (__bridge id)[UIColor colorWithRed:0.59f green:0.94f blue:0.91f alpha:1.00f].CGColor,
                              (__bridge id)[UIColor colorWithRed:0.440 green:0.990 blue:0.990 alpha:1.000].CGColor,
                              (__bridge id)[UIColor colorWithRed:0.24f green:0.85f blue:0.82f alpha:1.00f].CGColor]];

    self.gradientLayer.colors = _gradientLayerColors;
    //将CAGradientlayer对象添加在我们要设置背景色的视图的layer层
    [self.gradientBackgroundView.layer addSublayer:self.gradientLayer];
    
    
    NSArray *pointArray = [self getPointsWithCoordinates:_coordinates count:_count];
    
    /** 折线路径 */
    UIBezierPath *path = [UIBezierPath bezierPath];
    [pointArray enumerateObjectsUsingBlock:^(GradientLinePoint * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        // 折线
        if (idx == 0)
        {
            [path moveToPoint:CGPointMake(obj.x, obj.y)];
        }
        else
        {
            [path addLineToPoint:CGPointMake(obj.x, obj.y)];
        }
    }];
    /** 将折线添加到折线图层上，并设置相关的属性 */
    self.shapeLayer = [CAShapeLayer layer];
    self.shapeLayer.path = path.CGPath;
    self.shapeLayer.strokeColor = [UIColor whiteColor].CGColor;
    self.shapeLayer.fillColor   = [UIColor clearColor].CGColor;
    // 默认设置路径宽度为0，使其在起始状态下不显示
    self.shapeLayer.lineWidth = 0;
    self.shapeLayer.lineCap = kCALineCapRound;
    self.shapeLayer.lineJoin = kCALineJoinRound;
    // 设置折线图层为渐变图层的mask
    self.gradientBackgroundView.layer.mask = self.shapeLayer;
}

#pragma mark - 设置折线图层方法的具体实现

- (UIBezierPath *)setupLineChartLayerAppearanceWithCoordinates:(CLLocationCoordinate2D *)coordinates count:(NSUInteger)count
{
    NSArray *pointArray = [self getPointsWithCoordinates:coordinates count:count];
    
    /** 折线路径 */
    UIBezierPath *path = [UIBezierPath bezierPath];
    [pointArray enumerateObjectsUsingBlock:^(GradientLinePoint * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        // 折线
        if (idx == 0)
        {
            [path moveToPoint:CGPointMake(obj.x, obj.y)];
        }
        else
        {
            [path addLineToPoint:CGPointMake(obj.x, obj.y)];
        }
    }];
    /** 将折线添加到折线图层上，并设置相关的属性 */
    self.shapeLayer = [CAShapeLayer layer];
    self.shapeLayer.path = path.CGPath;
    self.shapeLayer.strokeColor = [UIColor whiteColor].CGColor;
    self.shapeLayer.fillColor   = [UIColor clearColor].CGColor;
    // 默认设置路径宽度为0，使其在起始状态下不显示
    //    self.shapeLayer.lineWidth = 0;
    self.shapeLayer.lineWidth = 6;
    //    self.shapeLayer.lineCap = kCALineCapRound;
    self.shapeLayer.lineJoin = kCALineJoinRound;
    // 设置折线图层为渐变图层的mask
    self.gradientBackgroundView.layer.mask = self.shapeLayer;
    
    return path;
}

#pragma mark - Interface

- (void)execute
{
    /* 使轨迹在地图可视范围内. */
    //226242624.000000 - 99843616.000000 - 14176.000000 - 4200.000000
//    NSLog(@"%f - %f - %f - %f",self.polyline.boundingMapRect.origin.x,self.polyline.boundingMapRect.origin.y,self.polyline.boundingMapRect.size.width,self.polyline.boundingMapRect.size.height);
    
    //    [ConfigData showWcAlertWithTitle:@"" message:[NSString stringWithFormat:@"%f - %f - %f - %f",self.polyline.boundingMapRect.origin.x,self.polyline.boundingMapRect.origin.y,self.polyline.boundingMapRect.size.width,self.polyline.boundingMapRect.size.height]];
    
    //计算位移差，让路线能显示在地图中的前提下尽量放大
    //    float pix_width  = (self.polyline.boundingMapRect.size.width / self.polyline.boundingMapRect.size.height) / (14176 / 4200);
    
    //+5000,+13000,-20000,-20000
    //    MAMapRect m = MAMapRectMake(self.polyline.boundingMapRect.origin.x + 500 / pix_width, self.polyline.boundingMapRect.origin.y + 1300 / pix_width, self.polyline.boundingMapRect.size.width - 2000 / pix_width, self.polyline.boundingMapRect.size.height - 2000 / pix_width);
    [self.mapView setVisibleMapRect:self.polyline.boundingMapRect edgePadding:self.edgeInsets animated:NO];//self.polyline.boundingMapRect
    
    
    //先显示开始点
    [self.mapView addAnnotation:self.startAnnotation];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //0.5秒后开始显示轨迹
        
        /* 构建path. */
//        CGPoint *points = [self pointsForCoordinates:_coordinates count:_count];
//        CGPathRef path = [self pathForPoints:points count:_count];
//
//        self.shapeLayer.path = path;
    
    
        [self drawGradientBackgroundView];
        [self.mapView.layer insertSublayer:self.gradientBackgroundView.layer atIndex:1];
//        [self.mapView addSubview:self.gradientBackgroundView];
        [self startDrawlineChart];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            //1秒后开始显示动态颜色
            [self startAnimating];
        });
        
        //线划完后显示结束点
        [self.mapView addAnnotation:self.annotation];
        
        MAAnnotationView *startAnnotationView = [self.mapView viewForAnnotation:self.startAnnotation];
        [startAnnotationView.annotation setCoordinate:_coordinates[0]];
        
        MAAnnotationView *annotationView = [self.mapView viewForAnnotation:self.annotation];
        if (annotationView != nil)
        {
            /* Annotation animation. */
//            CAAnimation *annotationAnimation = [self constructAnnotationAnimationWithPath:path.CGPath];
//            [annotationView.layer addAnimation:annotationAnimation forKey:@"annotation"];

            [annotationView.annotation setCoordinate:_coordinates[_count - 1]];

            /* ShapeLayer animation. */
//            CAAnimation *shapeLayerAnimation = [self constructShapeLayerAnimation];
//            shapeLayerAnimation.delegate = self;
//            [self.shapeLayer addAnimation:shapeLayerAnimation forKey:@"shape"];
        }

//        free(points),           points  = NULL;
//        CGPathRelease(path),    path    = NULL;
    });
}

#pragma mark - 绘制折线图动画

/** 动画开始，绘制折线图 */
- (void)startDrawlineChart {
    // 设置路径宽度为4，使其能够显示出来
    self.shapeLayer.lineWidth = 6;
    
    // 设置动画的相关属性
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    pathAnimation.duration = 0.5;
    pathAnimation.repeatCount = 1;
    pathAnimation.removedOnCompletion = NO;
    pathAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
    pathAnimation.toValue = [NSNumber numberWithFloat:1.0f];
    // 设置动画代理，动画结束时添加一个标签，显示折线终点的信息
    pathAnimation.delegate = self;
    [self.shapeLayer addAnimation:pathAnimation forKey:@"strokeEnd"];
}

#pragma mark - 折线图颜色渐变动画

- (void)performAnimation {
    
    // Update the colors on the model layer
    
    CAGradientLayer *layer = (id)self.gradientLayer;
    NSArray *fromColors = [layer colors];
    NSArray *toColors = [self shiftColors:fromColors];
    [layer setColors:toColors];
    
    // Create an animation to slowly move the hue gradient left to right.
    
    CABasicAnimation *animation;
    animation = [CABasicAnimation animationWithKeyPath:@"colors"];
    [animation setFromValue:fromColors];
    [animation setToValue:toColors];
    [animation setDuration:1.0f];
    [animation setRemovedOnCompletion:YES];
    [animation setFillMode:kCAFillModeForwards];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
    [animation setDelegate:self];
    
    // Add the animation to our layer
    [layer addAnimation:animation forKey:@"animateGradient"];
}

- (NSArray *)shiftColors:(NSArray *)colors {
    
    // Moves the last item in the array to the front
    // shifting all the other elements.
    
    NSMutableArray *mutable = [colors mutableCopy];
    id first = mutable[0];
    [mutable removeObject:first];
    [mutable addObject:first];
    return [NSArray arrayWithArray:mutable];
}

#pragma mark - CoreAnimation Delegate

- (void)animationDidStart:(CAAnimation *)animation
{
    [self makeMapViewEnable:NO];
    
//    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(willBeginTracking:)])
//    {
//        [self.delegate willBeginTracking:self];
//    }
}

- (void)animationDidStop:(CAAnimation *)animation finished:(BOOL)flag
{
    if (flag)
    {
        [self.mapView addOverlay:self.polyline];
        
//        [self.shapeLayer removeFromSuperlayer];
    }
    
    [self makeMapViewEnable:YES];
    
//    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(didEndTracking:)])
//    {
//        [self.delegate didEndTracking:self];
//    }
    
    if ([self isAnimating])
    {
        
        [self performAnimation];
    }
}

- (void)startAnimating {
    
    if (![self isAnimating]) {
        
        _animating = YES;
        
        [self performAnimation];
    }
}

- (void)stopAnimating {
    
    if ([self isAnimating]) {
        
        _animating = NO;
    }
}

#pragma mark - Utility

/* Enable/Disable mapView. */
- (void)makeMapViewEnable:(BOOL)enabled
{
    self.mapView.scrollEnabled          = enabled;
    self.mapView.zoomEnabled            = enabled;
}

- (NSArray *)getPointsWithCoordinates:(CLLocationCoordinate2D *)coordinates count:(NSUInteger)count
{
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:0];
    /* 经纬度转换为屏幕坐标. */
    for (int i = 0; i < count; i++)
    {
        CGPoint point = [self.mapView convertCoordinate:coordinates[i] toPointToView:self.mapView];
        GradientLinePoint *linePoint = [GradientLinePoint pointWithX:point.x andY:point.y];
        [array addObject:linePoint];
    }
    
    return [NSArray arrayWithArray:array];
}

/* 经纬度转屏幕坐标, 调用者负责释放内存. */
- (CGPoint *)pointsForCoordinates:(CLLocationCoordinate2D *)coordinates count:(NSUInteger)count
{
    if (coordinates == NULL || count <= 1)
    {
        return NULL;
    }
    
    /* 申请屏幕坐标存储空间. */
    CGPoint *points = (CGPoint *)malloc(count * sizeof(CGPoint));
    
    /* 经纬度转换为屏幕坐标. */
    for (int i = 0; i < count; i++)
    {
        points[i] = [self.mapView convertCoordinate:coordinates[i] toPointToView:self.mapView];
    }
    
    return points;
}

/* 构建path, 调用者负责释放内存. */
- (CGMutablePathRef)pathForPoints:(CGPoint *)points count:(NSUInteger)count
{
    if (points == NULL || count <= 1)
    {
        return NULL;
    }
    
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGPathAddLines(path, NULL, points, count);
    
    return path;
}

/* 构建annotationView的keyFrameAnimation. */
- (CAAnimation *)constructAnnotationAnimationWithPath:(CGPathRef)path
{
    if (path == NULL)
    {
        return nil;
    }
    
    CAKeyframeAnimation *thekeyFrameAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    thekeyFrameAnimation.duration        = self.duration;
    thekeyFrameAnimation.path            = path;
    thekeyFrameAnimation.calculationMode = kCAAnimationPaced;
    
    return thekeyFrameAnimation;
}

/* 构建shapeLayer的basicAnimation. */
- (CAAnimation *)constructShapeLayerAnimation
{
    CABasicAnimation *theStrokeAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    theStrokeAnimation.duration         = self.duration;
    theStrokeAnimation.fromValue        = @0.f;
    theStrokeAnimation.toValue          = @1.f;
    
    return theStrokeAnimation;
}

#pragma mark - 清除Annotation

- (void)clear
{
    /* 删除annotation. */
    [self.mapView removeAnnotation:self.annotation];
    
    /* 删除polyline. */
    [self.mapView removeOverlay:self.polyline];
    
    /* 删除shapeLayer. */
    [self.shapeLayer    removeFromSuperlayer];
    [self.gradientLayer removeFromSuperlayer];
    
    if(self.gradientBackgroundView)
        [self.gradientBackgroundView removeFromSuperview];
    
    [self stopAnimating];
}

#pragma mark - Life Cycle

- (void)dealloc
{
//    [self clear];
    
    if (_coordinates != NULL)
    {
        free(_coordinates), _coordinates = NULL;
    }
}


@end
