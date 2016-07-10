//
//  GraphView.m
//  Diapason
//
//  Created by imac on 13.03.15.
//  Copyright (c) 2015 Vormbrock. All rights reserved.
//

#import "GraphView.h"

#if defined(TARGET_BANJO)
    #define BACKGROUND_COLOR_DARK [UIColor colorWithRed:0.118 green:0.129 blue:0.157 alpha:0.9]
    #define BACKGROUND_COLOR_LIGHT [UIColor colorWithRed:0.118 green:0.129 blue:0.157 alpha:0.85]
#elif
    #define BACKGROUND_COLOR_DARK [UIColor colorWithRed:0.118 green:0.129 blue:0.157 alpha:1.0]
    #define BACKGROUND_COLOR_LIGHT [UIColor colorWithRed:0.118 green:0.129 blue:0.157 alpha:0.9]
#endif



@implementation GraphView



- (void)layoutSubviews {
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    
    gradient.frame = self.bounds;
    gradient.colors = @[(id)BACKGROUND_COLOR_LIGHT.CGColor, (id)BACKGROUND_COLOR_DARK.CGColor];
    gradient.locations = @[@0.0, @0.5, @1.0];
    

    
    [self.layer addSublayer:gradient];
    
    
    // add corners at the bottom
    float cornerRadius = [[UIScreen mainScreen] bounds].size.height / 40.0;
    UIRectCorner rectCorner = UIRectCornerBottomRight|UIRectCornerBottomLeft;
    [self applyRoundCorners:rectCorner radius:cornerRadius];
   
    [self addSubview:self.coordView];
    [self setupViewConstraints];
}





- (CoordinateSystemView*) coordView {
    if (_coordView == nil) {
        _coordView = [CoordinateSystemView new];
        _coordView.backgroundColor = [UIColor clearColor];
        [_coordView setTranslatesAutoresizingMaskIntoConstraints:NO];
    }
    return _coordView;
}



#pragma mark -constraints

- (void) setupViewConstraints {
    
    [self removeConstraints:[self constraints]];
    
    NSMutableArray *layoutConstraints = [NSMutableArray new];
    
    
    // COORDINATE SYSTEM
    // Center vertically
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.coordView
                                                              attribute:NSLayoutAttributeTop
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeTop
                                                             multiplier:0.95
                                                               constant:0.0]];
    
    // Center horizontally
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.coordView
                                                              attribute:NSLayoutAttributeCenterX
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeCenterX
                                                             multiplier:1.0
                                                               constant:0.0]];
    
    // Height
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.coordView
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeHeight
                                                             multiplier:0.85
                                                               constant:0.0]];
    // Width
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.coordView
                                                              attribute:NSLayoutAttributeWidth
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeWidth
                                                             multiplier:1.0
                                                               constant:0.0]];
    
    
    [self addConstraints:layoutConstraints];
}

-(void)dealloc {
    //NSLog(@"%s", __PRETTY_FUNCTION__);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
