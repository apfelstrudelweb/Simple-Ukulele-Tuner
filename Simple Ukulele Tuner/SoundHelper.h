//
//  SoundHelper.h
//  Simple Guitar Tuner
//
//  Created by imac on 02.07.15.
//  Copyright (c) 2015 Vormbrock. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

@interface SoundHelper : NSObject {
@public
    CGFloat toneFrequency;
}

+ (id)sharedSoundHelper;

- (void) playTone: (NSInteger) number;
- (void) stopTone;




@end

