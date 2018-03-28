//
//  YYAnimation.m
//  HairWasher
//
//  Created by 杨翊楷 on 13-1-15.
//
//

#import "YYAnimation.h"
#import <QuartzCore/QuartzCore.h>

@implementation YYAnimation

+(void)rippleAnimation:(UIView *)view
{
    CATransition *t = [CATransition animation];
    t.type = @"rippleEffect";
    t.duration = 1.0f;
    t.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [view.layer addAnimation:t forKey:@"Transition"];
}

+(void)suckAnimation:(UIView *)view
{
    CATransition *t = [CATransition animation];
    t.type = @"suckEffect";
    t.duration = 0.5f;
    t.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [view.layer addAnimation:t forKey:@"Transition"];
}

+(void)fadeAnimation:(UIView *)view duration:(NSTimeInterval)time
{
    CATransition *t = [CATransition animation];
    t.type = @"fade";
    t.duration = time;
    t.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [view.layer addAnimation:t forKey:@"Transition"];
}

+(void)moveInAnimation:(UIView *)view
{
    CATransition *t = [CATransition animation];
    t.type = @"moveIn";
    t.duration = 0.3f;
    t.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    t.subtype = kCATransitionFromTop;
    [view.layer addAnimation:t forKey:@"Transition"];
//    CATransition *animation = [CATransition animation];
//    animation.delegate = self;
//    animation.duration = 0.3;
//    animation.timingFunction = UIViewAnimationCurveEaseInOut;
//    animation.type = kCATransitionMoveIn;
//    animation.subtype = kCATransitionFromTop;
//    [[view.window layer] addAnimation:animation forKey:@"animation"];
}

+(void)cubeAnimation:(UIView *)view
{
    CATransition *t = [CATransition animation];
    t.type = @"cube";
    t.duration = 0.5f;
    t.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    t.subtype = kCATransitionFromTop;
    [view.layer addAnimation:t forKey:@"Transition"];
}

+(void)flipAnimation:(UIView *)view type:(NSString *)type
{
    CATransition *t = [CATransition animation];
    t.type = @"oglFlip";
    t.duration = 0.6f;
    t.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    t.subtype = type;
    [view.layer addAnimation:t forKey:@"Transition"];
}

+(void)popAnimation:(UIView *)view
{
    CAKeyframeAnimation *animation;
    animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    animation.duration = 0.4;
    animation.removedOnCompletion = YES;
    animation.fillMode = kCAFillModeForwards;
    NSMutableArray *values = [NSMutableArray array];

    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.8, 0.8, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.05, 1.05, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.95, 0.95, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)]];
    animation.values = values;
    [view.layer addAnimation:animation forKey:@"transform"];
}

+(void)popAppearAnimation:(UIView *)view
{
    CAKeyframeAnimation *animation;
    animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    animation.duration = 0.50;
    animation.removedOnCompletion = YES;
    animation.fillMode = kCAFillModeForwards;
    NSMutableArray *values = [NSMutableArray array];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.0, 0.0, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.0, 0.0, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.1, 0.1, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.2, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.9, 0.9, 0.9)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)]];
    animation.values = values;
    [view.layer addAnimation:animation forKey:@"transform"];
}

#pragma mark - POP Animation
/*
+ (void)showPopView:(UIView *)view from:(CGRect)fromFrame to:(CGRect)toFrame
{
    POPSpringAnimation *positionAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewFrame];
    positionAnimation.fromValue = [NSValue valueWithCGRect:fromFrame];
    positionAnimation.toValue = [NSValue valueWithCGRect:toFrame];
    positionAnimation.springBounciness = 5.0f;
    positionAnimation.springSpeed = 20.0f;
    [view pop_addAnimation:positionAnimation forKey:@"frameAnimation"];
}

+ (void)hidePopView:(UIView *)view from:(CGRect)fromFrame to:(CGRect)toFrame
{
    
    POPBasicAnimation *positionAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPViewFrame];
    positionAnimation.fromValue = [NSValue valueWithCGRect:fromFrame];
    positionAnimation.toValue = [NSValue valueWithCGRect:toFrame];
    
    //key一样就会用后面的动画覆盖之前的
    [view pop_addAnimation:positionAnimation forKey:@"frameAnimation"];
}
 */

@end
