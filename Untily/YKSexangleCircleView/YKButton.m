//
//  YKButton.m
//  iLiaoNing
//
//  Created by 杨翊楷 on 15/1/19.
//  Copyright (c) 2015年 杨翊楷. All rights reserved.
//

#import "YKButton.h"

@implementation YKButton

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)drawRect:(CGRect)rect
{
    //六边形坐标绘制算法
    //      .(1)
    //  .(6)    .(2)
    //
    //  .(5)    .(3)
    //      .(4)
    
    float wid = rect.size.width;
    float twoAndThree_X  = wid - 0.067 * wid;     //第2点和3点的x坐标
    float fiveAndSix_X   = 0.067 * wid;           //第5点和6点的x坐标
    float twoAndSix_Y    = (wid / 2 - 0.067 * wid) * 0.57;     //第2点和6点的y坐标
    float threeAndFive_Y = (wid / 2 - 0.067 * wid) * 0.57 + (wid / 2 - 0.067 * wid) * 0.57 * 2;     //第3点和5点的y坐标
    
    UIBezierPath* polygonPath = UIBezierPath.bezierPath;
    [polygonPath moveToPoint: CGPointMake(wid / 2, 0)];                       //1
    [polygonPath addLineToPoint: CGPointMake(twoAndThree_X, twoAndSix_Y)];    //2
    [polygonPath addLineToPoint: CGPointMake(twoAndThree_X, threeAndFive_Y)]; //3
    [polygonPath addLineToPoint: CGPointMake(wid / 2, wid)];                  //4
    [polygonPath addLineToPoint: CGPointMake(fiveAndSix_X, threeAndFive_Y)];  //5
    [polygonPath addLineToPoint: CGPointMake(fiveAndSix_X, twoAndSix_Y)];     //6
    [polygonPath closePath];
    [self.tintColor setFill];
    [polygonPath fill];
    
    /*
    UIBezierPath* polygonPath = UIBezierPath.bezierPath;
    [polygonPath moveToPoint: CGPointMake(25, 0)];
    [polygonPath addLineToPoint: CGPointMake(46.65, 12.5)];
    [polygonPath addLineToPoint: CGPointMake(46.65, 37.5)];
    [polygonPath addLineToPoint: CGPointMake(25, 50)];
    [polygonPath addLineToPoint: CGPointMake(3.35, 37.5)];
    [polygonPath addLineToPoint: CGPointMake(3.35, 12.5)];
    [polygonPath closePath];
    [UIColor.redColor setFill];
    [polygonPath fill];
     */
}

@end
