//
//  Spectrum.m
//  Diapason
//
//  Created by imac on 15.03.15.
//  Copyright (c) 2015 Vormbrock. All rights reserved.
//

#import "Spectrum.h"

@interface Spectrum() {
    NSUserDefaults *defaults;
    CGFloat frequencyOffset;
}
@end

@implementation Spectrum

- (id)init{
    self = [super init];
    if(self){
        defaults = [NSUserDefaults standardUserDefaults];
        frequencyOffset = [[defaults stringForKey:KEY_CALIBRATED_FREQUENCY] floatValue] - REF_FREQUENCY;
        self.isOutOfRange = NO;
        return self;
    }
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
    
//    if (self.isOutOfRange == YES) {
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"TuneDownNotification" object:nil userInfo:@{@"blink": @(NO)}];
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"TuneUpNotification" object:nil userInfo:@{@"blink": @(NO)}];
//        self.isOutOfRange = NO;
//    }
    
    
    NSInteger octave = (NSInteger) floorf((log(frequency) - log(16)) / log(2));
    self.octave = [NSNumber numberWithInteger:octave];
    

    NSArray *nominalFrequencies = [[SessionManager sharedManager] getUkuleleFrequencies];
    NSArray *nominalToneNames = [[SessionManager sharedManager] getUkuleleNotesArray];
    
    
    CGFloat minDeviation = 1000.0;
    CGFloat nominalFrequency = 0.0;
    NSString *nominalToneName = @"";
    
    for (int i=0; i<nominalFrequencies.count; i++) {
        CGFloat actualFrequency = [nominalFrequencies[i] floatValue];
        CGFloat deviation = fabs(frequency - actualFrequency);
        
        if (deviation < minDeviation) {
            minDeviation = deviation;
            nominalFrequency = actualFrequency;
            nominalToneName = nominalToneNames[i];
        }
    }
    
    self.toneName = nominalToneName;
    
    // now calculate ranges in function of played frequency and precision requested
    CGFloat greenAreaLimit = 0.015 * PRECISION * nominalFrequency;
    CGFloat upperLimit = 0.49 * nominalFrequency * (TONE_DIST - 1.0);
    CGFloat lowerLimit = 0.49 * nominalFrequency * (TONE_DIST - 1.0) / TONE_DIST;
    
    if (frequency < nominalFrequency) {
        self.isNegativeDeviation = YES;
    } else {
        self.isNegativeDeviation = NO;
    }
    
    CGFloat alpha = 1.0 - 30.0*fabs(frequency - nominalFrequency)/nominalFrequency;
    if (alpha < 0.0) alpha = 0.0;
    
    if (frequency < nominalFrequency) {
        self.tuneUp = YES;
    } else {
        self.tuneUp = NO;
    }
    
    if (fabs(frequency - nominalFrequency) < greenAreaLimit) {
        self.deviation = [NSNumber numberWithInt:0];
        self.stringFrequency = [NSNumber numberWithFloat:nominalFrequency];
        self.alpha = [NSNumber numberWithFloat:alpha];
        [self clearUpDownArrows];
    } else if (fabs(frequency - nominalFrequency) < 2*greenAreaLimit) {
        self.deviation = [NSNumber numberWithInt:1];
        self.stringFrequency = [NSNumber numberWithFloat:nominalFrequency];
        self.alpha = [NSNumber numberWithFloat:alpha];
        [self clearUpDownArrows];
    } else if (fabs(frequency - nominalFrequency) < 3*greenAreaLimit) {
        self.deviation = [NSNumber numberWithInt:2];
        self.stringFrequency = [NSNumber numberWithFloat:nominalFrequency];
        self.alpha = [NSNumber numberWithFloat:alpha];
        [self clearUpDownArrows];
    } else if (fabs(frequency - nominalFrequency) < upperLimit || fabs(nominalFrequency - frequency) < lowerLimit) {
        self.deviation = [NSNumber numberWithInt:3];
        self.stringFrequency = [NSNumber numberWithFloat:nominalFrequency];
        self.alpha = [NSNumber numberWithFloat:alpha];
        [self clearUpDownArrows];
    } else {
        self.deviation = [NSNumber numberWithInt:4];
        self.toneName = @"";
        self.alpha = [NSNumber numberWithFloat:0.0];
        
        [self showUpDownArrows: frequency nominalFrequency: nominalFrequency];
    }

}

- (void) showUpDownArrows: (CGFloat) frequency nominalFrequency:(CGFloat) nominalFrequency {
    
    self.isOutOfRange = YES;
    
    if (frequency > nominalFrequency) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"TuneDownNotification" object:nil userInfo:@{@"blink": @(YES)}];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"TuneUpNotification" object:nil userInfo:@{@"blink": @(YES)}];
    }
}

- (void) clearUpDownArrows {
    
    if (self.isOutOfRange == YES) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"TuneDownNotification" object:nil userInfo:@{@"blink": @(NO)}];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"TuneUpNotification" object:nil userInfo:@{@"blink": @(NO)}];
        self.isOutOfRange = NO;
    }

}

@end
