//
//  SessionManager.m
//  Diapaxon
//
//  Created by imac on 05.05.15.
//  Copyright (c) 2015 Vormbrock. All rights reserved.
//

#import "SessionManager.h"

@implementation SessionManager

@synthesize  currentSamplingRate;


#pragma mark Singleton Methods

+ (id)sharedManager {
    static SessionManager *sharedManager = nil;
    @synchronized(self) {
        if (sharedManager == nil)
            sharedManager = [[self alloc] init];
    }
    return sharedManager;
}

- (id)init {
    if (self = [super init]) {
        self.lastSemitoneFound = -1;
    }
    return self;
}

-(void) setFFT: (BOOL) flag {
    self.isFFTEnabled = flag;
}

-(BOOL) isFFT {
    return self.isFFTEnabled;
}

-(void) addSemitone {
    self.countSemitones++;
}
-(NSInteger) getNumberOfSemitones {
    return self.countSemitones;
}

-(void) setLastSemitone: (NSInteger) semitone {
    self.lastSemitoneFound = semitone;
}
-(NSInteger) getLastSemitone {
    return self.lastSemitoneFound;
}

-(void) setMessageActive: (BOOL) active {
    self.messageStillActive = active;
}
-(BOOL) isMessageActive {
    return self.messageStillActive;
}

-(void) setLastMessageDate:(NSDate*) date {
    self.lastMessageShownDate = date;
}
-(NSDate*) getLastMessageDate {
    return self.lastMessageShownDate;
}

-(void) addNumberOfStringsPlayed {
    self.countStringsPlayed++;
}

-(NSInteger) getNumberOfStringsPlayed {
    return self.countStringsPlayed;
}

-(void) setEstimatedTau:(CGFloat) tau {
    self.tau = tau;
}

-(CGFloat) getEstimatedTau {
    return self.tau;
}

-(void) setSoundPlaying: (BOOL) flag {
    self.isSoundPlayingEnabled = flag;
}

-(BOOL) isSoundPlaying {
    return self.isSoundPlayingEnabled;
}

-(void) setSoundCapturing: (BOOL) flag {
    self.isSoundCapturingEnabled = flag;
}

-(BOOL) isSoundCapturing {
    return self.isSoundCapturingEnabled;
}

-(void) setStringToneFrequency:(CGFloat) freq {
    self.toneFrequency = freq;
}

-(CGFloat) getStringToneFrequency {
    return self.toneFrequency;
}

-(void) setActualNumberOfInstrumentType:(NSInteger)number {
    self.numberOfInstrumentType = number;
}

-(NSInteger) getNumberOfInstrumentType {
    return self.numberOfInstrumentType;
}

-(NSDictionary*) getInstrumentSubtypesDictionary {
    
    NSDictionary* instrumentDictionary = @{ UKE_TYPE_01     : @[ @1,   @[@"D",@"G",@"B",@"E"],    @[@587.3,@392.0,@493.88,@659.26]],
                                            UKE_TYPE_02     : @[ @2,   @[@"C",@"F",@"A",@"D"],    @[@523.25,@349.23,@440.0,@587.33]],
                                            UKE_TYPE_03     : @[ @3,   @[@"A",@"D",@"F#",@"B"],   @[@440.0,@293.66,@370.0,@493.88]],
                                            UKE_TYPE_04     : @[ @4,   @[@"G",@"C",@"E",@"A"],    @[@392.0,@261.63,@329.63,@440.0]],
                                            UKE_TYPE_05     : @[ @5,   @[@"A",@"D",@"F#",@"B"],   @[@440.0,@293.66,@370.0,@493.88]],
                                            UKE_TYPE_06     : @[ @6,   @[@"G",@"C",@"E",@"A"],    @[@392.0,@261.63,@329.63,@440.0]],
                                            UKE_TYPE_07     : @[ @7,   @[@"A",@"D",@"F#",@"B"],   @[@440.0,@293.66,@370.0,@493.88]],
                                            UKE_TYPE_08     : @[ @8,   @[@"G",@"C",@"E",@"A"],    @[@392.0,@261.63,@329.63,@440.0]],
                                            UKE_TYPE_09     : @[ @9,   @[@"G",@"C",@"E",@"A"],    @[@196.0,@261.63,@329.63,@440.0]],
                                            UKE_TYPE_10     : @[ @10,  @[@"D",@"G",@"B",@"E"],    @[@293.66,@196.0,@246.94,@329.63]],
                                            UKE_TYPE_11     : @[ @11,  @[@"D",@"G",@"B",@"E"],    @[@146.83,@196.0,@246.94,@329.63]],
                                            UKE_TYPE_12     : @[ @12,  @[@"E",@"A",@"D",@"G"],    @[@41.2,@55.0,@73.42,@98.0]]
                                            };
    
    return instrumentDictionary;
}

-(NSArray*) getOrderedSubtypesArray {
    
    NSDictionary *dict = [self getInstrumentSubtypesDictionary];
    NSArray *orderedKeys = [dict keysSortedByValueUsingComparator:^NSComparisonResult(id obj1, id obj2){
        return [obj1[0] compare:obj2[0]];
    }];
    
    return orderedKeys;
}


// Background color issues
-(NSDictionary*) getColorsDict {
    NSDictionary *colorsDict = @{
                                 INSTRUMENT_COLOR_DEFAULT: BACKGROUND_COLOR_01,
                                 INSTRUMENT_COLOR_WHITE: BACKGROUND_COLOR_02,
                                 INSTRUMENT_COLOR_ORANGE: BACKGROUND_COLOR_03,
                                 INSTRUMENT_COLOR_RED: BACKGROUND_COLOR_04,
                                 INSTRUMENT_COLOR_GREEN: BACKGROUND_COLOR_05,
                                 INSTRUMENT_COLOR_BLUE: BACKGROUND_COLOR_06,
                                 INSTRUMENT_COLOR_PINK: BACKGROUND_COLOR_07,
                                 INSTRUMENT_COLOR_GAY: INSTRUMENT_COLOR_GAY // special case: make rainbow colors
                                 };
    return colorsDict;
}

-(NSArray*) getColorsArray {
    NSArray *colorsArray = @[
                             INSTRUMENT_COLOR_DEFAULT,
                             INSTRUMENT_COLOR_WHITE,
                             INSTRUMENT_COLOR_ORANGE,
                             INSTRUMENT_COLOR_RED,
                             INSTRUMENT_COLOR_GREEN,
                             INSTRUMENT_COLOR_BLUE,
                             INSTRUMENT_COLOR_PINK,
                             INSTRUMENT_COLOR_GAY
                             ];
    return colorsArray;
}

// colors for header in conjunction with colors above
-(UIColor*) getHeaderColor: (NSString*) mainColor {
    NSArray *bgColorsArray = @[
                             HEADER_BACKGROUND_COLOR_01, // default
                             HEADER_BACKGROUND_COLOR_02,
                             HEADER_BACKGROUND_COLOR_03,
                             HEADER_BACKGROUND_COLOR_04,
                             HEADER_BACKGROUND_COLOR_05,
                             HEADER_BACKGROUND_COLOR_06,
                             HEADER_BACKGROUND_COLOR_07,
                             HEADER_BACKGROUND_COLOR_08
                             ];
    
    NSInteger index = 0;
    
    for (NSString* str in [self getColorsArray]) {
        
        if ([str isEqualToString:mainColor]) {
            return bgColorsArray[index];
        }
        index++;
        
    }
    return nil;
}

-(void) setEdgeFrequencyArray:(NSArray *)edgeFrequencyArray {
    _edgeFrequencyArray = edgeFrequencyArray;
}


-(NSInteger)getCurrentSamplingRate {
    if (!self.currentSamplingRate) {
        self.currentSamplingRate = PREFERRED_SAMPLING_RATE;
    }
    return self.currentSamplingRate;
}


@end
