//
//  ViolinStringView.m
//  Simple Ukulele Tuner
//
//  Created by Ulrich Vormbrock on 15.08.17.
//  Copyright © 2017 Ulrich Vormbrock. All rights reserved.
//

#import "ViolinStringView.h"

@interface ViolinStringView() {
    
    NSUserDefaults *defaults;
    CGFloat frequencyOffset;
}
@end

@implementation ViolinStringView

- (id)initWithFrame:(CGRect)frame {
    
    
    self = [super initWithFrame:frame];
    
    if (self) {
        
        defaults = [NSUserDefaults standardUserDefaults];
        frequencyOffset = [[defaults stringForKey:KEY_CALIBRATED_FREQUENCY] floatValue] - REF_FREQUENCY;
        
//        CGSize size = [[UIScreen mainScreen] bounds].size;
//        
//        UIGraphicsBeginImageContext(size);
//        [[UIImage imageNamed:@"string_G.png"] drawInRect:[[UIScreen mainScreen] bounds]]; // G, D, A, E
//        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
//        UIGraphicsEndImageContext();
//        self.backgroundColor = [UIColor colorWithPatternImage:image];
        
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
    }
    
    return self;
}

-(void) updateLed:(NSNotification *) notification {
    
    self.backgroundColor = [UIColor clearColor];
    
    
    __block int stringNumber = -1;
    
    if ([notification.object isKindOfClass:[SoundFile class]]) {
        dispatch_async(dispatch_get_main_queue(), ^{

            SoundFile* sf = (SoundFile*)[notification object];
            
            if (sf.isActive) {
                stringNumber = [sf.toneNumber intValue];
                [self lightString:stringNumber];
            }
            
        });
    } else if ([notification.object isKindOfClass:[Spectrum class]]) {
        dispatch_async(dispatch_get_main_queue(), ^{

            Spectrum* spectrum = (Spectrum*)[notification object];
            //CGFloat alpha = [spectrum.alpha floatValue];
            CGFloat capturedFrequency = [spectrum.frequency floatValue] - frequencyOffset;
            
            NSArray* frequenciesArray = [SHARED_CONTEXT getFrequenciesArray];
            
            for (NSInteger i=0; i<frequenciesArray.count; i++) {
                CGFloat nominalFrequency = [frequenciesArray[i] floatValue];
                
                CGFloat upperLimit = 0.49 * nominalFrequency * (TONE_DIST - 1.0);
                CGFloat lowerLimit = 0.49 * nominalFrequency * (TONE_DIST - 1.0) / TONE_DIST;
                
                if (fabs(capturedFrequency - nominalFrequency) < upperLimit ||  fabs(nominalFrequency - capturedFrequency) < lowerLimit) {
                    
                    [self lightString:i];
                    break;

                }
                
            }

        });
    } else {
        NSLog(@"updateLed: error with notification type");
    }
    
}

- (void)lightString: (int) stringNumber {
    NSString *imageName = @"";
    
    switch (stringNumber) {
        case 0: imageName = @"string_G.png"; break;
        case 1: imageName = @"string_D.png"; break;
        case 2: imageName = @"string_A.png"; break;
        case 3: imageName = @"string_E.png"; break;
    }
    
    
    UIGraphicsBeginImageContext([[UIScreen mainScreen] bounds].size);
    [[UIImage imageNamed:imageName] drawInRect:[[UIScreen mainScreen] bounds]]; // G, D, A, E
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.backgroundColor = [UIColor colorWithPatternImage:image];
}


@end
