//
//  SoundHelper.m
//  Simple Guitar Tuner
//
//  Created by imac on 02.07.15.
//  Copyright (c) 2015 Vormbrock. All rights reserved.
//

#import "SoundHelper.h"
#import <AudioToolbox/AudioToolbox.h>

// This is our render callback. It will be called very frequently for short
// buffers of audio (512 samples per call on my machine).
OSStatus SineWaveRenderCallback(void * inRefCon,
                                AudioUnitRenderActionFlags * ioActionFlags,
                                const AudioTimeStamp * inTimeStamp,
                                UInt32 inBusNumber,
                                UInt32 inNumberFrames,
                                AudioBufferList * ioData) {
    
    
    CGFloat frequency = [SHARED_MANAGER getStringToneFrequency];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    CGFloat frequencyOffset = [[defaults stringForKey:KEY_CALIBRATED_FREQUENCY] floatValue] - REF_FREQUENCY;
    frequency += frequencyOffset;
    
    CGFloat factor = [SHARED_CONTEXT getFrequencyShiftFactor];
    
    frequency *= factor;
    
    double currentPhase = *((double *)inRefCon);
    
    // ioData is where we're supposed to put the audio samples we've created
    Float32 *outputBuffer = (Float32 *)ioData->mBuffers[0].mData;
    
    const double phaseStep = (frequency / 44100.) * (M_PI * 2.);
    
    for(NSInteger i = 0; i < inNumberFrames; i++) {
        outputBuffer[i] = (CGFloat) sin(currentPhase) + 0.5*(CGFloat) sin(4.0*currentPhase) + 0.4*(CGFloat) sin(8.0*currentPhase) + 0.3*(CGFloat) sin(12.0*currentPhase) + 0.2*(CGFloat) sin(16.0*currentPhase);
        currentPhase += phaseStep;
    }
    
    
    // If we were doing stereo (or more), this would copy our sine wave samples
    // to all of the remaining channels
    for(NSInteger i = 1; i < ioData->mNumberBuffers; i++) {
        memcpy(ioData->mBuffers[i].mData, outputBuffer, ioData->mBuffers[i].mDataByteSize);
    }
    
    
    // writing the current phase back to inRefCon so we can use it on the next call
    *((double *)inRefCon) = currentPhase;
    return noErr;
}

@interface SoundHelper() {
    
    AudioUnit outputUnit;
    double renderPhase;
    //float toneFrequency;
    
    NSError *setOverrideError;
    NSError *setCategoryError;
    
    AVAudioSession *session;
    AVAudioPlayer *audioPlayer;
    
    
}

@end

@implementation SoundHelper


#pragma mark Singleton Methods

+ (id)sharedSoundHelper {
    static SoundHelper *sharedSoundHelper = nil;
    @synchronized(self) {
        if (sharedSoundHelper == nil)
            sharedSoundHelper = [[self alloc] init];
    }
    return sharedSoundHelper;
}

- (id)init {
    if (self = [super init]) {
        session = [AVAudioSession sharedInstance];
        [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&setCategoryError];
        
        if(setCategoryError){
            NSLog(@"%@", [setCategoryError description]);
        }
    }
    return self;
}

- (void) playTone: (NSInteger) number {
    
    [session overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:&setOverrideError];
    
    
    NSArray* frequenciesArray = [SHARED_CONTEXT getFrequenciesArray];
    
    // use "autorelease" due to the flag "-fno-objc-arc" !!!
    SoundFile* sf = [[[SoundFile alloc] init] autorelease];
    sf.isActive = YES;
    sf.frequency = frequenciesArray[number];
    CGFloat frequency = [frequenciesArray[number] floatValue];
    sf.octave = [self getOctave:frequency];
    sf.toneNumber = [NSNumber numberWithInteger:number];
    
    [SHARED_MANAGER setStringToneFrequency:[frequenciesArray[number] floatValue]];

#if defined(TARGET_VIOLIN)
    NSArray *soundFilesArray = @[@"g-string.aiff", @"d-string.aiff", @"a-string.aiff", @"e-string.aiff"];
    [audioPlayer stop];
    if (number > soundFilesArray.count-1) return;
    [self playSoundFXnamed:soundFilesArray[number] Loop: YES];
#else
    [self playSineWave];
#endif
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PlayToneNotification" object:sf];

//    if ([version_lite isEqualToString:[SHARED_VERSION_MANAGER getVersion]] || [version_instrument isEqualToString:[SHARED_VERSION_MANAGER getVersion]]) {
//        // stop the tone for the lite version (after 3 sec)
//        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, NUM_SEC_PLAYTONE);
//        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//#if defined(TARGET_VIOLIN)
//            //[audioPlayer stop];
//#else
//            [self stopTone];
//#endif
//        });
//    }
}

- (void) stopTone {
    
#if defined(TARGET_VIOLIN)
    [audioPlayer stop];
#else
    AudioOutputUnitStop(outputUnit);
#endif
    
    // use "autorelease" due to the flag "-fno-objc-arc" !!!
    SoundFile* sf = [[[SoundFile alloc] init] autorelease];
    
    sf.isActive = NO;
    sf.toneNumber = [NSNumber numberWithInt:0];
    sf.frequency = [NSNumber numberWithFloat:0.0];
    
    [SHARED_MANAGER setSoundPlaying:NO];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PlayToneNotification" object:sf];
    
#if !defined(TARGET_VIOLIN)
    [session overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:nil];
#endif
    
}

- (void) playSineWave {
    // stop loop if tone is already playing
    AudioOutputUnitStop(outputUnit);
    
    //  First, we need to establish which Audio Unit we want.
    
    //  We start with its description, which is:
    AudioComponentDescription outputUnitDescription = {
        .componentType         = kAudioUnitType_Output,
        .componentSubType      = kAudioUnitSubType_RemoteIO,
        .componentManufacturer = kAudioUnitManufacturer_Apple
    };
    
    //  Next, we get the first (and only) component corresponding to that description
    AudioComponent outputComponent = AudioComponentFindNext(NULL, &outputUnitDescription);
    
    
    
    //  Now we can create an instance of that component, which will create an
    //  instance of the Audio Unit we're looking for (the default output)
    AudioComponentInstanceNew(outputComponent, &outputUnit);
    AudioUnitInitialize(outputUnit);
    
    //  Next we'll tell the output unit what format our generated audio will
    //  be in. Generally speaking, you'll want to stick to sane formats, since
    //  the output unit won't accept every single possible stream format.
    //  Here, we're specifying floating point samples with a sample rate of
    //  44100 Hz in mono (i.e. 1 channel)
    AudioStreamBasicDescription ASBD = {
        .mSampleRate       = 44100,
        .mFormatID         = kAudioFormatLinearPCM,
        .mFormatFlags      = kAudioFormatFlagsNativeFloatPacked,
        .mChannelsPerFrame = 1,
        .mFramesPerPacket  = 1,
        .mBitsPerChannel   = sizeof(Float32) * 8,
        .mBytesPerPacket   = sizeof(Float32),
        .mBytesPerFrame    = sizeof(Float32)
    };
    
    AudioUnitSetProperty(outputUnit,
                         kAudioUnitProperty_StreamFormat,
                         kAudioUnitScope_Input,
                         0,
                         &ASBD,
                         sizeof(ASBD));
    
    //  Next step is to tell our output unit which function we'd like it
    //  to call to get audio samples. We'll also pass in a context pointer,
    //  which can be a pointer to anything you need to maintain state between
    //  render callbacks. We only need to point to a double which represents
    //  the current phase of the sine wave we're creating.
    AURenderCallbackStruct callbackInfo = {
        .inputProc       = SineWaveRenderCallback,
        .inputProcRefCon = &renderPhase
    };
    
    AudioUnitSetProperty(outputUnit,
                         kAudioUnitProperty_SetRenderCallback,
                         kAudioUnitScope_Global,
                         0,
                         &callbackInfo,
                         sizeof(callbackInfo));
    
    //  Here we're telling the output unit to start requesting audio samples
    //  from our render callback. This is the line of code that starts actually
    //  sending audio to your speakers.
    AudioOutputUnitStart(outputUnit);
}



// Helper method
- (NSNumber*) getOctave: (CGFloat) frequency {
    
    NSInteger octave = 0;
    NSInteger numIterations = 10;
    
    /**
     *  IMPORTANT: the outer loop takes into account that tones may have different orders, for example tone A: 55Hz, 110Hz, 220Hz, 440Hz, etc - until a certain degree, we want to get the most used of them!
     */
    for (NSInteger j=0; j<numIterations; j++) {
        BOOL breakOuterLoop = NO;
        for (NSInteger k=0; k<BASIC_FREQUENCIES.count; k++) {
            
            CGFloat fact = powf(2.0, j);
            
            CGFloat stringFreq = [BASIC_FREQUENCIES[k] floatValue] * fact;
            
            // now calculate ranges in function of played frequency and precision requested
            CGFloat greenAreaLimit = 0.01 * PRECISION * stringFreq;
            
            octave = [[NSNumber numberWithInteger:j] intValue];
            
            if (fabs(frequency - stringFreq) < greenAreaLimit) {
                breakOuterLoop = YES;
                break;
            }
            
        }
        if (breakOuterLoop == YES) break;
    }
    return [NSNumber numberWithInteger:octave];
}

-(BOOL) playSoundFXnamed: (NSString*) vSFXName Loop: (BOOL) vLoop
{
    NSError *error;
    
    NSBundle* bundle = [NSBundle mainBundle];
    
    NSString* bundleDirectory = (NSString*)[bundle bundlePath];
    
    NSURL *url = [NSURL fileURLWithPath:[bundleDirectory stringByAppendingPathComponent:vSFXName]];
    
    audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    
    if(vLoop)
        audioPlayer.numberOfLoops = -1;
    else
        audioPlayer.numberOfLoops = 0;
    
    BOOL success = YES;
    
    if (audioPlayer == nil)
    {
        success = NO;
    }
    else
    {
        success = [audioPlayer play];
    }
    return success;
}
@end
