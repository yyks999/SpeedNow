//
//  YYPOPAnimation.m
//  SpeedNow
//
//  Created by 杨翊楷 on 15/11/30.
//  Copyright © 2015年 YK Yang. All rights reserved.
//

#import "YYPOPAnimation.h"
#import "POP.h"

@implementation YYPOPAnimation

//弹性动画
+ (void)springAnimation:(UIView *)view
{
    POPSpringAnimation* framePOP = [POPSpringAnimation animationWithPropertyNamed:kPOPViewBackgroundColor];
    framePOP.springSpeed = 10.f;
    framePOP.springBounciness = 4.f;
    framePOP.toValue =  [UIColor yellowColor];
    [framePOP setCompletionBlock:^(POPAnimation * anim , BOOL finsih) {
        if (finsih) {
//            NSLog(@"view.frame = %@",NSStringFromCGRect(view.frame));
        }
    }];
    [view pop_addAnimation:framePOP forKey:@"go"];
}

//减缓动画
+ (void)decayAnimation:(UIView *)view
{
    POPDecayAnimation* decay = [POPDecayAnimation animationWithPropertyNamed:kPOPViewFrame];
    //    decay.toValue = [NSValue valueWithCGRect:CGRectMake(200, 400, 100, 100)];
    decay.velocity = [NSValue valueWithCGRect:CGRectMake(200, 300, 100, 100)];
    [view pop_addAnimation:decay forKey:@"go"];
    
}


//基本动画
+ (void)basicAnimation:(UIView *)view
{
    POPBasicAnimation* basicAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerCornerRadius];
    basicAnimation.toValue = [NSNumber numberWithFloat:CGRectGetHeight(view.frame)/2.];
    basicAnimation.timingFunction =[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    basicAnimation.duration = 1.f;
    [basicAnimation setCompletionBlock:^(POPAnimation * ani, BOOL finish) {
        if (finish) {
//            NSLog(@"view.frame = %@",NSStringFromCGRect(view.frame));
            POPBasicAnimation* newBasic = [POPBasicAnimation easeInEaseOutAnimation];
            newBasic.property = [POPAnimatableProperty propertyWithName:kPOPLayerCornerRadius];
            newBasic.toValue = [NSNumber numberWithFloat:0];
            [view.layer pop_addAnimation:newBasic forKey:@"go"];
        }
    }];
    [view.layer pop_addAnimation:basicAnimation forKey:@"frameChange"];
}

//组合动画
+ (void)groupAnimation:(UIView *)view
{
    view.transform = CGAffineTransformMakeRotation(M_PI_2/3);
    
    
    POPBasicAnimation* spring = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerPositionY];
    spring.beginTime = CACurrentMediaTime();
    spring.duration = .4f;
    spring.fromValue = [NSNumber numberWithFloat:-100.f];
    spring.toValue = [NSNumber numberWithFloat:CGRectGetMinY(view.frame) + 80];
    [spring setCompletionBlock:^(POPAnimation * ani, BOOL finish) {
    }];
    
    
    POPBasicAnimation* basic = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerRotation];
    basic.beginTime = CACurrentMediaTime();
    basic.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    basic.toValue = [NSNumber numberWithFloat:-M_PI_4];
    basic.duration = .4f;
    
    
    POPBasicAnimation* rotation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerRotation];
    rotation.beginTime = CACurrentMediaTime() + .4f;
    rotation.toValue = [NSNumber numberWithFloat:0.f];
    rotation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    rotation.duration = .25f;
    
    
    POPBasicAnimation* donw = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerPositionY];
    donw.beginTime = CACurrentMediaTime() + 0.4f;
    donw.toValue = [NSNumber numberWithFloat:CGRectGetMinY(view.frame)];
    donw.duration = .25f;
    donw.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    
    
    [view.layer pop_addAnimation:spring forKey:@"spring"];
    [view.layer pop_addAnimation:basic forKey:@"basic"];
    [view.layer pop_addAnimation:donw forKey:@"down"];
    [view.layer pop_addAnimation:rotation forKey:@"rotation"];
}

@end
