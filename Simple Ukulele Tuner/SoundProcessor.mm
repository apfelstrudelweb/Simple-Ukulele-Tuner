//
//  SoundProcessor.m
//  Diapason
//
//  Created by imac on 15.03.15.
//  Copyright (c) 2015 Vormbrock. All rights reserved.
//

#import "SoundProcessor.h"
#import "Novocaine.h"
#import "RingBuffer.h"
#import "AudioFileReader.h"
#import "Yin.h"
#import "AutoCorrelation.h"
#import "FFT.h"
#import "Bandpass.h"

#define IS_MICROPHONE YES

#define NUM_CAPTURES_HOP 2
#define NUM_AVRG_VALUES 20



@interface SoundProcessor() {
    
    AVAudioPlayer *player;
    
    Novocaine *audioManager;
    RingBuffer *ringBuffer;
    AudioFileReader *fileReader;
    
    BOOL shouldStopCapture;
    
    //NSMutableArray* dominantFrequencies;
    __block NSMutableArray* previousFrequencyArray;
    
    NSInteger numOfErroneousFreqDetections;
    NSInteger numOfNoFrequencyDetecion;
}
@end

@implementation SoundProcessor


- (id)init {
    
    audioManager = [Novocaine audioManager];
    
    ringBuffer = new RingBuffer(32768, 2);
    previousFrequencyArray = [NSMutableArray new];
    numOfErroneousFreqDetections = 0;
    numOfNoFrequencyDetecion = 0;
    
    return self;
}


- (void) captureSound {
    
   // __block NSMutableArray* frequencyArray = [NSMutableArray new];
    __block CGFloat dbVal = 0.0;
    
    __block NSInteger numCaptures = 0;
    __block Spectrum *spect = [Spectrum new];
    __block AutoCorrelation* correlation = [AutoCorrelation new];
    __block FFT* fft = [FFT new];
    __block Yin* yin = [Yin new];
    __block NSMutableArray* result;
    
    Bandpass *bandpass = [[Bandpass alloc] initWithSamplingRate:PREFERRED_SAMPLING_RATE];
    [bandpass setCenterFrequency:520.0 andBandwidth:500.0];
    
    
    if (IS_MICROPHONE==YES) {
        
        [[Novocaine audioManager] setInputBlock:^(float *data, UInt32 numFrames, UInt32 numChannels) {
            ringBuffer->AddNewInterleavedFloatData(data, numFrames, numChannels);
            
            if (isnan(dbVal)) {
                dbVal = 0.0;
            }
            
            vDSP_vsq(data, 1, data, 1, numFrames*numChannels);
            float meanVal = 0.0;
            vDSP_meanv(data, 1, &meanVal, numFrames*numChannels);

            float one = 1.0;
            vDSP_vdbcon(&meanVal, 1, &one, &meanVal, 1, 1, 0);
            dbVal = dbVal + 0.2*(meanVal - dbVal);
            
            if (dbVal > -80) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateVolumeNotification" object:[NSNumber numberWithFloat:dbVal]];
            }

        }];
    }
    
    
    [[Novocaine audioManager] setOutputBlock:^(float *data, UInt32 numFrames, UInt32 numChannels) {
        ringBuffer->FetchInterleavedData(data, numFrames, numChannels);
 
        [bandpass filterData:data numFrames:numFrames numChannels:numChannels];

        CGFloat volume = 100 + dbVal;
        spect.volume = [NSNumber numberWithFloat:volume];
        

         // performance issue: wait until the nth loop until new processing restarts
         if (numCaptures % NUM_CAPTURES_HOP == 0 && volume > 20.0) {
     
             // mostly for iPad: join the two channels to one
             if (numChannels==2) {
                 for(int i = 0; i < numFrames; i++) {
                     data[i] = data[2*i];
                 }
             }
             
             
             if (![SHARED_MANAGER isFFT]) {
                 result = [correlation performAutocorrelation:data withFrames:numFrames];
             } else {
                 result = [fft performFFT:data withFrames:numFrames];
             }
             
             
             spect.data = result;

             [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateDataNotification" object:spect];
             
             
             // now perform "YIN, a fundamental frequency estimator for speech and music"
             CGFloat pitchInHertz = [yin getPitchInHertz:data withFrames:numFrames];
             // if no frequency has been found, resume loop
             if (pitchInHertz == -1) {
                 // silence the sound in order to disable sound feedback
                 [self silence: data andSize:(int) numChannels*numFrames];
                 
                 numOfErroneousFreqDetections++;
                 
                 if (numOfErroneousFreqDetections > 10) {
                     // reset smoothing array so that new frequencies can be smoothed again
                     [previousFrequencyArray removeAllObjects];
                     numOfErroneousFreqDetections = 0;
                     numOfNoFrequencyDetecion++;
                     
                     if (numOfNoFrequencyDetecion > 30) {
                         spect.frequency = @(0.0);
                         numOfNoFrequencyDetecion = 0;
                         [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateDataNotification" object:spect];
                     }
                     
                 }
                 return;
             }
             
             if (previousFrequencyArray.count > 1) {
                 CGFloat avrgFreq = [self getAverageValue];
                 
                 if (fabsf(avrgFreq - pitchInHertz) > 0.1*avrgFreq) {
                     // silence the sound in order to disable sound feedback
                     [self silence: data andSize:(int) numChannels*numFrames];
                     return;
                 }
             }

             // smooth data in order to average the last values
             [self queueObject:[NSNumber numberWithFloat:pitchInHertz]];
             if (previousFrequencyArray.count > 10) {
                 pitchInHertz = [self getAverageValue];
             } else {
                 // silence the sound in order to disable sound feedback
                 [self silence: data andSize:(int) numChannels*numFrames];
                 return;
             }
             
             NSNumber *frequency = [NSNumber numberWithDouble:pitchInHertz];
             spect.frequency = frequency;
             
             if ([SHARED_MANAGER isFFT]) {
                 int bin = pitchInHertz;
                 spect.bin = [NSNumber numberWithInt:bin];
             } else {
                 spect.bin = [NSNumber numberWithInt:PREFERRED_SAMPLING_RATE / pitchInHertz];
             }
             
             [spect calculateDeviation];
             
         }
         
         
         [[NSNotificationCenter defaultCenter] removeObserver:self];
         
         numCaptures++;
         
         // silence the sound in order to disable sound feedback
         [self silence: data andSize:(int) numChannels*numFrames];
         
     }];
    
    [audioManager play];
    
}


// avoid playthrough, thus disable sound
- (void) silence: (float*) data andSize:(NSInteger) size {
    for(NSInteger i=0; i<size; i++) {
        data[i] = 0.0;
    }
}

- (void) stopCapture {
    [audioManager pause];
    [previousFrequencyArray removeAllObjects];
}

- (void) queueObject: (NSNumber*) number {
    
    if (previousFrequencyArray.count > 5) {
        CGFloat capturedFrequency = [number floatValue];
        CGFloat averageFrequency = [self getAverageValue];
        CGFloat diff = fabsf(capturedFrequency - averageFrequency);
        if (diff / averageFrequency > 0.01) {
            //NSLog(@"capturedFrequency: %f - avrg:%f", capturedFrequency, averageFrequency);
            return;
        }
    }
    
    if (previousFrequencyArray.count > NUM_AVRG_VALUES) {
        [previousFrequencyArray removeLastObject];
        //NSLog(@"ARRAY FULL");
    }
    
    [previousFrequencyArray insertObject:number atIndex:0];
}

- (CGFloat) getAverageValue {
    CGFloat avrg = 0;
    for (NSNumber* num in previousFrequencyArray) {
        CGFloat val = [num floatValue];
        avrg += val;
    }
    
    return avrg / previousFrequencyArray.count;
}

@end
