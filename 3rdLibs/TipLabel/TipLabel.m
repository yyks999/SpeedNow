    //
    //  TipLabel.m
    //  DomainClient
    //
    //  Created by Sidney on 13-6-4.
    //  Copyright (c) 2013年 BH Technology Co., Ltd. All rights reserved.
    //

#import "TipLabel.h"

@implementation TipLabel

- (id)init
{
    self = [super initWithFrame:CGRectMake(SCREEN_WIDTH / 2, SCREEN_HEIGHT - 100 * SCALE, 100 * SCALE, 35 * SCALE)];
    if (self) {
            // Initialization code
        self.numberOfLines = 8;
    }
    return self;
}

- (CGSize)getSizeOfStr:(NSString *)str font:(UIFont *)font
{
//    CGSize size = [str sizeWithFont:font
//                  constrainedToSize:CGSizeMake(300 , MAXFLOAT)];
    NSDictionary *attribute = @{NSFontAttributeName:font};
    CGSize size = [str boundingRectWithSize:CGSizeMake(300 , MAXFLOAT) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
    return size;
}


- (void)showToastWithMessage:(NSString *)message showTime:(float)time
{
    CGSize size = [self getSizeOfStr:message font:[UIFont systemFontOfSize:(IS_IPAD) ? 22 : 16]];
    
    self.font = [UIFont systemFontOfSize:(IS_IPAD) ? 22 : 16];
    self.backgroundColor = [UIColor colorWithRed:0.27f green:0.68f blue:1.00f alpha:0.9f];//[UIColor colorWithRed:0 green:0 blue:0 alpha:0.9f];
    self.textAlignment = NSTextAlignmentCenter;
    self.textColor = [UIColor whiteColor];
    [[self layer] setCornerRadius:3];
    
    float width = (size.width + 15);
    int height = 30;
    if (width > SCREEN_WIDTH) {
        width = (SCREEN_WIDTH - 40);
    }
    if (size.height > height) {
        int n = size.height / height;
        if (n % height != 0) n ++;
        height = (n - 0.5f) * height;
    }
    
    float padScale = (IS_IPAD) ? 1.5 : 1;
    self.frame = CGRectMake((SCREEN_WIDTH - width * padScale) / 2, SCREEN_HEIGHT - (50 + height) * padScale, width * padScale, height * padScale);
    self.text = message;
//    [APP_DELEGATE.window.rootViewController.view addSubview:self];
    [APP_DELEGATE.window addSubview:self];
    [APP_DELEGATE.window bringSubviewToFront:self];
    [self performSelector:@selector(removeTipMessageLabel) withObject:nil afterDelay:time];
}

- (void)removeTipMessageLabel
{
    [UIView animateWithDuration:0.4f
                     animations:^{
                         self.alpha = 0;
                     } completion:^(BOOL finished) {
                         [self removeFromSuperview];
                         self.alpha = 1;
                     }];
}




/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end
