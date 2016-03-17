//
//  SoundFile.m
//  Diapason
//
//  Created by imac on 31.03.15.
//  Copyright (c) 2015 Vormbrock. All rights reserved.
//

#import "SoundFile.h"

@implementation SoundFile

- (NSString*) getSoundFile {
    
    switch ([self.toneNumber intValue]) {
        case 0: return @"tone_e_low";
        case 1: return @"tone_a";
        case 2: return @"tone_d";
        case 3: return @"tone_g";
        case 4: return @"tone_h";
        case 5: return @"tone_e_high";
        default: return nil;
    }
}

@end
