//
//  SettingsView.h
//  Simple Guitar Tuner
//
//  Created by imac on 02.07.15.
//  Copyright (c) 2015 Vormbrock. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsView : UIView

@property (strong, nonatomic) UIView *headerBackgroundView;
@property (strong, nonatomic) SettingsHeaderView *headerView;
@property (strong, nonatomic) SettingsMenuView *menuView;


@end
