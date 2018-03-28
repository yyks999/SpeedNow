//
//  BaseMapViewController.h
//  iLiaoNing
//
//  Created by 杨翊楷 on 14-8-18.
//  Copyright (c) 2014年 杨翊楷. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchAPI.h>
#import <AMapLocationKit/AMapLocationKit.h>

@interface BaseMapView : UIView <MAMapViewDelegate, AMapSearchDelegate>

@property (nonatomic, copy)   void (^getNowLocation)(CLLocation *location);
@property (nonatomic, strong) MAMapView      *mapView;          //高德mapView
@property (nonatomic, strong) MAUserLocation *myLocation;       //当前位置信息
@property (nonatomic, strong) AMapRoute      *route;            //路线方案

@property (nonatomic, strong) UIButton *biggerButton;           //放大按钮
@property (nonatomic, strong) UIButton *smallerButton;          //缩小按钮
@property (nonatomic, strong) UIButton *localButton;            //显示当前位置按钮

@property (nonatomic, strong) NSMutableArray *annotations;      //POI点集合数组
@property (nonatomic, strong) NSMutableArray *eventDataArray;   //POI点数据模型数组

@property (nonatomic, assign) BOOL didUpdateLocation;           //是否已定位成功
@property (nonatomic, assign) BOOL selectedAnn;                 //当前是否选中了某个POI点

- (void)locAction;
- (void)returnAction;
- (id)initWithFrame:(CGRect)frame;
- (void)showTraffic:(id)sender;

@end
