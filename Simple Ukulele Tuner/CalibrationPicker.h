//
//  CalibrationPicker.h
//  Simple Ukulele Tuner
//
//  Created by Ulrich Vormbrock on 08.03.16.
//  Copyright © 2016 Vormbrock. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CalibratorDelegate<NSObject>
@required
- (void) setCalibratedFrequeny: (CGFloat) frequency;
@end

@interface CalibrationPicker : UIView <UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, strong) UIButton *submitButton;
@property (nonatomic, strong) UIPickerView *freqPicker;

@property (nonatomic, weak) id<CalibratorDelegate> delegate;

@end
