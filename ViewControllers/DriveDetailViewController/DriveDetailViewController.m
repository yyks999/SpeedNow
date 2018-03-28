//
//  DriveDetailViewController.m
//  SpeedNow
//
//  Created by 杨翊楷 on 15/11/30.
//  Copyright © 2015年 YK Yang. All rights reserved.
//

#import "DriveDetailViewController.h"
#import "FoldingView.h"
#import "TrackingMapView.h"
#import "POP.h"
#import "GradientLineView.h"

@interface DriveDetailViewController ()
{
    int pix;
    int timeValue;
    
    NSTimer *atLeastTimer;
}

@property(nonatomic, strong) FoldingView *localView;    //地理位置
@property(nonatomic, strong) FoldingView *mapView;      //地图
@property(nonatomic, strong) FoldingView *distanceView; //距离
@property(nonatomic, strong) FoldingView *avgGasView;   //平均油耗
@property(nonatomic, strong) FoldingView *gasView;      //汽油消耗
@property(nonatomic, strong) FoldingView *maxSpeedView; //最高时速
@property(nonatomic, strong) FoldingView *avgSpeedView; //平均速度
@property(nonatomic, strong) FoldingView *timeView;     //行驶时间

//@property(nonatomic, strong) YKMapView *ykMapView;
@property (nonatomic, strong) TrackingMapView *ykMapView;


- (void)addFoldView;

@end

@implementation DriveDetailViewController

#pragma mark - Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0.20f green:0.20f blue:0.31f alpha:1.00f];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    [self getTimeValue];
    
    pix = 1;
    _allowExist = YES;
    
    [self addFoldView];

    for (int i = 0; i < 8; i++) {
        
        [self performSelector:@selector(blockAnimationWithStep:) withObject:[NSString stringWithFormat:@"%d",i + 1] afterDelay:0.5 + i * 0.2];
    }
    
    if(!atLeastTimer)
    {
        atLeastTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(notAllowedExist) userInfo:nil repeats:NO];
    }
    
    UISwipeGestureRecognizer *backGuest = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(back)];
    backGuest.direction = UISwipeGestureRecognizerDirectionDown;
    [self.view addGestureRecognizer:backGuest];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[[MapViewSingleton shareInstance] mapView] removeOverlay:_ykMapView.tracking.polyline];
    [[[MapViewSingleton shareInstance] mapView] removeAnnotation:_ykMapView.tracking.startAnnotation];
    [[[MapViewSingleton shareInstance] mapView] removeAnnotation:_ykMapView.tracking.annotation];
    
    [_ykMapView.tracking clear];
    _ykMapView.mapView.delegate = nil;
}

#pragma mark - blockAnimation

- (void)blockAnimationWithStep:(id)sender
{
    int step = [(NSString *)sender intValue];
    
    switch (step) {
        case 1:
            //1-地理位置
            [self.localView poke];
            break;
        case 2:
            //2-地图
            [self.mapView poke];
            break;
        case 3:
            //3-距离
            [self.distanceView poke];
            break;
        case 4:
            //4-平均油耗
            [self.avgGasView poke];
            break;
        case 5:
            //5-汽油消耗
            [self.gasView poke];
            break;
        case 6:
            //6-行驶时间
            [self.timeView poke];
            break;
        case 7:
            //7-平均速度
            [self.avgSpeedView poke];
            break;
        case 8:
            //8-最高时速
            [self.maxSpeedView poke];
            break;
            
        default:
            break;
    }
}

- (void)notAllowedExist
{
    _allowExist = NO;
}

#pragma mark - Private instance methods

- (void)addFoldView
{
//                            ___________________
//                            |                 |
//                            |        1        | 130
//                            |_________________|
//                            |                 |
//                            |        2        | 130
//                            |_________________|
//                            |         |   4   | 73
//                            |    3    |_______|
//                            |         |   5   | 73
//                            |_________|_______|
//                            |   7   |         |
//                            |_______|    6    | 148
//                            |   8   |         |
//                            |_______|_________|
    
    [self initLocalView];
    [self initMapView];
    [self initDistanceView];
    [self initAvgGasView];
    [self initGasView];
    [self initTimeView];
    [self initAvgSpeedView];
    [self initMaxSpeedView];
}

#pragma mark - Initialization

- (void)initLocalView
{
    //1-地理位置
    self.localView = [[FoldingView alloc] initWithFrame:CGRectMake(15, 15, 290, 130) image:[UIImage imageNamed:@""] layerSection:LayerSectionTop order:1];
    [self.view addSubview:self.localView];
    
    //需要一个中间View来承载动画
    UIView *localMidView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 290, 130)];
    localMidView.backgroundColor = [UIColor clearColor];
    [self.localView addSubview:localMidView];
    
    UILabel *titleLabel = [self createLableWithFrame:CGRectMake(0, 0, 290, 30) text:@"TRIP LOG" fontSize:15];
    titleLabel.textColor = [UIColor colorWithRed:0.85f green:0.86f blue:0.89f alpha:0.80f];
    [localMidView addSubview:titleLabel];
    
    UILabel *nowLabel = [self createLableWithFrame:CGRectMake(30, CGRectGetMaxY(titleLabel.frame) + 20, 80, 20) text:@"NOW" fontSize:13];
    nowLabel.textAlignment = NSTextAlignmentLeft;
    nowLabel.textColor = [UIColor colorWithRed:0.33f green:1.00f blue:1.00f alpha:1.00f];
    [localMidView addSubview:nowLabel];
    
    UILabel *nowPlace = [self createLableWithFrame:CGRectMake(30, CGRectGetMaxY(nowLabel.frame), 100, 40) text:[[ConfigData shareInstance] speedInfo].destination fontSize:13];
    nowPlace.textAlignment = NSTextAlignmentLeft;
    nowPlace.textColor = [UIColor whiteColor];
    nowPlace.numberOfLines = 0;
    [localMidView addSubview:nowPlace];
    
    UILabel *nowTimeLabel = [self createLableWithFrame:CGRectMake(CGRectGetMaxX(nowLabel.frame) - 5, CGRectGetMinY(nowLabel.frame), 70, 20) text:[ConfigData getNowDateString] fontSize:12];
    nowTimeLabel.textAlignment = NSTextAlignmentLeft;
    nowTimeLabel.textColor = [UIColor grayColor];
    nowTimeLabel.numberOfLines = 0;
    [localMidView addSubview:nowTimeLabel];
    
    UIView *separateLine = [[UIView alloc] initWithFrame:CGRectMake(144.5, 43, 1, 87)];
    separateLine.backgroundColor = [UIColor lightGrayColor];
    [localMidView addSubview:separateLine];
    
    UILabel *startLabel = [self createLableWithFrame:CGRectMake(CGRectGetMaxX(separateLine.frame) + 30, CGRectGetMinY(nowLabel.frame), 70, 20) text:@"START" fontSize:13];
    startLabel.textAlignment = NSTextAlignmentLeft;
    startLabel.textColor = [UIColor colorWithRed:0.33f green:1.00f blue:1.00f alpha:1.00f];
    [localMidView addSubview:startLabel];
    
    UILabel *startPlace = [self createLableWithFrame:CGRectMake(CGRectGetMinX(startLabel.frame), CGRectGetMaxY(startLabel.frame), 100, 40) text:[[ConfigData shareInstance] speedInfo].starting fontSize:13];
    startPlace.textAlignment = NSTextAlignmentLeft;
    startPlace.textColor = [UIColor whiteColor];
    startPlace.numberOfLines = 0;
    [localMidView addSubview:startPlace];
    
    UILabel *startTimeLabel = [self createLableWithFrame:CGRectMake(CGRectGetMaxX(startLabel.frame), CGRectGetMinY(startLabel.frame), 70, 20) text:[ConfigData getStartingDate] fontSize:12];
    startTimeLabel.textAlignment = NSTextAlignmentLeft;
    startTimeLabel.textColor = [UIColor grayColor];
    startTimeLabel.numberOfLines = 0;
    [localMidView addSubview:startTimeLabel];
    
    
    for (UIView *v in self.localView.subviews)
    {
        v.layer.transform = [self transform3D];
        v.layer.mask = [self maskForSection:LayerSectionTop withRect:v.bounds];
        [v.layer setAnchorPoint:CGPointMake(0.5, 0)];
        [v.layer setPosition:CGPointMake(v.layer.position.x + v.layer.bounds.size.width * (v.layer.anchorPoint.x - 0.5),v.layer.position.y + v.layer.bounds.size.height * (v.layer.anchorPoint.y - 0.5))];
        
        POPBasicAnimation *rotationAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerRotationX];
        rotationAnimation.duration = 0;
        rotationAnimation.toValue = @(-1.570796);
        [v.layer pop_addAnimation:rotationAnimation forKey:@"drotationAnimation"];
    }
}

- (void)initMapView
{
    //2-地图
    self.mapView = [[FoldingView alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.localView.frame), CGRectGetMaxY(self.localView.frame) + pix, self.localView.frame.size.width, 115) image:[UIImage imageNamed:@""] layerSection:LayerSectionTop order:2];
    [self.view addSubview:self.mapView];
    
    UIView *mapMidView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.localView.frame.size.width, 115)];
    mapMidView.backgroundColor = [UIColor clearColor];
    [self.mapView addSubview:mapMidView];
    
    _ykMapView = [[TrackingMapView alloc] initWithFrame:CGRectMake(0, 0, self.localView.frame.size.width, 135)];
    [mapMidView addSubview:_ykMapView];
    
    
    for (UIView *v in self.mapView.subviews)
    {
        v.layer.transform = [self transform3D];
        v.layer.mask = [self maskForSection:LayerSectionTop withRect:v.bounds];
        [v.layer setAnchorPoint:CGPointMake(0.5, 0)];
        [v.layer setPosition:CGPointMake(v.layer.position.x + v.layer.bounds.size.width * (v.layer.anchorPoint.x - 0.5),v.layer.position.y + v.layer.bounds.size.height * (v.layer.anchorPoint.y - 0.5))];
        
        POPBasicAnimation *rotationAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerRotationX];
        rotationAnimation.duration = 0;
        rotationAnimation.toValue = @(-1.570796);
        [v.layer pop_addAnimation:rotationAnimation forKey:@"drotationAnimation"];
    }
}

- (void)initDistanceView
{
    //3-距离
    self.distanceView = [[FoldingView alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.mapView.frame), CGRectGetMaxY(self.mapView.frame) + pix, 179, 147) image:[UIImage imageNamed:@""] layerSection:LayerSectionTop order:3];
    [self.view addSubview:self.distanceView];
    
    UIView *distanceMidView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 179, 147)];
    distanceMidView.backgroundColor = [UIColor clearColor];
    [self.distanceView addSubview:distanceMidView];
    
    
    NSString *distanceString = @"";
    if([[ConfigData shareInstance] speedInfo].distance <= 10000 && [[ConfigData shareInstance] speedInfo].distance >= 100)
    {
        float distanceValue = [[ConfigData shareInstance] speedInfo].distance / 1000;
        distanceString = [NSString stringWithFormat:@"%.1f",distanceValue];
    }
    else
    {
        int distanceValue = [[ConfigData shareInstance] speedInfo].distance / 1000;
        distanceString = [NSString stringWithFormat:@"%d",distanceValue];
    }
    
    CGSize txtSize = [distanceString getSizeOfStringFontSize:60 constroSize:CGSizeMake(MAXFLOAT, 70)];
    float txtWidth = txtSize.width;
    float txt_pix = txtWidth - 70;
    
    UILabel *distanceCount = [self createLableWithFrame:CGRectMake(52 - txt_pix / 2, 25, txtWidth, 70) text:distanceString fontSize:60];
    [distanceMidView addSubview:distanceCount];
    
    UILabel *kmLabel = [self createLableWithFrame:CGRectMake(CGRectGetMaxX(distanceCount.frame) + 5, CGRectGetMaxY(distanceCount.frame) - 40, 35, 35) text:@"km" fontSize:25];
    kmLabel.textColor = [UIColor lightGrayColor];
    [distanceMidView addSubview:kmLabel];
    
    UILabel *distanceLabel = [self createLableWithFrame:CGRectMake(0, CGRectGetMaxY(distanceCount.frame), distanceMidView.frame.size.width, 20) text:@"DISTANCE" fontSize:12];
    distanceLabel.font = [UIFont boldSystemFontOfSize:12];
    distanceLabel.textColor = [UIColor colorWithRed:0.33f green:1.00f blue:1.00f alpha:1.00f];
    [distanceMidView addSubview:distanceLabel];
    
    for (UIView *v in self.distanceView.subviews)
    {
        v.layer.transform = [self transform3D];
        v.layer.mask = [self maskForSection:LayerSectionTop withRect:v.bounds];
        [v.layer setAnchorPoint:CGPointMake(0.5, 0)];
        [v.layer setPosition:CGPointMake(v.layer.position.x + v.layer.bounds.size.width * (v.layer.anchorPoint.x - 0.5),v.layer.position.y + v.layer.bounds.size.height * (v.layer.anchorPoint.y - 0.5))];
        
        POPBasicAnimation *rotationAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerRotationX];
        rotationAnimation.duration = 0;
        rotationAnimation.toValue = @(-1.570796);
        [v.layer pop_addAnimation:rotationAnimation forKey:@"drotationAnimation"];
    }
}

- (void)initAvgGasView
{
    //4-平均油耗
    self.avgGasView = [[FoldingView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.distanceView.frame) + pix, CGRectGetMinY(self.distanceView.frame), 110, 73) image:[UIImage imageNamed:@""] layerSection:LayerSectionLeft order:4];
    [self.view addSubview:self.avgGasView];
    
    UIView *avgGasMidView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 110, 73)];
    avgGasMidView.backgroundColor = [UIColor clearColor];
    [self.avgGasView addSubview:avgGasMidView];
    
    UIImageView *avgGasImage = [[UIImageView alloc] initWithFrame:CGRectMake(10, 19, 35, 35)];
    avgGasImage.image = [UIImage imageNamed:@"avg_gas.png"];
    [avgGasMidView addSubview:avgGasImage];
    
    UILabel *avgGasLabel = [self createLableWithFrame:CGRectMake(CGRectGetMaxX(avgGasImage.frame), 17, 50, 40) text:@"12.3" fontSize:25];
    avgGasLabel.textAlignment = NSTextAlignmentLeft;
    [avgGasMidView addSubview:avgGasLabel];
    
    UILabel *lLabel = [self createLableWithFrame:CGRectMake(CGRectGetMaxX(avgGasLabel.frame), 20, 10, 40) text:@"L" fontSize:18];
    lLabel.textColor = [UIColor lightGrayColor];
    [avgGasMidView addSubview:lLabel];

    
    for (UIView *v in self.avgGasView.subviews)
    {
        v.layer.transform = [self transform3D];
        v.layer.mask = [self maskForSection:LayerSectionTop withRect:v.bounds];
        [v.layer setAnchorPoint:CGPointMake(0, 0.5)];
        [v.layer setPosition:CGPointMake(v.layer.position.x + v.layer.bounds.size.width * (v.layer.anchorPoint.x - 0.5),v.layer.position.y + v.layer.bounds.size.height * (v.layer.anchorPoint.y - 0.5))];
        
        POPBasicAnimation *rotationAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerRotationY];
        rotationAnimation.duration = 0;
        rotationAnimation.toValue = @(-1.570796);
        [v.layer pop_addAnimation:rotationAnimation forKey:@"drotationAnimation"];
    }
}

- (void)initGasView
{
    //5-汽油消耗
    self.gasView = [[FoldingView alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.avgGasView.frame), CGRectGetMaxY(self.avgGasView.frame) + pix, self.avgGasView.frame.size.width, self.avgGasView.frame.size.height) image:[UIImage imageNamed:@""] layerSection:LayerSectionLeft order:5];
    [self.view addSubview:self.gasView];
    
    UIView *gasMidView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 110, 73)];
    gasMidView.backgroundColor = [UIColor clearColor];
    [self.gasView addSubview:gasMidView];
    
    UIImageView *gasImage = [[UIImageView alloc] initWithFrame:CGRectMake(10, 19, 35, 35)];
    gasImage.image = [UIImage imageNamed:@"gas.png"];
    [gasMidView addSubview:gasImage];
    
    UILabel *gasLabel = [self createLableWithFrame:CGRectMake(CGRectGetMaxX(gasImage.frame), 17, 40, 40) text:@"16" fontSize:35];
    gasLabel.textAlignment = NSTextAlignmentLeft;
    [gasMidView addSubview:gasLabel];
    
    UILabel *lLabel = [self createLableWithFrame:CGRectMake(CGRectGetMaxX(gasLabel.frame), 23, 10, 40) text:@"L" fontSize:18];
    lLabel.textColor = [UIColor lightGrayColor];
    [gasMidView addSubview:lLabel];
    
    
    for (UIView *v in self.gasView.subviews)
    {
        v.layer.transform = [self transform3D];
        v.layer.mask = [self maskForSection:LayerSectionTop withRect:v.bounds];
        [v.layer setAnchorPoint:CGPointMake(0, 0.5)];
        [v.layer setPosition:CGPointMake(v.layer.position.x + v.layer.bounds.size.width * (v.layer.anchorPoint.x - 0.5),v.layer.position.y + v.layer.bounds.size.height * (v.layer.anchorPoint.y - 0.5))];
        
        POPBasicAnimation *rotationAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerRotationY];
        rotationAnimation.duration = 0;
        rotationAnimation.toValue = @(-1.570796);
        [v.layer pop_addAnimation:rotationAnimation forKey:@"drotationAnimation"];
    }
}

- (void)initTimeView
{
    //6-行驶时间
    self.timeView = [[FoldingView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - 15 - self.distanceView.frame.size.width), CGRectGetMaxY(self.gasView.frame) + pix, self.distanceView.frame.size.width, self.distanceView.frame.size.height) image:[UIImage imageNamed:@""] layerSection:LayerSectionTop order:6];
    [self.view addSubview:self.timeView];
    
    UIView *timeMidView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.distanceView.frame.size.width, self.distanceView.frame.size.height)];
    timeMidView.backgroundColor = [UIColor clearColor];
    [self.timeView addSubview:timeMidView];
    
    UILabel *timeCount = [self createLableWithFrame:CGRectMake(35, 25, 110, 70) text:[ConfigData getFullTimeBySecond:[[ConfigData shareInstance] speedInfo].driveTime] fontSize:50];
    [timeMidView addSubview:timeCount];
    
    UILabel *timeLabel = [self createLableWithFrame:CGRectMake(CGRectGetMinX(timeCount.frame), CGRectGetMaxY(timeCount.frame), 110, 20) text:@"TIME OF DRIVE" fontSize:12];
    timeLabel.font = [UIFont boldSystemFontOfSize:12];
    timeLabel.textColor = [UIColor colorWithRed:0.33f green:1.00f blue:1.00f alpha:1.00f];
    [timeMidView addSubview:timeLabel];
    
    
    for (UIView *v in self.timeView.subviews)
    {
        v.layer.transform = [self transform3D];
        v.layer.mask = [self maskForSection:LayerSectionTop withRect:v.bounds];
        [v.layer setAnchorPoint:CGPointMake(0.5, 0)];
        [v.layer setPosition:CGPointMake(v.layer.position.x + v.layer.bounds.size.width * (v.layer.anchorPoint.x - 0.5),v.layer.position.y + v.layer.bounds.size.height * (v.layer.anchorPoint.y - 0.5))];
        
        POPBasicAnimation *rotationAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerRotationX];
        rotationAnimation.duration = 0;
        rotationAnimation.toValue = @(-1.570796);
        [v.layer pop_addAnimation:rotationAnimation forKey:@"drotationAnimation"];
    }
}

- (void)initAvgSpeedView
{
    //7-平均速度
    self.avgSpeedView = [[FoldingView alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.distanceView.frame), CGRectGetMaxY(self.distanceView.frame) + pix, self.avgGasView.frame.size.width, self.avgGasView.frame.size.height) image:[UIImage imageNamed:@""] layerSection:LayerSectionRight order:7];
    [self.view addSubview:self.avgSpeedView];
    
    UIView *avgSpeedMidView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.avgGasView.frame.size.width, self.avgGasView.frame.size.height)];
    avgSpeedMidView.backgroundColor = [UIColor clearColor];
    [self.avgSpeedView addSubview:avgSpeedMidView];
    
    UIImageView *avgSpeedImage = [[UIImageView alloc] initWithFrame:CGRectMake(10, 19, 35, 35)];
    avgSpeedImage.image = [UIImage imageNamed:@"avg_speed.png"];
    [avgSpeedMidView addSubview:avgSpeedImage];
    
    UILabel *avgSpeedLabel = [self createLableWithFrame:CGRectMake(CGRectGetMaxX(avgSpeedImage.frame), 13, 50, 35) text:[NSString stringWithFormat:@"%d",[[ConfigData shareInstance] speedInfo].avgSpeed] fontSize:30];
    [avgSpeedMidView addSubview:avgSpeedLabel];
    
    UILabel *kmLabel = [self createLableWithFrame:CGRectMake(CGRectGetMinX(avgSpeedLabel.frame) + 7, CGRectGetMaxY(avgSpeedLabel.frame), 35, 8) text:@"km/h" fontSize:13];
    kmLabel.textColor = [UIColor lightGrayColor];
    [avgSpeedMidView addSubview:kmLabel];
    
    
    for (UIView *v in self.avgSpeedView.subviews)
    {
        v.layer.transform = [self transform3D];
        v.layer.mask = [self maskForSection:LayerSectionTop withRect:v.bounds];
        [v.layer setAnchorPoint:CGPointMake(1, 0.5)];
        [v.layer setPosition:CGPointMake(v.layer.position.x + v.layer.bounds.size.width * (v.layer.anchorPoint.x - 0.5),v.layer.position.y + v.layer.bounds.size.height * (v.layer.anchorPoint.y - 0.5))];
        
        POPBasicAnimation *rotationAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerRotationY];
        rotationAnimation.duration = 0;
        rotationAnimation.toValue = @(-1.570796);
        [v.layer pop_addAnimation:rotationAnimation forKey:@"drotationAnimation"];
    }
}

- (void)initMaxSpeedView
{
    //8-最高时速
    self.maxSpeedView = [[FoldingView alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.avgSpeedView.frame), CGRectGetMaxY(self.avgSpeedView.frame) + pix, self.avgGasView.frame.size.width, self.avgGasView.frame.size.height) image:[UIImage imageNamed:@""] layerSection:LayerSectionRight order:8];
    [self.view addSubview:self.maxSpeedView];
    
    UIView *maxSpeedMidView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.avgGasView.frame.size.width, self.avgGasView.frame.size.height)];
    maxSpeedMidView.backgroundColor = [UIColor clearColor];
    [self.maxSpeedView addSubview:maxSpeedMidView];
    
    UIImageView *maxSpeedImage = [[UIImageView alloc] initWithFrame:CGRectMake(10, 19, 35, 35)];
    maxSpeedImage.image = [UIImage imageNamed:@"top_speed.png"];
    [maxSpeedMidView addSubview:maxSpeedImage];
    
    UILabel *maxSpeedLabel = [self createLableWithFrame:CGRectMake(CGRectGetMaxX(maxSpeedImage.frame), 13, 50, 35) text:[NSString stringWithFormat:@"%d",[[ConfigData shareInstance] speedInfo].topSpeed] fontSize:30];
    [maxSpeedMidView addSubview:maxSpeedLabel];
    
    UILabel *kmLabel = [self createLableWithFrame:CGRectMake(CGRectGetMinX(maxSpeedLabel.frame) + 7, CGRectGetMaxY(maxSpeedLabel.frame), 35, 8) text:@"km/h" fontSize:13];
    kmLabel.textColor = [UIColor lightGrayColor];
    [maxSpeedMidView addSubview:kmLabel];
    
    
    for (UIView *v in self.maxSpeedView.subviews)
    {
        v.layer.transform = [self transform3D];
        v.layer.mask = [self maskForSection:LayerSectionTop withRect:v.bounds];
        [v.layer setAnchorPoint:CGPointMake(1, 0.5)];
        [v.layer setPosition:CGPointMake(v.layer.position.x + v.layer.bounds.size.width * (v.layer.anchorPoint.x - 0.5),v.layer.position.y + v.layer.bounds.size.height * (v.layer.anchorPoint.y - 0.5))];
        
        POPBasicAnimation *rotationAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerRotationY];
        rotationAnimation.duration = 0;
        rotationAnimation.toValue = @(-1.570796);
        [v.layer pop_addAnimation:rotationAnimation forKey:@"drotationAnimation"];
    }
}

#pragma mark - transform3D

- (CATransform3D)transform3D
{
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = 2.5 / -2000;
    return transform;
}

- (CAShapeLayer *)maskForSection:(LayerSection)section withRect:(CGRect)rect
{
    CAShapeLayer *layerMask = [CAShapeLayer layer];
    UIRectCorner corners = 0;//(section == LayerSectionTop) ? 0 : 12;
    
    layerMask.path = [UIBezierPath bezierPathWithRoundedRect:rect
                                           byRoundingCorners:corners
                                                 cornerRadii:CGSizeMake(5, 5)].CGPath;
    return layerMask;
}

#pragma mark - Time

- (void)getTimeValue
{
    //计算从启动应用到现在的时间差
    NSTimeInterval time_now  = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval time_last = [[NSUserDefaults standardUserDefaults] doubleForKey:SAVED_TIME];
    
    timeValue = time_now - time_last;
}

#pragma mark - Action

- (void)back
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

#pragma mark - Tool

//创建UILabel
- (UILabel *)createLableWithFrame:(CGRect)frame text:(NSString *)txt fontSize:(int)size
{
    UILabel * label = [[UILabel alloc] initWithFrame:frame];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:size];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = txt;
    return label;
}

@end
