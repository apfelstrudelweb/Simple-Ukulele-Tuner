//
//  FFT.m
//  Diapaxon
//
//  Created by imac on 02.05.15.
//  Copyright (c) 2015 Vormbrock. All rights reserved.
//

#include <stdio.h>
#import "FFT.h"

//static const int kProcessingBlockSize = 1024;
//static const int kMagnitudeThreshold = 50;
//static const int kFrequencyCutoff = 8000;

@interface FFT() {

    FFTSetup fftSetup;
    size_t              fftSize,
    fftSizeOver2,
    log2n,
    log2nOver2,
    windowSize,
    i;
    
    float               *in_real,
    *out_real,
    *window;
    
    float               scale;
    COMPLEX_SPLIT       split_data;
    NSMutableArray* result;
}
@end

@implementation FFT


- (NSMutableArray*) performFFT: (float*) data  withFrames: (NSInteger) numSamples {
    
    result = [NSMutableArray new];
    
    NSInteger size = numSamples;
    NSInteger window_size = numSamples * 7;
    
    fftSize = size;                 // sample size
    fftSizeOver2 = fftSize/2;
    log2n = log2f(fftSize);         // bins
    log2nOver2 = log2n/2;
    
    in_real = (float *) malloc(fftSize * sizeof(float));
    out_real = (float *) malloc(fftSize * sizeof(float));
    split_data.realp = (float *) malloc(fftSizeOver2 * sizeof(float));
    split_data.imagp = (float *) malloc(fftSizeOver2 * sizeof(float));
    
    windowSize = window_size;
    window = (float *) malloc(sizeof(float) * windowSize);
    memset(window, 0, sizeof(float) * windowSize);
    vDSP_hamm_window(window, window_size, vDSP_HANN_DENORM);
    
    scale = 1.0f/(float)(4.0f*fftSize);
    
    // allocate the fft object once
    fftSetup = vDSP_create_fftsetup(log2n, FFT_RADIX2);
    if (fftSetup == NULL) {
        printf("\nFFT_Setup failed to allocate enough memory.\n");
    }
    
    
    //multiply by window
    vDSP_vmul(data, 1, window, 1, in_real, 1, fftSize);
    
    //convert to split complex format with evens in real and odds in imag
    vDSP_ctoz((COMPLEX *) in_real, 2, &split_data, 1, fftSizeOver2);
    
    //calc fft
    vDSP_fft_zrip(fftSetup, &split_data, 1, log2n, FFT_FORWARD);
    
    split_data.imagp[0] = 0.0;
    
    for (i = 0; i < fftSizeOver2; i++)
    {
        //compute power
        CGFloat power = (i<2) ? 0.0 : split_data.realp[i]*split_data.realp[i] +
        split_data.imagp[i]*split_data.imagp[i];
        
        //compute magnitude and phase
        result[i] = [NSNumber numberWithFloat:sqrtf(power)];
        //phase[i] = atan2f(split_data.imagp[i], split_data.realp[i]);
    }


    [self clearMemory];
    
    return result;
}


- (void) clearMemory {

    free(in_real);
    free(out_real);
    free(split_data.realp);
    free(split_data.imagp);
    free(window);
    
    vDSP_destroy_fftsetup(fftSetup);

}

@end