//
//  InstrumentContext.h
//  Simple Ukulele Tuner
//
//  Created by Ulrich Vormbrock on 27.06.16.
//  Copyright © 2016 Ulrich Vormbrock. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InstrumentContext : NSObject

+ (id)sharedContext;

@property NSInteger numberOfStrings;
@property(strong, nonatomic) NSArray *frequenciesArray;
@property(strong, nonatomic) NSArray *stringNamesArray;
@property(strong, nonatomic) NSString *instrumentSubtype;

- (NSInteger) getNumberOfStrings;
- (NSArray *) getFrequenciesArray;
- (NSArray *) getStringNamesArray;
- (NSString *) getInstrumentSubtype;

- (void) updateInstrumentSubtype:(NSString *) subtype;

@end
