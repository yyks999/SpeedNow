//
//  YYPOPAnimation.h
//  SpeedNow
//
//  Created by 杨翊楷 on 15/11/30.
//  Copyright © 2015年 YK Yang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YYPOPAnimation : NSObject

+ (void)springAnimation:(UIView *)view;     //弹性动画
+ (void)decayAnimation:(UIView *)view;      //减缓动画
+ (void)basicAnimation:(UIView *)view;      //基本动画
+ (void)groupAnimation:(UIView *)view;      //组合动画

@end
