//
//  MeterView.m
//  Simple Guitar Tuner
//
//  Created by imac on 22.06.15.
//  Copyright (c) 2015 Vormbrock. All rights reserved.
//

#import "MeterView.h"

@interface MeterView() {
    CGFloat meterWidth;
}

@end

@implementation MeterView

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        [self addSubview:self.gauge];
        [self updateWidth:nil];
        //[self setupConstraints];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateWidth:)
                                                     name:@"UpdateDefaultsNotification"
                                                   object:nil];
        
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

#pragma mark - Notification
-(void) updateWidth:(NSNotification *) notification {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString* defaultSubtype;
#if defined(TARGET_UKULELE)
    defaultSubtype = [defaults stringForKey:KEY_UKE_TYPE];
#elif defined(TARGET_GUITAR)
    defaultSubtype = [defaults stringForKey:KEY_GUITAR_TYPE];
#elif defined(TARGET_MANDOLIN)
    
#elif defined(TARGET_BANJO)
    
#elif defined(TARGET_VIOLIN)
    
#elif defined(TARGET_BALALAIKA)
    
#endif
    NSArray* frequenciesArray = [[SHARED_MANAGER getInstrumentSubtypesDictionary] objectForKey:defaultSubtype][2];
    NSInteger numberOfStrings = frequenciesArray.count;
    
    if (numberOfStrings < 6) {
        meterWidth = 0.495;
    } else {
        meterWidth = 0.66;
    }
    
    [self setupConstraints];
}

#pragma mark -layout constraints
- (void)setupConstraints {
    
    [self removeConstraints:[self constraints]];
    
    
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
                                                             multiplier:meterWidth
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
