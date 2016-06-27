//
//  BackgroundView.m
//  Simple Guitar Tuner
//
//  Created by imac on 04.07.15.
//  Copyright (c) 2015 Vormbrock. All rights reserved.
//

#import "BackgroundView.h"

@interface BackgroundView() {
    NSDictionary* colorsDict;
    CAGradientLayer *gradient;
    NSUserDefaults *defaults;
}
@end

@implementation BackgroundView


- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    
    if (self) {
  
        colorsDict = [SHARED_MANAGER getColorsDict];
        
        defaults = [NSUserDefaults standardUserDefaults];
        NSString* colorString = [defaults stringForKey:KEY_INSTRUMENT_COLOR];
        
        id color = [colorsDict objectForKey:colorString];
        
        if ([INSTRUMENT_COLOR_GAY isEqual:color]) {
            [self makeBackgroundGay];
        } else {
            self.backgroundColor = (UIColor*)color;
        }
        
        // draw sound hole as part of background image (guitar)
        [self addSubview:self.circleView];
        [self addSubview:self.mainView];
        
        [self setupLayoutConstraints];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateBackground:)
                                                     name:@"UpdateDefaultsNotification"
                                                   object:nil];
        
        
    }
    return self;
}

#pragma mark - Notification
- (void) updateBackground:(NSNotification *) notification {
    
    NSString* colorString = [defaults stringForKey:KEY_INSTRUMENT_COLOR];
    
    
    if (gradient) {
        [gradient removeFromSuperlayer];
    }
    
    id color = [colorsDict objectForKey:colorString];
    
    if ([INSTRUMENT_COLOR_GAY isEqual:color]) {
        [self makeBackgroundGay];
    } else {
        //[gradient removeFromSuperlayer];
        self.backgroundColor = (UIColor*)color;
    }
    
    [self setNeedsDisplay];
}


- (void) makeBackgroundGay {
    
    gradient = [CAGradientLayer layer];
    
    UIColor *c1 = [UIColor colorWithRed:0.60 green:0.00 blue:1.00 alpha:1.0]; // lila
    UIColor *c2 = [UIColor colorWithRed:0.23 green:0.23 blue:0.91 alpha:1.0]; // blue
    UIColor *c3 = [UIColor colorWithRed:0.32 green:0.84 blue:0.09 alpha:1.0]; // green
    UIColor *c4 = [UIColor colorWithRed:1.00 green:1.00 blue:0.00 alpha:1.0]; // yellow
    UIColor *c5 = [UIColor colorWithRed:1.00 green:0.62 blue:0.00 alpha:1.0]; // orange
    UIColor *c6 = [UIColor colorWithRed:1.00 green:0.00 blue:0.00 alpha:1.0]; // red
    
    gradient.colors = [NSArray arrayWithObjects:(id)[c1 CGColor],(id)[c2 CGColor], (id)[c3 CGColor], (id)[c4 CGColor],(id)[c5 CGColor],(id)[c6 CGColor], nil];
    
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat width = screenRect.size.width;
    CGFloat height = screenRect.size.height;
    
    
    CGRect bounds = CGRectMake(0.0, 0.0, width, height);
    gradient.bounds = bounds;
    
    gradient.anchorPoint = CGPointZero;
    
    gradient.startPoint = CGPointMake(0.0, 0.5);
    gradient.endPoint = CGPointMake(1.0, 0.5);
    
    NSMutableArray* locationsarray = [NSMutableArray new];
    
    CGFloat fact = 1.0/6.0;
    CGFloat pos = 0.0;
    
    for (NSInteger i=0; i<6; i++) {
        [locationsarray addObject:[NSNumber numberWithFloat:pos]];
        pos += fact;
    }
    
    gradient.locations = locationsarray;
    
    [self.layer insertSublayer:gradient atIndex:0];
}


#pragma mark -view instantiations
- (MainView*) mainView {
    if (_mainView == nil) {
        _mainView = [MainView new];
        [_mainView setTranslatesAutoresizingMaskIntoConstraints:NO];
    }
    return _mainView;
}

// draw the sound hole of the guitar (we don't use png for it)

- (CircleView*) circleView {
    
    if (_circleView == nil) {
        
        _circleView = [CircleView new];
        _circleView.backgroundColor = [UIColor blackColor];
        
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGFloat width = screenRect.size.width;
        CGFloat height = screenRect.size.height;
        
        CGFloat posY = IS_IPAD ? 0.6*height/2 : 0.65*height/2;
        
        CAShapeLayer *shape = [CAShapeLayer layer];
        UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(width/2, posY) radius:(width/4.0) startAngle:0 endAngle:(2 * M_PI) clockwise:YES];
        shape.path = path.CGPath;
        _circleView.layer.mask = shape;
        [_circleView setTranslatesAutoresizingMaskIntoConstraints:NO];
    }
    
    return _circleView;
}

- (void)setupLayoutConstraints {
    
    [self removeConstraints:[self constraints]];
    
    NSMutableArray *layoutConstraints = [NSMutableArray new];
    
    
    // Center vertically
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.mainView
                                                              attribute:NSLayoutAttributeBaseline
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeBaseline
                                                             multiplier:1.0
                                                               constant:0.0]];
    
    // Center horizontally
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.mainView
                                                              attribute:NSLayoutAttributeRight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeRight
                                                             multiplier:1.0
                                                               constant:0.0]];
    
    // Width
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.mainView
                                                              attribute:NSLayoutAttributeWidth
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeWidth
                                                             multiplier:1.0
                                                               constant:0.0]];
    
    // Height
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.mainView
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeHeight
                                                             multiplier:1.0
                                                               constant:0.0]];
    
    // CIRCLE VIEW
    
    // Center vertically
    
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.circleView
                                                              attribute:NSLayoutAttributeTop
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeTop
                                                             multiplier:1.0
                                                               constant:0.0]];
    
    // Center horizontally
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.circleView
                                                              attribute:NSLayoutAttributeCenterX
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeCenterX
                                                             multiplier:1.0
                                                               constant:0.0]];
    
    // Width
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.circleView
                                                              attribute:NSLayoutAttributeWidth
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeWidth
                                                             multiplier:1.0
                                                               constant:0.0]];
    
    // Height
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.circleView
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeHeight
                                                             multiplier:1.0
                                                               constant:0.0]];
    
    // add all constraints at once
    [self addConstraints:layoutConstraints];
    
}

-(void)dealloc {
    //NSLog(@"%s", __PRETTY_FUNCTION__);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
