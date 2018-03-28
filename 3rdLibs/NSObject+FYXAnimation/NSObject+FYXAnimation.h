//
//  NSObject+FYXAnimation.h
//  WangliBank
//
//  Created by Yixiong on 14-5-12.
//  Copyright (c) 2014年 iSoftstone infomation Technology (Group) Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (FYXAnimation)
- (void)animateNumberInLabel:(UILabel *)label
                    duration:(NSTimeInterval)duration;
- (void)animateNumberInLabel:(UILabel *)label
                     toValue:(CGFloat)toValue
                    duration:(NSTimeInterval)duration;
@end
