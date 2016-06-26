//
//  GaugeView.m
//  Simple Guitar Tuner
//
//  Created by imac on 22.06.15.
//  Copyright (c) 2015 Vormbrock. All rights reserved.
//

#import "GaugeView.h"

@interface GaugeView() {
    CGFloat ratio;
}
@end

@implementation GaugeView


- (void)layoutSubviews {
    
    // 1. 3D background
    UIImage* background = [UIImage imageWithCGImage:[UIImage imageNamed:@"gaugeBackground.png"].CGImage];
    
    ratio = background.size.width / background.size.height;
    
    self.gaugeBackgroundImageView = [[UIImageView alloc] initWithImage:background];
    [self.gaugeBackgroundImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addSubview:self.gaugeBackgroundImageView];
    [self setupBackgroundConstraints];
    
    CGRect frame = self.frame;//CGRectMake(0.005*size.width, 0.0, 0.992*size.width, 0.8*size.height);
    
    // 2. picker view
    self.picker = [[HorizontalPicker alloc] initWithFrame:frame];
    [self.picker setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addSubview:self.picker];
    [self setupPickerConstraints];
    

}

#pragma mark - Layout Constraints
- (void)setupBackgroundConstraints {


    NSMutableArray *layoutConstraints = [NSMutableArray new];
    
    /**
     *  3-D-background
     */
    
    // Center vertically
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.gaugeBackgroundImageView
                                                              attribute:NSLayoutAttributeCenterY
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeCenterY
                                                             multiplier:1.0
                                                               constant:0.0]];
    
    // Center horizontally
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.gaugeBackgroundImageView
                                                              attribute:NSLayoutAttributeCenterX
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeCenterX
                                                             multiplier:1.0
                                                               constant:0.0]];
    
    // Width
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.gaugeBackgroundImageView
                                                              attribute:NSLayoutAttributeWidth
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeWidth
                                                             multiplier:1.0
                                                               constant:0.0]];
    
    // Height
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.gaugeBackgroundImageView
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeHeight
                                                             multiplier:0.0
                                                               constant:self.frame.size.height]];
    
    
    // add all constraints at once
    [self addConstraints:layoutConstraints];
    
}

- (void)setupPickerConstraints {
    
    
    CGFloat relWidth = 0.99;
    CGFloat relHeight = 0.92;
    
    NSMutableArray *layoutConstraints = [NSMutableArray new];
    
    
    /**
     *  picker view
     */
    
    // Center vertically
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.picker
                                                              attribute:NSLayoutAttributeCenterY
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.gaugeBackgroundImageView
                                                              attribute:NSLayoutAttributeCenterY
                                                             multiplier:1.0
                                                               constant:0.0]];
    
    // Center horizontally
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.picker
                                                              attribute:NSLayoutAttributeCenterX
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.gaugeBackgroundImageView
                                                              attribute:NSLayoutAttributeCenterX
                                                             multiplier:1.0
                                                               constant:0.0]];
    
    // Width
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.picker
                                                              attribute:NSLayoutAttributeWidth
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.gaugeBackgroundImageView
                                                              attribute:NSLayoutAttributeWidth
                                                             multiplier:relWidth
                                                               constant:0.0]];
    
    // Height
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.picker
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.gaugeBackgroundImageView
                                                              attribute:NSLayoutAttributeHeight
                                                             multiplier:relHeight
                                                               constant:0.0]];
    
    
    // add all constraints at once
    [self addConstraints:layoutConstraints];
    
}

@end
