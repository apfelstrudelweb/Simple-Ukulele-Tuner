//
//  Spectrum.m
//  Diapason
//
//  Created by imac on 15.03.15.
//  Copyright (c) 2015 Vormbrock. All rights reserved.
//

#import "Spectrum.h"

@interface Spectrum() {
    UIAlertView *message;
    NSUserDefaults *defaults;
    CGFloat frequencyOffset;
}
@end

@implementation Spectrum

- (id)init {
    defaults = [NSUserDefaults standardUserDefaults];
    frequencyOffset = [[defaults stringForKey:KEY_CALIBRATED_FREQUENCY] floatValue] - REF_FREQUENCY;
    return self;
}

- (CGFloat) getCenterFrequency {
    if ([self.deviation intValue] < 4) {
        return [self.stringFrequency floatValue];
    }
    return -1.0;
}

- (void) calculateDeviation {
    
    CGFloat frequency = [self.frequency floatValue] - frequencyOffset;
    self.toneName = @"";
    self.deviation = [NSNumber numberWithInt:-1];
    
    NSInteger numIterations = 10;
    
    NSArray *edgeFrequencyArray = [[SessionManager sharedManager] getEdgeFrequencyArray];
    
    CGFloat minFreq = 0.9*([edgeFrequencyArray[0] floatValue] - frequencyOffset);
    CGFloat maxFreq = 1.05*([edgeFrequencyArray[1] floatValue] - frequencyOffset);
    
    if (frequency > maxFreq) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"TuneDownNotification" object:nil];
    }
    
    if (frequency > 0.0 && frequency < minFreq) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"TuneUpNotification" object:nil];
    }
    
    /**
     *  IMPORTANT: the outer loop takes into account that tones may have different orders, for example tone A: 55Hz, 110Hz, 220Hz, 440Hz, etc - until a certain degree, we want to get the most used of them!
     */
    for (NSInteger j=0; j<numIterations; j++) {
        BOOL breakOuterLoop = NO;
        for (NSInteger k=0; k<BASIC_FREQUENCIES.count; k++) {
            
            CGFloat fact = powf(2.0, j);
            
            CGFloat stringFreq = [BASIC_FREQUENCIES[k] floatValue] * fact;
            
            
            // now calculate ranges in function of played frequency and precision requested
            CGFloat greenAreaLimit = 0.015 * PRECISION * stringFreq;
            CGFloat upperLimit = 0.49 * stringFreq * (TONE_DIST - 1.0);
            CGFloat lowerLimit = 0.49 * stringFreq * (TONE_DIST - 1.0) / TONE_DIST;
            
            if (frequency < stringFreq) {
                self.isNegativeDeviation = YES;
            } else {
                self.isNegativeDeviation = NO;
            }
            
            self.toneName = [NSString stringWithFormat:@"%@", NOTATION_EN[k]];
            self.octave = [NSNumber numberWithInteger:j];
            self.toneNumber = [NSNumber numberWithInteger:((int)BASIC_FREQUENCIES.count-k)];
            
//            // special case: high E (329.6 Hz)
//            if ([@"E" isEqualToString:self.toneName] && [self.octave intValue] == 4) {
//                self.toneName = @"E'";
//            }
            
            CGFloat alpha = 1.0 - 30.0*fabs(frequency - stringFreq)/stringFreq;
            if (alpha < 0.0) alpha = 0.0;
            
            if (frequency < stringFreq) {
                self.tuneUp = YES;
            } else {
                self.tuneUp = NO;
            }
            
            if (fabs(frequency - stringFreq) < greenAreaLimit) {
                self.deviation = [NSNumber numberWithInt:0];
                self.stringFrequency = [NSNumber numberWithFloat:stringFreq];
                self.alpha = [NSNumber numberWithFloat:alpha];
                breakOuterLoop = YES;
                break;
            } else if (fabs(frequency - stringFreq) < 2*greenAreaLimit) {
                self.deviation = [NSNumber numberWithInt:1];
                self.stringFrequency = [NSNumber numberWithFloat:stringFreq];
                self.alpha = [NSNumber numberWithFloat:alpha];
                breakOuterLoop = YES;
                break;
            } else if (fabs(frequency - stringFreq) < 3*greenAreaLimit) {
                self.deviation = [NSNumber numberWithInt:2];
                self.stringFrequency = [NSNumber numberWithFloat:stringFreq];
                self.alpha = [NSNumber numberWithFloat:alpha];
                breakOuterLoop = YES;
                break;
            } else if (fabs(frequency - stringFreq) < upperLimit ||  fabs(stringFreq - frequency) < lowerLimit) {
                self.deviation = [NSNumber numberWithInt:3];
                self.stringFrequency = [NSNumber numberWithFloat:stringFreq];
                self.alpha = [NSNumber numberWithFloat:alpha];
                breakOuterLoop = YES;
                break;
            } else {
                self.deviation = [NSNumber numberWithInt:4];
                self.toneName = @"";
                self.alpha = [NSNumber numberWithFloat:0.0];
            }
        }
        if (breakOuterLoop==YES) break;
    }
 
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0 && message.tag == 1) {
        //NSLog(@"clicked");
        [SHARED_MANAGER setMessageActive:NO];
    }
}

@end
