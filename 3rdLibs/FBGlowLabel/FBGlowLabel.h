#import <UIKit/UIKit.h>

@interface FBGlowLabel : UILabel
@property (nonatomic, assign) CGFloat glowSize;
@property (nonatomic, strong) UIColor *glowColor;
@property (nonatomic, assign) CGFloat innerGlowSize;
@property (nonatomic, strong) UIColor *innerGlowColor;
@end

