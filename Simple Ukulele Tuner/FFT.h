//
//  FFT.h
//  Diapaxon
//
//  Created by imac on 02.05.15.
//  Copyright (c) 2015 Vormbrock. All rights reserved.
//

#import <Accelerate/Accelerate.h>
#include <MacTypes.h>

@interface FFT : NSObject

- (NSMutableArray*) performFFT: (float*) data  withFrames: (NSInteger) numberOfFrames;
- (void) clearMemory;


@end
