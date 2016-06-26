//
//  StringButtonView.m
//  Simple Guitar Tuner
//
//  Created by imac on 30.06.15.
//  Copyright (c) 2015 Vormbrock. All rights reserved.
//

#import "StringButtonView.h"


#define ALPHA_OFF 0.0
#define LABEL_COLOR [UIColor colorWithRed:0.13 green:0.13 blue:0.13 alpha:1.0]


@interface StringButtonView() {
    //float imageWidth;
    NSMutableArray *imageViewsArray;
    NSMutableArray *labelsArray;
    NSMutableArray *stringsArray;
    UIImage *ledBg;
    UIImage *led;
    
    CGFloat shadowRadius, shadowOffset;
    
    NSInteger activeTag;
    
    NSUserDefaults *defaults;
    NSInteger numberOfStrings;
    CGFloat frequencyOffset;
    
}
@end

@implementation StringButtonView


- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        activeTag = -1;
        
        shadowRadius = IS_IPAD ? 0.4 : 0.2;
        shadowOffset = IS_IPAD ? 0.7 : 0.5;
        
        defaults = [NSUserDefaults standardUserDefaults];
        frequencyOffset = [[defaults stringForKey:KEY_CALIBRATED_FREQUENCY] floatValue] - REF_FREQUENCY;
        
        [self populateStringsArray];
        
        ledBg = [UIImage imageNamed:@"stringPassive.png"];
        led = [UIImage imageNamed:@"stringActive.png"];

        
        // input from microphone
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateStringButton:)
                                                     name:@"UpdateDataNotification"
                                                   object:nil];
        
        // fixed frequency from sound file (strings E A D G B E')
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateStringButton:)
                                                     name:@"PlayToneNotification"
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateToneLabels:)
                                                     name:@"UpdateDefaultsNotification"
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateCalFreq:)
                                                     name:@"UpdateCalibratedFrequencyNotification"
                                                   object:nil];
        
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
        numberOfStrings = frequenciesArray.count;
        
        [self createImage];
        [self setupLedConstraints];
        
    }
    return self;
}

-(void)populateStringsArray {
    
    NSString* defaultSubType;
    
#if defined(TARGET_UKULELE)
    defaultSubType = [defaults stringForKey:KEY_UKE_TYPE];
#elif defined(TARGET_GUITAR)
    defaultSubType = [defaults stringForKey:KEY_GUITAR_TYPE];
#elif defined(TARGET_MANDOLIN)
    
#elif defined(TARGET_BANJO)
    
#elif defined(TARGET_VIOLIN)
    
#elif defined(TARGET_BALALAIKA)
    
#endif
    
    stringsArray = [[SHARED_MANAGER getInstrumentSubtypesDictionary] objectForKey:defaultSubType][1];
}


#pragma mark - gesture recognizer
// event handler for playing tones in a loop
-(void)tapDetected:(UITapGestureRecognizer *)gestureRecognizer {
    
    // if sound is captured by microphone, disable synthetic sound from device
    if ([SHARED_MANAGER isSoundCapturingEnabled]) {
        //NSLog(@"No led touch!");
        return;
    }
    
    //Get the View
    HitImageView *view = (HitImageView*)gestureRecognizer.view;
    HitImageView *selectedView;
    
    // clear all green LEDs
    for (HitImageView *view in imageViewsArray) {
        if (view.tag > numberOfStrings-1) {
            view.alpha = ALPHA_OFF;
        }
    }
    
    //NSLog(@"tag:%ld", (long)view.tag);
    
    // Attention: this piece of code only works in conjunction with enlarged hit area!!!
    NSInteger actualTag = (NSInteger) view.tag;
    NSInteger toneNumber = actualTag - numberOfStrings;
    
    if ([SHARED_MANAGER isSoundPlaying]) {
        selectedView = imageViewsArray[view.tag];
        selectedView.alpha = ALPHA_OFF;
        [SHARED_SOUND_HELPER stopTone];
        // if user hits button again, stop
        if (actualTag == activeTag) {
            activeTag = -1;
            return;
        }
    }
    
    if (actualTag != activeTag) {
        selectedView = imageViewsArray[view.tag];
        selectedView.alpha = 1.0;
        activeTag = (int)view.tag;
        [SHARED_SOUND_HELPER playTone:toneNumber];
    } else {
        selectedView = imageViewsArray[view.tag];
        selectedView.alpha = ALPHA_OFF;
        [SHARED_SOUND_HELPER stopTone];
        activeTag = -1;
    }
    
    if ([version_lite isEqualToString:[SHARED_VERSION_MANAGER getVersion]] || [version_instrument isEqualToString:[SHARED_VERSION_MANAGER getVersion]]) {
        // LITE version: tone is played only once (3s) - after that time elapsed, clear LED and enable microphone again
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, NUM_SEC_PLAYTONE);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            UIView* selectedView = imageViewsArray[view.tag];
            selectedView.alpha = ALPHA_OFF;
            activeTag = -1;
            [SHARED_SOUND_HELPER stopTone];
            return;
        });
    }
    
}

#pragma mark - Notification
-(void) updateCalFreq:(NSNotification *) notification {
    
    frequencyOffset = [[defaults stringForKey:KEY_CALIBRATED_FREQUENCY] floatValue] - REF_FREQUENCY;
}

-(void) updateToneLabels:(NSNotification *) notification {
    
    for (UIView* subview in self.subviews) {
        if ([subview isKindOfClass:[UILabel class]]) {
            [subview removeFromSuperview];
        }
    }
    
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
    numberOfStrings = frequenciesArray.count;
    
    [self populateStringsArray];
    
    int index = 0;
    
    for (UIView* subview in self.subviews) {
        if ([subview isKindOfClass:[UILabel class]]) {
            UILabel* label = (UILabel*) subview;
            label.text = stringsArray[index];
            index++;
            if (index == numberOfStrings) break;
        }
    }
    
    [self createImage];
    [self setupLedConstraints];
}

-(void) updateStringButton:(NSNotification *) notification {
    
    if ([notification.object isKindOfClass:[Spectrum class]])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            
            // clear LEDs
            for (NSInteger i=0; i<numberOfStrings; i++) {
                ((UIView*)imageViewsArray[i+numberOfStrings]).alpha = ALPHA_OFF;
            }
            
            Spectrum* spectrum = (Spectrum*)[notification object];
            CGFloat alpha = [spectrum.alpha floatValue];
            CGFloat capturedFrequency = [spectrum.frequency floatValue] - frequencyOffset;
            
            NSString* defaultUkeType = [defaults stringForKey:KEY_UKE_TYPE];
            NSArray* frequenciesArray = [[SHARED_MANAGER getInstrumentSubtypesDictionary] objectForKey:defaultUkeType][2];
            
            for (NSInteger i=0; i<frequenciesArray.count; i++) {
                CGFloat nominalFrequency = [frequenciesArray[i] floatValue];
                
                CGFloat upperLimit = 0.49 * nominalFrequency * (TONE_DIST - 1.0);
                CGFloat lowerLimit = 0.49 * nominalFrequency * (TONE_DIST - 1.0) / TONE_DIST;
                
                if (fabs(capturedFrequency - nominalFrequency) < upperLimit ||  fabs(nominalFrequency - capturedFrequency) < lowerLimit) {
                    NSInteger num = i+numberOfStrings;
                    if (num >= imageViewsArray.count) return;
                    ((UIView*)imageViewsArray[i+numberOfStrings]).alpha = alpha;
                }
                
            }
            
        });
    } else if ([notification.object isKindOfClass:[SoundFile class]]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            // clear LEDs
            for (NSInteger i=0; i<numberOfStrings; i++) {
                ((UIView*)imageViewsArray[i+numberOfStrings]).alpha = ALPHA_OFF;
            }
            
            SoundFile* sf = (SoundFile*)[notification object];
            NSInteger toneNumber = [sf.toneNumber intValue];
            
            if (sf.isActive) {
                ((UIView*)imageViewsArray[toneNumber+numberOfStrings]).alpha = 1.0;
            }
            
        });
    } else {
        NSLog(@"updateStringButton: error with notification type");
    }
}


#pragma mark -creation of images

- (void) createImage {
    
    for (UIView *view in imageViewsArray) {
        [view removeFromSuperview];
    }
    
    imageViewsArray = [NSMutableArray new];
    
    // Backgrounds
    UIImage* _ledBg = [UIImage imageWithCGImage:ledBg.CGImage]; // trick for @2x.png
    
    
    self.imageViewBg_1 = [[HitImageView alloc] initWithImage:_ledBg];
    [self.imageViewBg_1 setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addSubview:self.imageViewBg_1];
    [imageViewsArray addObject:self.imageViewBg_1];
    
    self.imageViewBg_2 = [[HitImageView alloc] initWithImage:_ledBg];
    [self.imageViewBg_2 setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addSubview:self.imageViewBg_2];
    [imageViewsArray addObject:self.imageViewBg_2];
    
    self.imageViewBg_3 = [[HitImageView alloc] initWithImage:_ledBg];
    [self.imageViewBg_3 setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addSubview:self.imageViewBg_3];
    [imageViewsArray addObject:self.imageViewBg_3];
    
    self.imageViewBg_4 = [[HitImageView alloc] initWithImage:_ledBg];
    [self.imageViewBg_4 setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addSubview:self.imageViewBg_4];
    [imageViewsArray addObject:self.imageViewBg_4];
    
    if (numberOfStrings > 4) {
        self.imageViewBg_5 = [[HitImageView alloc] initWithImage:_ledBg];
        [self.imageViewBg_5 setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self addSubview:self.imageViewBg_5];
        [imageViewsArray addObject:self.imageViewBg_5];
    }
    
    if (numberOfStrings > 5) {
        self.imageViewBg_6 = [[HitImageView alloc] initWithImage:_ledBg];
        [self.imageViewBg_6 setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self addSubview:self.imageViewBg_6];
        [imageViewsArray addObject:self.imageViewBg_6];
    }
    
    
    // LEDs
    UIImage* _led = [UIImage imageWithCGImage:led.CGImage];
    
    
    self.imageView_1 = [[HitImageView alloc] initWithImage:_led];
    [self.imageView_1 setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addSubview:self.imageView_1];
    [imageViewsArray addObject:self.imageView_1];
    
    self.imageView_2 = [[HitImageView alloc] initWithImage:_led];
    [self.imageView_2 setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addSubview:self.imageView_2];
    [imageViewsArray addObject:self.imageView_2];
    
    self.imageView_3 = [[HitImageView alloc] initWithImage:_led];
    [self.imageView_3 setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addSubview:self.imageView_3];
    [imageViewsArray addObject:self.imageView_3];
    
    self.imageView_4 = [[HitImageView alloc] initWithImage:_led];
    [self.imageView_4 setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addSubview:self.imageView_4];
    [imageViewsArray addObject:self.imageView_4];
    
    if (numberOfStrings > 4) {
        self.imageView_5 = [[HitImageView alloc] initWithImage:_led];
        [self.imageView_5 setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self addSubview:self.imageView_5];
        [imageViewsArray addObject:self.imageView_5];
    }
    
    if (numberOfStrings > 5) {
        self.imageView_5 = [[HitImageView alloc] initWithImage:_led];
        [self.imageView_5 setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self addSubview:self.imageView_5];
        [imageViewsArray addObject:self.imageView_5];
    }
    
    labelsArray = [NSMutableArray new];
    
    for (NSString* toneName in stringsArray) {
        UILabel *label = [UILabel new];
        NSString* buttonTitle = toneName;
        [label setText:buttonTitle];
        [label setFont:[UIFont fontWithName:FONT_BOLD size:[UILabel getFontSizeForTabButton]]];
        [label setTextColor:LABEL_COLOR];
        label.textAlignment = NSTextAlignmentCenter;
        [label setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        label.layer.shadowColor = [UIColor lightGrayColor].CGColor;
        label.layer.shadowRadius = shadowRadius;
        label.layer.shadowOpacity = 1;
        label.layer.shadowOffset = CGSizeMake(shadowOffset, shadowOffset);
        label.layer.masksToBounds = NO;
        
        [labelsArray addObject:label];
        
        [self addSubview:label];
    }
    
    // gesture recognizer
    NSInteger index = 0;
    for (HitImageView* view in imageViewsArray) {
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDetected:)];
        singleTap.numberOfTapsRequired = 1;
        [view setUserInteractionEnabled:YES];
        [view addGestureRecognizer:singleTap];
        view.tag = index;
        
        index++;
    }
    
}


- (void) setupLedConstraints {
    
    [self removeConstraints:[self constraints]];
    
    NSMutableArray *layoutConstraints = [NSMutableArray new];
    
    NSInteger i=1;
    
    for (UIView* view in imageViewsArray) {
        
        view.alpha = i>numberOfStrings ? ALPHA_OFF : 0.9;
        NSInteger num = i>numberOfStrings ? i-numberOfStrings : i;
        CGFloat len = 9.3;
        CGFloat offset;
        
        if (numberOfStrings == 4) {
            offset = 1.25;
        } else if (numberOfStrings == 5) {
            offset = 0.7;
        } else {
            offset = 0.25;
        }
        
        CGFloat fact = 2.5*(num + offset)/len;
        
        CGFloat width = [UIScreen mainScreen].applicationFrame.size.width / 15.0;
        
        // Center horizontally
        [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:view
                                                                  attribute:NSLayoutAttributeCenterX
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self
                                                                  attribute:NSLayoutAttributeCenterX
                                                                 multiplier:fact
                                                                   constant:0]];
        
        // Center vertically
        [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:view
                                                                  attribute:NSLayoutAttributeTop
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self
                                                                  attribute:NSLayoutAttributeTop
                                                                 multiplier:1.0
                                                                   constant:0.0]];
        
        [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:view
                                                                  attribute:NSLayoutAttributeWidth
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self
                                                                  attribute:NSLayoutAttributeWidth
                                                                 multiplier:0
                                                                   constant:width]];
        
        [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:view
                                                                  attribute:NSLayoutAttributeHeight
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self
                                                                  attribute:NSLayoutAttributeHeight
                                                                 multiplier:0.0
                                                                   constant:width]];
        
        i++;
    }
    
    i = 0;
    
    for (UIView* view in labelsArray) {
        
        
        UIView* referenceView = imageViewsArray[i];
        
        // Center horizontally
        [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:view
                                                                  attribute:NSLayoutAttributeCenterX
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:referenceView
                                                                  attribute:NSLayoutAttributeCenterX
                                                                 multiplier:1.0
                                                                   constant:0]];
        
        // Center vertically
        [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:view
                                                                  attribute:NSLayoutAttributeCenterY
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:referenceView
                                                                  attribute:NSLayoutAttributeCenterY
                                                                 multiplier:0.9
                                                                   constant:0.0]];
        
        // Width
        [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:view
                                                                  attribute:NSLayoutAttributeWidth
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:referenceView
                                                                  attribute:NSLayoutAttributeWidth
                                                                 multiplier:1.0
                                                                   constant:0.0]];
        
        // Height
        [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:view
                                                                  attribute:NSLayoutAttributeHeight
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:referenceView
                                                                  attribute:NSLayoutAttributeHeight
                                                                 multiplier:1.0
                                                                   constant:0.0]];
        
        i++;
    }
    
    // add all constraints at once
    [self addConstraints:layoutConstraints];
}

-(void)dealloc {
    //NSLog(@"%s", __PRETTY_FUNCTION__);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
