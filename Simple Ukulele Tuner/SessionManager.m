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
@synthesize spectrum;
@synthesize isMinVolumeReached;


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
    
    NSDictionary* instrumentDictionary;
    
#if defined(TARGET_UKULELE)
    //                                            order    tone names                  frequencies (Hz)               frequency multiplication ("Tuning by ear")
    instrumentDictionary = @{ UKE_TYPE_01     : @[ @1,   @[@"D",@"G",@"B",@"E"],    @[@587.3,@392.0,@493.88,@659.26],               @0.5],
                              UKE_TYPE_02     : @[ @2,   @[@"C",@"F",@"A",@"D"],    @[@523.25,@349.23,@440.0,@587.33],              @0.5],
                              UKE_TYPE_03     : @[ @3,   @[@"A",@"D",@"F#",@"B"],   @[@440.0,@293.66,@370.0,@493.88],               @0.5],
                              UKE_TYPE_04     : @[ @4,   @[@"G",@"C",@"E",@"A"],    @[@392.0,@261.63,@329.63,@440.0],               @0.5],
                              UKE_TYPE_05     : @[ @5,   @[@"A",@"D",@"F#",@"B"],   @[@440.0,@293.66,@370.0,@493.88],               @0.5],
                              UKE_TYPE_06     : @[ @6,   @[@"G",@"C",@"E",@"A"],    @[@392.0,@261.63,@329.63,@440.0],               @0.5],
                              UKE_TYPE_07     : @[ @7,   @[@"A",@"D",@"F#",@"B"],   @[@440.0,@293.66,@370.0,@493.88],               @0.5],
                              UKE_TYPE_08     : @[ @8,   @[@"G",@"C",@"E",@"A"],    @[@392.0,@261.63,@329.63,@440.0],               @0.5],
                              UKE_TYPE_09     : @[ @9,   @[@"G",@"C",@"E",@"A"],    @[@196.0,@261.63,@329.63,@440.0],               @0.5],
                              UKE_TYPE_10     : @[ @10,  @[@"D",@"G",@"B",@"E"],    @[@293.66,@196.0,@246.94,@329.63],              @1.0],
                              UKE_TYPE_11     : @[ @11,  @[@"D",@"G",@"B",@"E"],    @[@146.83,@196.0,@246.94,@329.63],              @1.0],
                              UKE_TYPE_12     : @[ @12,  @[@"E",@"A",@"D",@"G"],    @[@41.2,@55.0,@73.42,@98.0],                    @2.0]
                            };
    
#elif defined(TARGET_GUITAR)
    instrumentDictionary = @{ GUITAR_TYPE_01     : @[ @1,   @[@"E",@"A",@"D",@"G",@"B",@"E"],   @[@82.4,@110.0,@146.8,@196.0,@246.9,@329.6],   @1.0],  //E2-A2=110-D3-G3-B3-E4
                              GUITAR_TYPE_02     : @[ @2,   @[@"D",@"A",@"D",@"G",@"B",@"E"],   @[@73.42,@110.0,@146.8,@196.0,@246.9,@329.6],   @1.0],  //Drop D
                              GUITAR_TYPE_03     : @[ @3,   @[@"C",@"G",@"C",@"F",@"A",@"D"],   @[@64.41,@98.0,@130.81,@174.61,@220.0,@293.66],   @1.0],  // Drop C
                              GUITAR_TYPE_04     : @[ @4,   @[@"D",@"G",@"D",@"G",@"B",@"D"],   @[@73.42,@98.0,@146.83,@196.00,@246.94,@293.66],   @1.0],  // Open G
                              GUITAR_TYPE_05     : @[ @5,   @[@"B",@"E",@"A",@"D",@"G"],        @[@30.87,@41.2,@55.0,@73.4,@98.0],             @2.0],
                              GUITAR_TYPE_06     : @[ @6,   @[@"E",@"A",@"D",@"G",@"C"],        @[@41.2,@55.0,@73.4,@98.0,@130.81],            @2.0],
                              GUITAR_TYPE_07     : @[ @7,   @[@"A#",@"D#",@"G#",@"F",@"F#"],    @[@29.14,@38.89,@51.9,@87.3,@92.5],            @2.0],
                              GUITAR_TYPE_08     : @[ @8,   @[@"A",@"D",@"G",@"C",@"F"],        @[@27.5,@36.7,@49.0,@65.4,@87.3],              @2.0],
                              GUITAR_TYPE_09     : @[ @9,   @[@"E",@"A",@"D",@"G"],             @[@41.2,@55.0,@73.4,@98.0],                    @2.0],
                              GUITAR_TYPE_10     : @[ @10,  @[@"D",@"A",@"D",@"G"],             @[@36.71,@55.0,@73.4,@98.0],                   @2.0],
                              GUITAR_TYPE_11     : @[ @11,  @[@"D#",@"G#",@"C#",@"A#"],         @[@38.89,@51.9,@69.3,@116.54],                 @2.0],
                              GUITAR_TYPE_12     : @[ @12,  @[@"D",@"G",@"C",@"A"],             @[@36.7,@49.0,@65.4,@110],                     @2.0],
                              GUITAR_TYPE_13     : @[ @13,  @[@"B",@"E",@"A",@"D"],             @[@30.87,@41.2,@55.0,@73.4],                   @2.0],
                              GUITAR_TYPE_14     : @[ @14,  @[@"C",@"A",@"D",@"G"],             @[@32.7,@55.0,@73.4,@98.0],                    @2.0]
                            };
    
#elif defined(TARGET_MANDOLIN)
    // up to now only one violin type
    instrumentDictionary = @{ MANDOLIN_TYPE_01     : @[ @1,   @[@"G",@"D",@"A",@"E"],            @[@196.0,@293.7,@440.0,@659.3],               @1.0] // Standard
                              };
#elif defined(TARGET_BANJO)
    instrumentDictionary = @{ BANJO_TYPE_01     : @[ @1,   @[@"D",@"G",@"B",@"E"],              @[@146.8,@196.0,@246.9,@329.6],                @1.0], // Chicago
                              BANJO_TYPE_02     : @[ @2,   @[@"C",@"G",@"B",@"D"],              @[@130.8,@196.0,@246.9,@293.7],                @1.0], // C
                              BANJO_TYPE_03     : @[ @3,   @[@"G",@"D",@"A",@"E"],              @[@98.0,@146.8,@220.0,@329.6],                 @1.0], // Irish Tenor
                              BANJO_TYPE_04     : @[ @4,   @[@"D",@"G",@"B",@"D"],              @[@146.8,@196.0,@246.9,@293.7],                @1.0], // Open G
                              BANJO_TYPE_05     : @[ @5,   @[@"C",@"G",@"D",@"A"],              @[@130.8,@196.0,@293.7,@440.0],                @1.0], // Tenor
                              
                              BANJO_TYPE_06     : @[ @6,   @[@"G",@"D",@"G",@"B",@"D"],         @[@392.0,@146.8,@196.0,@246.9,@293.7],         @1.0], // Standard
                              BANJO_TYPE_07     : @[ @7,   @[@"G",@"C",@"G",@"B",@"D"],         @[@392.0,@130.8,@196.0,@246.9,@293.7],         @1.0], // C
                              BANJO_TYPE_08     : @[ @8,   @[@"G",@"C",@"G",@"C",@"D"],         @[@392.0,@130.8,@196.0,@261.6,@293.7],         @1.0], // Double C
                              BANJO_TYPE_09     : @[ @9,   @[@"A",@"D",@"A",@"D",@"E"],         @[@440.0,@146.8,@220.0,@293.7,@329.6],         @1.0], // Oldtime D
                              BANJO_TYPE_10     : @[ @10,  @[@"A",@"E",@"A",@"C#",@"E"],        @[@440.0,@164.8,@220.0,@277.2,@329.6],         @1.0], // Open A
                              BANJO_TYPE_11     : @[ @11,  @[@"F#",@"D",@"F#",@"A",@"D"],       @[@370.0,@146.8,@185.0,@220.0,@293.7],         @1.0], // Open D
                              BANJO_TYPE_12     : @[ @12,  @[@"G",@"D",@"G",@"C",@"D"],         @[@392.0,@146.8,@196.0,@261.6,@293.7],         @1.0], // Sawmill
                              
                              BANJO_TYPE_13     : @[ @13,   @[@"G",@"G",@"D",@"G",@"B",@"D"],   @[@392.0,@98.0,@146.8,@196.0,@246.9,@293.7],   @1.0], // Open G
                              BANJO_TYPE_14     : @[ @14,   @[@"E",@"A",@"D",@"G",@"B",@"E"],   @[@82.4,@110.0,@146.8,@196.0,@246.9,@329.6],   @1.0]  // Banjo Guitar
                            };

#elif defined(TARGET_VIOLIN)
    // up to now only one violin type
    instrumentDictionary = @{ VIOLIN_TYPE_01     : @[ @1,   @[@"G",@"D",@"A",@"E"],              @[@196.0,@293.7,@440.0,@659.3],               @1.0] // Standard
                              };
#elif defined(TARGET_BALALAIKA)
    instrumentDictionary = @{ BALALAIKA_TYPE_01     : @[ @1,   @[@"E",@"E",@"A"],               @[@659.3,@659.3,@880.0],                 @1.0], // Descant
                              BALALAIKA_TYPE_02     : @[ @2,   @[@"H",@"E",@"A"],               @[@493.9,@659.3,@880.0],                 @1.0], // Piccolo
                              BALALAIKA_TYPE_03     : @[ @3,   @[@"E",@"E",@"A"],               @[@329.6,@329.6,@440.0],                 @1.0], // Prima
                              BALALAIKA_TYPE_04     : @[ @4,   @[@"G",@"H",@"D"],               @[@196.0,@246.9,@293.7],                 @1.0], // Guitar Style
                              BALALAIKA_TYPE_05     : @[ @5,   @[@"A",@"A",@"D"],               @[@220.0,@220.0,@293.7],                 @1.0], // Secunda
                              BALALAIKA_TYPE_06     : @[ @6,   @[@"E",@"E",@"A"],               @[@164.8,@164.8,@220.0],                 @1.0], // Alto
                              BALALAIKA_TYPE_07     : @[ @7,   @[@"E",@"A",@"E"],               @[@164.8,@220.0,@329.6],                 @1.0], // Tenor
                              BALALAIKA_TYPE_08     : @[ @8,   @[@"E",@"A",@"D"],               @[@82.4,@110.0,@146.8],                  @2.0], // Bass
                              BALALAIKA_TYPE_09     : @[ @9,   @[@"E",@"A",@"D"],               @[@41.2,@55.0,@73.4],                    @3.0] // Contrabass
                              };
#endif

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

//-(void)setUniqueSpectrum:(Spectrum *)spectrum {
//    self.spectrum = spectrum;
//}
//
//-(Spectrum*)getSpectrum {
//    return self.spectrum;
//}


@end
