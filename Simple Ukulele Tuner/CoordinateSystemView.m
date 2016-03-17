//
//  CoordinateSystemView.m
//  
//
//  Created by imac on 17.06.15.
//
//

#import "CoordinateSystemView.h"

//#define OUTER_BORDER_COLOR  [UIColor colorWithRed:0.15 green:0.91 blue:0.42 alpha:0.7]
#define GRID_COLOR [UIColor colorWithRed:0.286 green:0.298 blue:0.318 alpha:1]

//#define ALPHA_ON 0.75

#define NUMBER_VERT_LINES_AUTOCORR 15

#define LOG_LABELS @[@"",@"20",@"",@"", @"50",@"",@"",@"",@"", @"100",@"200",@"",@"",@"500", @"",@"", @"",@"",@"1k", @"",@""]

#define LINEAR_LABELS @[@"",@"500",@"",@"",@"", @"100",@"",@"",@"",@"", @"50",@"",@"",@"40",@"", @"",@"", @"",@"",@"", @"",@""]

@interface CoordinateSystemView(){
    
    CGFloat gridThickness;
    NSMutableArray* fftComponentsArray;
    NSMutableArray* autoComponentsArray;
}

@end

@implementation CoordinateSystemView


- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        gridThickness = IS_IPAD ? 2.0 : 1.0;

        self.layers = [NSMutableArray new];
        
        //[self createInfoLabel:frame];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateView:)
                                                     name:@"ChangeGraphModeNotification"
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                         selector:@selector(updateView:)
                                                            name:@"ChangeGraphModeNotification"
                                                           object:nil];
        
        
    }
    return self;
}

- (CurveSubView*) curveView {
    if (_curveView == nil) {
        _curveView = [CurveSubView new];
        _curveView.backgroundColor = [UIColor clearColor];
        [_curveView setTranslatesAutoresizingMaskIntoConstraints:NO];
    }
    return _curveView;
}

- (void)layoutSubviews {
    
    /*
     *  IMPORTANT for "Toggle-In Status Bar Notification":
     *  prevents that elements are displayed twice!
     *  In such case, the method "layoutSubviews" is triggered
     */
    // remove autocorrelation-specific elements from view
    for (UIView* comp in autoComponentsArray) {
        [comp removeFromSuperview];
    }
    // remove FFT-specific elements from view
    for (UIView* comp in fftComponentsArray) {
        [comp removeFromSuperview];
    }
    
    if ([SHARED_MANAGER isFFT]) {
        [self drawLogarithmicAxis];
    } else {
        [self drawLinearAxis];
        [self drawMiddleLine];
    }
    
    [self drawHorizontalLines];
    
    [self addSubview:self.curveView];
    
    [self setupCurveViewConstraints];
}

-(void) updateView:(NSNotification *) notification {

    if ([SHARED_MANAGER isFFT]) {
        [self drawLogarithmicAxis];
        // remove autocorrelation-specific elements from view
        for (UIView* comp in autoComponentsArray) {
            [comp removeFromSuperview];
        }
    } else {
        [self drawLinearAxis];
        // remove FFT-specific elements from view
        for (UIView* comp in fftComponentsArray) {
            [comp removeFromSuperview];
        }
    }
    
}

- (void) drawLogarithmicAxis {
    
    if (!fftComponentsArray) {
        fftComponentsArray = [NSMutableArray new];
    }

    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    
    CGFloat numIterations = 3; // (10...100), (110...1000), (1100...10000)
    
    // 1. calculate factor for logarithmic summation so that 2 log sections (à 10) fit into the box
    CGFloat fact = 0.866 * width / log10(10) / (numIterations-1);
    
    // 2. draw logarithmic lines and labels below (10 Hz ... 2.000 Hz)
    CGFloat offset = 0;
    
    NSArray* labelArray = LOG_LABELS;
    
    NSInteger index = 0;
    
    for (NSInteger i=0; i<numIterations; i++) {
        
        NSInteger startIndex = i==0 ? 1 : 2;
        NSInteger endIndex = i==numIterations-1 ? 3 : 11;
        
        for (NSInteger j=startIndex; j<endIndex; j++) {
  
            offset = i*fact*log10(10);
            
            CGFloat lineHeight = self.frame.size.height;
            
            NSString* labelText = labelArray[index++];
            
            if (![@"" isEqualToString:labelText]) {
                
                NSInteger fontSize = IS_IPAD ? 20 : 12;
                
                UILabel* label=[[UILabel alloc]initWithFrame:CGRectMake(offset + fact*log10(j)-fontSize, height, 2*fontSize, 1.3*fontSize)];
                
  
                [label setText:labelText];
                [label setFont:[UIFont fontWithName:@"Helvetica-Bold" size:fontSize]];
                [label setTextColor:[UIColor whiteColor]];
                [label setTextAlignment:NSTextAlignmentCenter];
                
                [self addSubview:label];//Add it to the view of your choice.
                
                [fftComponentsArray addObject:label];

            }
            
            if ((i==0 && j>1) || (i>0 && i<numIterations-2) || (i>0 && i<numIterations-1 && j<endIndex)) {
                UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(offset + fact*log10(j), 0, gridThickness, lineHeight)];
                lineView.backgroundColor = GRID_COLOR;
                [self addSubview:lineView];
                [fftComponentsArray addObject:lineView];
            }
        }
    }

}

- (void) drawLinearAxis {
    
    if (!autoComponentsArray) {
        autoComponentsArray = [NSMutableArray new];
    }
    
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    
    CGFloat fact = width/(NUMBER_VERT_LINES_AUTOCORR+1);
    
    NSInteger endIndex = NUMBER_VERT_LINES_AUTOCORR+1;
    
    NSArray* labelArray = LINEAR_LABELS;
    
    for (NSInteger i=1; i<endIndex; i++) {
        
        CGFloat xPos = fact*i;
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(xPos, 0, gridThickness, height)];
        lineView.backgroundColor = GRID_COLOR;
        lineView.alpha = 0.7;
        [self addSubview:lineView];
        [autoComponentsArray addObject:lineView];
        
        
        NSString* labelText = labelArray[i];
        
        if (![@"" isEqualToString:labelText]) {
            
            NSInteger fontSize = IS_IPAD ? 20 : 12;
            
            UILabel* label=[[UILabel alloc]initWithFrame:CGRectMake(xPos-fontSize, height, 2*fontSize, 1.3*fontSize)];
            
            
            [label setText:labelText];
            [label setFont:[UIFont fontWithName:@"Helvetica-Bold" size:fontSize]];
            [label setTextColor:[UIColor whiteColor]];
            [label setTextAlignment:NSTextAlignmentCenter];
            
            [self addSubview:label];//Add it to the view of your choice.
            
            [autoComponentsArray addObject:label];
            
        }
    }
    
}

- (void) drawHorizontalLines {
    
    CGFloat numberOfLines = 10;
    CGFloat lineWidth = self.frame.size.width;
    CGFloat linePos = self.frame.size.height/numberOfLines;
    
    for (NSInteger i=1; i<numberOfLines+1; i++) {
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, linePos*i, lineWidth, gridThickness)];
        lineView.backgroundColor = GRID_COLOR;
        lineView.alpha = 0.7;
        [self addSubview:lineView];
        
        [fftComponentsArray addObject:lineView];
    }
}

- (void) drawMiddleLine {
    CGFloat lineWidth = self.frame.size.width;
    CGFloat linePos = self.frame.size.height/2;
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, linePos, lineWidth, 2*gridThickness)];
    lineView.backgroundColor = GRID_COLOR;
    lineView.alpha = 0.7;
    [self addSubview:lineView];
    
    [autoComponentsArray addObject:lineView];
}

#pragma mark -NSNotificationCenter
-(void) toggleView:(NSNotification *) notification {
    SoundFile* sf = ((SoundFile*)[notification object]);
    if (sf.isActive) {
        self.alpha = 0.0;
    } else {
        self.alpha = 1.0;
    }
}

- (void) setupCurveViewConstraints {
    
    NSMutableArray *layoutConstraints = [NSMutableArray new];
    
    // Center vertically
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.curveView
                                                              attribute:NSLayoutAttributeCenterY
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeCenterY
                                                             multiplier:1.0
                                                               constant:0.0]];
    
    // Center horizontally
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.curveView
                                                              attribute:NSLayoutAttributeCenterX
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeCenterX
                                                             multiplier:1.0
                                                               constant:0.0]];
    
    // Height
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.curveView
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeHeight
                                                             multiplier:1.0
                                                               constant:0.0]];
    
    // Width
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.curveView
                                                              attribute:NSLayoutAttributeWidth
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeWidth
                                                             multiplier:1.0
                                                               constant:0.0]];
    
    
    
    [self addConstraints:layoutConstraints];
}

-(void)dealloc {
    //NSLog(@"%s", __PRETTY_FUNCTION__);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
