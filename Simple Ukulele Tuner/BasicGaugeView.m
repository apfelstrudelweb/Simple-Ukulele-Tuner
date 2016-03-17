//
//  BasicGaugeView.m
//  Diapason
//
//  Created by imac on 01.04.15.
//  Copyright (c) 2015 Vormbrock. All rights reserved.
//

#import "BasicGaugeView.h"

@interface BasicGaugeView() {

    CALayer *rightBorder;
    CGFloat bottomBorderWidth;
}
@end

@implementation BasicGaugeView


- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateGauge:)
                                                     name:@"UpdateVolumeNotification"
                                                   object:nil];
        
    }
    return self;
}



- (void)layoutSubviews {

    // make corner for the coloured meter
    CGFloat height = self.frame.size.height;
    self.layer.cornerRadius = 0.5 * height;
    self.layer.masksToBounds = YES;

    [self addMeter];
}

- (void) addMeter {
    
    if (self.gradient==nil) {
        
        self.gradient = [CAGradientLayer layer];
        
        UIColor *blueColour = [UIColor colorWithRed:0.43 green:0.62 blue:0.92 alpha:1.0];
        UIColor *greenColour = [UIColor colorWithRed:0.35 green:0.98 blue:0.35 alpha:1.0];
        UIColor *yellowColour = [UIColor colorWithRed:1.00 green:0.91 blue:0.00 alpha:1.0];
        UIColor *redColour = [UIColor colorWithRed:1.00 green:0.0 blue:0.00 alpha:1.0];
        self.gradient.colors = [NSArray arrayWithObjects:(id)[blueColour CGColor],(id)[greenColour CGColor], (id)[yellowColour CGColor], (id)[redColour CGColor], nil];
        
        
        CGFloat width = self.bounds.size.width;
        CGFloat height = self.bounds.size.height;
        
        CGFloat fact = 2.5;
        
        CGRect bounds = CGRectMake(0.0, 0.0, width/fact, height);
        self.gradient.bounds = bounds;
        
        self.gradient.anchorPoint = CGPointZero;
        
        self.gradient.startPoint = CGPointMake(0, 0.0);
        self.gradient.endPoint = CGPointMake(fact, 0.0);
        
        self.gradient.locations = @[@0.0, @0.2, @0.5, @1.0];
        
        [self.layer addSublayer:self.gradient];
    }
    
}

#pragma mark - Notification
-(void) updateGauge:(NSNotification *) notification {
    if ([notification.object isKindOfClass:[NSNumber class]]) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //[animation adjustFrequency:freq];
            
            CGFloat dbVal = [(NSNumber*)[notification object] floatValue];
            
            CGFloat width = self.bounds.size.width;
            CGFloat height = self.bounds.size.height - bottomBorderWidth;
            
            CGFloat newX = (100.0+dbVal)*width/100.0;
            
            CGFloat fact = width/newX;
            
            CGRect bounds = CGRectMake(0.0, 0.0, newX, height);
            self.gradient.bounds = bounds;
            self.gradient.endPoint = CGPointMake(fact, 0.0);
            
            
            if (rightBorder) {
                [rightBorder removeFromSuperlayer];
            }
            
            CGFloat lineWidth = IS_IPAD ? 8.0 : 4.0;
            
            rightBorder = [CALayer layer];
            rightBorder.borderColor = [UIColor redColor].CGColor;
            rightBorder.borderWidth = lineWidth;
            rightBorder.frame = CGRectMake(CGRectGetWidth(self.gradient.bounds)-lineWidth, 0, lineWidth, CGRectGetHeight(self.gradient.bounds));
            
            [self.gradient addSublayer:rightBorder];

        });
    } else {
        NSLog(@"Error, object not recognized.");
    }
}



-(void)dealloc {
    //NSLog(@"%s", __PRETTY_FUNCTION__);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
