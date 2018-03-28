//
//  ViewController.h
//  CircleTest
//
//  Created by 杨翊楷 on 14-10-20.
//  Copyright (c) 2014年 杨翊楷. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "CDCircle.h"

@interface ConceptionViewController : UIViewController <CDCircleDelegate, CDCircleDataSource, CLLocationManagerDelegate>

@property (retain, nonatomic) UILabel *lonLabel;
@property (retain, nonatomic) UILabel *latLabel;
@property (retain, nonatomic) CLLocationManager *locManager;


@property (nonatomic, strong) FBGlowLabel *speedLabel;
@property (nonatomic, strong) UILabel *unitLabel;
@property (nonatomic, strong) UIView  *circleView;

@property (nonatomic, strong) UIView  *leftShowView;
@property (nonatomic, strong) UIView  *bottomShowView;
@property (nonatomic, strong) UIView  *left_BottonShowView;
@property (nonatomic, strong) UIView  *right_BottonShowView;

-(IBAction)buttonClick:(id)sender;

@end
