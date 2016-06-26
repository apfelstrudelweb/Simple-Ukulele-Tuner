//
//  SessionManager.h
//  Diapaxon
//
//  Created by imac on 05.05.15.
//  Copyright (c) 2015 Vormbrock. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SessionManager : NSObject

@property BOOL isFFTEnabled;
@property NSInteger countSemitones;
@property NSInteger lastSemitoneFound;
@property BOOL messageStillActive;
@property (strong, nonatomic) NSDate* lastMessageShownDate;
@property NSInteger countStringsPlayed;
@property CGFloat tau;
@property BOOL isSoundPlayingEnabled;
@property BOOL isSoundCapturingEnabled;
@property CGFloat toneFrequency;
@property NSInteger numberOfInstrumentType;
@property (strong, nonatomic) NSArray *edgeFrequencyArray;


@property NSInteger currentSamplingRate;

+ (id)sharedManager;

-(void) setFFT: (BOOL) flag;
-(BOOL) isFFT;

-(void) addSemitone;
-(NSInteger) getNumberOfSemitones;

-(void) setLastSemitone: (NSInteger) semitone;
-(NSInteger) getLastSemitone;

-(void) setMessageActive: (BOOL) active;
-(BOOL) isMessageActive;

-(void) setLastMessageDate:(NSDate*) date;
-(NSDate*) getLastMessageDate;

-(void) addNumberOfStringsPlayed;
-(NSInteger) getNumberOfStringsPlayed;

-(void) setEstimatedTau:(CGFloat) tau;
-(CGFloat) getEstimatedTau;

-(void) setSoundPlaying: (BOOL) flag;
-(BOOL) isSoundPlaying;

-(void) setSoundCapturing: (BOOL) flag;
-(BOOL) isSoundCapturing;

-(void) setStringToneFrequency:(CGFloat) freq;
-(CGFloat) getStringToneFrequency;

-(void) setActualNumberOfInstrumentType:(NSInteger)number;
-(NSInteger) getNumberOfInstrumentType;

//-(void) setEdgeFrequencyArray:(NSArray *)edgeFrequencyArray;
//-(NSArray *) getEdgeFrequencyArray;

-(void) setCurrentSamplingRate:(NSInteger)currentSamplingRate;
-(NSInteger)getCurrentSamplingRate;

-(NSDictionary*) getInstrumentSubtypesDictionary;
-(NSArray*) getOrderedSubtypesArray;


-(NSDictionary*) getColorsDict;
-(NSArray*) getColorsArray;
-(UIColor*) getHeaderColor: (NSString*) mainColor;

@end
