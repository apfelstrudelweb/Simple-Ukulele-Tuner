//
//  Yin.m
//  Diapason
//
//  Created by imac on 14.04.15.
//  Copyright (c) 2015 Vormbrock. All rights reserved.
//

#import "Yin.h"

#define DEFAULT_THRESHOLD 0.15
#define MINIMAL_PROBABILITY 0.85


@implementation Yin


- (CGFloat) getPitchInHertz: (float*) data withFrames: (NSInteger) numberOfFrames {
    
    CGFloat floatingThreshold = DEFAULT_THRESHOLD;
    
    NSInteger bufferSize = numberOfFrames/2;
    float *yinBuffer = (float *)malloc((bufferSize) * sizeof(float));
    
    NSInteger index, tau;
    CGFloat delta;

    for (tau = 0; tau < bufferSize; tau++) {
        yinBuffer[tau] = 0;
    }
    
    
    
    /**
     * Implements the difference function as described in step 2 of the YIN
     * paper.
     */
    yinBuffer[0] = 0;
    for (tau=1; tau<bufferSize; tau++) {

        for (index=0; index<bufferSize; index++) {
            
            delta = (data[index] - data[index+tau]);//*hann[index];
            yinBuffer[tau] += delta*delta;
        }
    }
    
    /**
     * The cumulative mean normalized difference function as described in step 3
     * of the YIN paper.
     * yinBuffer[0] == yinBuffer[1] = 1
     */
    CGFloat runningSum = 0;
    for (tau = 1; tau < bufferSize; tau++) {
        runningSum += yinBuffer[tau];
        yinBuffer[tau] *= tau / runningSum;
    }
    
    
    /**
     * Implements step 4 of the Yin paper.
     */
    CGFloat probability = 1.0;
    
    for (tau = 2; tau < bufferSize; tau++) {
        if (yinBuffer[tau] < floatingThreshold) {
            while (tau + 1 < bufferSize && yinBuffer[tau + 1] < yinBuffer[tau]) {
                tau++;
            }
            probability = 1 - yinBuffer[tau];
            break;
        }
    }
    
    [SHARED_MANAGER setEstimatedTau:tau];
    
    
    /**
     * Implements step 5 of the Yin paper. It refines the estimated tau
     * value using parabolic interpolation. This is needed to detect higher
     * frequencies more precisely. See http://fizyka.umk.pl/nrbook/c10-2.pdf
     */
    // if no pitch found, tau => -1
    if (tau == bufferSize || ( tau < bufferSize && yinBuffer[tau] >= floatingThreshold)) {
//        tau = -1;
//        probability = 0.0;
        free(yinBuffer);
    } else {
        CGFloat betterTau;
        NSInteger x0;
        NSInteger x2;
        
        if (tau < 1) {
            x0 = tau;
        } else {
            x0 = tau - 1;
        }
        if (tau + 1 < bufferSize) {
            x2 = tau + 1;
        } else {
            x2 = tau;
        }
        if (x0 == tau) {
            if (yinBuffer[tau] <= yinBuffer[x2]) {
                betterTau = tau;
            } else {
                betterTau = x2;
            }
        } else if (x2 == tau) {
            if (tau < bufferSize && yinBuffer[tau] <= yinBuffer[x0]) {
                betterTau = tau;
            } else {
                betterTau = x0;
            }
        } else {
            CGFloat s0, s1, s2;
            s0 = yinBuffer[x0];
            s1 = yinBuffer[tau];
            s2 = yinBuffer[x2];
            betterTau = tau + (s2 - s0) / (2 * (2 * s1 - s2 - s0));
        }
        
//        // use only for testing and calibrating
//        if (false ) {
//            float f0 = 932.3;
//            float corrTau = betterTau - PREFERRED_SAMPLING_RATE/f0;
//            [corFrequencies addObject:[NSNumber numberWithFloat:corrTau]];
//            NSNumber *averageValue = [corFrequencies valueForKeyPath:@"@avg.self"];
//            NSLog(@"betterTau: %f, corrTau: %f", betterTau, [averageValue floatValue]);
//        }
        
        
        
        /*
         * Pitch correction 4th octave
         */
        
        // workaround for 'C4' -> 261.6 Hz (middle C)
        if (betterTau > 41.7 && betterTau < 42.4) {
            betterTau += 0.021;
        }
        
        //        // workaround for 'Cis4' -> 277.2 Hz
        //        if (betterTau > 39.7 && betterTau < 39.8) {
        //            // no correction necessary
        //        }
        //
        //        // workaround for 'D4' -> 293.7 Hz
        //        if (betterTau > 37.5 && betterTau < 37.6) {
        //            // no correction necessary
        //        }
        
        // workaround for 'Es4' -> 311.1 Hz
        if (betterTau >= 35.0 && betterTau < 35.5) {
            betterTau += 0.015;
        }
        
        // workaround for 'E4' -> 329.6 Hz
        if (betterTau >= 33.0 && betterTau < 35.0) {
            betterTau += 0.012;
        }
        
        // workaround for 'F4' -> 349.2 Hz
        if (betterTau >= 30.0 && betterTau < 33.0) {
            betterTau += 0.0014;
        }
        
        // workaround for 'Fis4' -> 370.0 Hz
        if (betterTau >= 29.0 && betterTau < 30.0) {
            betterTau += 0.012;
        }
        
        // workaround for 'G4' -> 392.0 Hz
        if (betterTau >= 28.0 && betterTau < 29.0) {
            betterTau += 0.023;
        }
        
        // workaround for 'Gis4' -> 415.3 Hz
        if (betterTau >= 25.5 && betterTau < 28.0) {
            betterTau += 0.0018;
        }
        
        // workaround for 'A4' -> 440 Hz (chamber tone)
        if (betterTau >= 24.5 && betterTau < 25.5) {
            betterTau += 0.022;
        }
        
        // workaround for 'Bflat4' -> 466.2 Hz
        if (betterTau >= 23.0 && betterTau < 24.5) {
            betterTau += 0.006;
        }
        
        // workaround for 'B4' -> 493.9 Hz
        if (betterTau >= 21.5 && betterTau < 23.0) {
            betterTau += 0.018;
        }
        
        
        /*
         * Pitch correction 5th octave
         */
        // workaround for 'C5' -> 523.3 Hz
        if (betterTau >= 21.0 && betterTau < 21.5) {
            betterTau += 0.0268;
        }
        
        // workaround for 'Cis5' -> 554.4 Hz
        if (betterTau >= 19.0 && betterTau < 21.0) {
            betterTau += 0.0207;
        }
        
        // workaround for 'D5' -> 587.3 Hz
        if (betterTau >= 18.0 && betterTau < 19.0) {
            betterTau += 0.007061;
        }
        
        // workaround for 'Es5' -> 622.3 Hz
        if (betterTau >= 17.5 && betterTau < 18.0) {
            betterTau += 0.0128;
        }
        
        // workaround for 'E5' -> 659.3 Hz
        if (betterTau >= 16.5 && betterTau < 17.5) {
            betterTau += 0.01;
        }
        
        // workaround for 'F5' -> 698.5 Hz
        if (betterTau >= 15.5 && betterTau < 16.5) {
            betterTau += 0.008;
        }
        
        // workaround for 'Fis5' -> 740.0 Hz
        if (betterTau >= 14.5 && betterTau < 15.5) {
            betterTau += 0.0255;
        }
        
        // workaround for 'G5' -> 784.0 Hz
        if (betterTau >= 13.5 && betterTau < 14.5) {
            betterTau += 0.036;
        }
        
        // workaround for 'Gis5' -> 830.6 Hz
        if (betterTau >= 13.0 && betterTau < 13.5) {
            betterTau += 0.03485;
        }
        
        // workaround for 'A5' -> 880.0 Hz
        if (betterTau >= 12.5 && betterTau < 13.0) {
            betterTau += 0.01;
        }
        
        // workaround for 'Bflat5' -> 932.3 Hz
        if (betterTau >= 11.5 && betterTau < 12.5) {
            betterTau += 0.0297;
        }
        
        // workaround for 'B5' -> 987.8 Hz
        if (betterTau <= 11.5) {
            betterTau += 0.045;
        }
        
        // for exactly 2000 Hz
        if (betterTau < 11.031) {
            betterTau -= 0.02;
        }
        
        free(yinBuffer);
        
        // in case of not sufficiennt probability, don't display the data (in order to smooth them)
        if (probability < MINIMAL_PROBABILITY) {
           // NSLog(@"NO FREQUENCY FOUND");
            return -1;
        }
        
        CGFloat pitchInHertz = PREFERRED_SAMPLING_RATE / betterTau;
        
        //floatingThreshold = 0.00159*pitchInHertz - 0.07727;
//        if (pitchInHertz > 100) floatingThreshold = 0.15;
//        if (pitchInHertz > 150) floatingThreshold = 0.1;
//        if (pitchInHertz > 300) floatingThreshold = 0.02;
        
        return pitchInHertz;
    }
    
    return -1;
}
@end
