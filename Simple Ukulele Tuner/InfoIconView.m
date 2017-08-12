//
//  InfoIconView.m
//  Simple Guitar Tuner
//
//  Created by imac on 14.05.15.
//  Copyright (c) 2015 Vormbrock. All rights reserved.
//

#import "InfoIconView.h"

@interface InfoIconView() {
    PopupView* popup;
}
@end

@implementation InfoIconView


- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        
        // no info button for balalaika
#if defined(TARGET_BALALAIKA)
        return self;
#endif
        
        // info icon (button)
        self.infoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        NSString* imageName = @"info.png"; //IS_IPAD ? @"infoIcon2x.png" : @"infoIcon.png";
        UIImage* infoIcon = [UIImage imageNamed:imageName];
        [self.infoButton  setImage:infoIcon forState:UIControlStateNormal];
        [self.infoButton setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.infoButton addTarget:self action:@selector(showInfo:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:self.infoButton];
        
        [self setupConstraints];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(removePopup:)
                                                     name:@"PopupRemovalNotification"
                                                   object:nil];
    }
    
    return self;
}

#pragma mark - Notification
-(void) showInfo:(NSNotification *) notification {
    
    if (popup==nil) {
        popup = [PopupView new];
        
        UIWindow* currentWindow = [UIApplication sharedApplication].keyWindow;
        [currentWindow addSubview:popup.view];
    } 
}

- (void) removePopup:(NSNotification *) notification {
    popup = nil;
}

#pragma mark - Layout Constraints
- (void)setupConstraints {
    
    CGFloat iconSize = IS_IPAD ? 64.0 : 32.0;
    
    [self removeConstraints:[self constraints]];
    
    NSMutableArray *layoutConstraints = [NSMutableArray new];
    
    // Center vertically
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.infoButton
                                                              attribute:NSLayoutAttributeBaseline
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeBaseline
                                                             multiplier:1.0
                                                               constant:0.0]];
    
    // Center horizontally
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.infoButton
                                                              attribute:NSLayoutAttributeRight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeRight
                                                             multiplier:1.0
                                                               constant:0.0]];
    
    // Width
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.infoButton
                                                              attribute:NSLayoutAttributeWidth
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeWidth
                                                             multiplier:0.0
                                                               constant:iconSize]];
    
    // Height
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.infoButton
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeHeight
                                                             multiplier:0.0
                                                               constant:iconSize]];
    
    
    // add all constraints at once
    [self addConstraints:layoutConstraints];
    
}


@end
