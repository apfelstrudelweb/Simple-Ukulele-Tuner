//
//  BridgeView.h
//  Simple Guitar Tuner
//
//  Created by imac on 22.06.15.
//  Copyright (c) 2015 Vormbrock. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BridgeView : UIView

@property (strong, retain) LedView* ledView;
@property (strong, retain) StringButtonView* stringButtonView;

@property (strong, retain) UIImageView* arrowUpView;
@property (strong, retain) UIImageView* arrowDownView;

@end
