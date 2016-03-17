//
//  Bandpass.m
//  Diapason
//
//  Created by imac on 26.03.15.
//  Copyright (c) 2015 Vormbrock. All rights reserved.
//

#import "Bandpass.h"
#define MAX_CHANNEL_COUNT 2

@implementation Bandpass

- (void) setCenterFrequency: (float)f0 andBandwidth:(float)b {
    F0 = f0;
    B = b;
    
    float Q = F0/B;
    
    if ((F0 != 0.0f) && (Q != 0.0f)) {
        
        //[self intermediateVariables:F0 Q:Q];
        omega = 2*M_PI*F0/samplingRate;
        omegaS = sin(omega);
        omegaC = cos(omega);
        alpha = omegaS / (2*Q);
        
        a0 = 1 + alpha;
        b0 = alpha                  / a0;
        b1 = 0                      / a0;
        b2 = (-1 * alpha)           / a0;
        a1 = (-2 * omegaC)          / a0;
        a2 = (1 - alpha)            / a0;
        
        coefficients[0] = b0;
        coefficients[1] = b1;
        coefficients[2] = b2;
        coefficients[3] = a1;
        coefficients[4] = a2;
    }
}



- (id)initWithSamplingRate:(float)sr {
    if (self = [self init]) {
        samplingRate = sr;
        
        for (int i = 0; i < 5; i++) {
            coefficients[i] = 0.0f;
        }
        
        for (int i = 0; i < MAX_CHANNEL_COUNT; i++) {
            gInputKeepBuffer[i] = (float *)calloc(2, sizeof(float));
            gOutputKeepBuffer[i] = (float *)calloc(2, sizeof(float));
        }
        
        zero = 0.0f;
        one = 1.0f;
    }
    return self;
}


#pragma mark - Effects

- (void) applyGain:(float *)data length:(vDSP_Length)length gain:(float)gain {
    vDSP_vsmul(data, 1, &gain, data, 1, length);
}

#pragma mark - Active Filtering
- (void)filterData:(float *)data numFrames:(UInt32)numFrames numChannels:(UInt32)numChannels {
    switch (numChannels) {
        case 1:
            [self filterContiguousData:data numFrames:numFrames channel:0];
            break;
        case 2: {
            float *left = (float *)malloc((numFrames + 2) * sizeof(float));
            float *right = (float *)malloc((numFrames + 2) * sizeof(float));
            
            [self deinterleave:data left:left right:right length:numFrames];
            [self filterContiguousData:left numFrames:numFrames channel:0];
            [self filterContiguousData:right numFrames:numFrames channel:1];
            [self interleave:data left:left right:right length:numFrames];
            
            free(left);
            free(right);
            
            break;
        }
        default:
            NSLog(@"WARNING: Unsupported number of channels %u", (unsigned int)numChannels);
            break;
    }
}

- (void) filterContiguousData: (float *)data numFrames:(UInt32)numFrames channel:(UInt32)channel {
    
    // Provide buffer for processing
    float *tInputBuffer = (float*) malloc((numFrames + 2) * sizeof(float));
    float *tOutputBuffer = (float*) malloc((numFrames + 2) * sizeof(float));
    
    // Copy the data
    memcpy(tInputBuffer, gInputKeepBuffer[channel], 2 * sizeof(float));
    memcpy(tOutputBuffer, gOutputKeepBuffer[channel], 2 * sizeof(float));
    memcpy(&(tInputBuffer[2]), data, numFrames * sizeof(float));
    
    // Do the processing
    vDSP_deq22(tInputBuffer, 1, coefficients, tOutputBuffer, 1, numFrames);
    
    // Copy the data
    memcpy(data, tOutputBuffer, numFrames * sizeof(float));
    memcpy(gInputKeepBuffer[channel], &(tInputBuffer[numFrames]), 2 * sizeof(float));
    memcpy(gOutputKeepBuffer[channel], &(tOutputBuffer[numFrames]), 2 * sizeof(float));
    
    free(tInputBuffer);
    free(tOutputBuffer);
}

#pragma mark - Etc

- (void) deinterleave: (float *)data left: (float*) left right: (float*) right length: (vDSP_Length)length {
    vDSP_vsadd(data, 2, &zero, left, 1, length);
    vDSP_vsadd(data+1, 2, &zero, right, 1, length);
}

- (void) interleave: (float *)data left: (float*) left right: (float*) right length: (vDSP_Length)length {
    vDSP_vsadd(left, 1, &zero, data, 2, length);
    vDSP_vsadd(right, 1, &zero, data+1, 2, length);
}

- (void) mono: (float *)data left: (float*) left right: (float*) right length: (vDSP_Length)length {
    [self applyGain:left length:length gain:0.5];
    [self applyGain:right length:length gain:0.5];
    
    vDSP_vadd(left, 1, right, 1, left, 1, length);
    
    [self interleave:data left:left right:left length:length];
}




@end
