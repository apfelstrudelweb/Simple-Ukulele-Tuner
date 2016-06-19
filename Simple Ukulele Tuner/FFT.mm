//
//  FFT.m
//  Diapaxon
//
//  Created by imac on 02.05.15.
//  Copyright (c) 2015 Vormbrock. All rights reserved.
//

#include <stdio.h>
#import "FFT.h"

@interface FFT() {
    
    size_t windowSize;
    float *window;
    
    FFTSetup fftSetup;
    COMPLEX_SPLIT complexA;
    Float32 *outFFTData;
    Float32 *invertedCheckData;
    NSMutableArray* result;
}
@end

@implementation FFT


- (NSMutableArray*) performFFT: (float*) data  withFrames: (NSInteger) numSamples {
    
    result = [NSMutableArray new];
    
    vDSP_Length log2n = log2f(numSamples);
    fftSetup = vDSP_create_fftsetup(log2n, FFT_RADIX2);
    NSInteger nOver2 = numSamples/2;
    complexA.realp = (Float32*) malloc(nOver2*sizeof(Float32) );
    complexA.imagp = (Float32*) malloc(nOver2*sizeof(Float32) );
    
    outFFTData = (Float32 *) malloc(nOver2*sizeof(Float32) );
    memset(outFFTData, 0, nOver2*sizeof(Float32) );
    
    invertedCheckData = (Float32*) malloc(numSamples*sizeof(Float32) );
    
    Float32 mFFTNormFactor = 1.0/(2*numSamples);
    
    //Convert float array of reals samples to COMPLEX_SPLIT array A
    vDSP_ctoz((COMPLEX*)data, 2, &(complexA), 1, numSamples/2);
    
    //Perform FFT using fftSetup and A
    //Results are returned in A
    vDSP_fft_zrip(fftSetup, &(complexA), 1, log2n, FFT_FORWARD);

    
    //scale fft
    vDSP_vsmul(complexA.realp, 1, &mFFTNormFactor, complexA.realp, 1, numSamples/2);
    vDSP_vsmul(complexA.imagp, 1, &mFFTNormFactor, complexA.imagp, 1, numSamples/2);
    
    vDSP_zvmags(&(complexA), 1, outFFTData, 1, numSamples/2);
    
    //to check everything (checking by reversing to time-domain data) =============================
    vDSP_fft_zrip(fftSetup, &(complexA), 1, log2n, FFT_INVERSE);
    vDSP_ztoc( &(complexA), 1, (COMPLEX *) invertedCheckData , 2, numSamples/2);
    
    for (int i = 0; i < 200; i++) {
        result[i] = [NSNumber numberWithFloat:outFFTData[i]];
    }
    
    [self clearMemory];
    
    return result;
}


- (void) clearMemory {
    
    free(complexA.realp);
    free(complexA.imagp);
    free(outFFTData);
    free(invertedCheckData);
    vDSP_destroy_fftsetup(fftSetup);
}

@end