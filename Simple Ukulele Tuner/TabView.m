//
//  TabView.m
//  Diapaxon
//
//  Created by imac on 05.05.15.
//  Copyright (c) 2015 Vormbrock. All rights reserved.
//

#import "TabView.h"

#define LABEL_COLOR [UIColor colorWithRed:0.13 green:0.13 blue:0.13 alpha:1.0]

@interface TabView() {
    CGFloat buttonWidth, buttonHeight;
    CGFloat w, h;
    CGFloat shadowRadius, shadowOffset;
}
@end

@implementation TabView


- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        buttonWidth = 0.48;
        buttonHeight = 0.8;
        
        shadowRadius = IS_IPAD ? 0.4 : 0.2;
        shadowOffset = IS_IPAD ? 0.7 : 0.5;
       
        [self setNeedsDisplay];
    }
    return self;
}

- (void)layoutSubviews {
    
    w = self.frame.size.width;
    h = self.frame.size.height;
    
    [self createFFTButton];
    [self createAutocorrelationButton];
    [self addAutocorrelationText];
    [self addFFTText];
    
    [self setupButtonConstraints];
}

#pragma mark -creation of buttons
- (void) createFFTButton {

    // image and text
    self.fftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.fftButton setBackgroundImage:[UIImage imageNamed:@"tabActive.png"] forState:UIControlStateNormal];
    
    // Event
    [self.fftButton addTarget:self
                                   action:@selector(fftButtonTouchedUpInside:)
                         forControlEvents:UIControlEventTouchUpInside];
    
    [self.fftButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self addSubview:self.fftButton];
}

- (void) createAutocorrelationButton {
    
    // image and text
    self.autocorrelationButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.autocorrelationButton setBackgroundImage:[UIImage imageNamed:@"tabPassive.png"] forState:UIControlStateNormal];

    // Event
    [self.autocorrelationButton addTarget:self
                           action:@selector(autocorrelationButtonTouchedUpInside:)
                 forControlEvents:UIControlEventTouchUpInside];

    [self.autocorrelationButton setTranslatesAutoresizingMaskIntoConstraints:NO];

    [self addSubview:self.autocorrelationButton];
}

#pragma mark -creation of button labels
- (void) addAutocorrelationText {

    
    UILabel *customLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, buttonWidth*w, 0.9*buttonHeight*h)];
    NSString* buttonTitle = [NSString stringWithFormat:NSLocalizedString(@"tab_autocorrelation", @"button for autocorrelation")];
    [customLabel setText:buttonTitle];
    [customLabel setFont:[UIFont fontWithName:FONT_BOLD size:[UILabel getFontSizeForTabButton]]];
    [customLabel setTextColor:LABEL_COLOR];
    customLabel.textAlignment = NSTextAlignmentCenter;
    
    //customLabel.backgroundColor = [UIColor greenColor];
    
    customLabel.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    customLabel.layer.shadowRadius = shadowRadius;
    customLabel.layer.shadowOpacity = 1;
    customLabel.layer.shadowOffset = CGSizeMake(shadowOffset, shadowOffset);
    customLabel.layer.masksToBounds = NO;
    
    [self.autocorrelationButton addSubview:customLabel];
}



- (void) addFFTText {

    UILabel *customLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, buttonWidth*w, 0.9*buttonHeight*h)];
    NSString* buttonTitle = [NSString stringWithFormat:NSLocalizedString(@"tab_fft", @"button for fft")];
    [customLabel setText:buttonTitle];
    [customLabel setFont:[UIFont fontWithName:FONT_BOLD size:[UILabel getFontSizeForTabButton]]];
    [customLabel setTextColor:LABEL_COLOR];
    customLabel.textAlignment = NSTextAlignmentCenter;
    
    customLabel.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    customLabel.layer.shadowRadius = shadowRadius;
    customLabel.layer.shadowOpacity = 1;
    customLabel.layer.shadowOffset = CGSizeMake(shadowOffset, shadowOffset);
    customLabel.layer.masksToBounds = NO;
    
    [self.fftButton addSubview:customLabel];
}


#pragma mark -button event handler
- (void)autocorrelationButtonTouchedUpInside:(UIButton*)button {
    //NSLog(@"autocorrelationButtonTouchedUpInside");
    [SHARED_MANAGER setFFT:NO];
    
    [self.autocorrelationButton setBackgroundImage:[UIImage imageNamed:@"tabActive.png"] forState:UIControlStateNormal];
    [self.fftButton setBackgroundImage:[UIImage imageNamed:@"tabPassive.png"] forState:UIControlStateNormal];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ChangeGraphModeNotification" object:nil];
    
    [self showUpgrades];
}

- (void)fftButtonTouchedUpInside:(UIButton*)button {
    //NSLog(@"fftButtonTouchedUpInside");
    [SHARED_MANAGER setFFT:YES];
    
    [self.autocorrelationButton setBackgroundImage:[UIImage imageNamed:@"tabPassive.png"] forState:UIControlStateNormal];
    [self.fftButton setBackgroundImage:[UIImage imageNamed:@"tabActive.png"] forState:UIControlStateNormal];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ChangeGraphModeNotification" object:nil];
    
    [self showUpgrades];
}

- (void) showUpgrades {
    
    NSString* currentVersion = [SHARED_VERSION_MANAGER getVersion];
    
    if ([version_lite isEqualToString:currentVersion] || [version_uke isEqualToString:currentVersion]) {
        
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGFloat screenWidth = screenRect.size.width;
        CGFloat screenHeight = screenRect.size.height;
        
        UIView *upgradeView = [[UpgradeView alloc] initWithFrame: CGRectMake ( 0, 0, screenWidth, screenHeight)];
        UIWindow* window = [UIApplication sharedApplication].keyWindow;
        [window addSubview:upgradeView];
        
    }
}

#pragma mark -constraints
- (void) setupButtonConstraints {
    NSMutableArray *layoutConstraints = [NSMutableArray new];

    
    // Center vertically
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.fftButton
                                                              attribute:NSLayoutAttributeCenterY
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeCenterY
                                                             multiplier:1.4
                                                               constant:0.0]];
    
    // Center horizontally
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.fftButton
                                                              attribute:NSLayoutAttributeLeft
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeLeft
                                                             multiplier:1.0
                                                               constant:0.0]];
    
    // Width
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.fftButton
                                                              attribute:NSLayoutAttributeWidth
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeWidth
                                                             multiplier:buttonWidth
                                                               constant:0.0]];
    
    // Height
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.fftButton
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeHeight
                                                             multiplier:buttonHeight
                                                               constant:0.0]];
    
    // Center vertically
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.autocorrelationButton
                                                              attribute:NSLayoutAttributeCenterY
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeCenterY
                                                             multiplier:1.4
                                                               constant:0.0]];
    
    // Center horizontally
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.autocorrelationButton
                                                              attribute:NSLayoutAttributeRight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeRight
                                                             multiplier:1.0
                                                               constant:0.0]];
    
    // Width
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.autocorrelationButton
                                                              attribute:NSLayoutAttributeWidth
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeWidth
                                                             multiplier:buttonWidth
                                                               constant:0.0]];
    
    // Height
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.autocorrelationButton
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeHeight
                                                             multiplier:buttonHeight
                                                               constant:0.0]];
    
    
    // add all constraints at once
    [self addConstraints:layoutConstraints];
}

@end
