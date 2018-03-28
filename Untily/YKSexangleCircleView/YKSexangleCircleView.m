//
//  YKSexangleCircleView.m
//  iLiaoNing
//
//  Created by 杨翊楷 on 15/1/20.
//  Copyright (c) 2015年 杨翊楷. All rights reserved.
//

#import "YKSexangleCircleView.h"
#import "YKButton.h"

@interface YKSexangleCircleView()
{
    NSMutableArray *buttonArray;
    
    int wid;
}

@end

@implementation YKSexangleCircleView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        buttonArray = [NSMutableArray arrayWithCapacity:0];
        wid = frame.size.width / (3 + 2 / 10); //三个六边形加上两个1/10的间距
        
        [self initSexangleCircleCenter];
    }
    
    return self;
}

-(void)initSexangleCircleCenter
{
    _centerButton = [[YKButton alloc] initWithFrame:CGRectMake(0, 0, wid, wid)];
    _centerButton.tintColor = [UIColor colorWithRed:0.96f green:0.53f blue:0.02f alpha:1.00f];
    [_centerButton.titleLabel setFont:[UIFont systemFontOfSize:18]];
    [_centerButton.titleLabel setNumberOfLines:0];
    [_centerButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [_centerButton setTitle:@"HELLO" forState:UIControlStateNormal];
    [_centerButton addTarget:self action:@selector(buttonTarget:) forControlEvents:UIControlEventTouchUpInside];
    _centerButton.tag = 10000;
    [self addSubview:_centerButton];
    _centerButton.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
}

-(void)buttonTarget:(id)sender
{
    YKButton *btn = (YKButton *)sender;

    if(btn != _centerButton)
    {
        if(btn.selected == NO)
        {
            for (YKButton *b in buttonArray) {
                [UIView animateWithDuration:0.2 animations:^{
                    b.transform = CGAffineTransformMakeScale(1.0, 1.0);
                    b.selected = NO;
                }];
            }
            
            [UIView animateWithDuration:0.2 animations:^{
                btn.transform = CGAffineTransformMakeScale(1.2, 1.2);
            }];
            btn.selected = YES;
        }else
        {
            [UIView animateWithDuration:0.2 animations:^{
                btn.transform = CGAffineTransformMakeScale(1.0, 1.0);
            }];
            btn.selected = NO;
        }
    }
    else
    {
        if(self.isAnimating)
            return;
    }
    
    if(self.buttonClick)
        self.buttonClick(btn, btn.tag - 10000);
}

-(void)setCenterTitle:(NSString *)title
{
    [_centerButton setTitle:title forState:UIControlStateNormal];
}

-(void)animationDone
{
    self.isAnimating = NO;
}


#pragma mark - 
#pragma mark - show & hide

-(void)showWithContents:(NSArray *)contents
{
    if(self.isAnimating || buttonArray.count != 0)
        return;
    
    self.isAnimating = YES;
    
    
    //环六边形坐标绘制算法
    //      .(1)  .(2)
    //
    //    .(6) .(0) .(3)
    //
    //      .(5)  .(4)
    
    float X = self.frame.size.width / 2;
    float Y = self.frame.size.height / 2;
    float radius = ((wid / 2 - 0.067 * wid) * 2 + wid / 10);
    float oneAndFive_cneterX  = X - radius / 2;
    float twoAndFour_centerX  = X + radius / 2;
    float oneAndTwo_centerY   = Y - radius / 2 * 1.72;
    float fourAndFive_centerY = Y + radius / 2 * 1.72;
    
    float x[6] = {oneAndFive_cneterX, twoAndFour_centerX, X + radius, twoAndFour_centerX, oneAndFive_cneterX, X - radius};
    float y[6] = {oneAndTwo_centerY, oneAndTwo_centerY, Y, fourAndFive_centerY, fourAndFive_centerY, Y};
    
    
//    NSArray *titleArray = [NSArray arrayWithObjects:@"支持\n一键上网",@"免费看\n直播、点播",@"最多的免费\n上网地点",@"全国用户\n均可使用",@"一次注册\n走遍辽宁",@"发现\n本地生活", nil];
    NSArray *colorArray = [NSArray arrayWithObjects:
                           [UIColor colorWithRed:0.58f green:0.81f blue:0.38f alpha:1.00f],
                           [UIColor colorWithRed:1.00f green:0.45f blue:0.48f alpha:1.00f],
                           [UIColor colorWithRed:0.93f green:0.79f blue:0.28f alpha:1.00f],
                           [UIColor colorWithRed:0.61f green:0.35f blue:0.72f alpha:1.00f],
                           [UIColor colorWithRed:0.20f green:0.28f blue:0.37f alpha:1.00f],
                           [UIColor colorWithRed:0.44f green:0.82f blue:0.99f alpha:1.00f],
                           nil];
    
    for (int i = 0; i < 6; i++)
    {
        YKButton *button = [[YKButton alloc] initWithFrame:CGRectMake(0, 0, wid, wid)];
        button.center = CGPointMake(X, Y);
        button.tintColor = colorArray[i];
        [button.titleLabel setFont:[UIFont systemFontOfSize:18]];
        [button.titleLabel setNumberOfLines:0];
        [button.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [button setTitle:contents[i] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(buttonTarget:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = 10001 + i;
        [self insertSubview:button belowSubview:_centerButton];
        
        NSDictionary *coordinate = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:x[i]], @"x", [NSNumber numberWithFloat:y[i]], @"y", nil];
        button.transform = CGAffineTransformMakeScale(0.001, 0.001);
        [buttonArray addObject:button];
        
        [self performSelector:@selector(showButtonWithAnimation:) withObject:[NSDictionary dictionaryWithObjectsAndKeys:button, @"button", coordinate, @"coordinate", nil] afterDelay:0.1 * i];
    }
    
    for (int i = 1; i <= 6; i++) {
        [self performSelector:@selector(buttonTarget:) withObject:buttonArray[i - 1] afterDelay:1.3 + 0.15 * i];
    }

    [self performSelector:@selector(buttonTarget:) withObject:buttonArray[5] afterDelay:2.35];
    [self performSelector:@selector(animationDone) withObject:nil afterDelay:2.5];
}

-(void)showButtonWithAnimation:(NSDictionary *)info
{
    UIButton *button = (UIButton *)[info objectForKey:@"button"];
    NSDictionary *coordinate = (NSDictionary *)[info objectForKey:@"coordinate"];
    
    [UIView animateWithDuration:0.25 animations:^{
        
        button.center = CGPointMake([[coordinate objectForKey:@"x"] floatValue], [[coordinate objectForKey:@"y"] floatValue]);
        button.alpha = 1;
        button.transform = CGAffineTransformMakeScale(1.2, 1.2);
        
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.15 animations:^{
            
            button.transform = CGAffineTransformMakeScale(0.8, 0.8);
            
        } completion:^(BOOL finished) {
            
            [UIView animateWithDuration:0.15 animations:^{
                
                button.transform = CGAffineTransformMakeScale(1, 1);
                
            } completion:^(BOOL finished) {
                
//                if(button.tag - 10001 == buttonArray.count - 1)
//                    self.isAnimating = NO;
                button.layer.shadowColor = [UIColor blackColor].CGColor;
                button.layer.shadowOpacity = 0.2;
                button.layer.shadowOffset = CGSizeMake(0, 1);
                button.layer.shadowRadius = 2;
                
            }];
        }];
    }];
}

-(void)hide
{
    if(self.isAnimating)
        return;
    
    self.isAnimating = YES;
    int inetratorI = 0;
    for (UIButton *button in buttonArray)
    {
        float delayTime = inetratorI * 0.1;
        [self performSelector:@selector(hideBubbleWithAnimation:) withObject:button afterDelay:delayTime];
        ++inetratorI;
    }
}

-(void)hideBubbleWithAnimation:(UIButton *)button
{
    [UIView animateWithDuration:0.2 animations:^{
        button.transform = CGAffineTransformMakeScale(1.2, 1.2);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.25 animations:^{
            button.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
            button.transform = CGAffineTransformMakeScale(0.001, 0.001);
            button.alpha = 0;
        } completion:^(BOOL finished) {
            if(button.tag - 10001 == buttonArray.count - 1) {
                self.isAnimating = NO;
                [button removeFromSuperview];
                [buttonArray removeAllObjects];
            }
            [button removeFromSuperview];
        }];
    }];
}

@end
