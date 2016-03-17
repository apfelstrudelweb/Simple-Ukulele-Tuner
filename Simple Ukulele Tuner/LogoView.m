//
//  LogoView.m
//  Diapaxon
//
//  Created by imac on 29.04.15.
//  Copyright (c) 2015 Vormbrock. All rights reserved.
//

#import "LogoView.h"

@interface LogoView() {
    UIImage *logoPng;
}
@end

@implementation LogoView



- (id)init {
    return [self initWithFrame:CGRectZero];
}

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        
        logoPng = [UIImage imageNamed:@"apfelstrudel.png"];
        // Workaround ... don't know why it takes the larger pic for iphone5 ...
        if (IS_IPAD) {
            logoPng = [UIImage imageNamed:@"apfelstrudel2x.png"];
        }
        
        UIImage* logoImg = [UIImage imageWithCGImage:logoPng.CGImage];
        self.imageView = [[UIImageView alloc] initWithImage:logoImg];
        [self.imageView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self addSubview:self.imageView];
        
        
        self.headline = [[UILabel alloc] initWithFrame:frame];
        self.headline.textAlignment = NSTextAlignmentCenter;
        self.headline.textColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
        [self.headline setTranslatesAutoresizingMaskIntoConstraints:NO];
        self.headline.text = @"designed by";
        
        self.headline.font = [UIFont fontWithName:FONT_BOLD size:[UILabel getFontSizeForStrings]];
        
        [self addSubview:self.headline];
        
        [self setupLayoutConstraints];

    }

    return self;
}

#pragma mark -layout constraints
- (void)setupLayoutConstraints {
    
    
    
    NSMutableArray *layoutConstraints = [NSMutableArray new];
    
    
    // Center vertically
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.headline
                                                              attribute:NSLayoutAttributeCenterY
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeCenterY
                                                             multiplier:-0.5
                                                               constant:0.0]];
    
    // Center horizontally
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.headline
                                                              attribute:NSLayoutAttributeCenterX
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeCenterX
                                                             multiplier:1.0
                                                               constant:0.0]];
    
    // Center vertically
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.imageView
                                                              attribute:NSLayoutAttributeCenterY
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeCenterY
                                                             multiplier:1.0
                                                               constant:0.0]];
    
    // Center horizontally
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.imageView
                                                              attribute:NSLayoutAttributeCenterX
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeCenterX
                                                             multiplier:1.0
                                                               constant:0.0]];
    
    CGFloat logoWidth = logoPng.size.width;
    
    // Width
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.imageView
                                                              attribute:NSLayoutAttributeWidth
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeWidth
                                                             multiplier:0.0
                                                               constant:logoWidth]];
    

    
    // add all constraints at once
    [self addConstraints:layoutConstraints];
    
}


@end
