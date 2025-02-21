//
//  InstrumentContext.m
//  Simple Ukulele Tuner
//
//  Created by Ulrich Vormbrock on 27.06.16.
//  Copyright © 2016 Ulrich Vormbrock. All rights reserved.
//

#import "InstrumentContext.h"

@implementation InstrumentContext

+ (id)sharedContext {
    static InstrumentContext *sharedContext = nil;
    @synchronized(self) {
        if (sharedContext == nil)
            sharedContext = [[self alloc] init];
    }
    return sharedContext;
}

- (id)init {
    if (self = [super init]) {
 
    }
    return self;
}

- (NSInteger) getNumberOfStrings {
    
    return [self getFrequenciesArray].count;
}

- (NSArray *) getFrequenciesArray {
    
    NSString* defaultSubtype = [self getInstrumentSubtype];
    
    NSDictionary *instrDict = [SHARED_MANAGER getInstrumentSubtypesDictionary];
    NSArray* frequenciesArray = [instrDict objectForKey:defaultSubtype][2];
    
    return frequenciesArray;
}

- (CGFloat) getFrequencyShiftFactor {

    NSString* defaultSubtype = [self getInstrumentSubtype];
    
    NSDictionary *instrDict = [SHARED_MANAGER getInstrumentSubtypesDictionary];
    CGFloat frequencyShiftFactor = [[instrDict objectForKey:defaultSubtype][3] floatValue];
    
    return frequencyShiftFactor;
}

- (NSArray *) getStringNamesArray {
    
    NSString* defaultSubtype = [self getInstrumentSubtype];
    
    NSDictionary *instrDict = [SHARED_MANAGER getInstrumentSubtypesDictionary];
    NSArray* stringNamesArray = [instrDict objectForKey:defaultSubtype][1];
    
    return stringNamesArray;
}

- (NSString *) getInstrumentSubtype {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString* subtype;
#if defined(TARGET_UKULELE)
    subtype = [defaults stringForKey:KEY_UKE_TYPE];
#elif defined(TARGET_GUITAR)
    subtype = [defaults stringForKey:KEY_GUITAR_TYPE];
#elif defined(TARGET_MANDOLIN)
    subtype = [defaults stringForKey:KEY_MANDOLIN_TYPE];
#elif defined(TARGET_BANJO)
    subtype = [defaults stringForKey:KEY_BANJO_TYPE];
#elif defined(TARGET_VIOLIN)
    subtype = [defaults stringForKey:KEY_VIOLIN_TYPE];
#elif defined(TARGET_BALALAIKA)
    subtype = [defaults stringForKey:KEY_BALALAIKA_TYPE];
#endif
    return subtype;
}

- (void) updateInstrumentSubtype:(NSString *) subtype {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
#if defined(TARGET_UKULELE)
    [defaults setObject:subtype forKey:KEY_UKE_TYPE];
#elif defined(TARGET_GUITAR)
    [defaults setObject:subtype forKey:KEY_GUITAR_TYPE];
#elif defined(TARGET_MANDOLIN)
    [defaults setObject:subtype forKey:KEY_MANDOLIN_TYPE];
#elif defined(TARGET_BANJO)
    [defaults setObject:subtype forKey:KEY_BANJO_TYPE];
#elif defined(TARGET_VIOLIN)
    [defaults setObject:subtype forKey:KEY_VIOLIN_TYPE];
#elif defined(TARGET_BALALAIKA)
    [defaults setObject:subtype forKey:KEY_BALALAIKA_TYPE];
#endif
    
    [defaults synchronize];
}

@end
