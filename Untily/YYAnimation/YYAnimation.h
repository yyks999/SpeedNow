//
//  YYAnimation.h
//  HairWasher
//
//  Created by 杨翊楷 on 13-1-15.
//
//

#import <Foundation/Foundation.h>

@interface YYAnimation : NSObject

+(void)rippleAnimation:(UIView *)view;
+(void)suckAnimation:(UIView *)view;
+(void)fadeAnimation:(UIView *)view duration:(NSTimeInterval)time;
+(void)cubeAnimation:(UIView *)view;
+(void)moveInAnimation:(UIView *)view;
+(void)popAnimation:(UIView *)view;
+(void)popAppearAnimation:(UIView *)view;
+(void)flipAnimation:(UIView *)view type:(NSString *)type;
/*
+ (void)showPopView:(UIView *)view from:(CGRect)fromFrame to:(CGRect)toFrame;
+ (void)hidePopView:(UIView *)view from:(CGRect)fromFrame to:(CGRect)toFrame;
*/
@end
