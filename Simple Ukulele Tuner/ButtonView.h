//
//  ButtonView.h
//  Simple Guitar Tuner
//
//  Created by imac on 22.06.15.
//  Copyright (c) 2015 Vormbrock. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ButtonView : UIView

@property (strong, retain) UIButton* microphoneButton;
@property (strong, retain) UIButton* settingsButton;
@property (strong, retain) SettingsView* settingsView;

@end
