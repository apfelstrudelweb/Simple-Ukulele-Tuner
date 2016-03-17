//
//  HitImageView.m
//  Simple Guitar Tuner
//
//  Created by imac on 02.07.15.
//  Copyright (c) 2015 Vormbrock. All rights reserved.
//

#import "HitImageView.h"

@implementation HitImageView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    CGRect frame = CGRectInset(self.bounds, -5, -5);
    
    return CGRectContainsPoint(frame, point) ? self : nil;
}

@end
