//
//  GlobalConfig.h
//  Forum
//
//  Created by 杨翊楷 on 12-8-20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//
#import "AppDelegate.h"

#ifndef GLOBAL_CONFIG
#define GLOBAL_CONFIG


/***************************** Head File ****************************/

#import <SystemConfiguration/CaptiveNetwork.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import "NSDictionaryAdditions.h"
#import "CSAnimationView.h"
#import "FBGlowLabel.h"
#import "GPLoadingView.h"
#import "SCSiriWaveformView.h"
#import "YYPOPAnimation.h"
#import "YYAnimation.h"
#import <MAMapKit/MAMapKit.h>
#import "MapViewSingleton.h"
#import "PulsingHaloLayer.h"
#import "Tracking.h"
#import "UserInfoModel.h"
#import "Reachability.h"
#import "JSON.h"
#import "UIImage+category.h"
#import "TipLabel.h"
#import "WCAlertView.h"
#import "NSString+HMString.h"
#import "UserInfoModel.h"
#import "ConfigData.h"
#import "NSString+category.h"
#import "BaseMapView.h"
#import "WGS84_TO_GCJ02.h"

/***************************** Mode ****************************/

#define USEING_NETWORK YES      //控制开启网络接口调用


#if DEBUG                       //控制是否输出Log信息
//#define NSLog(...) NSLog(__VA_ARGS__)
#define NSLog(s,...) NSLog(@"%s LINE:%d < %@ >",__FUNCTION__, __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__])
#else
#define NSLog(...) {}
#endif

#define IS_ILIAONING ([[ConfigData getDeviceSSID] isEqualToString:@"i-LiaoNing"] || [[ConfigData getDeviceSSID] isEqualToString:@"CMCC"] || [[ConfigData getDeviceSSID] isEqualToString:@"i-LiaoNing-Free"])    //校验SSID

#define IS_WIFI      ([[ConfigData shareInstance] netStatus] == ReachableViaWWAN)


/***************************** The Key ****************************/

#define ENTER_FOREGROUND  @"enterforeground"                    //应用从后台返回前端

#define USER_INFO         @"userinfo"                           //存储用户信息
#define HTML_XML          @"htmlxml"                            //用于下线的信息标识
#define SAVED_TIME        @"savedtime"                          //记录启动应用时的时间
#define SAVED_LOCATION   @"savelocation"                       //记录下经过的地点


#define GAOTIE            NO

/***************************** 接口定义参数 ****************************/

#define MAX_SPEED           151     //定义最大速度
#define NETWORKTIMEOUT      30      //网络接口请求超时时间30秒
#define WEBVIEW_TIMEOUT     40      //webView请求超时时间40秒
#define TOSATTIME           2       //toast显示时间
#define ANIMATION_TIME      2       //动画持续时间
#define NETWORK_TIMEOUT     5       //大于5秒判定网络超时
#define DEFAULT_MAP_ZOOMIN  15      //默认地图缩放级别
#define REFRESH_POI_REGON   5000    //根据算法小于此值不刷新POI
#define TEST_SHORT_TIMEOUT  3       //网络连通性测试间隔(短)
#define TEST_LONG_TIMEOUT   5       //网络连通性测试间隔(长)
#define UI_TAB_BAR_HEIGHT	57.0f   //底部Bar的高度

//用于适配iPad分辨率，用scale将视图等比放大
#define SCALE (([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) ? (768 / 320) : 1)

//底部Bar中间圆形按钮大小
#define CENTER_BUTTON_SIZE  (([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) ? 38 : 50)

//底部Bar中间圆形按钮layer大小
#define CENTER_LAYER_SIZE (([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) ? 44 : 56)

//底部Bar中间按钮拱形背景位置
#define CENTER_BUTTON_BG_POSITION (([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) ? (-13) : (-11))

//底部Bar中间圆形按钮距离屏幕最下方距离
#define CUSTOM_TABBAR_UP_POSITION (([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) ? 39 : 41)

//返回按钮图片调整
#define BACK_BUTTON_EDGEINSERT    UIEdgeInsetsMake(2.5, 12.5, 7.5, 17.5)



/***************************** Frame ****************************/

#define IS_IPAD ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)   //[ConfigData checkDevice:@"iPad"]

#define IS_IPHONE4 ([[UIScreen mainScreen] bounds].size.height == 480)

#define SCREEN_WIDTH  (([[[UIDevice currentDevice] systemVersion] floatValue] >= 8) ? (([[UIScreen mainScreen] nativeBounds].size.width)/[UIScreen mainScreen].nativeScale) : ([[UIScreen mainScreen] bounds].size.width))

#define SCREEN_HEIGHT (([[[UIDevice currentDevice] systemVersion] floatValue] >= 8) ? ((([[UIScreen mainScreen] nativeBounds].size.height)/[UIScreen mainScreen].nativeScale)) : ([[UIScreen mainScreen] bounds].size.height))

#define APP_DELEGATE ((AppDelegate *)[[UIApplication sharedApplication] delegate])

#define DOCUMENT_DIRECTORY_PATH [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]

#define BUNDLE_IDENTIFIER [[NSBundle mainBundle] bundleIdentifier]

#define DB_PATH [DOCUMENT_DIRECTORY_PATH stringByAppendingPathComponent:@"JiuHaoDatabase.db"]

#define SCREEN_SHOT_IMG_PATH [DOCUMENT_DIRECTORY_PATH stringByAppendingPathComponent:@"screenshot.img"]

#define IS_4_INCH_SCREEN  (([[UIScreen mainScreen] bounds].size.height == 568) ? YES : NO)

#define IS_4_BIGGER_INCH_SCREEN (([[UIScreen mainScreen] bounds].size.height > 568) ? YES : NO)

#define IS_IOS_7 (([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) ? YES : NO)

#define PIXEL_20 (([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) ? 0 : 20)

#define LOGIN_VIEW_PIXEL (([[UIScreen mainScreen] bounds].size.height == 568) ? 40 : 0)

#define BUNDLE_FILE_PATH(filename)  [[NSBundle mainBundle] pathForAuxiliaryExecutable:filename]

#define NAV_BAR_HEIGHT (([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) ? 65 : 45)



/***************************** Color ****************************/

#define MYBLUECOLOR         [UIColor colorWithRed:0.27f green:0.68f blue:1.00f alpha:1.00f]
#define MYBLUECOLOR_NEW     [UIColor colorWithRed:0.40f green:0.73f blue:0.99f alpha:1.00f]
#define MYBGCOLOR           [UIColor colorWithRed:0.96f green:0.96f blue:0.96f alpha:1.00f]
#define MYGRAYCOLOR         [UIColor colorWithRed:0.44f green:0.44f blue:0.44f alpha:1.00f]
#define MYLIGHTGRAYCOLOR    [UIColor colorWithRed:0.88f green:0.88f blue:0.88f alpha:1.00f]
#define MYGREENCOLOR        [UIColor colorWithRed:0.45f green:0.90f blue:0.29f alpha:1.00f]
#define MYDARKGREENCOLOR    [UIColor colorWithRed:0.01f green:0.85f blue:0.01f alpha:1.00f]
#define MYLIGHTGREENCOLOR   [UIColor colorWithRed:0.51f green:0.91f blue:0.33f alpha:1.00f]
#define MYORANGECOLOR       [UIColor colorWithRed:0.96f green:0.53f blue:0.02f alpha:1.00f]
#define MYYELLOWCOLOR       [UIColor colorWithRed:1.00f green:0.83f blue:0.58f alpha:1.00f]
#define MYDARKYELLOWCOLOR   [UIColor colorWithRed:1.00f green:0.59f blue:0.16f alpha:1.00f]
#define MYLIGHTYELLOWCOLOR  [UIColor colorWithRed:1.00f green:0.93f blue:0.36f alpha:1.00f]

#define MYTHINGRAYCOLOR     [UIColor colorWithRed:0.88f green:0.88f blue:0.88f alpha:0.50f]
#define MYTHINYELLOWCOLOR   [UIColor colorWithRed:1.00f green:0.93f blue:0.36f alpha:0.50f]
#define MYTHINGREENCOLOR    [UIColor colorWithRed:0.51f green:0.91f blue:0.33f alpha:0.50f]
#define MYTHINBLURCOLOR     [UIColor colorWithRed:0.53f green:0.79f blue:0.99f alpha:1.00f]


#define COLOR_RGB(r,g,b)    [UIColor colorWithRed:(r/255.0f) green:(g/255.0f) blue:(b/255.0f) alpha:1]
#define COLOR_RGBA(r,g,b,a) [UIColor colorWithRed:(r/255.0f) green:(g/255.0f) blue:(b/255.0f) alpha:a]


#endif

