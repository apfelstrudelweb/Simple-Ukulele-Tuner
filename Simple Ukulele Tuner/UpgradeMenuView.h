//
//  UpgradeView.h
//  Simple Ukulele Tuner
//
//  Created by Ulrich Vormbrock on 03.08.15.
//  Copyright (c) 2015 Vormbrock. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UpgradeMenuView : UIView <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate>

@property (nonatomic, strong) UITableView* tableView;
@property (nonatomic, strong) UIView* loadingView;

@end
