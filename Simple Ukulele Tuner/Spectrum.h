//
//  Spectrum.h
//  Diapason
//
//  Created by imac on 15.03.15.
//  Copyright (c) 2015 Vormbrock. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Spectrum : NSObject <UIAlertViewDelegate>

//@property bool isFFT;
@property (strong, retain) NSNumber* frequency;
@property (strong, retain) NSNumber* stringFrequency;
@property (strong, retain) NSArray* data;
@property (strong, retain) NSNumber* deviation;
@property BOOL tuneUp;
@property (strong, retain) NSNumber* alpha;
@property (strong, retain) NSNumber* toneNumber;
@property (strong, retain) NSString* toneName;
@property (strong, retain) NSNumber* octave;
@property (strong, retain) NSNumber* bin;
@property BOOL isNegativeDeviation;

@property (strong, retain) NSNumber* volume;

- (void) calculateDeviation;
- (CGFloat) getCenterFrequency;
@end
