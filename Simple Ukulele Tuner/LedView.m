//
//  InfoView.m
//  Diapason
//
//  Created by imac on 13.03.15.
//  Copyright (c) 2015 Vormbrock. All rights reserved.
//

#import "LedView.h"

#define ALPHA_OFF 0.0

@interface LedView() {
    
    NSMutableArray *imageViewsArray;
    UIImage *ledBg;
    UIImage *led;
    NSInteger numberOfStrings;
    
    NSInteger activeTag;
    
    NSUserDefaults *defaults;
    CGFloat frequencyOffset;
    
    NSTimer *soundTimer;
}
@end

@implementation LedView


- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        activeTag = -1;
        
        defaults = [NSUserDefaults standardUserDefaults];
        frequencyOffset = [[defaults stringForKey:KEY_CALIBRATED_FREQUENCY] floatValue] - REF_FREQUENCY;
        
        ledBg = [UIImage imageNamed:@"ledPassive.png"];
        led = [UIImage imageNamed:@"ledActive.png"];
        //self.backgroundColor = [UIColor redColor];

        
        // input from microphone
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateLed:)
                                                     name:@"UpdateDataNotification"
                                                   object:nil];
        
        // fixed frequency from sound file (strings E A D G B E')
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateLed:)
                                                     name:@"PlayToneNotification"
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateCalFreq:)
                                                     name:@"UpdateDefaultsNotification"
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateLedGroup:)
                                                     name:@"UpdateDefaultsNotification"
                                                   object:nil];
        
        numberOfStrings = [SHARED_CONTEXT getNumberOfStrings];
        
        [self createImage];
        [self setupLedConstraints];
    }
    return self;
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
    UIImageView *view = (UIImageView*)gestureRecognizer.view;
    
    UIImageView *selectedView;
    
    // clear all green LEDs
    for (UIImageView *view in imageViewsArray) {
        if (view.tag > numberOfStrings-1) {
            view.alpha = ALPHA_OFF;
        }
    }
    
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
        activeTag = (NSInteger)view.tag;
        [SHARED_SOUND_HELPER playTone:toneNumber];
    } else {
        selectedView = imageViewsArray[view.tag];
        selectedView.alpha = ALPHA_OFF;
        [SHARED_SOUND_HELPER stopTone];
        activeTag = -1;
    }
    
    [soundTimer invalidate];

    if ([version_lite isEqualToString:[SHARED_VERSION_MANAGER getVersion]] || [version_instrument isEqualToString:[SHARED_VERSION_MANAGER getVersion]]) {
        // LITE version: tone is played only once (3s) - after that time elapsed, clear LED and enable microphone again
        soundTimer = [NSTimer scheduledTimerWithTimeInterval:NUM_SEC_PLAYTONE
                                         target:self
                                       selector:@selector(resetToneAndLed:)
                                       userInfo:view
                                        repeats:NO];
   }
}

- (void)resetToneAndLed:(NSTimer *)timer {
    UIView *view = (UIView *)[timer userInfo];
    UIView *selectedView = imageViewsArray[view.tag];
    selectedView.alpha = ALPHA_OFF;
    activeTag = -1;
    [SHARED_SOUND_HELPER stopTone];
}


#pragma mark - Notification
-(void) updateLedGroup:(NSNotification *) notification {

    numberOfStrings = [SHARED_CONTEXT getNumberOfStrings];
    
    [self createImage];
    [self setupLedConstraints];
}

-(void) updateCalFreq:(NSNotification *) notification {
    
    frequencyOffset = [[defaults stringForKey:KEY_CALIBRATED_FREQUENCY] floatValue] - REF_FREQUENCY;
}

-(void) updateLed:(NSNotification *) notification {
    
    if ([notification.object isKindOfClass:[SoundFile class]]) {
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
    } else if ([notification.object isKindOfClass:[Spectrum class]]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            // clear LEDs
            for (NSInteger i=0; i<numberOfStrings; i++) {
                ((UIView*)imageViewsArray[i+numberOfStrings]).alpha = ALPHA_OFF;
            }
            
            Spectrum* spectrum = (Spectrum*)[notification object];
            CGFloat alpha = [spectrum.alpha floatValue];
            CGFloat capturedFrequency = [spectrum.frequency floatValue] - frequencyOffset;
            
            NSArray* frequenciesArray = [SHARED_CONTEXT getFrequenciesArray];
            
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
    } else {
        NSLog(@"updateLed: error with notification type");
    }
    
}


#pragma mark -creation of images
- (void) createImage {
    
    for (UIView *view in imageViewsArray) {
        [view removeFromSuperview];
    }
    
    imageViewsArray = [[NSMutableArray alloc] initWithCapacity:numberOfStrings];
    
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
    
    
    // gesture recognizer
    NSInteger index = 0;
    for (UIImageView* view in imageViewsArray) {
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
        
        view.alpha = i > numberOfStrings ? ALPHA_OFF : 0.9;
        NSInteger num = i > numberOfStrings ? i-numberOfStrings : i;
        CGFloat len = 9.3;
        
        CGFloat offset;
        
        if (numberOfStrings == 3) {
            offset = 1.75;
        } else if (numberOfStrings == 4) {
            offset = 1.25;
        } else if (numberOfStrings == 5) {
            offset = 0.7;
        } else {
            offset = 0.25;
        }
        
        CGFloat fact = 2.5*(num + offset)/len;
        
        CGFloat width = [UIScreen mainScreen].bounds.size.width / 15.0;
        
        
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
    
    // add all constraints at once
    [self addConstraints:layoutConstraints];
}

-(void)dealloc {
    //NSLog(@"%s", __PRETTY_FUNCTION__);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
