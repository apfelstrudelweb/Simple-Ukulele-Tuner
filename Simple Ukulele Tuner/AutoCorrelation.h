//
//  AutoCorrelation.h
//  Diapason
//
//  Created by imac on 14.04.15.
//  Copyright (c) 2015 Vormbrock. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AutoCorrelation : NSObject

- (NSMutableArray*) performAutocorrelation: (float*) data  withFrames: (NSInteger) numberOfFrames;

@end
