//
//  UIView+uvo.m
//  Simple Guitar Tuner
//
//  Created by imac on 23.06.15.
//  Copyright (c) 2015 Vormbrock. All rights reserved.
//

#import "UIView+uvo.h"

@implementation UIView (uvo)

- (void)applyRoundCorners:(UIRectCorner)corners radius:(CGFloat)radius {
    
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:corners cornerRadii:CGSizeMake(radius, radius)];
    
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = self.bounds;
    maskLayer.path = maskPath.CGPath;
    
    self.layer.mask = maskLayer;
}

@end
