//
//  Yin.m
//  Diapason
//
//  Created by imac on 14.04.15.
//  Copyright (c) 2015 Vormbrock. All rights reserved.
//

#import "Yin.h"

#if defined(TARGET_VIOLIN) || defined(TARGET_MANDOLIN)
    #define DEFAULT_THRESHOLD 0.2f
    #define MINIMAL_PROBABILITY 0.93f
#else
    #define DEFAULT_THRESHOLD 0.15f
    #define MINIMAL_PROBABILITY 0.96f
#endif



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
        
        
        free(yinBuffer);
        
        // in case of not sufficiennt probability, don't display the data (in order to smooth them)
        if (probability < MINIMAL_PROBABILITY) {
           // NSLog(@"NO FREQUENCY FOUND");
            return -1;
        }
        
        CGFloat pitchInHertz = PREFERRED_SAMPLING_RATE / betterTau;
        
//        //workaround for 'Es4' -> 311.1 Hz
//        if (fabsf(pitchInHertz) - 311.1 < 10.0) {
//            pitchInHertz -= 0.9;
//            //NSLog(@"diff=%f", diff);
//        }
//        
//        // Crucial Uke Frequencies
//        if (fabsf(pitchInHertz) - 98.0 < 10.0) {
//            pitchInHertz += 0.8;
//        }
//        
//        if (fabsf(pitchInHertz) - 146.83 < 10.0) {
//            pitchInHertz += 0.9;
//        }
//        
//        if (fabsf(pitchInHertz) - 196.0 < 10.0) {
//            pitchInHertz += 0.75;
//        }
//        
//        if (fabsf(pitchInHertz) - 246.94 < 10.0) {
//            pitchInHertz += 0.4;
//        }
//        
//        if (fabsf(pitchInHertz) - 261.63 < 10.0) {
//            pitchInHertz += 0.8;
//        }
//        
//        if (fabsf(pitchInHertz) - 293.66 < 10.0) {
//            pitchInHertz += 0.8;
//        }
//        
//        if (fabsf(pitchInHertz) - 329.63 < 10.0) {
//            pitchInHertz -= 1.0;
//        }
//        
//        if (fabsf(pitchInHertz) - 349.23 < 10.0) {
//            pitchInHertz += 1.25;
//        }
//        
//        if (fabsf(pitchInHertz) - 370.0 < 10.0) {
//            pitchInHertz -= 0.8;
//        }
//        
//        if (fabsf(pitchInHertz) - 392.0 < 10.0) {
//            pitchInHertz -= 0.5;
//        }
//        
//        if (fabsf(pitchInHertz) - 440.0 < 10.0) {
//            pitchInHertz -= 0.4;
//        }
//        
//        if (fabsf(pitchInHertz) - 493.88 < 10.0) {
//            pitchInHertz -= 1.5;
//        }
//        
//        if (fabsf(pitchInHertz) - 523.25 < 10.0) {
//            pitchInHertz -= 0.6;
//        }
//        
//        if (fabsf(pitchInHertz) - 587.33 < 10.0) {
//            pitchInHertz -= 2.3;
//        }
//        
//        if (fabsf(pitchInHertz) - 659.26 < 10.0) {
//            pitchInHertz -= 4.0;
//        }
//        

        return pitchInHertz;
    }
    
    return -1;
}
@end
