//
//  MainView.m
//  Diapason
//
//  Created by imac on 13.03.15.
//  Copyright (c) 2015 Vormbrock. All rights reserved.
//

#import "MainView.h"

#define ALPHA_INACTIVE 0.2

@interface MainView() {
    BOOL load;
    BOOL isGraphEnabled;
    
    NSUserDefaults *defaults;
}
@property NSDictionary *viewsDictionary;
@end

@implementation MainView


- (id)initWithFrame:(CGRect)frame {
    
    [self checkVersion];
    
    self = [super initWithFrame:frame];
    
    _viewsDictionary = @{ @"header"      : self.headerView,
                          @"graph"       : self.graphView,
                          @"tab"         : self.tabView,
                          @"bridge"      : self.bridgeView,
                          @"type"        : self.instrumentSubtypeView,
                          @"meter"       : self.meterView,
                          @"deviation"      : self.deviationView,
                          @"gauge"       : self.gaugeView,
                          @"button"      : self.buttonView};

    
    if (self) {
        
        CGSize size = [[UIScreen mainScreen] bounds].size;
        
        // make header's background color red -> entire width
        self.headerBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, size.width, 0.01*[SUBVIEW_PROPORTIONS[0] floatValue]*size.height)];
        
        defaults = [NSUserDefaults standardUserDefaults];
        NSString* colorString = [defaults stringForKey:KEY_INSTRUMENT_COLOR];
        [self.headerBackgroundView setBackgroundColor:[SHARED_MANAGER getHeaderColor:colorString]];
        
        [self addSubview:self.headerBackgroundView];
        
        [self addSubview:self.headerView];
        [self addSubview:self.graphView];
        [self addSubview:self.tabView];
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
    
    defaults = [NSUserDefaults standardUserDefaults];
    NSString* colorString = [defaults stringForKey:KEY_INSTRUMENT_COLOR];
    [self.headerBackgroundView setBackgroundColor:[SHARED_MANAGER getHeaderColor:colorString]];
    
    [self setBackgroundImage];
    
    [self setNeedsDisplay];
}

- (void) updateVersion:(NSNotification *) notification {
    
    [self checkVersion];
    
    _graphView.alpha = isGraphEnabled ? 1.0 : ALPHA_INACTIVE;
    _tabView.alpha = isGraphEnabled ? 1.0 : ALPHA_INACTIVE;
    
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
- (HeaderView*) headerView {
    if (_headerView == nil) {
        _headerView = [HeaderView new];
        _headerView.layer.borderColor = [UIColor whiteColor].CGColor;
        [_headerView setTranslatesAutoresizingMaskIntoConstraints:NO];
    }
    return _headerView;
}

- (GraphView*) graphView {
    if (_graphView == nil) {
        _graphView = [GraphView new];
        _graphView.layer.borderColor = [UIColor whiteColor].CGColor;
        _graphView.alpha = isGraphEnabled ? 1.0 : ALPHA_INACTIVE;
        [_graphView setTranslatesAutoresizingMaskIntoConstraints:NO];
    }
    return _graphView;
}

- (TabView*) tabView {
    if (_tabView == nil) {
        _tabView = [TabView new];
        _tabView.layer.borderColor = [UIColor whiteColor].CGColor;
        _tabView.alpha = isGraphEnabled ? 1.0 : ALPHA_INACTIVE;
        [_tabView setTranslatesAutoresizingMaskIntoConstraints:NO];
    }
    return _tabView;
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

    NSInteger numberOfStrings = [SHARED_CONTEXT getNumberOfStrings];
    
    NSString *backgrImgName;
    
    if (numberOfStrings == 4) {
        backgrImgName = @"background4";
    } else if (numberOfStrings == 5) {
        backgrImgName = @"background5";
    } else {
        backgrImgName = @"background6";
    }

    
    UIGraphicsBeginImageContext(self.frame.size);
    [[UIImage imageNamed:backgrImgName] drawInRect:self.bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.backgroundColor = [UIColor colorWithPatternImage:image];
}


#pragma mark -layout constraints
- (void)setupLayoutConstraintsPro {
    
    CGSize size = [[UIScreen mainScreen] bounds].size;
    CGFloat screenHeight = size.height;
    // let a space on top and bottom of the display
    CGFloat effectiveScreenHeight = screenHeight;// - 2*MARGIN;
    CGFloat minFactor = effectiveScreenHeight/screenHeight;
    
    NSString* verticalVisualFormatText = [NSString stringWithFormat:@"V:|-%d-[header]-%d-[graph]-%d-[tab]-%d-[bridge]-%d-[type]-%d-[meter]-%d-[deviation]-%d-[gauge]-%d-[button]", 0, 0, 0, 0, 0, 0, 0, 0, 0];
    
    NSArray *verticalPositionConstraints = [NSLayoutConstraint constraintsWithVisualFormat:verticalVisualFormatText
                                                                                   options:0
                                                                                   metrics:nil
                                                                                     views:_viewsDictionary];
    
    NSArray* viewsArray = @[self.headerView, self.graphView, self.tabView, self.bridgeView, self.instrumentSubtypeView, self.meterView, self.deviationView, self.gaugeView, self.buttonView];
    
    
    for (NSInteger i=0; i<SUBVIEW_PROPORTIONS.count;i++) {
        
        CGFloat factor = [SUBVIEW_PROPORTIONS[i] floatValue];
        UIView* view = viewsArray[i];
        CGFloat width = CONTENT_WIDTH;
        
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
