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

-(void) setActualNumberOfUkeType:(NSInteger)number {
    self.numberOfUkeType = number;
    
    // now get min and max frequency
    NSArray *frequencyArray = [self getUkuleleFrequencies];
    
    NSNumber* min = [frequencyArray valueForKeyPath:@"@min.self"];
    NSNumber* max = [frequencyArray valueForKeyPath:@"@max.self"];
    
    [self setEdgeFrequencyArray:@[min, max]];
}

-(NSInteger) getNumberOfUkeType {
    return self.numberOfUkeType;
}


// Sound types issues
-(NSArray*) getUkuleleTypesArray {
    NSArray *ukeTypesArray = @[
                                UKU_TYPE_01,
                                UKU_TYPE_02,
                                UKU_TYPE_03,
                                UKU_TYPE_04,
                                UKU_TYPE_05,
                                UKU_TYPE_06,
                                UKU_TYPE_07,
                                UKU_TYPE_08,
                                UKU_TYPE_09,
                                UKU_TYPE_10,
                                UKU_TYPE_11,
                                UKU_TYPE_12
                             ];
    return ukeTypesArray;
}

-(NSArray*) getUkuleleNotesArray {
    NSArray *ukeNotesArray = @[
                               @[@"D",@"G",@"B",@"E"], // D5 - G4 - B4 - E5
                               @[@"C",@"F",@"A",@"D"], // C5 - F4 - A4 - D5
                               @[@"A",@"D",@"F♯",@"B"], // A4 - D4 - F#4 - B4
                               @[@"G",@"C",@"E",@"A"], // G4 - C4 - E4 - A4
                               @[@"A",@"D",@"F♯",@"B"], // A4 - D4 - F#4 - B4
                               @[@"G",@"C",@"E",@"A"], // G4 - C4 - E4 - A4
                               @[@"A",@"D",@"F♯",@"B"], // A4 - D4 - F#4 - B4
                               @[@"G",@"C",@"E",@"A"], // G4 - C4 - E4 - A4
                               @[@"G",@"C",@"E",@"A"], // G3 - C4 - E4 - A4
                               @[@"D",@"G",@"B",@"E"], // D4 - G3 - B3 - E4
                               @[@"D",@"G",@"B",@"E"], // D3 - G3 - B3 - E4
                               @[@"E",@"A",@"D",@"G"]  // E1 - A1 - D2 - G2
                               ];
    return ukeNotesArray[self.numberOfUkeType];
}

// ukulele frequencies
-(NSArray*) getUkuleleFrequencies {
    NSArray *ukeFrequenciesArray = @[
                               @[@587.3,@392.0,@493.88,@659.26], // D5 - G4 - B4 - E5
                               @[@523.25,@349.23,@440.0,@587.33], // C5 - F4 - A4 - D5
                               @[@440.0,@293.66,@370.0,@493.88], // A4 - D4 - F#4 - B4
                               @[@392.0,@261.63,@329.63,@440.0], // G4 - C4 - E4 - A4
                               @[@440.0,@293.66,@370.0,@493.88], // A4 - D4 - F#4 - B4
                               @[@392.0,@261.63,@329.63,@440.0], // G4 - C4 - E4 - A4
                               @[@440.0,@293.66,@370.0,@493.88], // A4 - D4 - F#4 - B4
                               @[@392.0,@261.63,@329.63,@440.0], // G4 - C4 - E4 - A4
                               @[@196.0,@261.63,@329.63,@440.0], // G3 - C4 - E4 - A4
                               @[@293.66,@196.0,@246.94,@329.63], // D4 - G3 - B3 - E4
                               @[@146.83,@196.0,@246.94,@329.63], // D3 - G3 - B3 - E4
                               @[@41.2,@55.0,@73.42,@98.0]  // E1 - A1 - D2 - G2
                               ];
    return ukeFrequenciesArray[self.numberOfUkeType];
}


// Background color issues
-(NSDictionary*) getColorsDict {
    NSDictionary *colorsDict = @{
                                 GUITAR_COLOR_DEFAULT: BACKGROUND_COLOR_01,
                                 GUITAR_COLOR_WHITE: BACKGROUND_COLOR_02,
                                 GUITAR_COLOR_ORANGE: BACKGROUND_COLOR_03,
                                 GUITAR_COLOR_RED: BACKGROUND_COLOR_04,
                                 GUITAR_COLOR_GREEN: BACKGROUND_COLOR_05,
                                 GUITAR_COLOR_BLUE: BACKGROUND_COLOR_06,
                                 GUITAR_COLOR_PINK: BACKGROUND_COLOR_07,
                                 GUITAR_COLOR_GAY: GUITAR_COLOR_GAY // special case: make rainbow colors
                                 };
    return colorsDict;
}

-(NSArray*) getColorsArray {
    NSArray *colorsArray = @[
                             GUITAR_COLOR_DEFAULT,
                             GUITAR_COLOR_WHITE,
                             GUITAR_COLOR_ORANGE,
                             GUITAR_COLOR_RED,
                             GUITAR_COLOR_GREEN,
                             GUITAR_COLOR_BLUE,
                             GUITAR_COLOR_PINK,
                             GUITAR_COLOR_GAY
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

-(NSArray *) getEdgeFrequencyArray {
    return self.edgeFrequencyArray;
}

-(NSInteger)getCurrentSamplingRate {
    if (!self.currentSamplingRate) {
        self.currentSamplingRate = PREFERRED_SAMPLING_RATE;
    }
    return self.currentSamplingRate;
}


@end
