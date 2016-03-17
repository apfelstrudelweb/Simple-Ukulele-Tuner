//
//  CalibrationPicker.m
//  Simple Ukulele Tuner
//
//  Created by Ulrich Vormbrock on 08.03.16.
//  Copyright © 2016 Vormbrock. All rights reserved.
//

#import "CalibrationPicker.h"

#import "CalibrationPicker.h"
#import "UILabel+uvo.h"

@interface CalibrationPicker() {
    id selectedEntry;
    
    CGFloat pickerWidth;
    CGFloat pickerHeight;
    
    CGFloat calibratedFrequency;
}

@end

@implementation CalibrationPicker


- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        calibratedFrequency = [[defaults stringForKey:@"calibratedFrequency"] floatValue];
        
        //self.backgroundColor = [UIColor lightGrayColor];
        self.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"settingsPatternDark.png"]];
        
        pickerWidth = self.frame.size.width;
        pickerHeight = self.frame.size.height;
        
        self.freqPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, 0.8*pickerWidth, pickerHeight)];
        self.freqPicker.delegate = self;
        self.freqPicker.dataSource = self;
        self.freqPicker.showsSelectionIndicator = YES;
        
        // default: 440.0 Hz
        NSString *freqString = [NSString stringWithFormat:@"%f", 10*calibratedFrequency];
        
        NSString *first = [freqString substringWithRange:NSMakeRange(0, 1)];
        NSString *second = [freqString substringWithRange:NSMakeRange(1, 1)];
        NSString *third = [freqString substringWithRange:NSMakeRange(2, 1)];
        NSString *fourth = [freqString substringWithRange:NSMakeRange(3, 1)];
        
        [self.freqPicker selectRow:[first intValue] inComponent:0 animated:YES];
        [self.freqPicker selectRow:[second intValue] inComponent:1 animated:YES];
        [self.freqPicker selectRow:[third intValue] inComponent:2 animated:YES];
        [self.freqPicker selectRow:[fourth intValue] inComponent:3 animated:YES];
        
        
        [self addSubview:self.freqPicker];
        
        
        UILabel *decSepLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.55*pickerWidth, 0.36*pickerHeight, pickerHeight, 0.25*pickerHeight)];
        
        [decSepLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:1.5*[UILabel getFontSizeForHeadline]]];
        decSepLabel.textColor = [UIColor whiteColor];
        
        decSepLabel.text = @".";
        [self.freqPicker addSubview:decSepLabel];
        
        
        self.submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.submitButton addTarget:self
                              action:@selector(submitValue:)
                    forControlEvents:UIControlEventTouchUpInside];
        [self.submitButton setTitle:@"OK" forState:UIControlStateNormal];
        [self.submitButton setTitleColor:[UIColor colorWithRed:0.09 green:0.82 blue:0.09 alpha:1.0] forState:UIControlStateNormal];
        self.submitButton.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:[UILabel getFontSizeForHeadline]];
        
        //[self.submitButton sizeToFit];
        
        self.submitButton.frame = CGRectMake(0.8*pickerWidth, 0.45*pickerHeight, 0.2*pickerWidth, 20);
        [self addSubview:self.submitButton];
        
    }
    return self;
}

#pragma mark -UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 4;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)componen {
    return 10;
}

#pragma mark -UIPickerViewDelegate
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    return [NSString stringWithFormat:@"%ld",(long)row];
    
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    
    if (component < 3) {
        return pickerWidth / 6;
    } else {
        return pickerWidth / 5.0;
    }
    
}


- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    
    UILabel* tView = (UILabel*)view;
    if (!tView)
    {
        tView = [[UILabel alloc] init];
        [tView setFont:[UIFont fontWithName:@"Helvetica-Bold" size:[UILabel getFontSizeForHeadline]]];
        tView.textAlignment = NSTextAlignmentCenter;
        tView.text = [NSString stringWithFormat:@"%ld",(long)row];
        
        if (component == 3) {
            tView.textColor = [UIColor colorWithRed:0.50 green:0.91 blue:0.50 alpha:1.0];
        } else {
            tView.textColor = [UIColor colorWithRed:0.09 green:0.82 blue:0.09 alpha:1.0];
        }
        
        // 440.0 Hz should be drawn in different color
        if ( (component==0 && row==4) || (component==1 && row==4) || (component==2 && row==0) || (component==3 && row==0) ) {
            tView.textColor = [UIColor whiteColor];
        }
    }
    return tView;
}


#pragma mark -UIButton event
- (void)submitValue:(UIButton *)button {
    
    NSString *str100 = [self pickerView:self.freqPicker titleForRow:[self.freqPicker selectedRowInComponent:0] forComponent:0];
    NSString *str10 = [self pickerView:self.freqPicker titleForRow:[self.freqPicker selectedRowInComponent:1] forComponent:1];
    NSString *str1 = [self pickerView:self.freqPicker titleForRow:[self.freqPicker selectedRowInComponent:2] forComponent:2];
    NSString *str01 = [self pickerView:self.freqPicker titleForRow:[self.freqPicker selectedRowInComponent:3] forComponent:3];
    
    CGFloat selectedFreq10 = [[NSString stringWithFormat:@"%@%@%@", str100, str10, str1] floatValue];
    CGFloat selectedFreq01 = [[NSString stringWithFormat:@"%@", str01] floatValue] / 10.0;
    CGFloat selectedFreq = selectedFreq10 + selectedFreq01;
    
    if ( (440.0 - selectedFreq > 10.0) || (selectedFreq - 440.0) > 60.0 ) {
        
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Warning"
                                                          message:@"The calibration frequency must be between 430 Hz and 500 Hz."
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        
        [message show];
        
        return;
    }
    
    
    
    [self.delegate setCalibratedFrequeny:selectedFreq];
    
    [self removeFromSuperview];
}


@end
