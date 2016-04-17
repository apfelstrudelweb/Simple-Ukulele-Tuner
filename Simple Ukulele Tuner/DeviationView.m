//
//  OctaveView.m
//  Simple Guitar Tuner
//
//  Created by imac on 22.06.15.
//  Copyright (c) 2015 Vormbrock. All rights reserved.
//

#import "DeviationView.h"

#define OCTAVE_COLOR [UIColor colorWithRed:172.0/255.0 green:174.0/255.0 blue:178.0/255.0 alpha:1.0]
#define BLANK_LED_COLOR [UIColor colorWithRed:79.0/255.0 green:82.0/255.0 blue:90.0/255.0 alpha:1.0]

#define OK_COLOR [UIColor colorWithRed:0.00 green:1.00 blue:0.00 alpha:1.0]
#define OK_COLOR_HALF [UIColor colorWithRed:0.00 green:1.00 blue:0.00 alpha:0.5]
#define OK_COLOR_QUART [UIColor colorWithRed:0.00 green:1.00 blue:0.00 alpha:0.25]

@interface DeviationView() {
    CGFloat shadowRadius, shadowOffset;
    
    NSMutableArray *imageViewsArray;
}
@end


@implementation DeviationView


- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
   
        shadowRadius = IS_IPAD ? 0.4 : 0.2;
        shadowOffset = IS_IPAD ? 0.7 : 0.5;
        
        [self createImage];
        [self createLabel];
        [self setupConstraints];
        
        
        // input coming from microphone
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateInfoPanel:)
                                                     name:@"UpdateDataNotification"
                                                   object:nil];
        // fixed frequency from sound file (strings E A D G B E')
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateInfoPanel:)
                                                     name:@"PlayToneNotification"
                                                   object:nil];
        
    }
    return self;
}

#pragma mark -creation of images
- (void) createLabel {
    self.toneLabel = [UILabel new];
    self.toneLabel.textAlignment = NSTextAlignmentLeft;
    self.toneLabel.textColor = [UIColor greenColor];
    [self.toneLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    self.toneLabel.font = [UIFont fontWithName:FONT_BOLD size:[UILabel getFontSizeForHeadline]];
    
    self.toneLabel.text = @"";
    
    [self addSubview:self.toneLabel];
}


- (void) createImage {

    
    imageViewsArray = [NSMutableArray new];
    
    // green LED
    self.devView_center = [UIView new];
    self.devView_center.backgroundColor = BLANK_LED_COLOR;
    [self.devView_center setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addSubview:self.devView_center];
    [imageViewsArray addObject:self.devView_center];
    
    // "tune up"
    self.devView_m3 = [UIView new];
    self.devView_m3.backgroundColor = BLANK_LED_COLOR;
    [self.devView_m3 setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addSubview:self.devView_m3];
    [imageViewsArray addObject:self.devView_m3];
    
    self.devView_m2 = [UIView new];
    self.devView_m2.backgroundColor = BLANK_LED_COLOR;
    [self.devView_m2 setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addSubview:self.devView_m2];
    [imageViewsArray addObject:self.devView_m2];
    
    self.devView_m1 = [UIView new];
    self.devView_m1.backgroundColor = BLANK_LED_COLOR;
    [self.devView_m1 setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addSubview:self.devView_m1];
    [imageViewsArray addObject:self.devView_m1];
    
    // "tune down"
    self.devView_p1 = [UIView new];
    self.devView_p1.backgroundColor = BLANK_LED_COLOR;
    [self.devView_p1 setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addSubview:self.devView_p1];
    [imageViewsArray addObject:self.devView_p1];
    
    self.devView_p2 = [UIView new];
    self.devView_p2.backgroundColor = BLANK_LED_COLOR;
    [self.devView_p2 setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addSubview:self.devView_p2];
    [imageViewsArray addObject:self.devView_p2];
    
    self.devView_p3 = [UIView new];
    self.devView_p3.backgroundColor = BLANK_LED_COLOR;
    [self.devView_p3 setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addSubview:self.devView_p3];
    [imageViewsArray addObject:self.devView_p3];
}

#pragma mark - Notification
-(void) updateInfoPanel:(NSNotification *) notification {
    
    if ([notification.object isKindOfClass:[Spectrum class]]) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            Spectrum* spect = (Spectrum*)[notification object];
            NSInteger deviation = [spect.deviation integerValue];
            BOOL isNegativeDeviation = spect.isNegativeDeviation;
            CGFloat frequency = [spect.frequency floatValue];

            
            [self resetDisplays];
            
            if (spect.isOutOfRange == YES) {
                return;
            }

            if (deviation > 3) return;
            
            if (frequency > 0.0 && isNegativeDeviation == YES) {
                if (deviation == 3) {
                    self.devView_m3.backgroundColor = [UIColor redColor];
                    self.devView_m2.backgroundColor = [UIColor redColor];
                    self.devView_m1.backgroundColor = [UIColor redColor];
                } else if (deviation == 2) {
                    self.devView_m2.backgroundColor = [UIColor redColor];
                    self.devView_m1.backgroundColor = [UIColor redColor];
                    self.devView_center.backgroundColor = OK_COLOR_QUART;
                } else if (deviation == 1) {
                    self.devView_m1.backgroundColor = [UIColor redColor];
                    self.devView_center.backgroundColor = OK_COLOR_HALF;
                } else {
                    self.devView_center.backgroundColor = OK_COLOR;
                }
            } else if (frequency > 0.0 && isNegativeDeviation == NO) {
                if (deviation == 3) {
                    self.devView_p3.backgroundColor = [UIColor redColor];
                    self.devView_p2.backgroundColor = [UIColor redColor];
                    self.devView_p1.backgroundColor = [UIColor redColor];
                } else if (deviation == 2) {
                    self.devView_p2.backgroundColor = [UIColor redColor];
                    self.devView_p1.backgroundColor = [UIColor redColor];
                    self.devView_center.backgroundColor = OK_COLOR_QUART;
                } else if (deviation == 1) {
                    self.devView_p1.backgroundColor = [UIColor redColor];
                    self.devView_center.backgroundColor = OK_COLOR_HALF;
                } else {
                    self.devView_center.backgroundColor = OK_COLOR;
                }
            }
            
            self.toneLabel.text = [NSString stringWithFormat:@"%@%@", spect.toneName, spect.octave];
            
            if (frequency > 0.0 && deviation > 0) {
                self.toneLabel.textColor = [UIColor redColor];
            } else if (frequency > 0.0 && deviation == 0) {
                self.toneLabel.textColor = OK_COLOR;;
            } else {
                 self.toneLabel.text = @"";
            }


        });
    } else if ([notification.object isKindOfClass:[SoundFile class]]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
             [self resetDisplays];
            
            SoundFile* sf = (SoundFile*)[notification object];

            if (sf.isActive == YES) {
                self.devView_center.backgroundColor = [UIColor greenColor];
            } 
            
        });
    } else {
        NSLog(@"Error, object not recognised.");
        self.devView_center.backgroundColor = BLANK_LED_COLOR;
    }
}

- (void) resetDisplays {
    self.devView_m3.backgroundColor = BLANK_LED_COLOR;
    self.devView_m2.backgroundColor = BLANK_LED_COLOR;
    self.devView_m1.backgroundColor = BLANK_LED_COLOR;
    self.devView_center.backgroundColor = BLANK_LED_COLOR;
    self.devView_p3.backgroundColor = BLANK_LED_COLOR;
    self.devView_p2.backgroundColor = BLANK_LED_COLOR;
    self.devView_p1.backgroundColor = BLANK_LED_COLOR;
    self.toneLabel.text = @"";
}

#pragma mark - layout constraints
- (void)setupConstraints {
    
    NSMutableArray *layoutConstraints = [NSMutableArray new];
    
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.toneLabel
                                                              attribute:NSLayoutAttributeCenterY
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeCenterY
                                                             multiplier:1.0
                                                               constant:0.0]];
    
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.toneLabel
                                                              attribute:NSLayoutAttributeCenterX
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeCenterX
                                                             multiplier:1.8
                                                               constant:0.0]];
    
    for (UIView *view in imageViewsArray) {
        
        view.layer.cornerRadius = IS_IPAD ? 8.0 : 4.0;
        view.layer.masksToBounds = YES;
        
        
        // Center vertically
        [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:view
                                                                  attribute:NSLayoutAttributeCenterY
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self
                                                                  attribute:NSLayoutAttributeCenterY
                                                                 multiplier:1.0
                                                                   constant:0.0]];
        
        [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:view
                                                                  attribute:NSLayoutAttributeWidth
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self
                                                                  attribute:NSLayoutAttributeWidth
                                                                 multiplier:0.05
                                                                   constant:0.0]];
        
        [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:view
                                                                  attribute:NSLayoutAttributeHeight
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:view
                                                                  attribute:NSLayoutAttributeWidth
                                                                 multiplier:1.0
                                                                   constant:0.0]];

    }
    
    // GREEN LED
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.devView_m3
                                                              attribute:NSLayoutAttributeCenterX
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeCenterX
                                                             multiplier:0.55
                                                               constant:0.0]];
    
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.devView_m2
                                                              attribute:NSLayoutAttributeCenterX
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeCenterX
                                                             multiplier:0.7
                                                               constant:0.0]];
    
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.devView_m1
                                                              attribute:NSLayoutAttributeCenterX
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeCenterX
                                                             multiplier:0.85
                                                               constant:0.0]];
    

    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.devView_center
                                                              attribute:NSLayoutAttributeCenterX
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeCenterX
                                                             multiplier:1.0
                                                               constant:0.0]];
    
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.devView_p1
                                                              attribute:NSLayoutAttributeCenterX
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeCenterX
                                                             multiplier:1.15
                                                               constant:0.0]];
    
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.devView_p2
                                                              attribute:NSLayoutAttributeCenterX
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeCenterX
                                                             multiplier:1.3
                                                               constant:0.0]];
    
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.devView_p3
                                                              attribute:NSLayoutAttributeCenterX
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeCenterX
                                                             multiplier:1.45
                                                               constant:0.0]];
    

    
    // add all constraints at once
    [self addConstraints:layoutConstraints];
    
}


-(void)dealloc {
    //NSLog(@"%s", __PRETTY_FUNCTION__);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
