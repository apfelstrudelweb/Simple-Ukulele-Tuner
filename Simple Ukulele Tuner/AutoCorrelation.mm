//
//  AutoCorrelation.m
//  Diapason
//
//  Created by imac on 14.04.15.
//  Copyright (c) 2015 Vormbrock. All rights reserved.
//

#import "AutoCorrelation.h"

@implementation AutoCorrelation


- (NSMutableArray*) performAutocorrelation: (float*) data  withFrames: (NSInteger) numberOfFrames {

    NSMutableArray* result = [NSMutableArray new];

    
    CGFloat sum;
    // minimal frequency 21.83 Hz (F0)
    NSInteger upperLimit = numberOfFrames/3;

    
    for (NSInteger i=0; i<=upperLimit; i++) {
        sum = 0;
        
        CGFloat x = 0.0;
        CGFloat y = 0.0;
        
        for (NSInteger j=0; j<upperLimit-i; j++) {
            
            x = data[j];
            y = data[j+i];
            
            CGFloat diff = x*y;
            sum += diff;
            
        }
        result[i] = [NSNumber numberWithFloat:sum]; //[NSNumber numberWithFloat:data[i]]; // for test only ...
    }
    return result;
}
@end
