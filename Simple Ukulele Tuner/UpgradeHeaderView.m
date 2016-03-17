//
//  UpgradeHeaderView.m
//  Simple Ukulele Tuner
//
//  Created by Ulrich Vormbrock on 06.08.15.
//  Copyright (c) 2015 Vormbrock. All rights reserved.
//

#import "UpgradeHeaderView.h"

@interface UpgradeHeaderView() {
    CGFloat iconRatio;
}
@end

@implementation UpgradeHeaderView


- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        // close button
        self.closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        NSString* imageName1 = @"closeButton.png";
        UIImage* micIcon = [UIImage imageNamed:imageName1];
        [self.closeButton  setImage:micIcon forState:UIControlStateNormal];
        [self.closeButton setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.closeButton addTarget:self action:@selector(closeWindow:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.closeButton];
        
        iconRatio = micIcon.size.width / micIcon.size.height;
        
        // title label
        self.titleLabel = [[UILabel alloc] initWithFrame:frame];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.textColor = TEXT_COLOR_HEADER;
        [self.titleLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        self.titleLabel.text = @"Upgrades";
        
        self.titleLabel.font = [UIFont fontWithName:FONT_BOLD size:[UILabel getFontSizeForHeadline]];
        [self addSubview:self.titleLabel];
        
        [self setupConstraints];
        
    }
    return self;
}

#pragma mark - NSNotificationCenter
- (void) closeWindow:(NSNotification *) notification {
    // Once removeFromSuperView method is called, that view is also released from memory.
    [self.superview removeFromSuperview];
}

- (void)setupConstraints {
    
    
    NSMutableArray *layoutConstraints = [NSMutableArray new];
    
    CGFloat iconWidth = IS_IPAD ? 60.0 : 30.0;
    
    // 1. CLOSE BUTTON
    // Center horizontally
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.closeButton
                                                              attribute:NSLayoutAttributeLeft
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeLeft
                                                             multiplier:1.0
                                                               constant:0.0]];
    // Center vertically
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.closeButton
                                                              attribute:NSLayoutAttributeBaseline
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeBaseline
                                                             multiplier:0.84
                                                               constant:0.0]];
    // Width
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.closeButton
                                                              attribute:NSLayoutAttributeWidth
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeWidth
                                                             multiplier:0.0
                                                               constant:iconWidth]];
    
    // Height
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.closeButton
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeHeight
                                                             multiplier:0.0
                                                               constant:iconWidth/iconRatio]];
    
    
    
    // 2. TITLE LABEL
    // Center horizontally
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.titleLabel
                                                              attribute:NSLayoutAttributeCenterX
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeCenterX
                                                             multiplier:1.0
                                                               constant:0.0]];
    // Center vertically
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.titleLabel
                                                              attribute:NSLayoutAttributeBaseline
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeBaseline
                                                             multiplier:0.8
                                                               constant:0.0]];
    
    // add all constraints at once
    [self addConstraints:layoutConstraints];
    
}



@end
