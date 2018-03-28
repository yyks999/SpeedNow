/*
 Copyright (C) <2012> <Wojciech Czelalski/CzekalskiDev>
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
#define degreesToRadians(x) (M_PI * (x) / 180.0)
#define kRotationDegrees 90
#import "CDCircle.h"
#import <QuartzCore/QuartzCore.h>
#import "CDCircleGestureRecognizer.h"
#import "CDCircleThumb.h"
#import "CDCircleOverlayView.h"

@interface CDCircle()
{
    int lastSpeed;
    int speedDisparity;
}

@end

@implementation CDCircle
@synthesize circle, recognizer, path, numberOfSegments, separatorStyle, overlayView, separatorColor, ringWidth, circleColor, thumbs, overlay;
@synthesize delegate, dataSource;
@synthesize inertiaeffect;
//Need to add property "NSInteger numberOfThumbs" and add this property to initializer definition, and property "CGFloat ringWidth equal to circle radius - path radius.

//Circle radius is equal to rect / 2 , path radius is equal to rect1/2.

-(id) initWithFrame:(CGRect)frame numberOfSegments: (NSInteger) nSegments ringWidth:(CGFloat)width {
    self = [super initWithFrame:frame];
    
    if (self) {
        lastSpeed = 0;
        speedDisparity = 0;
        self.inertiaeffect = YES;
        //        self.recognizer = [[CDCircleGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
        //        [self addGestureRecognizer:self.recognizer];
        self.opaque = NO;
        isInit = NO;
        self.numberOfSegments = nSegments;
        self.separatorStyle = CDCircleThumbsSeparatorBasic;
        self.ringWidth = width;
        self.circleColor = [UIColor clearColor];
        
        
        CGRect rect1 = CGRectMake(0, 0, CGRectGetHeight(frame) - (2*ringWidth), CGRectGetWidth(frame) - (2*ringWidth));
        self.thumbs = [NSMutableArray array];
        for (int i = 0; i < self.numberOfSegments; i++) {
            
            CDCircleThumb * thumb = [[CDCircleThumb alloc] initWithShortCircleRadius:rect1.size.height/2 longRadius:frame.size.height/2 numberOfSegments:self.numberOfSegments];
            [self.thumbs addObject:thumb];
        }
        
        
        
    }
    return self;
}


-(void) drawRect:(CGRect)rect {
    [super drawRect:rect];
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState (ctx);
    CGContextSetBlendMode(ctx, kCGBlendModeCopy);
    
    [self.circleColor setFill];
    circle = [UIBezierPath bezierPathWithOvalInRect:rect];
    [circle closePath];
    [circle fill];
    
    
    CGRect rect1 = CGRectMake(0, 0, CGRectGetHeight(rect) - (2*ringWidth), CGRectGetWidth(rect) - (2*ringWidth));
    rect1.origin.x = rect.size.width / 2  - rect1.size.width / 2;
    rect1.origin.y = rect.size.height / 2  - rect1.size.height / 2;
    
    
    path = [UIBezierPath bezierPathWithOvalInRect:rect1];
    [self.circleColor setFill];
    [path fill];
    CGContextRestoreGState(ctx);
    
    
    //Drawing Thumbs
    CGFloat fNumberOfSegments = self.numberOfSegments;
    CGFloat perSectionDegrees = 360.f / fNumberOfSegments;
    CGFloat totalRotation = 360.f / fNumberOfSegments;
    CGPoint centerPoint = CGPointMake(rect.size.width/2, rect.size.height/2);
    
    
    
    CGFloat deltaAngle = 0.0;
    
    for (int i = 0; i < self.numberOfSegments; i++) {
        
        
        CDCircleThumb * thumb = [self.thumbs objectAtIndex:i];
        thumb.tag = i;
        thumb.iconView.image = [self.dataSource circle:self iconForThumbAtRow:thumb.tag];
        
        CGFloat radius = rect1.size.height/2 + ((rect.size.height/2 - rect1.size.height/2)/2) - thumb.yydifference;
        CGFloat x = centerPoint.x + (radius * cos(degreesToRadians(perSectionDegrees)));
        CGFloat yi = centerPoint.y + (radius * sin(degreesToRadians(perSectionDegrees)));
        
        
        
        [thumb setTransform:CGAffineTransformMakeRotation(degreesToRadians((perSectionDegrees + kRotationDegrees)))];
        if (i==0) {
            deltaAngle= degreesToRadians(360 - kRotationDegrees) + atan2(thumb.transform.a, thumb.transform.b);
            [thumb.iconView setIsSelected:YES];
            self.recognizer.currentThumb = thumb;
        }
        
        
        //set position of the thumb
        thumb.layer.position = CGPointMake(x, yi);
        
        
        perSectionDegrees += totalRotation;
        
        
        if(!isInit)
        {
            if(i < 26 || i > 46)
            {
//                [self performSelector:@selector(addThumb:) withObject:thumb afterDelay:0.01 * i];
                [self addThumb:thumb];
            }
            
            if(i + 1 == self.thumbs.count)
                isInit = YES;
        }else
        {
            [self addSubview:thumb];
        }
    }
    
    [self setTransform:CGAffineTransformRotate(self.transform,deltaAngle)];
}


-(void)addThumb:(id)sender
{
    CDCircleThumb * thumb = (CDCircleThumb *)sender;
    [self addSubview:thumb];
    
    NSInteger index = [self.thumbs indexOfObject:thumb];
    if((index + 1) == self.thumbs.count)
    {
        if(self.animationComplete)
            self.animationComplete();
    }
}


-(void) tapped: (CDCircleGestureRecognizer *) arecognizer{
    if (arecognizer.ended == NO) {
        CGPoint point = [arecognizer locationInView:self];
        if ([path containsPoint:point] == NO) {
            
            [self setTransform:CGAffineTransformRotate([self transform], [arecognizer rotation])];
        }
        
    }
}

-(void)setNum:(int)num
{
    //获取系数，即圆盘上每一格代表的速度大小
    float modulus = (float)MAX_SPEED / (float)51;
    //计算出此次速度对应圆盘上的刻度是多少
    int numStep = num / modulus;//(GAOTIE ? 7 : 3);
    //计算出和上一次速度相比，圆盘应增/减几格
    speedDisparity = numStep - lastSpeed;
    //取绝对值
    int absDisparity = abs(speedDisparity);
    
    float animationTimes = 0;
    if(absDisparity != 0)
    {
        //速度和上一次不同，计算出需要执行几次动画
        animationTimes = (float)0.3/absDisparity;
    }
    
    for (int i = 0; i<absDisparity; i++) {
        [self performSelector:@selector(changeCircle:) withObject:[NSNumber numberWithInt:i] afterDelay:i*animationTimes];
    }
    
    //[self setNeedsDisplay];
}

-(void)changeCircle:(id)index
{
    //获取应移动的格数
    int indexTag = [(NSNumber *)index intValue];
    
    if(speedDisparity > 0)
    {
        //如果是增
        //
        int circleTo = 47 + lastSpeed + indexTag;
        if(circleTo > 71)
        {
            circleTo = circleTo - 71 - 1;
        }
        
        circleTo = (circleTo > 71) ? 71 : circleTo;
        
        CDCircleThumb * minThumb = [self.thumbs objectAtIndex:circleTo];
        minThumb.iconView.image = [UIImage imageNamed:[NSString stringWithFormat:@"light_scale_%d@2x.png",lastSpeed + indexTag]];
        [minThumb.iconView setNeedsDisplay];
    }
    else
    {
        //如果是减
        int circleTo = 47 + lastSpeed - indexTag;
        if(circleTo > 71)
        {
            circleTo = circleTo - 71 - 1;
        }
        
        circleTo = (circleTo < 0)  ? 0  : circleTo;
        
        CDCircleThumb * minThumb = [self.thumbs objectAtIndex:circleTo];
        minThumb.iconView.image = [UIImage imageNamed:@"pic_scale@2x.png"];
        [minThumb.iconView setNeedsDisplay];
    }
    
    if(indexTag + 1 == abs(speedDisparity))
        lastSpeed = (speedDisparity) + lastSpeed;
}

@end
