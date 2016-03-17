//
//  Bandpass.h
//  Diapason
//
//  Created by imac on 26.03.15.
//  Copyright (c) 2015 Vormbrock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Accelerate/Accelerate.h>

@interface Bandpass : NSObject {
    float zero, one;
    
    float samplingRate;
    
    float *gInputKeepBuffer[2];
    float *gOutputKeepBuffer[2];
    
    float omega, omegaS, omegaC, alpha;
    
    float coefficients[5];
    
    float a0, a1, a2, b0, b1, b2;
    
    float F0;
    float B;
}


#pragma mark - Setters
- (void) setCenterFrequency: (float)f0 andBandwidth:(float)b;

#pragma mark -init
- (id)initWithSamplingRate:(float)sr;

#pragma mark - Effects

- (void) filterData:(float *)data numFrames:(UInt32)numFrames numChannels:(UInt32)numChannels;
- (void) filterContiguousData: (float *)data numFrames:(UInt32)numFrames channel:(UInt32)channel;
- (void) applyGain:(float *)data length:(vDSP_Length)length gain:(float)gain;

#pragma mark - Etc
- (void) deinterleave: (float *)data left: (float*) left right: (float*) right length: (vDSP_Length)length;
- (void) interleave: (float *)data left: (float*) left right: (float*) right length: (vDSP_Length)length;
- (void) mono: (float *)data left: (float*) left right: (float*) right length: (vDSP_Length)length;

@end
