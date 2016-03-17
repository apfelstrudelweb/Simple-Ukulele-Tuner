
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>


@class HorizontalPicker;


@interface HorizontalPicker : UIView {
    CGFloat value;
    
    NSInteger steps;
    CGFloat minimumValue;
    CGFloat maximumValue;
    
    CGFloat fontSize;
    
    @private
    CGFloat scale; 
}

- (void)snapToMarkerAnimated:(BOOL)animated;

- (CGFloat)minimumValue;
- (void)setMinimumValue:(CGFloat)newMin;

- (CGFloat)maximumValue;
- (void)setMaximumValue:(CGFloat)newMax;


- (CGFloat)value;
- (void)setValue:(CGFloat)newValue inOctave:(NSInteger) octave;

- (void)setBackground:(NSInteger)deviation;

@end