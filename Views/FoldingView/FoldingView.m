//
//  FoldView.m
//  Popping
//
//  Created by André Schneider on 22.06.14.
//  Copyright (c) 2014 André Schneider. All rights reserved.
//

#import "FoldingView.h"
#import "UIImage+Blur.h"
#import "POP.h"

@interface FoldingView() <POPAnimationDelegate>
- (void)addTopView;
- (void)addBottomView;
- (void)addGestureRecognizers;
- (void)rotateToOriginWithVelocity:(CGFloat)velocity;
- (void)handlePan:(UIPanGestureRecognizer *)recognizer;
- (CATransform3D)transform3D;
- (UIImage *)imageForSection:(LayerSection)section withImage:(UIImage *)image;
- (CAShapeLayer *)maskForSection:(LayerSection)section withRect:(CGRect)rect;
- (BOOL)isLocation:(CGPoint)location inView:(UIView *)view;

@property(nonatomic) UIImage *image;
@property(nonatomic) UIImageView *topView;
@property(nonatomic) UIImageView *backView;
@property(nonatomic) CAGradientLayer *bottomShadowLayer;
@property(nonatomic) CAGradientLayer *topShadowLayer;
@property(nonatomic) NSUInteger initialLocation;
@property(nonatomic) int orderNumber;
@property(nonatomic) LayerSection layer_section;

@end

@implementation FoldingView

- (id)initWithFrame:(CGRect)frame image:(UIImage *)image layerSection:(LayerSection)section order:(int)order
{
    self = [super initWithFrame:frame];
    if (self) {
        _image = image;
        _orderNumber = order;

        _layer_section = section;
//        [self addBottomView];
        [self addTopView];

//        [self addGestureRecognizers];
    }
    return self;
}

#pragma mark - Private Instance methods

- (void)addTopView
{
    UIImage *image = [self imageForSection:LayerSectionTop withImage:self.image];

    self.topView = [[UIImageView alloc] initWithFrame:CGRectMake(0.f,
                                                                 0.f,
                                                                 CGRectGetWidth(self.bounds),  CGRectGetHeight(self.bounds))];
                                                                 //CGRectGetMidY(self.bounds))];
//    self.topView.image = image;
    
    //x:0.5保证锚点横坐标在x轴中间，y:0保证锚点纵坐标在0处
    
//    if(_layer_section == LayerSectionTop || _layer_section == LayerSectionBottom)
//        [self.topView.layer setAnchorPoint:CGPointMake(0.5, 0)];
//    else if(_layer_section == LayerSectionLeft)
//        [self.topView.layer setAnchorPoint:CGPointMake(0, 0.5)];
//    else if(_layer_section == LayerSectionRight)
//        [self.topView.layer setAnchorPoint:CGPointMake(1, 0.5)];
//    
//    [self.topView.layer setPosition:CGPointMake(
//        self.topView.layer.position.x + self.topView.layer.bounds.size.width * (self.topView.layer.anchorPoint.x - 0.5),
//    self.topView.layer.position.y + self.topView.layer.bounds.size.height * (self.topView.layer.anchorPoint.y - 0.5))];
//    NSLog(@"%@",NSStringFromCGPoint(self.topView.layer.position));
    
    
    self.topView.layer.transform = [self transform3D];
    self.topView.layer.mask = [self maskForSection:LayerSectionTop withRect:self.topView.bounds];
    self.topView.userInteractionEnabled = YES;
    self.topView.contentMode = UIViewContentModeScaleAspectFill;
    self.topView.backgroundColor = [UIColor colorWithRed:0.28f green:0.29f blue:0.37f alpha:0.80f];

    self.backView = [[UIImageView alloc] initWithFrame:self.topView.bounds];
    self.backView.image = [image blurredImage];
    self.backView.alpha = 0.0;

    self.topShadowLayer = [CAGradientLayer layer];
    self.topShadowLayer.frame = self.topView.bounds;
    self.topShadowLayer.colors = @[(id)[UIColor clearColor].CGColor, (id)[UIColor blackColor].CGColor];
    self.topShadowLayer.opacity = 0;

    [self.topView addSubview:self.backView];
    [self.topView.layer addSublayer:self.topShadowLayer];
    [self addSubview:self.topView];
    
    NSString *rotationType = @"";
    float toValue = -1.570796;
    if(_layer_section == LayerSectionTop || _layer_section == LayerSectionBottom)
    {
        rotationType = kPOPLayerRotationX;
        toValue = -1.570796;
    }
    else if(_layer_section == LayerSectionLeft)
    {
        rotationType = kPOPLayerRotationY;
        toValue = -1.570796;
    }
    else if(_layer_section == LayerSectionRight)
    {
        rotationType = kPOPLayerRotationY;
        toValue = -1.570796;
    }
    
    
    NSString *key = [NSString stringWithFormat:@"%drotationAnimation",_orderNumber];
    
    POPBasicAnimation *rotationAnimation = [POPBasicAnimation animationWithPropertyNamed:rotationType];
    rotationAnimation.duration = 0;
    rotationAnimation.toValue = @(toValue);
    [self.topView.layer pop_addAnimation:rotationAnimation forKey:key];
}

- (void)addBottomView
{
    UIImage *image = [self imageForSection:LayerSectionBottom withImage:self.image];

    UIImageView *bottomView = [[UIImageView alloc] initWithFrame:CGRectMake(0.f,
                                                                            CGRectGetMidY(self.bounds),
                                                                            CGRectGetWidth(self.bounds),
                                                                            CGRectGetMidY(self.bounds))];
    bottomView.image = image;
    bottomView.contentMode = UIViewContentModeScaleAspectFill;
    bottomView.layer.mask = [self maskForSection:LayerSectionBottom withRect:bottomView.bounds];

    self.bottomShadowLayer = [CAGradientLayer layer];
    self.bottomShadowLayer.frame = bottomView.bounds;
    self.bottomShadowLayer.colors = @[(id)[UIColor blackColor].CGColor, (id)[UIColor clearColor].CGColor];
    self.bottomShadowLayer.opacity = 0;

    [bottomView.layer addSublayer:self.bottomShadowLayer];
    [self addSubview:bottomView];
}

- (void)addGestureRecognizers
{
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                           action:@selector(handlePan:)];

    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                           action:@selector(poke)];

    [self.topView addGestureRecognizer:panGestureRecognizer];
    [self.topView addGestureRecognizer:tapGestureRecognizer];
}

- (void)poke
{
    [self rotateToOriginWithVelocity:7];
}

- (void)handlePan:(UIPanGestureRecognizer *)recognizer
{
    /*
    CGPoint location = [recognizer locationInView:self];

    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.initialLocation = location.y;
        NSLog(@"1");
    }

    if ([[self.topView.layer valueForKeyPath:@"transform.rotation.x"] floatValue] < -M_PI_2) {
        self.backView.alpha = 1.0;
        [CATransaction begin];
        [CATransaction setValue:(id)kCFBooleanTrue
                         forKey:kCATransactionDisableActions];
        self.topShadowLayer.opacity = 0.0;
        self.bottomShadowLayer.opacity = (location.y-self.initialLocation)/(CGRectGetHeight(self.bounds)-self.initialLocation);
        [CATransaction commit];
        NSLog(@"2 --- %f",(location.y-self.initialLocation)/(CGRectGetHeight(self.bounds)-self.initialLocation));
    } else {
        self.backView.alpha = 0.0;
        [CATransaction begin];
        [CATransaction setValue:(id)kCFBooleanTrue
                         forKey:kCATransactionDisableActions];
        CGFloat opacity = (location.y-self.initialLocation)/(CGRectGetHeight(self.bounds)-self.initialLocation);
        self.bottomShadowLayer.opacity = opacity;
        self.topShadowLayer.opacity = opacity;
        [CATransaction commit];
        NSLog(@"3 --- %f",opacity);
    }

    if ([self isLocation:location inView:self]) {
        CGFloat conversionFactor = -M_PI / (CGRectGetHeight(self.bounds) - self.initialLocation);
        
        NSString *rotationType = @"";
        if(_layer_section == LayerSectionTop || _layer_section == LayerSectionBottom)
            rotationType = kPOPLayerRotationX;
        
        if(_layer_section == LayerSectionLeft || _layer_section == LayerSectionRight)
            rotationType = kPOPLayerRotationY;
        
        POPBasicAnimation *rotationAnimation = [POPBasicAnimation animationWithPropertyNamed:rotationType];

        rotationAnimation.duration = 0.01;
        rotationAnimation.toValue = @((location.y-self.initialLocation)*conversionFactor);
        [self.topView.layer pop_addAnimation:rotationAnimation forKey:@"rotationAnimation"];
        NSLog(@"4 --- %f",(location.y-self.initialLocation)*conversionFactor);
    } else {
        recognizer.enabled = NO;
        recognizer.enabled = YES;
        NSLog(@"5");
    }

    if (recognizer.state == UIGestureRecognizerStateEnded ||
        recognizer.state == UIGestureRecognizerStateCancelled) {
        [self rotateToOriginWithVelocity:0];
        NSLog(@"6");
    }
     */
}

- (void)rotateToOriginWithVelocity:(CGFloat)velocity
{
    NSString *rotationType = @"";
    float toValue = 0;
    if(_layer_section == LayerSectionTop || _layer_section == LayerSectionBottom)
        rotationType = kPOPLayerRotationX;
    
    if(_layer_section == LayerSectionLeft || _layer_section == LayerSectionRight)
        rotationType = kPOPLayerRotationY;
    
    if(_layer_section == LayerSectionLeft)
        toValue = 3.1;
    
    NSString *key = [NSString stringWithFormat:@"%d_rotationAnimation",_orderNumber];
    
    POPSpringAnimation *rotationAnimation = [POPSpringAnimation animationWithPropertyNamed:rotationType];
    if (velocity > 0) {
        rotationAnimation.velocity = @(velocity);
    }
    rotationAnimation.springBounciness = 15.0f;
    rotationAnimation.dynamicsMass = 3.0f;
    rotationAnimation.dynamicsTension = 200;
    rotationAnimation.toValue = @(0);
    rotationAnimation.delegate = self;
    [self.topView.layer pop_addAnimation:rotationAnimation forKey:key];
    
    for (UIView *v in self.subviews) {
        
        POPSpringAnimation *_rotationAnimation = [POPSpringAnimation animationWithPropertyNamed:rotationType];
        if (velocity > 0) {
            _rotationAnimation.velocity = @(velocity);
        }
        _rotationAnimation.springBounciness = 15.0f;
        _rotationAnimation.dynamicsMass = 3.0f;
        _rotationAnimation.dynamicsTension = 200;
        _rotationAnimation.toValue = @(0);
        _rotationAnimation.delegate = self;
        [v.layer pop_addAnimation:_rotationAnimation forKey:key];
    }
}

- (CATransform3D)transform3D
{
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = 2.5 / -2000;
    return transform;
}

- (BOOL)isLocation:(CGPoint)location inView:(UIView *)view
{
    if ((location.x > 0 && location.x < CGRectGetWidth(self.bounds)) &&
        (location.y > 0 && location.y < CGRectGetHeight(self.bounds))) {
        return YES;
    }
    return NO;
}

- (UIImage *)imageForSection:(LayerSection)section withImage:(UIImage *)image
{
    CGRect rect = CGRectMake(0.f, 0.f, image.size.width, image.size.height / 2.f);
    if (section == LayerSectionBottom) {
        rect.origin.y = image.size.height / 2.f;
    }

    CGImageRef imgRef = CGImageCreateWithImageInRect(image.CGImage, rect);
    UIImage *imagePart = [UIImage imageWithCGImage:imgRef];
    CGImageRelease(imgRef);

    return imagePart;
}

- (CAShapeLayer *)maskForSection:(LayerSection)section withRect:(CGRect)rect
{
    CAShapeLayer *layerMask = [CAShapeLayer layer];
    UIRectCorner corners = 0;//(section == LayerSectionTop) ? 0 : 12;

    layerMask.path = [UIBezierPath bezierPathWithRoundedRect:rect
                                           byRoundingCorners:corners
                                                 cornerRadii:CGSizeMake(5, 5)].CGPath;
    return layerMask;
}

#pragma mark - POPAnimationDelegate

- (void)pop_animationDidApply:(POPAnimation *)anim
{
    /*
    CGFloat currentValue = [[anim valueForKey:@"currentValue"] floatValue];
    if (currentValue > -M_PI_2) {
        self.backView.alpha = 0.f;
        [CATransaction begin];
        [CATransaction setValue:(id)kCFBooleanTrue
                         forKey:kCATransactionDisableActions];
        self.bottomShadowLayer.opacity = -currentValue/M_PI;
        self.topShadowLayer.opacity = -currentValue/M_PI; //currentValue = -1.55183053
        [CATransaction commit];
    }
     */
}

@end
