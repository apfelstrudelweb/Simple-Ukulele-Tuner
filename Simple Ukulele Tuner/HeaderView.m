//
//  HeaderView.m
//  Diapason
//
//  Created by imac on 13.03.15.
//  Copyright (c) 2015 Vormbrock. All rights reserved.
//

#import "HeaderView.h"

#define ALPHA_OFF 0.2
#define COLOR_440       [UIColor colorWithRed:0.773 green:0.529 blue:0.384 alpha:1]
#define COLOR_NOT_440   [UIColor colorWithRed:0.133 green:0.824 blue:0.141 alpha:1]

@interface HeaderView() {
    NSString *strHz;
    
    BOOL isFrequencyEnabled;
    NSUserDefaults *defaults;
    CGFloat calibrationFrequency;
}
@end

@implementation HeaderView



- (id)init {
    return [self initWithFrame:CGRectZero];
}


- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        [self checkVersion];
        
        defaults = [NSUserDefaults standardUserDefaults];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateVersion:)
                                                     name:@"UpdateVersionNotification"
                                                   object:nil];
        
        strHz = [NSString stringWithFormat:NSLocalizedString(@"lbl_hertz", @"unit Hz")];
        

        // headline
        self.frequencyLabel = [[UILabel alloc] initWithFrame:frame];
        self.frequencyLabel.textAlignment = NSTextAlignmentCenter;
        self.frequencyLabel.textColor = TEXT_COLOR_HEADER;
        [self.frequencyLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        self.frequencyLabel.text = [NSString stringWithFormat:@"%.01f %@", 0.0, strHz];

        self.frequencyLabel.font = [UIFont fontWithName:FONT_BOLD size:[UILabel getFontSizeForHeadline]];
        
        NSMutableAttributedString *notifyingStr = [[NSMutableAttributedString alloc] initWithString:self.frequencyLabel.text];
        [notifyingStr beginEditing];
        [notifyingStr addAttribute:NSFontAttributeName
                             value:[UIFont fontWithName:@"AppleGothic" size:0.9*[UILabel getFontSizeForHeadline]]
                             range:NSMakeRange(self.frequencyLabel.text.length-2,2)];
        [notifyingStr endEditing];
        
        self.frequencyLabel.attributedText = notifyingStr;
        
        [self addSubview:self.frequencyLabel];
        
        self.diffLabel = [[UILabel alloc] initWithFrame:frame];
        self.diffLabel.textAlignment = NSTextAlignmentLeft;
        self.diffLabel.textColor = TEXT_COLOR_HEADER;
        [self.diffLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        //self.diffLabel.text = [NSString stringWithFormat:@"%.01f %@", 0.0, strHz];
        self.diffLabel.font = [UIFont fontWithName:FONT size:[UILabel getFontSizeForSubHeadline]];
        
        self.frequencyLabel.alpha = isFrequencyEnabled==YES ? 1.0 : ALPHA_OFF;
        self.diffLabel.alpha = isFrequencyEnabled==YES ? 1.0 : ALPHA_OFF;
        
        [self addSubview:self.diffLabel];
        
        // info icon (button)
        [self addSubview:self.infoIconView];
        
        calibrationFrequency = [[defaults stringForKey:KEY_CALIBRATED_FREQUENCY] floatValue];
        self.calibrationLabel = [[UILabel alloc] initWithFrame:frame];
        self.calibrationLabel.textAlignment = NSTextAlignmentCenter;
        self.calibrationLabel.textColor = (calibrationFrequency == 440.0) ? COLOR_440 : COLOR_NOT_440;
        [self.calibrationLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        NSString *fontName = (calibrationFrequency == 440.0) ? FONT : FONT_BOLD;
        self.calibrationLabel.font = [UIFont fontWithName:fontName size:[UILabel getFontSizeForSubHeadline]];
        
        NSString *plus = (calibrationFrequency > 440.0) ? @"+" : @"";
        self.calibrationLabel.text = [NSString stringWithFormat:@"%.1f %@ (%@%.01f)", calibrationFrequency, strHz, plus, calibrationFrequency-440.0];
        
        [self addSubview:self.calibrationLabel];
        
        [self setupLabelConstraints];
        
        
        // frequency from mic
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateFrequency:)
                                                     name:@"UpdateDataNotification"
                                                   object:nil];
        // fixed frequency from sound file (strings E A D G B E')
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateFrequency:)
                                                     name:@"PlayToneNotification"
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateCalibratedFrequency:)
                                                     name:@"UpdateCalibratedFrequencyNotification"
                                                   object:nil];
        

    }
    return self;
}

- (void)checkVersion {
    NSString* currentVersion = [SHARED_VERSION_MANAGER getVersion];
    
    if ([version_signal isEqualToString:currentVersion] || [version_premium isEqualToString:currentVersion]) {
        isFrequencyEnabled = YES;
    }
}

#pragma mark - Notification
- (void) updateVersion:(NSNotification *) notification {
    
    [self checkVersion];
    
    self.frequencyLabel.alpha = isFrequencyEnabled==YES ? 1.0 : ALPHA_OFF;
    self.diffLabel.alpha = isFrequencyEnabled==YES ? 1.0 : ALPHA_OFF;
    
    [self setNeedsDisplay];
}

- (InfoIconView *) infoIconView {
    if (_infoIconView == nil) {
        _infoIconView = [InfoIconView new];
        [_infoIconView setTranslatesAutoresizingMaskIntoConstraints:NO];
    }
    return _infoIconView;
}


#pragma mark - Notification
- (void)updateCalibratedFrequency:(NSNotification *) notification  {
    
    if ([notification.object isKindOfClass:[NSNumber class]]) {
        calibrationFrequency = [((NSNumber*)[notification object]) floatValue];
        
        NSString *plus = (calibrationFrequency > 440.0) ? @"+" : @"";
        self.calibrationLabel.text = [NSString stringWithFormat:@"%.1f %@ (%@%.01f)", calibrationFrequency, strHz, plus, calibrationFrequency-440.0];
        
        self.calibrationLabel.textColor = (calibrationFrequency == 440.0) ? COLOR_440 : COLOR_NOT_440;
        NSString *fontName = (calibrationFrequency == 440.0) ? FONT : FONT_BOLD;
        self.calibrationLabel.font = [UIFont fontWithName:fontName size:[UILabel getFontSizeForSubHeadline]];
        
    }
}

-(void) updateFrequency:(NSNotification *) notification
{
    // don't display frequencies in lite or uke version
    if (isFrequencyEnabled == NO) return;
    
    if ([notification.object isKindOfClass:[Spectrum class]]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSNumber *freq = ((Spectrum*)[notification object]).frequency;
            NSNumber *stringfreq = ((Spectrum*)[notification object]).stringFrequency;
            CGFloat frequency = [freq floatValue];
            CGFloat calibrationOffset = calibrationFrequency - REF_FREQUENCY;
            CGFloat stringFrequency = [stringfreq floatValue];
            CGFloat diff = stringFrequency - frequency + calibrationOffset;
            if (frequency == 0.0) {
                diff = 0.0;
            }
            self.frequencyLabel.text = [NSString stringWithFormat:@"%.01f %@", frequency, strHz];
            UniChar ucode;
            if (diff>0) {
                ucode = 0x2191; // arrow up
            } else {
                ucode = 0x2193; // arrow down
            }
            
            if (fabs(diff)<0.05) {
                ucode = 0x2713; // haken
            }

            NSString* additionalInfo = [NSString stringWithCharacters:&ucode length:1];
            self.diffLabel.text = frequency > 0.0 ? [NSString stringWithFormat:@"%@%.01f %@", additionalInfo, fabs(diff), strHz] : @"";
        });
    } else if ([notification.object isKindOfClass:[SoundFile class]]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSNumber *freq = ((SoundFile*)[notification object]).frequency;
            CGFloat frequency = [freq floatValue];
            CGFloat frequencyOffset = [[defaults stringForKey:KEY_CALIBRATED_FREQUENCY] floatValue] - REF_FREQUENCY;
            
            if (frequency > 0.0) {
                frequency += frequencyOffset;
            }
            
            self.frequencyLabel.text = [NSString stringWithFormat:@"%.01f %@", frequency, strHz];
            // additional info: always "haken" for given sounds 
            UniChar ucode = 0x2713;
            NSString* additionalInfo = [NSString stringWithCharacters:&ucode length:1];
            self.diffLabel.text = frequency > 0.0 ? [NSString stringWithFormat:@"%@%.01f %@", additionalInfo, 0.0, strHz] : @"";
        });
    } else {
        NSLog(@"Error, object not recognised.");
    }
}

- (void)setupLabelConstraints {
    
    
    NSMutableArray *layoutConstraints = [NSMutableArray new];
    // 1. DIFFERENCE LABEL
    // Center horizontally
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.diffLabel
                                                              attribute:NSLayoutAttributeLeft
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeLeft
                                                             multiplier:1.0
                                                               constant:0.0]];
    // Center vertically
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.diffLabel
                                                              attribute:NSLayoutAttributeBaseline
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeBaseline
                                                             multiplier:0.8
                                                               constant:0.0]];
    // Width
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.diffLabel
                                                              attribute:NSLayoutAttributeWidth
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeWidth
                                                             multiplier:0.4
                                                               constant:0.0]];
    
    
    
    // 2. FREQUENCY LABEL
    // Center horizontally
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.frequencyLabel
                                                              attribute:NSLayoutAttributeCenterX
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeCenterX
                                                             multiplier:1.0
                                                               constant:0.0]];
    // Center vertically
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.frequencyLabel
                                                              attribute:NSLayoutAttributeBaseline
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeBaseline
                                                             multiplier:0.8
                                                               constant:0.0]];

    // 3. INFO ICON
    // Center vertically
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.infoIconView
                                                              attribute:NSLayoutAttributeBaseline
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeBaseline
                                                             multiplier:0.85
                                                               constant:0.0]];
    
    // Center horizontally
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.infoIconView
                                                              attribute:NSLayoutAttributeRight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeRight
                                                             multiplier:1.0
                                                               constant:0.0]];
    
    // Width
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.infoIconView
                                                              attribute:NSLayoutAttributeWidth
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeWidth
                                                             multiplier:0.12
                                                               constant:0.0]];
    
    // Height
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.infoIconView
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeHeight
                                                             multiplier:0.4
                                                               constant:0.0]];
    
    // CALIBRATION LABEL
    // Center vertically
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.calibrationLabel
                                                              attribute:NSLayoutAttributeBaseline
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeBaseline
                                                             multiplier:0.45
                                                               constant:0.0]];
    
    // Center horizontally
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.calibrationLabel
                                                              attribute:NSLayoutAttributeCenterX
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeCenterX
                                                             multiplier:1.0
                                                               constant:0.0]];
    
    // Width
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.calibrationLabel
                                                              attribute:NSLayoutAttributeWidth
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeWidth
                                                             multiplier:0.5
                                                               constant:0.0]];


    
    // add all constraints at once
    [self addConstraints:layoutConstraints];
    
}

-(void)dealloc {
    //NSLog(@"%s", __PRETTY_FUNCTION__);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
