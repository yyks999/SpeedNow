//
//  FoldView.h
//  Popping
//
//  Created by André Schneider on 22.06.14.
//  Copyright (c) 2014 André Schneider. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, LayerSection) {
    LayerSectionTop,
    LayerSectionBottom,
    LayerSectionLeft,
    LayerSectionRight
};

@interface FoldingView : UIView

- (id)initWithFrame:(CGRect)frame image:(UIImage *)image layerSection:(LayerSection)section order:(int)order;
- (void)poke;

@end
