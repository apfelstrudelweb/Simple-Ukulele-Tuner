//
//  ButtonView.m
//  Simple Guitar Tuner
//
//  Created by imac on 22.06.15.
//  Copyright (c) 2015 Vormbrock. All rights reserved.
//

#import "ButtonView.h"

@interface ButtonView() {
    
    BOOL microphoneIsActive;
    SoundProcessor *processor;
}

@end

@implementation ButtonView


- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        processor = [SoundProcessor new];
        
        // microphone button
        self.microphoneButton = [UIButton buttonWithType:UIButtonTypeCustom];
        NSString* imageName1 = @"microphoneOn.png";
        UIImage* micIcon = [UIImage imageNamed:imageName1];
        [self.microphoneButton  setImage:micIcon forState:UIControlStateNormal];
        [self.microphoneButton setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.microphoneButton addTarget:self action:@selector(toggleMicrophone:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:self.microphoneButton];
        
        // settings button
        self.settingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
        NSString* imageName2 = @"settings.png";
        UIImage* settingsIcon = [UIImage imageNamed:imageName2];
        [self.settingsButton  setImage:settingsIcon forState:UIControlStateNormal];
        [self.settingsButton setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.settingsButton addTarget:self action:@selector(showSettings:) forControlEvents:UIControlEventTouchUpInside];
        
        
        [self addSubview:self.settingsButton];
        
        [self setupConstraints];
        
        // when app enters in background, stop current tasks
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(handleEnteredBackground:)
                                                     name: UIApplicationDidEnterBackgroundNotification
                                                   object: nil];
        
        // fixed frequency from sound file (strings E A D G B E')
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleMicrophone:)
                                                     name:@"PlayToneNotification"
                                                   object:nil];
        
        
    }
    return self;
}

#pragma mark - NSNotificationCenter
// if sound is played, disable microphone!
- (void) handleMicrophone:(NSNotification *) notification {
    if ([notification.object isKindOfClass:[SoundFile class]]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            BOOL isActive = ((SoundFile*)[notification object]).isActive;
            //NSLog(@"is active: %d", isActive);
            self.microphoneButton.enabled = !isActive;
        });
    } else {
        NSLog(@"Error, object not recognised.");
    }
}

- (void) toggleMicrophone:(NSNotification *) notification {
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    
    // AZ DEBUG @@ iOS 7+
    AVAudioSessionRecordPermission sessionRecordPermission = [session recordPermission];
    
    if (sessionRecordPermission == AVAudioSessionRecordPermissionDenied) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Microphone disabled"
                                                        message:@"You must first enable the microphone for this app. Go to Settings -> Simple Ukulele Tuner and turn the microphone switch on."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    microphoneIsActive = !microphoneIsActive;
    
    NSString* imageName = microphoneIsActive ? @"microphoneOff.png" : @"microphoneOn.png";
    UIImage* micIcon = [UIImage imageNamed:imageName];
    [self.microphoneButton  setImage:micIcon forState:UIControlStateNormal];
    
    // start/stop audio processing
    if (microphoneIsActive==YES) {
 
        [SHARED_MANAGER setSoundCapturing:YES];
        [processor captureSound];
    } else {
        [SHARED_MANAGER setSoundCapturing:NO];
        [processor stopCapture];
    }
    
    // disable settings button when microphone is active
    self.settingsButton.enabled = !microphoneIsActive;
    
}

- (void)handleEnteredBackground:(NSNotification *) notification {
    
    NSString* imageName = @"microphoneOn.png";
    UIImage* micIcon = [UIImage imageNamed:imageName];
    [self.microphoneButton  setImage:micIcon forState:UIControlStateNormal];
    microphoneIsActive = NO;
    [processor stopCapture];
}

// make modal window for user defined settings
- (void) showSettings:(NSNotification *) notification {
    UIWindow* window = [UIApplication sharedApplication].keyWindow;

    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    self.settingsView = [[SettingsView alloc] initWithFrame: CGRectMake ( 0, 0, screenWidth, screenHeight)];

    [window addSubview:self.settingsView];
}

#pragma mark - Layout Constraints
- (void)setupConstraints {
    
    CGFloat iconSize = IS_IPAD ? 120.0 : 60.0;
    
    [self removeConstraints:[self constraints]];
    
    NSMutableArray *layoutConstraints = [NSMutableArray new];
    
    // Microphone
    // Center vertically
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.microphoneButton
                                                              attribute:NSLayoutAttributeCenterY
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeCenterY
                                                             multiplier:1.0
                                                               constant:0.0]];
    
    // Center horizontally
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.microphoneButton
                                                              attribute:NSLayoutAttributeCenterX
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeCenterX
                                                             multiplier:1.0
                                                               constant:0.0]];
    
    // Width
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.microphoneButton
                                                              attribute:NSLayoutAttributeWidth
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeWidth
                                                             multiplier:0.0
                                                               constant:iconSize]];
    
    // Height
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.microphoneButton
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeHeight
                                                             multiplier:0.0
                                                               constant:iconSize]];
    
    // Settings
    // Center vertically
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.settingsButton
                                                              attribute:NSLayoutAttributeCenterY
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeCenterY
                                                             multiplier:1.0
                                                               constant:0.0]];
    
    // Center horizontally
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.settingsButton
                                                              attribute:NSLayoutAttributeRight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeRight
                                                             multiplier:1.0
                                                               constant:0.0]];
    
    // Width
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.settingsButton
                                                              attribute:NSLayoutAttributeWidth
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeWidth
                                                             multiplier:0.0
                                                               constant:0.6*iconSize]];
    
    // Height
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.settingsButton
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeHeight
                                                             multiplier:0.0
                                                               constant:0.6*iconSize]];
    
    
    // add all constraints at once
    [self addConstraints:layoutConstraints];
    
}

-(void)dealloc {
    //NSLog(@"%s", __PRETTY_FUNCTION__);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
