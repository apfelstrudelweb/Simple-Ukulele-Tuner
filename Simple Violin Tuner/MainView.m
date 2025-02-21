//
//  MainView.m
//  Diapason
//
//  Created by imac on 13.03.15.
//  Copyright (c) 2015 Vormbrock. All rights reserved.
//

#import "MainView.h"
#import "PremiumView.h"

#define ALPHA_INACTIVE 0.2

@interface MainView() {
    BOOL load;
    BOOL isGraphEnabled;
    
    NSUserDefaults *defaults;
}
@property NSDictionary *viewsDictionary;
@property (strong, nonatomic) PremiumView *premiumView;
@end

@implementation MainView


- (id)initWithFrame:(CGRect)frame {
    
    [self checkVersion];
    
    self = [super initWithFrame:frame];
    
    _viewsDictionary = @{
                          @"premium"     : self.premiumView,
                          @"bridge"      : self.bridgeView,
                          @"type"        : self.instrumentSubtypeView,
                          @"meter"       : self.meterView,
                          @"deviation"   : self.deviationView,
                          @"gauge"       : self.gaugeView,
                          @"button"      : self.buttonView};
    
    
    if (self) {
        
        CGSize size = [[UIScreen mainScreen] bounds].size;
        
        // make header's background color red -> entire width
        self.headerBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, size.width, 0.01*[SUBVIEW_PROPORTIONS[0] floatValue]*size.height)];
        
        defaults = [NSUserDefaults standardUserDefaults];
        NSString* colorString = [defaults stringForKey:KEY_INSTRUMENT_COLOR];
        [self.headerBackgroundView setBackgroundColor:[SHARED_MANAGER getHeaderColor:colorString]];
        
        
        [self addSubview:self.violinStringView];
        
        
        NSMutableArray *layoutConstraints = [NSMutableArray new];
        // Width
        [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.violinStringView
                                                                  attribute:NSLayoutAttributeWidth
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self
                                                                  attribute:NSLayoutAttributeWidth
                                                                 multiplier:1.0
                                                                   constant:0.0]];
        
        // Height
        [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.violinStringView
                                                                  attribute:NSLayoutAttributeHeight
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self
                                                                  attribute:NSLayoutAttributeHeight
                                                                 multiplier:1.0
                                                                   constant:0.0]];
        [self addConstraints:layoutConstraints];
        
        
        [self addSubview:self.premiumView];
        [self addSubview:self.bridgeView];
        [self addSubview:self.instrumentSubtypeView];
        [self addSubview:self.meterView];
        [self addSubview:self.deviationView];
        [self addSubview:self.gaugeView];
        [self addSubview:self.buttonView];
        
        
        // layout constraints
        [self setupLayoutConstraintsPro];
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarFrameWillChange:) name:UIApplicationWillChangeStatusBarFrameNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateBackground:)
                                                     name:@"UpdateDefaultsNotification"
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateVersion:)
                                                     name:@"UpdateVersionNotification"
                                                   object:nil];
        
        
    }
    return self;
}

- (void) updateBackground:(NSNotification *) notification {
    
    NSString* colorString = [defaults stringForKey:KEY_INSTRUMENT_COLOR];
    [self.headerBackgroundView setBackgroundColor:[SHARED_MANAGER getHeaderColor:colorString]];
    
    
    [self setBackgroundImage];
    
    [self setNeedsDisplay];
}

- (void) updateVersion:(NSNotification *) notification {
    
    [self checkVersion];
    
    _premiumView.alpha = isGraphEnabled ? 1.0 : ALPHA_INACTIVE;
    _premiumView.alpha = isGraphEnabled ? 1.0 : ALPHA_INACTIVE;
    
    [self setNeedsDisplay];
}

- (void)checkVersion {
    NSString* currentVersion = [SHARED_VERSION_MANAGER getVersion];
    
    if ([version_signal isEqualToString:currentVersion] || [version_premium isEqualToString:currentVersion]) {
        isGraphEnabled = YES;
    }
}


- (void)statusBarFrameWillChange:(NSNotification *)note {
    
    for (CALayer *layer in self.graphView.layers) {
        [layer removeFromSuperlayer];
    }
    
}



#pragma mark -view instantiations

- (ViolinStringView*) violinStringView {
    if (_violinStringView == nil) {
        _violinStringView = [ViolinStringView new];
        [_violinStringView setTranslatesAutoresizingMaskIntoConstraints:NO];
        //_violinStringView.backgroundColor = [UIColor greenColor];
    }
    return _violinStringView;
}


- (PremiumView*) premiumView {
    if (_premiumView == nil) {
        _premiumView = [PremiumView new];
        _premiumView.layer.borderColor = [UIColor whiteColor].CGColor;
        [_premiumView setTranslatesAutoresizingMaskIntoConstraints:NO];
        //_premiumView.backgroundColor = [UIColor greenColor];
    }
    return _premiumView;
}


- (BridgeView*) bridgeView {
    if (_bridgeView == nil) {
        _bridgeView = [BridgeView new];
        _bridgeView.layer.borderColor = [UIColor whiteColor].CGColor;
        [_bridgeView setTranslatesAutoresizingMaskIntoConstraints:NO];
    }
    return _bridgeView;
}

- (InstrumentSubtypeView*) instrumentSubtypeView {
    if (_instrumentSubtypeView == nil) {
        _instrumentSubtypeView = [InstrumentSubtypeView new];
        _instrumentSubtypeView.layer.borderColor = [UIColor whiteColor].CGColor;
        [_instrumentSubtypeView setTranslatesAutoresizingMaskIntoConstraints:NO];
    }
    return _instrumentSubtypeView;
}

- (MeterView*) meterView {
    if (_meterView == nil) {
        _meterView = [MeterView new];
        _meterView.layer.borderColor = [UIColor whiteColor].CGColor;
        [_meterView setTranslatesAutoresizingMaskIntoConstraints:NO];
        //_meterView.backgroundColor = [UIColor blueColor];
    }
    return _meterView;
}

- (DeviationView*) deviationView {
    if (_deviationView == nil) {
        _deviationView = [DeviationView new];
        _deviationView.layer.borderColor = [UIColor whiteColor].CGColor;
        [_deviationView setTranslatesAutoresizingMaskIntoConstraints:NO];
    }
    return _deviationView;
}

- (GaugeView*) gaugeView {
    if (_gaugeView == nil) {
        _gaugeView = [GaugeView new];
        _gaugeView.layer.borderColor = [UIColor whiteColor].CGColor;
        [_gaugeView setTranslatesAutoresizingMaskIntoConstraints:NO];
    }
    return _gaugeView;
}

- (ButtonView*) buttonView {
    if (_buttonView == nil) {
        _buttonView = [ButtonView new];
        _buttonView.layer.borderColor = [UIColor whiteColor].CGColor;
        [_buttonView setTranslatesAutoresizingMaskIntoConstraints:NO];
    }
    return _buttonView;
}


- (void)layoutSubviews {
    [self setBackgroundImage];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ApplicationDidFinishLoading" object:nil];
}

- (void) setBackgroundImage {

    NSString *backgrImgName = IS_IPAD ?  @"violin_ipad" : @"violin_iphone";
        
    UIImage *bgImage = [UIImage imageNamed:backgrImgName];
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    UIGraphicsBeginImageContextWithOptions(screenSize, NO, 0.f);
    [bgImage drawInRect:CGRectMake(0.f, 0.f, screenSize.width, screenSize.height)];
    UIImage * resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIColor *backgroundColor = [UIColor colorWithPatternImage:resultImage];
    self.backgroundColor = backgroundColor;
}


#pragma mark -layout constraints
- (void)setupLayoutConstraintsPro {
    
    CGSize size = [[UIScreen mainScreen] bounds].size;
    CGFloat screenHeight = size.height;
    // let a space on top and bottom of the display
    CGFloat effectiveScreenHeight = screenHeight;// - 2*MARGIN;
    CGFloat minFactor = effectiveScreenHeight/screenHeight;
    
    NSString* verticalVisualFormatText = [NSString stringWithFormat:@"V:|-%d-[premium]-%d-[bridge]-%d-[type]-%d-[meter]-%d-[deviation]-%d-[gauge]-%d-[button]", 0, 0, 0, 0, 0, 0, 0];
    
    NSArray *verticalPositionConstraints = [NSLayoutConstraint constraintsWithVisualFormat:verticalVisualFormatText
                                                                                   options:0
                                                                                   metrics:nil
                                                                                     views:_viewsDictionary];
    
    NSArray* viewsArray = @[self.premiumView, self.bridgeView, self.instrumentSubtypeView, self.meterView, self.deviationView, self.gaugeView, self.buttonView];
    
    
    for (NSInteger i=0; i<SUBVIEW_PROPORTIONS.count;i++) {
        
        CGFloat factor = [SUBVIEW_PROPORTIONS[i] floatValue];
        UIView* view = viewsArray[i];
        CGFloat width = i==0 ? 1.0 : CONTENT_WIDTH;
        
        NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:view
                                                                           attribute:NSLayoutAttributeWidth
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:self
                                                                           attribute:NSLayoutAttributeWidth
                                                                          multiplier:width
                                                                            constant:0];
        
        NSLayoutConstraint *centerConstraint = [NSLayoutConstraint constraintWithItem:view
                                                                            attribute:NSLayoutAttributeCenterX
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:self
                                                                            attribute:NSLayoutAttributeCenterX
                                                                           multiplier:1.0
                                                                             constant:0];
        
        NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:view
                                                                            attribute:NSLayoutAttributeHeight
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:self
                                                                            attribute:NSLayoutAttributeHeight
                                                                           multiplier:minFactor*factor/100.0
                                                                             constant:0];
        
        [self addConstraint:widthConstraint];
        [self addConstraint:centerConstraint];
        [self addConstraint:heightConstraint];
    }
    
    
    for (NSInteger i = 0; i<verticalPositionConstraints.count; i++) {
        [self addConstraint:verticalPositionConstraints[i]];
    }
}


-(void)dealloc {
    //NSLog(@"%s", __PRETTY_FUNCTION__);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
