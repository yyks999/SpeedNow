//
//  NSObject+FYXAnimation.m
//  WangliBank
//
//  Created by Yixiong on 14-5-12.
//  Copyright (c) 2014年 iSoftstone infomation Technology (Group) Co.,Ltd. All rights reserved.
//

#import "NSObject+FYXAnimation.h"
#import "Pop.h"

@implementation NSObject (FYXAnimation)
- (void)animateNumberInLabel:(UILabel *)label
                    duration:(NSTimeInterval)duration{
    
    POPBasicAnimation *animation = [POPBasicAnimation animation];
    animation.property = [self animationProperty];
    animation.fromValue = @(0);
    int toValue = [label.text intValue];
    animation.toValue  = @(toValue);
    animation.duration = duration;
    
    //增加animation 时间函数控制
    //标准的淡入淡出效果
    //    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    //自定义的效果，一开始速度很快，最后慢慢增加，欲罢不能的感觉..＝。＝
    animation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.12 :1.0 :0.11 :0.94];
    [label pop_addAnimation:animation forKey:@"numberLabelAnimation"];
}

- (POPMutableAnimatableProperty *)animationProperty {
    return [POPMutableAnimatableProperty
            propertyWithName:@"com.wanglibao.mainPage"
            initializer:^(POPMutableAnimatableProperty *prop) {
                prop.writeBlock = ^(id obj, const CGFloat values[]) {
                    UILabel *label = (UILabel *)obj;
                    NSNumber *number = @(values[0]);
                    int num = [number intValue];
                    label.text = [@(num) stringValue];
                };
            }];
}

- (void)animateNumberInLabel:(UILabel *)label
                     toValue:(CGFloat)toValue
                    duration:(NSTimeInterval)duration{
    
    POPBasicAnimation *animation = [POPBasicAnimation animation];
    animation.property = [self animationProperty];
    animation.fromValue = @([label.text intValue]);
    animation.toValue  = @(toValue);
    animation.duration = duration;
    
    //增加animation 时间函数控制
    //标准的淡入淡出效果
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    //自定义的效果，一开始速度很快，最后慢慢增加，欲罢不能的感觉..＝。＝
    animation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.12 :1.0 :0.11 :0.94];
    [label pop_addAnimation:animation forKey:@"numberLabelAnimation"];
}



@end
