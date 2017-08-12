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


#define IS_MICROPHONE YES


#define NUM_AVRG_VALUES 50
#define CAPACITY 200



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
    
    NSUserDefaults *defaults;
    NSInteger sensitivity;
}

@end

@implementation SoundProcessor


- (id)init{
    self = [super init];
    if(self){
        audioManager = [Novocaine audioManager];
        
        ringBuffer = new RingBuffer(32768, 2);
        previousFrequencyArray = [NSMutableArray new];
        numOfErroneousFreqDetections = 0;
        numOfNoFrequencyDetecion = 0;
        
        defaults = [NSUserDefaults standardUserDefaults];
    }
    return self;
}


- (void) captureSound {
    
    [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:nil];
    
    sensitivity = [[defaults stringForKey:KEY_SENSITIVITY] integerValue];
    
    __block CGFloat dbVal = 0.0;
    
    __block NSInteger numCaptures = 0;
    __block Spectrum *spect = [Spectrum new];
    __block AutoCorrelation* correlation = [AutoCorrelation new];
    __block FFT* fft = [FFT new];
    __block Yin* yin = [Yin new];
    __block NSMutableArray* result;
    

    if (IS_MICROPHONE==YES) {
        
        [[Novocaine audioManager] setInputBlock:^(float *data, UInt32 numFrames, UInt32 numChannels) {
            ringBuffer->AddNewInterleavedFloatData(data, numFrames, numChannels);
            
            //[bandpass filterData:data numFrames:numFrames numChannels:numChannels];
            
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
        
        NSInteger numHops = 5;
        
        switch(sensitivity) {
            case 1: numHops = 12; break;
            case 2: numHops = 8; break;
            case 4: numHops = 3; break;
            case 5: numHops = 1; break;
        }
        
        
        if (numCaptures++ % CAPACITY == 0) {
            previousFrequencyArray = [NSMutableArray new];
        }

        CGFloat volume = 100 + dbVal;
        spect.volume = [NSNumber numberWithFloat:volume];

         if (numCaptures % numHops == 0 && volume > 5.0) {
     
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

             // now perform "YIN, a fundamental frequency estimator for speech and music"
             CGFloat pitchInHertz = [yin getPitchInHertz:data withFrames:numFrames];
             
             [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateDataNotification" object:spect];
             
             if (pitchInHertz == -1) {
                 [self silence: data andSize:(int) numChannels*numFrames];
                 return;
             }
             
          
             if (previousFrequencyArray.count > 1) {
                 CGFloat avrgFreq = [self getAverageValue];
                 
                 if (std::abs(avrgFreq - pitchInHertz) > 0.05*avrgFreq) {
                     // silence the sound in order to disable sound feedback
                     [self silence: data andSize:(int) numChannels*numFrames];
                     return;
                 }
                 pitchInHertz = avrgFreq;
             }
             
             
             NSNumber *frequency = [NSNumber numberWithDouble:pitchInHertz];
             spect.frequency = frequency;

             if ([SHARED_MANAGER isFFT]) {
                 NSInteger bin = pitchInHertz;
                 spect.bin = [NSNumber numberWithInteger:bin];
             } else {
                 spect.bin = [NSNumber numberWithInt:PREFERRED_SAMPLING_RATE / pitchInHertz];
             }
             
             [spect calculateDeviation];
             
         }
         
         
         [[NSNotificationCenter defaultCenter] removeObserver:self];
         
         //numCaptures++;
         
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
        CGFloat diff = std::abs(capturedFrequency - averageFrequency);
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
