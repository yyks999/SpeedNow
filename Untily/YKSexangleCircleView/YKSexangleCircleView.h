//
//  YKSexangleCircleView.h
//  iLiaoNing
//
//  Created by 杨翊楷 on 15/1/20.
//  Copyright (c) 2015年 杨翊楷. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YKButton;

@interface YKSexangleCircleView : UIView

@property (nonatomic, copy) void (^buttonClick)(YKButton *button, NSInteger index);

@property (nonatomic, strong) YKButton *centerButton;

@property (nonatomic, assign) BOOL isAnimating;


-(void)showWithContents:(NSArray *)contents;
-(void)hide;
-(void)setCenterTitle:(NSString *)title;

@end
