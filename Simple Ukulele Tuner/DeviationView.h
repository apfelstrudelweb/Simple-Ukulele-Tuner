//
//  DeviationView.h
//  Simple Guitar Tuner
//
//  Created by imac on 22.06.15.
//  Copyright (c) 2015 Vormbrock. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DeviationView : UIView

@property (strong, retain) UILabel* toneLabel;

@property (strong, retain) UIView* devView_m3;
@property (strong, retain) UIView* devView_m2;
@property (strong, retain) UIView* devView_m1;
@property (strong, retain) UIView* devView_center;
@property (strong, retain) UIView* devView_p1;
@property (strong, retain) UIView* devView_p2;
@property (strong, retain) UIView* devView_p3;

@end
