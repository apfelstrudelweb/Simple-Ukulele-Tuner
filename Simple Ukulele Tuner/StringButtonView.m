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
        [self createImage];
        [self setupLedConstraints];
        
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
        
    }
    return self;
}

-(void)populateStringsArray {
    
    NSString* defaultUkeType = [defaults stringForKey:KEY_UKE_TYPE];
    NSArray *stringSplitArray = [defaultUkeType componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"("]];
    //NSString* ukeTypeName = stringSplitArray[0];
    NSString* fullString = stringSplitArray[1];
    NSString* ukeTypeNotes = [fullString substringToIndex:fullString.length-1];
    ukeTypeNotes = [ukeTypeNotes stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSArray* tempStringsArray = [ukeTypeNotes componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"-"]];
    
    stringsArray = [NSMutableArray new];
    // remove octaves
    for (NSString* _note in tempStringsArray) {
        NSString* note = [_note substringToIndex:_note.length-1];
        [stringsArray addObject:note];
    }
    
    //now set index of uke for sound processing later
    NSArray* ukeTypesArray = [SHARED_MANAGER getUkuleleTypesArray];
    NSInteger index = 0;
    
    for (NSString* type in ukeTypesArray) {
        NSString* trimmedUkeType = [type stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSString* trimmedDefaultUkeType = [defaultUkeType stringByReplacingOccurrencesOfString:@" " withString:@""];
        
        if ([trimmedUkeType isEqualToString:trimmedDefaultUkeType]) {
            [SHARED_MANAGER setActualNumberOfUkeType:index];
        }
        index++;
    }
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
        if (view.tag > NUMBER_OF_STRINGS-1) {
            view.alpha = ALPHA_OFF;
        }
    }
    
    //NSLog(@"tag:%ld", (long)view.tag);
    
    // Attention: this piece of code only works in conjunction with enlarged hit area!!!
    NSInteger actualTag = (NSInteger) view.tag;
    NSInteger toneNumber = actualTag - NUMBER_OF_STRINGS;
    
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
    
    if ([version_lite isEqualToString:[SHARED_VERSION_MANAGER getVersion]] || [version_uke isEqualToString:[SHARED_VERSION_MANAGER getVersion]]) {
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
    
    [self populateStringsArray];
    
    NSInteger index = 0;
    
    for (UIView* subview in self.subviews) {
        if ([subview isKindOfClass:[UILabel class]]) {
            UILabel* label = (UILabel*) subview;
            label.text = stringsArray[index];
            index++;
        }
    }
}

-(void) updateStringButton:(NSNotification *) notification {
    
    if ([notification.object isKindOfClass:[Spectrum class]])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            
            // clear LEDs
            for (NSInteger i=0; i<NUMBER_OF_STRINGS; i++) {
                ((UIView*)imageViewsArray[i+NUMBER_OF_STRINGS]).alpha = ALPHA_OFF;
            }
            
            Spectrum* spectrum = (Spectrum*)[notification object];
            CGFloat alpha = [spectrum.alpha floatValue];
            CGFloat capturedFrequency = [spectrum.frequency floatValue] - frequencyOffset;
            
            NSArray* frequenciesArray = [SHARED_MANAGER getUkuleleFrequencies];
            
            for (NSInteger i=0; i<frequenciesArray.count; i++) {
                CGFloat nominalFrequency = [frequenciesArray[i] floatValue];
                
                CGFloat upperLimit = 0.49 * nominalFrequency * (TONE_DIST - 1.0);
                CGFloat lowerLimit = 0.49 * nominalFrequency * (TONE_DIST - 1.0) / TONE_DIST;
                
                if (fabs(capturedFrequency - nominalFrequency) < upperLimit ||  fabs(nominalFrequency - capturedFrequency) < lowerLimit) {
                    ((UIView*)imageViewsArray[i+NUMBER_OF_STRINGS]).alpha = alpha;
                }
                
            }
            
        });
    } else if ([notification.object isKindOfClass:[SoundFile class]]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            // clear LEDs
            for (NSInteger i=0; i<NUMBER_OF_STRINGS; i++) {
                ((UIView*)imageViewsArray[i+NUMBER_OF_STRINGS]).alpha = ALPHA_OFF;
            }
            
            SoundFile* sf = (SoundFile*)[notification object];
            NSInteger toneNumber = [sf.toneNumber intValue];
            
            if (sf.isActive) {
                ((UIView*)imageViewsArray[toneNumber+NUMBER_OF_STRINGS]).alpha = 1.0;
            }
            
        });
    } else {
        NSLog(@"updateStringButton: error with notification type");
    }
}


#pragma mark -creation of images

- (void) createImage {
    
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
    NSMutableArray *layoutConstraints = [NSMutableArray new];
    
    NSInteger i=1;
    
    for (UIView* view in imageViewsArray) {
        
        view.alpha = i>NUMBER_OF_STRINGS ? ALPHA_OFF : 0.9;
        NSInteger num = i>NUMBER_OF_STRINGS ? i-NUMBER_OF_STRINGS : i;
        CGFloat len = 9.3;
        CGFloat fact = 2.5*(num+1.25)/len;
        
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
