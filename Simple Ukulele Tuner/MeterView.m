//
//  MeterView.m
//  Simple Guitar Tuner
//
//  Created by imac on 22.06.15.
//  Copyright (c) 2015 Vormbrock. All rights reserved.
//

#import "MeterView.h"

@implementation MeterView

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        [self addSubview:self.gauge];
        [self setupConstraints];
        
    }
    return self;
}


- (BasicGaugeView*) gauge {
    if (_gauge== nil) {
        _gauge = [BasicGaugeView new];
        [_gauge setTranslatesAutoresizingMaskIntoConstraints:NO];
    }
    return _gauge;
}

#pragma mark -layout constraints
- (void)setupConstraints {
    
    
    NSMutableArray *layoutConstraints = [NSMutableArray new];
    
    
    // Center horizontally
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.gauge
                                                              attribute:NSLayoutAttributeCenterX
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeCenterX
                                                             multiplier:1.0
                                                               constant:0.0]];
    // Center vertically
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.gauge
                                                              attribute:NSLayoutAttributeCenterY
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeCenterY
                                                             multiplier:0.95
                                                               constant:0.0]];
    // Width
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.gauge
                                                              attribute:NSLayoutAttributeWidth
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeWidth
                                                             multiplier:0.495
                                                               constant:0.0]];
    
    // Height
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.gauge
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeHeight
                                                             multiplier:0.66
                                                               constant:0.0]];
    
    // add all constraints at once
    [self addConstraints:layoutConstraints];
    
}


@end
