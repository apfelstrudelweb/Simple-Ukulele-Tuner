//
//  ViolinStringView.m
//  Simple Ukulele Tuner
//
//  Created by Ulrich Vormbrock on 15.08.17.
//  Copyright © 2017 Ulrich Vormbrock. All rights reserved.
//

#import "ViolinStringView.h"

@implementation ViolinStringView

- (id)initWithFrame:(CGRect)frame {
    
    
    self = [super initWithFrame:frame];
    
    if (self) {
        
//        CGSize size = [[UIScreen mainScreen] bounds].size;
//        
//        UIGraphicsBeginImageContext(size);
//        [[UIImage imageNamed:@"string_G.png"] drawInRect:[[UIScreen mainScreen] bounds]]; // G, D, A, E
//        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
//        UIGraphicsEndImageContext();
//        self.backgroundColor = [UIColor colorWithPatternImage:image];
        
        // input from microphone
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateLed:)
                                                     name:@"UpdateDataNotification"
                                                   object:nil];
        
        // fixed frequency from sound file (strings E A D G B E')
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateLed:)
                                                     name:@"PlayToneNotification"
                                                   object:nil];
    }
    
    return self;
}

-(void) updateLed:(NSNotification *) notification {
    
    self.backgroundColor = [UIColor clearColor];
    
    if ([notification.object isKindOfClass:[SoundFile class]]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            

            
            SoundFile* sf = (SoundFile*)[notification object];
            NSInteger toneNumber = [sf.toneNumber intValue];
            
            if (sf.isActive) {
                
                NSString *imageName = @"";
                
                switch (toneNumber) {
                    case 0: imageName = @"string_G.png"; break;
                    case 1: imageName = @"string_D.png"; break;
                    case 2: imageName = @"string_A.png"; break;
                    case 3: imageName = @"string_E.png"; break;
                }

                
                UIGraphicsBeginImageContext([[UIScreen mainScreen] bounds].size);
                [[UIImage imageNamed:imageName] drawInRect:[[UIScreen mainScreen] bounds]]; // G, D, A, E
                UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                self.backgroundColor = [UIColor colorWithPatternImage:image];
                
            }
            
        });
    } else if ([notification.object isKindOfClass:[Spectrum class]]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            

            
            Spectrum* spectrum = (Spectrum*)[notification object];
            CGFloat alpha = [spectrum.alpha floatValue];
            //CGFloat capturedFrequency = [spectrum.frequency floatValue] - frequencyOffset;
            
            
        });
    } else {
        NSLog(@"updateLed: error with notification type");
    }
    
}


@end
