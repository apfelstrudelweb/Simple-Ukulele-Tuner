//
//  BridgeView.m
//  Simple Guitar Tuner
//
//  Created by imac on 22.06.15.
//  Copyright (c) 2015 Vormbrock. All rights reserved.
//

#import "BridgeView.h"

@interface BridgeView()

@property (nonatomic) BOOL isWarningUp;
@property (nonatomic) BOOL isWarningDown;

@property (nonatomic) NSInteger numWarningUp;
@property (nonatomic) NSInteger numWarningDown;

@property (nonatomic, weak) NSTimer *timerUp;
@property (nonatomic, weak) NSTimer *timerDown;

@property (nonatomic) BOOL areArrowsEnabled;

@end

@implementation BridgeView


- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
#if !defined(TARGET_BANJO)
        self.ledView = [LedView new];
        [self.ledView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self addSubview:self.ledView];
        [self setupLedConstraints];
#endif
        
        self.stringButtonView = [StringButtonView new];
        [self.stringButtonView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self addSubview:self.stringButtonView];
        [self setupStringButtonConstraints];
        
        UIImage *arrowUp = [UIImage imageWithCGImage:[UIImage imageNamed:@"arrowUp.png"].CGImage];
        UIImage *arrowDown = [UIImage imageWithCGImage:[UIImage imageNamed:@"arrowDown.png"].CGImage];
        
        self.arrowUpView = [[UIImageView alloc] initWithImage:arrowUp];
        self.arrowDownView = [[UIImageView alloc] initWithImage:arrowDown];
        
        [self.arrowUpView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.arrowDownView setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        [self addSubview:self.arrowUpView];
        [self addSubview:self.arrowDownView];
        
        [self setupWarningConstraints];
        
        self.arrowUpView.alpha = 0.0;
        self.arrowDownView.alpha = 0.0;
        
        self.isWarningUp = NO;
        self.isWarningDown = NO;
        
        self.areArrowsEnabled = NO;
        
        [self checkVersion];
        
        if (self.areArrowsEnabled == YES) {
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(blinkArrowUp:)
                                                         name:@"TuneUpNotification"
                                                       object:nil];
            
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(blinkArrowDown:)
                                                         name:@"TuneDownNotification"
                                                       object:nil];
        }

    }
    return self;
}

- (void)checkVersion {
    NSString* currentVersion = [SHARED_VERSION_MANAGER getVersion];
    
    if ([version_signal isEqualToString:currentVersion] || [version_premium isEqualToString:currentVersion]) {
        self.areArrowsEnabled = YES;
    }
}

- (void) blinkArrowUp: (NSNotification *) notification {
    
    NSDictionary* userInfo = notification.userInfo;
    BOOL blink = ((NSNumber*)userInfo[@"blink"]).boolValue;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (blink == NO) {
            self.arrowUpView.alpha = 0.0;
            self.isWarningUp = NO;
            return;
        }
        
        if (self.isWarningUp == YES) return;
        self.isWarningUp = YES;

        __weak typeof(self) weakSelf = self;
        
        [UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationOptionAutoreverse|UIViewAnimationOptionRepeat animations:^{
            
            [UIView setAnimationRepeatCount:20];
            
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (strongSelf) {
                strongSelf.arrowUpView.alpha = 1.0;
            }
        } completion:^(BOOL finished){
            weakSelf.arrowUpView.alpha = 0.0;
            weakSelf.isWarningUp = NO;
        }];
        
    });
    
}

- (void) blinkArrowDown: (NSNotification *) notification {
    
    NSDictionary* userInfo = notification.userInfo;
    BOOL blink = ((NSNumber*)userInfo[@"blink"]).boolValue;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (blink == NO) {
            self.arrowDownView.alpha = 0.0;
            self.isWarningDown = NO;
            return;
        }
        
        if (self.isWarningDown == YES) return;
        self.isWarningDown = YES;
        
        __weak typeof(self) weakSelf = self;
        
        [UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationOptionAutoreverse|UIViewAnimationOptionRepeat animations:^{
            
            [UIView setAnimationRepeatCount:20];
            
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (strongSelf) {
                strongSelf.arrowDownView.alpha = 1.0;
            }
        } completion:^(BOOL finished){
            weakSelf.arrowDownView.alpha = 0.0;
            weakSelf.isWarningDown = NO;
        }];
        
    });

}


#pragma mark -constraints
- (void) setupLedConstraints {
    
    NSMutableArray *layoutConstraints = [NSMutableArray new];
    
    
    // Center vertically
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.ledView
                                                              attribute:NSLayoutAttributeBaseline
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeBaseline
                                                             multiplier:1.0
                                                               constant:0.0]];
    
    // Center horizontally
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.ledView
                                                              attribute:NSLayoutAttributeCenterX
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeCenterX
                                                             multiplier:1.0
                                                               constant:0.0]];
    
    // Width
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.ledView
                                                              attribute:NSLayoutAttributeWidth
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeWidth
                                                             multiplier:0.8
                                                               constant:0.0]];
    
    // Height
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.ledView
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeHeight
                                                             multiplier:0.45
                                                               constant:0.0]];
    
    
    // add all constraints at once
    [self addConstraints:layoutConstraints];
}

- (void) setupStringButtonConstraints {
    NSMutableArray *layoutConstraints = [NSMutableArray new];
    
#if defined(TARGET_BANJO)
    // Center vertically
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.stringButtonView
                                                              attribute:NSLayoutAttributeCenterY
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeCenterY
                                                             multiplier:1.5
                                                               constant:0.0]];
#elif (TARGET_GUITAR || TARGET_UKULELE || TARGET_BALALAIKA)
    // Center vertically
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.stringButtonView
                                                              attribute:NSLayoutAttributeBaseline
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeBaseline
                                                             multiplier:1.0
                                                               constant:0.0]];
#endif
    
    // Center horizontally
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.stringButtonView
                                                              attribute:NSLayoutAttributeCenterX
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeCenterX
                                                             multiplier:1.0
                                                               constant:0.0]];
    
    // Width
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.stringButtonView
                                                              attribute:NSLayoutAttributeWidth
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeWidth
                                                             multiplier:0.8
                                                               constant:0.0]];
    
    // Height
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.stringButtonView
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeHeight
                                                             multiplier:0.2
                                                               constant:0.0]];
    
    
    // add all constraints at once
    [self addConstraints:layoutConstraints];
}

- (void) setupWarningConstraints {
    
    NSMutableArray *layoutConstraints = [NSMutableArray new];
    
    CGFloat height = [UIScreen mainScreen].bounds.size.width / 5.5;
    CGFloat offsetX = [UIScreen mainScreen].bounds.size.width / 20.0;
    
    
    // Center vertically
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.arrowUpView
                                                              attribute:NSLayoutAttributeBaseline
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeBaseline
                                                             multiplier:1.0
                                                               constant:0.0]];
    
    // Center horizontally
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.arrowUpView
                                                              attribute:NSLayoutAttributeLeft
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeLeft
                                                             multiplier:1.0
                                                               constant:-offsetX]];
    
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.arrowUpView
                                                              attribute:NSLayoutAttributeWidth
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeWidth
                                                             multiplier:0
                                                               constant:0.7*height]];
    
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.arrowUpView
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeHeight
                                                             multiplier:0.0
                                                               constant:height]];
    
    
    // Center vertically
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.arrowDownView
                                                              attribute:NSLayoutAttributeBaseline
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeBaseline
                                                             multiplier:1.0
                                                               constant:0.0]];
    
    // Center horizontally
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.arrowDownView
                                                              attribute:NSLayoutAttributeRight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeRight
                                                             multiplier:1.0
                                                               constant:offsetX]];
    
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.arrowDownView
                                                              attribute:NSLayoutAttributeWidth
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeWidth
                                                             multiplier:0
                                                               constant:0.7*height]];
    
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.arrowDownView
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeHeight
                                                             multiplier:0.0
                                                               constant:height]];
    
    
    
    // add all constraints at once
    [self addConstraints:layoutConstraints];
}


-(void)dealloc {
    //NSLog(@"%s", __PRETTY_FUNCTION__);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
