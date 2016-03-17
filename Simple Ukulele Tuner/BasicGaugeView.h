//
//  BasicGaugeView.h
//  Diapason
//
//  Created by imac on 01.04.15.
//  Copyright (c) 2015 Vormbrock. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BasicGaugeView : UIView

@property (strong, retain) CAGradientLayer *gradient;

- (void) addMeter;

@end
