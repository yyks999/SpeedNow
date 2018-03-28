//
//  ViewController.m
//  CircleTest
//
//  Created by 杨翊楷 on 14-10-20.
//  Copyright (c) 2014年 杨翊楷. All rights reserved.
//

#import "ConceptionViewController.h"
#import "CDCircleOverlayView.h"
#import "YYAnimation.h"
#import <CommonCrypto/CommonDigest.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreLocation/CLLocation.h>
#import "AFSoundManager.h"
#import "NSObject+FYXAnimation.h"
#import "PQFCustomLoaders.h"
#import "VideoViewController.h"
#import "PoliceViewController.h"
#import "DriveDetailViewController.h"
#import "TrackingMapView.h"

#define ADDRESS_INTERVAL  30    //定位间隔
#define VOICE_INTERVAL    40    //报速间隔
#define DISTANCE_INTERVAL 3     //超过此距离更新location信息 (单位：米)
#define LOCATION_DISTANCE 100   //超过此距离更新location缓存  (单位：米)
#define TEST_VALUE        32
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)(((rgbValue) & 0xFF0000) >> 16))/255.0 green:((float)(((rgbValue) & 0xFF00) >> 8))/255.0 blue:((float)((rgbValue) & 0xFF))/255.0 alpha:1.0]

#define TEST_MODEL      YES

@interface ConceptionViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
{
    CDCircle *circle;
    GPLoadingView *loading;
    SCSiriWaveformView *speedFlowView;
    PQFCirclesInTriangle *circlesInTriangle;
    
    DriveDetailViewController *ddVC;

    CLLocation *homeLocation;   //家的位置
    CLLocation *startLocation;  //开始行驶位置
    CLLocation *midLocation;    //记录中间位置
    
    NSTimer *timer;
    NSTimer *stopTimer;
    NSTimer *showDetailTimer;
    NSTimer *voiceTimer;
    NSTimer *testTimer;
    
    NSArray *speedColors;
    
    UIView *shadowView;
    
    float localSpeed;
    float lastSpeed;
    float savepoint;
    
    int testNum;
    
    BOOL testModel;
    BOOL testAdd;
    BOOL speedZero;
}

@property (nonatomic, strong) CSAnimationView *animation_bottomView;      //底部大视图动画
@property (nonatomic, strong) CSAnimationView *animation_leftView;        //左侧视图动画
@property (nonatomic, strong) CSAnimationView *animation_leftBottomView;  //底部左视图动画
@property (nonatomic, strong) CSAnimationView *animation_rightBottomView; //底部右视图动画

@property (nonatomic, strong) AFSoundManager  *soundManager;
@property (nonatomic, strong) BaseMapView     *baseMapView; //地图View
@property (nonatomic, strong) TrackingMapView *ykMapView;

@property (nonatomic, strong) UILabel *nearestLabel;        //标题标签
@property (nonatomic, strong) UILabel *distanceLabel;       //距离标签
@property (nonatomic, strong) UILabel *placeLabel;          //位置标签

@property (nonatomic, strong) UILabel *leftReportLabel;
@property (nonatomic, strong) UILabel *rightReportLabel;
@property (nonatomic, strong) UILabel *leftTitleLabel;
@property (nonatomic, strong) UILabel *rightTitleLabel;

@property (nonatomic, strong) UIButton *cameraButton;       //摄像头按钮
@property (nonatomic, strong) UIButton *leftButton;         //底部左视图按钮
@property (nonatomic, strong) UIButton *rightButton;        //底部右视图按钮

@property (nonatomic, strong) UIImageView *leftImageView;
@property (nonatomic, strong) UIImageView *leftBottomImageView;
@property (nonatomic, strong) UIImageView *rightBottomImageView;

@property (nonatomic, strong) NSMutableArray *driveLoaction;
@property (nonatomic, strong) CLLocation *nowLocation;    //目前位置


@end

@implementation ConceptionViewController
@synthesize nowLocation;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0.25f green:0.26f blue:0.38f alpha:1.00f];

    testNum = 0;
    testAdd = YES;
    testModel = NO;
    
    if(GAOTIE)
    {
        speedColors = @[[UIColor colorWithRed:0.24f green:0.85f blue:0.82f alpha:1.00f],
                         [UIColor colorWithRed:0.24f green:0.85f blue:0.82f alpha:1.00f],
                         [UIColor colorWithRed:0.59f green:0.94f blue:0.91f alpha:1.00f],
                         [UIColor colorWithRed:0.59f green:0.94f blue:0.91f alpha:1.00f],
                         [UIColor colorWithRed:0.90f green:0.72f blue:0.85f alpha:1.00f],
                         [UIColor colorWithRed:0.90f green:0.72f blue:0.85f alpha:1.00f],
                         [UIColor colorWithRed:0.91f green:0.58f blue:0.82f alpha:1.00f],
                         [UIColor colorWithRed:0.91f green:0.58f blue:0.82f alpha:1.00f],
                         [UIColor colorWithRed:0.72f green:0.19f blue:0.86f alpha:1.00f],
                         [UIColor colorWithRed:0.72f green:0.19f blue:0.86f alpha:1.00f]];
        
    }
    else
    {
        speedColors = @[[UIColor colorWithRed:0.24f green:0.85f blue:0.82f alpha:1.00f],
                        [UIColor colorWithRed:0.59f green:0.94f blue:0.91f alpha:1.00f],
                        [UIColor colorWithRed:0.90f green:0.72f blue:0.85f alpha:1.00f],
                        [UIColor colorWithRed:0.91f green:0.58f blue:0.82f alpha:1.00f],
                        [UIColor colorWithRed:0.72f green:0.19f blue:0.86f alpha:1.00f]];
    }
    
    localSpeed = 0;
    lastSpeed  = 0;
    savepoint  = 0;
    speedZero  = YES;
    homeLocation  = [[CLLocation alloc] initWithLatitude:41.71521548 longitude:123.41970205];
//    homeLocation  = [[CLLocation alloc] initWithLatitude:39.868271 longitude:116.634228];//张靖乐
//    homeLocation  = [[CLLocation alloc] initWithLatitude:41.764853   longitude:123.4088]; //周妍
    _driveLoaction = [[NSMutableArray alloc] initWithCapacity:0];

    //预加载地图
    _ykMapView = [[TrackingMapView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT + 20, SCREEN_WIDTH, 135)];
    [self.view addSubview:_ykMapView];
    
    //初始化界面
    [self initSubViews];
    
    //初始化位置管理器
    _locManager = [[CLLocationManager alloc]init];
    //设置代理
    _locManager.delegate = self;
    //设置位置经度
    _locManager.desiredAccuracy = kCLLocationAccuracyBest;
    //设置每隔5米更新位置
    _locManager.distanceFilter = DISTANCE_INTERVAL;
    if ([_locManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [_locManager requestWhenInUseAuthorization];
    }
    
    //开始定位服务
    if(!TEST_MODEL)
        [_locManager startUpdatingLocation];
    
    //注册返回应用的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterFor) name:ENTER_FOREGROUND object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if(_ykMapView)
    {
        [[[MapViewSingleton shareInstance] mapView] removeOverlay:_ykMapView.tracking.polyline];
        [[[MapViewSingleton shareInstance] mapView] removeAnnotation:_ykMapView.tracking.startAnnotation];
        [[[MapViewSingleton shareInstance] mapView] removeAnnotation:_ykMapView.tracking.annotation];
        
        [_ykMapView.tracking clear];
        [_ykMapView removeFromSuperview];
        _ykMapView = nil;
    }
}

#pragma mark - Animation & SubViews

- (void)initAutoNavMap
{
    self.baseMapView = [[BaseMapView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT + 20, SCREEN_WIDTH, 20)];
    [self.view addSubview:self.baseMapView];
    
    __block ConceptionViewController *vc = self;
    self.baseMapView.getNowLocation = ^(CLLocation *location)
    {
        [vc.driveLoaction addObject:location];//vc.nowLocation];
        
        //更新缓存的location点
        [ConfigData updateLocationInfoWith:vc.driveLoaction];
        [[ConfigData shareInstance] speedInfo].locationArray = [NSArray arrayWithArray:vc.driveLoaction];
        
    };
}

- (void)initBottomShowView
{
    _bottomShowView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 180 * SCALE)];
    _bottomShowView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.1];
//    [self.view insertSubview:_bottomShowView belowSubview:_left_BottonShowView];
    
    _animation_bottomView = [self createCSAnimationViewWithFrame:CGRectMake(0, SCREEN_HEIGHT - 180 * SCALE, SCREEN_WIDTH, 180 * SCALE) type:@"bounceUp" withView:_bottomShowView duration:2 delay:0.5];
    [self.view insertSubview:_animation_bottomView belowSubview:_animation_leftBottomView];
    [_animation_bottomView startCanvasAnimation];
}

- (void)initLeftShowView
{
    _leftShowView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 80 * SCALE, 180 * SCALE)];
    _leftShowView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.1];
    [_bottomShowView addSubview:_leftShowView];
    
    _leftImageView = [self createImageViewWithFrame:CGRectMake(20 * SCALE, 40 * SCALE, 40 * SCALE, 40 * SCALE) image:[UIImage imageNamed:@"camera_btn.png"]];
    [_leftShowView addSubview:_leftImageView];
    
    _cameraButton = [self createButtonWithFrame:CGRectMake(0, 0, 80 * SCALE, 180 * SCALE) title:@"" target:@selector(openCamera:)];
    [_leftShowView addSubview:_cameraButton];
    
    
    _nearestLabel = [self createLableWithFrame:CGRectMake(105 * SCALE, 20 * SCALE, 200 * SCALE, 10 * SCALE) text:@"LEAVE HOME" fontSize:IS_IPAD ? 15 : 10];
    [_bottomShowView addSubview:_nearestLabel];
    [self performAnimationOnView:_nearestLabel duration:0.4 delay:0.6];
    
    _distanceLabel = [self createLableWithFrame:CGRectMake(CGRectGetMinX(_nearestLabel.frame), CGRectGetMaxY(_nearestLabel.frame) + 8 * SCALE, 200 * SCALE, 25 * SCALE) text:@"220m" fontSize:IS_IPAD ? 34 : 23];
    _distanceLabel.textColor = [UIColor colorWithRed:0.15f green:0.84f blue:0.80f alpha:1.00f];
    _distanceLabel.font = [UIFont boldSystemFontOfSize:IS_IPAD ? 34 : 23];
    [_bottomShowView addSubview:_distanceLabel];
    [self performAnimationOnView:_distanceLabel duration:0.4 delay:0.7];
    
    _placeLabel = [self createLableWithFrame:CGRectMake(CGRectGetMinX(_nearestLabel.frame), CGRectGetMaxY(_distanceLabel.frame) + 5 * SCALE, 200 * SCALE, 30 * SCALE) text:@"Locationing..." fontSize:(IS_IPAD) ? 32 : 21];
    _placeLabel.numberOfLines = 0;
    [_bottomShowView addSubview:_placeLabel];
    [self performAnimationOnView:_placeLabel duration:0.4 delay:0.8];
    
//    NSString *address = @"沈阳市和平区浑南新区金仓路11号";
//    CGSize regon_txtSize = [self getSizeOfString:address fontSize:(IS_IPAD) ? 28.0f : 21.0f constroSize:CGSizeMake(200, MAXFLOAT)];
//    float regon_txtHeight = regon_txtSize.height;
//    _placeLabel.frame = CGRectMake(_placeLabel.frame.origin.x, _placeLabel.frame.origin.y, 200 * SCALE, regon_txtHeight);
//    _placeLabel.text = address;
    
    
    _animation_leftView = [self createCSAnimationViewWithFrame:CGRectMake(0, 0, 80 * SCALE, 180 * SCALE) type:@"bounceRight" withView:_leftShowView duration:ANIMATION_TIME delay:0.5];
    [_bottomShowView addSubview:_animation_leftView];
    [_animation_leftView startCanvasAnimation];
}

- (void)initLeftBottonShowView
{
    _left_BottonShowView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH / 2, 60 * SCALE)];
    _left_BottonShowView.backgroundColor = [UIColor colorWithRed:0.15f green:0.84f blue:0.80f alpha:1.00f];
//    [self.view addSubview:_left_BottonShowView];
    
    _leftBottomImageView = [self createImageViewWithFrame:CGRectMake(10 * SCALE, 8 * SCALE, 40 * SCALE, 40 * SCALE) image:[UIImage imageNamed:@"speed_test_normal.png"]];
    [_left_BottonShowView addSubview:_leftBottomImageView];
    
    _leftReportLabel = [self createLableWithFrame:CGRectMake(CGRectGetMaxX(_leftBottomImageView.frame)  + 10 * SCALE, CGRectGetMinY(_leftBottomImageView.frame) + 4 * SCALE, 100 * SCALE, 10 * SCALE) text:@"REPORT" fontSize:IS_IPAD ? 15 : 9];
    [_left_BottonShowView addSubview:_leftReportLabel];
    
    _leftTitleLabel = [self createLableWithFrame:CGRectMake(CGRectGetMinX(_leftReportLabel.frame), CGRectGetMaxY(_leftReportLabel.frame), 100 * SCALE, 20 * SCALE) text:@"Police" fontSize:IS_IPAD ? 30 : 16];
    [_left_BottonShowView addSubview:_leftTitleLabel];
    
    _leftButton = [self createButtonWithFrame:CGRectMake(0, 0, SCREEN_WIDTH / 2, 60 * SCALE) title:@"" target:@selector(leftButtonClick:)];
    [_left_BottonShowView addSubview:_leftButton];
    
    _animation_leftBottomView = [self createCSAnimationViewWithFrame:CGRectMake(0, SCREEN_HEIGHT - 60 * SCALE, SCREEN_WIDTH / 2, 60 * SCALE) type:@"bounceUp" withView:_left_BottonShowView duration:2.5 delay:0.5];
    [self.view addSubview:_animation_leftBottomView];
    [_animation_leftBottomView startCanvasAnimation];
}

- (void)initRightBottonShowView
{
    _right_BottonShowView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH / 2, 60 * SCALE)];
    _right_BottonShowView.backgroundColor = [UIColor colorWithRed:0.49f green:0.40f blue:1.00f alpha:1.00f];
//    [self.view addSubview:_right_BottonShowView];
    
    _rightBottomImageView = [self createImageViewWithFrame:CGRectMake(10 * SCALE, 8 * SCALE, 40 * SCALE, 40 * SCALE) image:[UIImage imageNamed:@"settings_normal.png"]];
    [_right_BottonShowView addSubview:_rightBottomImageView];
    
    _rightReportLabel = [self createLableWithFrame:CGRectMake(CGRectGetMaxX(_leftBottomImageView.frame)  + 10 * SCALE, CGRectGetMinY(_leftBottomImageView.frame) + 4 * SCALE, 100 * SCALE, 10 * SCALE) text:@"REPORT" fontSize:IS_IPAD ? 15 : 9];
    [_right_BottonShowView addSubview:_rightReportLabel];
    
    _rightTitleLabel = [self createLableWithFrame:CGRectMake(CGRectGetMinX(_leftReportLabel.frame), CGRectGetMaxY(_leftReportLabel.frame), 100 * SCALE, 20 * SCALE) text:@"Incident" fontSize:IS_IPAD ? 30 : 16];
    [_right_BottonShowView addSubview:_rightTitleLabel];
    
    _rightButton = [self createButtonWithFrame:CGRectMake(0, 0, SCREEN_WIDTH / 2, 60 * SCALE) title:@"" target:@selector(rightButtonClick:)];
    [_right_BottonShowView addSubview:_rightButton];
    
    _animation_rightBottomView = [self createCSAnimationViewWithFrame:CGRectMake(SCREEN_WIDTH / 2, SCREEN_HEIGHT - 60 * SCALE, SCREEN_WIDTH / 2, 60 * SCALE) type:@"bounceUp" withView:_right_BottonShowView duration:2.5 delay:0.5];
    [self.view addSubview:_animation_rightBottomView];
    [_animation_rightBottomView startCanvasAnimation];
}

- (void)initSubViews
{
    _circleView = [[UIView alloc] initWithFrame:CGRectMake(0, (IS_IPAD ? 20 : 40) * SCALE, SCREEN_WIDTH, SCREEN_WIDTH)];
    _circleView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_circleView];
    _circleView.hidden = YES;
    
    _unitLabel = [self createLableWithFrame:CGRectMake(0, 85 * SCALE, SCREEN_WIDTH, 30 * SCALE) text:@"KM/H" fontSize:IS_IPAD ? 20 : 13];
    _unitLabel.textAlignment = NSTextAlignmentCenter;
    [_unitLabel setTextColor:[UIColor lightGrayColor]];
    _unitLabel.alpha = 0;
    [_circleView addSubview:_unitLabel];
    
    _speedLabel = [[FBGlowLabel alloc] initWithFrame:CGRectMake(0, 95 * SCALE, SCREEN_WIDTH, 160 * SCALE)];
    _speedLabel.alpha = 0;
    _speedLabel.text = @"0";
    _speedLabel.textAlignment = NSTextAlignmentCenter;
    _speedLabel.font = [UIFont fontWithName:@"Apple SD Gothic Neo" size:IS_IPAD ? 200 : 110];
    _speedLabel.glowSize = 10;
    _speedLabel.innerGlowSize = 4;
    _speedLabel.textColor = UIColor.whiteColor;
    _speedLabel.glowColor = speedColors[0];
    _speedLabel.innerGlowColor = speedColors[0];
    [_circleView addSubview:_speedLabel];
    
    shadowView = [[UIView alloc] initWithFrame:CGRectMake(0, _circleView.frame.size.height - (IS_IPAD ? 135 : 75) * SCALE, SCREEN_WIDTH, (IS_IPAD ? 135 : 75) * SCALE)];
    shadowView.backgroundColor = [UIColor colorWithRed:0.25f green:0.26f blue:0.38f alpha:1.00f];
    [_circleView addSubview:shadowView];
    
    [self performSelector:@selector(blockAnimation:) withObject:@"1" afterDelay:0.4];
    [self performSelector:@selector(blockAnimation:) withObject:@"2" afterDelay:0.6];
    [self performSelector:@selector(blockAnimation:) withObject:@"3" afterDelay:0.9];
    [self performSelector:@selector(blockAnimation:) withObject:@"4" afterDelay:1.6];
    [self performSelector:@selector(blockAnimation:) withObject:@"5" afterDelay:2.5];
    [self performSelector:@selector(blockAnimation:) withObject:@"6" afterDelay:3.6];
    [self performSelector:@selector(blockAnimation:) withObject:@"7" afterDelay:2.3];
    [self performSelector:@selector(blockAnimation:) withObject:@"8" afterDelay:2.3];
}

- (void)blockAnimation:(NSString *)stepStr
{
    int step = [stepStr intValue];
    
    switch (step) {
        case 1:
            [self initLeftBottonShowView];
            
            break;
        case 2:
            [self initRightBottonShowView];
            
            break;
        case 3:
            [self initBottomShowView];
            
            break;
        case 4:
            [self initLeftShowView];
            
            break;
        case 5:
            [self initCircleView];
            
            break;
        case 6:
            [self animateNumberInLabel:_speedLabel toValue:0 duration:1];
            //测试用
//            [circle setNum:78];
            
            [self initAutoNavMap];
            
            break;
        case 7:
        {
            loading = [[GPLoadingView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - (IS_IPAD ? 300 : 280) * SCALE) / 2, (IS_IPAD ? 10 : 20) * SCALE, (IS_IPAD ? 300 : 280) * SCALE, (IS_IPAD ? 300 : 280) * SCALE)];
            [_circleView addSubview:loading];
            [loading startAnimation];
            
            [_circleView bringSubviewToFront:shadowView];
            
            //测试用
            if(TEST_MODEL)
                [NSTimer scheduledTimerWithTimeInterval:0.15 target:self selector:@selector(buttonClick:) userInfo:nil repeats:YES];
        }
            
            break;
        case 8:
        {
            [self initSpeedFlowView];
            
            timer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(updateLocation) userInfo:nil repeats:YES];
        }
            
            break;
            
        default:
            break;
    }
}

- (void)initSpeedFlowView
{
//    speedFlowView = [[SCSiriWaveformView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - shadowView.frame.size.height) / 2, 0, shadowView.frame.size.height, shadowView.frame.size.height)];
    speedFlowView = [[SCSiriWaveformView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, shadowView.frame.size.height)];
//    speedFlowView = [[SCSiriWaveformView alloc] initWithFrame:CGRectMake(70 * SCALE, 140 * SCALE, SCREEN_WIDTH - 140 * SCALE, SCREEN_WIDTH - 140 * SCALE)];
    speedFlowView.translatesAutoresizingMaskIntoConstraints = NO;
    speedFlowView.backgroundColor = [UIColor clearColor];
//    speedFlowView.layer.cornerRadius = speedFlowView.frame.size.height / 2;
//    speedFlowView.layer.borderWidth = 1;
//    speedFlowView.layer.borderColor = [UIColor colorWithRed:0.45f green:0.55f blue:0.80f alpha:1.00f].CGColor;
    [shadowView addSubview:speedFlowView];
    
    [speedFlowView setWaveColor:speedColors[0]];//[UIColor colorWithRed:0.49f green:0.40f blue:1.00f alpha:1.00f]];
    [speedFlowView setPrimaryWaveLineWidth:3.0f];
    [speedFlowView setSecondaryWaveLineWidth:1.0];
    
    
//    circlesInTriangle = [[PQFCirclesInTriangle alloc] initLoaderOnView:shadowView];
//    circlesInTriangle.center = CGPointMake((SCREEN_WIDTH - shadowView.frame.size.height) / 3 * 2, speedFlowView.center.y);
//    circlesInTriangle.backgroundColor = [UIColor clearColor];
//    circlesInTriangle.label.text = @"";
//    
//    [circlesInTriangle show];
    
    //测试用
    [[NSRunLoop currentRunLoop] addTimer:[NSTimer scheduledTimerWithTimeInterval:0.03 target:self selector:@selector(updateSpeedLine) userInfo:nil repeats:YES] forMode:NSRunLoopCommonModes];
}

#pragma mark - Button Action

- (void)buttonClick:(id)sender
{
//    int num = arc4random() % 153;  //51 * 3
//    testNum = num;
    
    if(testNum > MAX_SPEED)
        testAdd = NO;
    
    if(testNum <= 0)
        testAdd = YES;

    
    if(testAdd == YES)
        testNum ++;
    else
        testNum --;
    
    [circle setNum:testNum];
    
    [self animateNumberInLabel:_speedLabel toValue:testNum duration:0.5];
    
    self.speedLabel.glowColor = speedColors[testNum/TEST_VALUE];
    self.speedLabel.innerGlowColor = speedColors[testNum/TEST_VALUE];
    
    [speedFlowView setWaveColor:speedColors[testNum/TEST_VALUE]];
}

- (void)upGuest
{
    testModel = YES;
    testNum = 0;
    
    [_locManager stopUpdatingLocation];
    
    //测试用
    testTimer = [NSTimer scheduledTimerWithTimeInterval:0.15 target:self selector:@selector(buttonClick:) userInfo:nil repeats:YES];
}

- (void)downGuest
{
    testModel = NO;
    testNum = 0;
    
    [_locManager startUpdatingLocation];
    
    if(testTimer)
    {
        [testTimer invalidate];
        testTimer = nil;
    }
}

- (void)leftButtonClick:(id)sender
{
    DriveDetailViewController *ddvc = [[DriveDetailViewController alloc] init];
    [self presentViewController:ddvc animated:YES completion:^{

    }];
    
//    PoliceViewController *pVC = [[PoliceViewController alloc] init];
//    [self presentViewController:pVC animated:YES completion:^{
//        
//    }];
}

- (void)rightButtonClick:(id)sender
{    
    [self.baseMapView locAction];
    
//    VideoViewController *vVC = [[VideoViewController alloc] init];
//    [self presentViewController:vVC animated:YES completion:^{
//        
//    }];
}

- (void)openCamera:(id)sender
{
    //TODO:暂时关闭相机
//    return;
    
    //打开相机
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
//        UIImagePickerController *imgPicker = [[UIImagePickerController alloc] init];
//        [imgPicker setDelegate:self];
//        [imgPicker setAllowsEditing:YES];
//        imgPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
//        imgPicker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
//        [self presentViewController:imgPicker animated:YES completion:nil];
        
        [self LocalPhoto];
    }
    else
    {
        [self showAlertView:nil message:@"该设备没有照相机"];
    }
}

//打开本地相册
-(void)LocalPhoto
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    picker.delegate = self;
    //设置选择后的图片可被编辑
    picker.allowsEditing = YES;
    [self presentViewController:picker animated:YES completion:^{
    }];
}

// 当从相册里选择一张照片或者用相机进行拍摄之后，该方法被调用
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera)
    {
        UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    }
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}
- (void)image:(UIImage*)image didFinishSavingWithError:(NSError*)error contextInfo:(void*)contextInfo
{
    UIAlertView *alert;
    
    if (error)
    {
        alert = [[UIAlertView alloc] initWithTitle:@"错误"
                                           message:@"保存失败"
                                          delegate:self cancelButtonTitle:@"确定"
                                 otherButtonTitles:nil];
    }
    else
    {
        alert = [[UIAlertView alloc] initWithTitle:@"成功"
                                           message:@"保存成功"
                                          delegate:self cancelButtonTitle:@"确定"
                                 otherButtonTitles:nil];
    }
//    [alert show];
}

- (void)changeNum
{
    if(testModel)
        return;
    
    //共51格 每格代表3公里 测速上限 51 * 3 = 153
    //共51格 每格代表7公里 测速上限 51 * 7 = 357

    if(localSpeed < 0)
        localSpeed = 0;
    
    int KM_Speed = localSpeed * 3600 / 1000;
    int KM_Last_Speed = lastSpeed * 3600 / 1000;

    self.unitLabel.text = @"KM/H";
    
    [circle setNum:KM_Speed];

    [self animateNumberInLabel:_speedLabel toValue:KM_Speed duration:0.5];

    self.speedLabel.glowColor = speedColors[KM_Speed/TEST_VALUE];
    self.speedLabel.innerGlowColor = speedColors[KM_Speed/TEST_VALUE];
    
//    int speedFlow = KM_Speed / 10;
//    [speedFlowView updateWithLevel:(speedFlow * 10) / 1000];
    
    //如果瞬时加速超过8km/h，播放涡轮加速音乐
    float acceleration = KM_Speed - KM_Last_Speed;
    if(acceleration > 100)
    {
        if(!_soundManager)
        {
            _soundManager = [AFSoundManager sharedManager];
            [_soundManager startPlayingLocalFileWithName:@"boost.mp3" andBlock:^(int percentage, CGFloat elapsedTime, CGFloat timeRemaining, NSError *error, BOOL finished) {
                if(timeRemaining == 0)
                {
                    _soundManager = nil;
                }
            }];
        }
    }
    
    lastSpeed = localSpeed;
}

- (void)resetSpeed
{
    localSpeed = 0;
    [self changeNum];
    
    if(!ddVC && !showDetailTimer)
    {
        ddVC = [[DriveDetailViewController alloc] init];
        [self presentViewController:ddVC animated:YES completion:^{
            showDetailTimer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(resetDetailTimer) userInfo:nil repeats:NO];
        }];
    }
}

- (void)resetDetailTimer
{
    showDetailTimer = nil;
}

/*从后台返回前端*/
- (void)enterFor
{
    [loading startAnimation];
    
    [_circleView bringSubviewToFront:shadowView];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(updateLocation) userInfo:nil repeats:YES];
    showDetailTimer = [NSTimer scheduledTimerWithTimeInterval:20 target:self selector:@selector(resetDetailTimer) userInfo:nil repeats:NO];
}

- (void)updateSpeedLine
{
    //限制波形大小
    float speed = [_speedLabel.text floatValue] > 100 ? 100 : [_speedLabel.text floatValue];
    
    float num = ([_speedLabel.text floatValue] == 0 ? 5 : speed) / 100;
    [speedFlowView updateWithLevel:num];
}

- (void)updateLocation
{
    CLGeocoder *clGeoCoder = [[CLGeocoder alloc] init];
    CLGeocodeCompletionHandler handle = ^(NSArray *placemarks,NSError *error)
    {
        for (CLPlacemark * placeMark in placemarks)
        {
            NSDictionary *addressDic=placeMark.addressDictionary;
            
            //            NSString *state=[addressDic getStringValueForKey:@"State" defaultValue:@"北京"];   //省
            NSString *city =[addressDic getStringValueForKey:@"City" defaultValue:@""];         //市
            NSString *subLocality=[addressDic objectForKey:@"SubLocality"];                     //区
            NSString *street=[addressDic objectForKey:@"Street"];                               //街
            
            NSString *fullAddress = [NSString stringWithFormat:@"%@%@%@",city,subLocality,street];
            NSString *address = [[fullAddress componentsSeparatedByString:@"(null"] objectAtIndex:0];
            
            CGSize regon_txtSize = [self getSizeOfString:address fontSize:(IS_IPAD) ? 28.0f : 21.0f constroSize:CGSizeMake(200, MAXFLOAT)];
            float regon_txtHeight = regon_txtSize.height;
            _placeLabel.frame = CGRectMake(_placeLabel.frame.origin.x, _placeLabel.frame.origin.y, 200 * SCALE, regon_txtHeight);
            _placeLabel.text = address;
            
            if([[[ConfigData shareInstance] speedInfo].starting isEqualToString:@"Legionarska Bratislava"])
                [[ConfigData shareInstance] speedInfo].starting = address;
            
            [[ConfigData shareInstance] speedInfo].destination = address;
        }
    };
    
    [clGeoCoder reverseGeocodeLocation:nowLocation completionHandler:handle];
}

#pragma mark - CircleView

- (void)initCircleView
{
    ConceptionViewController *vc = self;
    
    //出现环形圆  circle环中共72个刻度，一个刻度代表5，新界面
    self.circleView.hidden = NO;
    
    circle = [[CDCircle alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - 320 * SCALE) / 2, 0, 320 * SCALE, 320 * SCALE) numberOfSegments:72 ringWidth:90.f];
    circle.dataSource = self;
    circle.delegate = self;
    
    circle.circleColor = [UIColor clearColor];
    [_circleView addSubview:circle];
    circle.animationComplete = ^()
    {
        [UIView animateWithDuration:0.3 animations:^{
            //最后文本出现
            vc.speedLabel.alpha = 1;
            vc.unitLabel.alpha  = 1;
        }];
    };
    
    [YYAnimation popAnimation:self.circleView];
}

#pragma mark - Circle delegate & data source

- (void)circle:(CDCircle *)circle didMoveToSegment:(NSInteger)segment thumb:(CDCircleThumb *)thumb {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"User did select item" message:[NSString stringWithFormat:@"Segment's tag: %li", (long)segment] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
}

- (UIImage *)circle:(CDCircle *)circle iconForThumbAtRow:(NSInteger)row {
    
    return [UIImage imageNamed:@"pic_scale.png"];
}

#pragma mark - CLLocationManagerDelegate

//协议中的方法，作用是每当位置发生更新时会调用的委托方法
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    //结构体，存储位置坐标
    CLLocationCoordinate2D loc = [newLocation coordinate];
    float longitude = loc.longitude;
    float latitude = loc.latitude;
    self.lonLabel.text = [NSString stringWithFormat:@"%f",longitude];
    self.latLabel.text = [NSString stringWithFormat:@"%f",latitude];
    [self changeNum];
}

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations
{
    if(stopTimer)
    {
        [stopTimer invalidate];
        stopTimer = nil;
    }
    
    stopTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(resetSpeed) userInfo:nil repeats:NO];
    
    //记录开始位置
    if(!startLocation || startLocation.coordinate.longitude == 0 || startLocation.coordinate.latitude == 0)
    {
        startLocation = [locations lastObject];
    }
    
    //得到newLocation
    CLLocation *loc = [locations objectAtIndex:0];
    //判断是不是属于国内范围
//    if (![WGS84_TO_GCJ02 isLocationOutOfChina:[loc coordinate]]) {
//        //转换后的coord
//        CLLocationCoordinate2D coord = [WGS84_TO_GCJ02 transformFromWGSToGCJ:[loc coordinate]];
//        
//        //记录当前位置
//        nowLocation = [[CLLocation alloc] initWithLatitude:coord.latitude longitude:coord.longitude];
//    }
//    else
//    {
        //记录当前位置
        nowLocation = [locations lastObject];
//    }
    
    //读取当前行驶速度
    localSpeed = loc.speed;
    speedZero = (localSpeed > 0) ? NO : YES;
    [self changeNum];
    
    if(localSpeed != 0 && ddVC && !ddVC.allowExist)
    {
        [ddVC dismissViewControllerAnimated:YES completion:^{
            ddVC = nil;
        }];
    }
    
    //获取离家距离
    CLLocation *location = [[CLLocation alloc] initWithLatitude:nowLocation.coordinate.latitude longitude:nowLocation.coordinate.longitude];
    [self updateDistanceWithLocation:location];
    
    
    [self updateSpeedInfo];
    [self updateLocationInfo];
}

//当位置获取或更新失败会调用的方法
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSString *errorMsg = nil;
    if ([error code] == kCLErrorDenied) {
        errorMsg = @"访问被拒绝";
    }
    if ([error code] == kCLErrorLocationUnknown) {
        errorMsg = @"获取位置信息失败";
    }
    
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Location"
                                                      message:errorMsg delegate:self cancelButtonTitle:@"Ok"otherButtonTitles:nil, nil];
    [alertView show];
}

#pragma mark - Voice

- (void)playSpeedVoice
{
    int speed = [self.speedLabel.text intValue];
    
    int hundred = speed / 100;        //百位
    int decade  = speed % 100 / 10;   //十位
    int unit    = speed % 10;         //个位
    
    NSString *hundredVoiceName = [NSString stringWithFormat:@"caged_num_%d.caf",hundred * 100];
    NSString *decadeVoiceName  = [NSString stringWithFormat:@"caged_num_%d.caf",decade * 10];
    NSString *unitVoiceName    = [NSString stringWithFormat:@"caged_num_%d.caf",unit];
    
    if(speed < 10)
    {
        //0~10
        [self playUnitVoiceName:unitVoiceName];
    }
    else if(speed > 9 && speed < 20)
    {
        //11~20
        [self playUnitVoiceName:[NSString stringWithFormat:@"caged_num_%@.caf",self.speedLabel.text]];
    }
    else if(speed < 100)
    {
        //20~99
        [self playDecadeVoiceName:decadeVoiceName];
        
        [self performSelector:@selector(playUnitVoiceName:) withObject:unitVoiceName afterDelay:0.6];
    }
    else
    {
        //100~
        
        [self playHundredVoiceName:hundredVoiceName];
        
        [self performSelector:@selector(playDecadeVoiceName:) withObject:decadeVoiceName afterDelay:0.8];
        
        [self performSelector:@selector(playUnitVoiceName:) withObject:unitVoiceName afterDelay:1.5];
    }
}

- (void)playHundredVoiceName:(NSString *)voiceName
{
    //百
    [[AFSoundManager sharedManager]startPlayingLocalFileWithName:voiceName andBlock:^(int percentage, CGFloat elapsedTime, CGFloat timeRemaining, NSError *error, BOOL finished) {
        
    }];
}

- (void)playDecadeVoiceName:(NSString *)voiceName
{
    //十
    [[AFSoundManager sharedManager]startPlayingLocalFileWithName:voiceName andBlock:^(int percentage, CGFloat elapsedTime, CGFloat timeRemaining, NSError *error, BOOL finished) {
        
    }];
}

- (void)playUnitVoiceName:(NSString *)voiceName
{
    //个
    [[AFSoundManager sharedManager]startPlayingLocalFileWithName:voiceName andBlock:^(int percentage, CGFloat elapsedTime, CGFloat timeRemaining, NSError *error, BOOL finished) {
        
    }];
}

#pragma mark - Map Tool

//更新当前位置离家距离
- (void)updateDistanceWithLocation:(CLLocation*)newLocation
{
    CLLocationDistance meters =[newLocation distanceFromLocation:homeLocation];
    
    NSString *unit      = (meters > 1000) ? @"公里" : @"米";
    float distaceValue  = (meters > 1000) ? (meters/1000) : meters;
    _distanceLabel.text = (meters > 1000) ? [NSString stringWithFormat:@"%.1f%@", distaceValue, unit] : [NSString stringWithFormat:@"%d%@", (int)meters, unit];
}

//更新当前速度信息
- (void)updateSpeedInfo
{
    //当前时速
    int KM_Speed = localSpeed * 3600 / 1000;
    
    //更新行驶距离
    if(localSpeed != 0)
    {
        CLLocationDistance meters = [nowLocation distanceFromLocation:midLocation ? midLocation : startLocation];
        
        //更新中间位置点
        midLocation = nowLocation;
        
        [[ConfigData shareInstance] speedInfo].distance += (meters >= 0) ? meters : 0;
        [[ConfigData shareInstance] setDriveDistance:[[ConfigData shareInstance] speedInfo].distance];
    }
    
    //更新最大时速
    if(KM_Speed > [[ConfigData shareInstance] speedInfo].topSpeed)
        [[ConfigData shareInstance] speedInfo].topSpeed = KM_Speed;
    
    //计算从启动应用到现在的时间差
    NSTimeInterval time_now  = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval time_last = [[NSUserDefaults standardUserDefaults] doubleForKey:SAVED_TIME];
    
    int timeValue = time_now - time_last;
    
    //记录行驶时间（单位：秒）
    [[ConfigData shareInstance] speedInfo].driveTime = timeValue;
    
    //计算平均时速
    float driveDistance = [[ConfigData shareInstance] driveDistance];
    
    float avgSpeed   = (timeValue == 0) ? 0 : driveDistance / timeValue;
    int   avgKMSpeed = avgSpeed * 3600 / 1000;
    
    [[ConfigData shareInstance] speedInfo].avgSpeed = avgKMSpeed;
}

//更新当前位置点缓存
- (void)updateLocationInfo
{
    float distanceAdd = [[ConfigData shareInstance] speedInfo].distance - savepoint;
    
    if(nowLocation && nowLocation.coordinate.longitude != 0 && nowLocation.coordinate.latitude != 0 && distanceAdd > LOCATION_DISTANCE)
    {
        //使用高德地图定位
        [self.baseMapView locAction];
        
//        [_driveLoaction addObject:nowLocation];
//        
//        //更新缓存的location点
//        [ConfigData updateLocationInfoWith:_driveLoaction];
//        [[ConfigData shareInstance] speedInfo].locationArray = [NSArray arrayWithArray:_driveLoaction];
    
        //记录下更新缓存时的行驶距离
        savepoint = [[ConfigData shareInstance] speedInfo].distance;
        
//        [ConfigData showToastWithMessage:[NSString stringWithFormat:@"记录成功 经度：%f 纬度:%f\n记录时距离：%f",nowLocation.coordinate.longitude, nowLocation.coordinate.latitude, savepoint] showTime:TOSATTIME];
    }
    else
    {
//        [ConfigData showToastWithMessage:[NSString stringWithFormat:@"记录时距离：%f 总距离：%f 差：%f", savepoint, [[ConfigData shareInstance] speedInfo].distance, distanceAdd] showTime:TOSATTIME];
    }
}

#pragma mark - View Tool

//创建UILabel
- (UILabel *)createLableWithFrame:(CGRect)frame text:(NSString *)txt fontSize:(int)size
{
    UILabel * label = [[UILabel alloc] initWithFrame:frame];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:size];
    label.textAlignment = NSTextAlignmentLeft;
    label.text = txt;
    return label;
}

//创建UIImageView
- (UIImageView *)createImageViewWithFrame:(CGRect)frame image:(UIImage *)image
{
    UIImageView * imageview = [[UIImageView alloc] initWithFrame:frame];
    imageview.image = image;
    return imageview;
}

//创建UIButton
- (UIButton *)createButtonWithFrame:(CGRect)frame title:(NSString *)title target:(SEL)tar
{
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = frame;
    [btn setTitle:title forState:UIControlStateNormal];
    [btn addTarget:self action:tar forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

//创建动画特效
- (CSAnimationView *)createCSAnimationViewWithFrame:(CGRect)frame type:(NSString *)type withView:(UIView *)view duration:(CGFloat)duration delay:(CGFloat)delay
{
    CSAnimationView * animationView = [[CSAnimationView alloc] initWithFrame:frame];
    animationView.layer.cornerRadius = 0;
    animationView.layer.borderWidth  = 1.0f;
    animationView.layer.borderColor  = [UIColor clearColor].CGColor;
    animationView.backgroundColor = [UIColor clearColor];
    animationView.delay = 0.5;
    animationView.duration = duration;
    animationView.type = type;
    [animationView addSubview:view];
    
    return animationView;
}

- (void)performAnimationOnView:(UIView *)view duration:(NSTimeInterval)duration delay:(NSTimeInterval)delay {
    // Start
    view.alpha = 0;
    view.transform = CGAffineTransformMakeTranslation(0, 100 * SCALE);
    [UIView animateKeyframesWithDuration:duration delay:delay options:0 animations:^{
        // End
        view.alpha = 1;
        view.transform = CGAffineTransformMakeTranslation(0, 0);
    } completion:^(BOOL finished) { }];
}

- (void)showAlertView:(NSString *)title message:(NSString *)msg
{
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:title
                                                         message:msg
                                                        delegate:nil
                                               cancelButtonTitle:@"确定"
                                               otherButtonTitles:nil];
    [alertView show];
}

#pragma mark - NSObject Tool

- (CGSize)getSizeOfString:(NSString *)string fontSize:(int)fontSize constroSize:(CGSize)size
{
    NSDictionary *attribute = @{NSFontAttributeName:[UIFont systemFontOfSize:fontSize]};
    CGSize s = [string boundingRectWithSize:size options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
    return s;
}

#pragma mark - Warning

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
