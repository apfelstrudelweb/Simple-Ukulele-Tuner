//
//  SoundFile.h
//  Diapason
//
//  Created by imac on 31.03.15.
//  Copyright (c) 2015 Vormbrock. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SoundFile : NSObject

@property BOOL isActive;
@property (strong, retain) NSNumber* toneNumber;
@property (strong, retain) NSNumber* frequency;
@property (strong, retain) NSNumber* octave;

- (NSString*) getSoundFile;

@end
