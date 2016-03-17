//
//  UpgradeView.h
//  Simple Ukulele Tuner
//
//  Created by Ulrich Vormbrock on 06.08.15.
//  Copyright (c) 2015 Vormbrock. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UpgradeMenuView.h"
#import "UpgradeHeaderView.h"

@interface UpgradeView : UIView

@property (strong, nonatomic) UIView *headerBackgroundView;
@property (strong, nonatomic) UpgradeHeaderView *headerView;
@property (strong, nonatomic) UpgradeMenuView *menuView;

@end
