//
//  SettingsMenuView.h
//  Simple Guitar Tuner
//
//  Created by imac on 03.07.15.
//  Copyright (c) 2015 Vormbrock. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UpgradeView.h"

@interface SettingsMenuView : UIView <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate>

@property (nonatomic, strong) UITableView* tableView;
@property (strong, nonatomic) UpgradeView *upgradeView;
@property (nonatomic, strong) UIView* loadingView;

@end
