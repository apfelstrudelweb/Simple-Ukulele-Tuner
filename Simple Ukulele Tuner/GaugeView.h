//
//  GaugeView.h
//  Simple Guitar Tuner
//
//  Created by imac on 22.06.15.
//  Copyright (c) 2015 Vormbrock. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GaugeView : UIView
@property (strong, retain) UIImageView* gaugeBackgroundImageView;
@property (strong, retain) HorizontalPicker* picker;
@end
