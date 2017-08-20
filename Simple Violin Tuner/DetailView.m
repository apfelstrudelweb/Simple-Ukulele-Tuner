//
//  DetailView.m
//  Simple Ukulele Tuner
//
//  Created by Ulrich Vormbrock on 19.08.17.
//  Copyright © 2017 Ulrich Vormbrock. All rights reserved.
//

#import "DetailView.h"

#define SUBVIEW_PROPORTIONS_DEATILVIEW @[@20.0, @60.0, @20.0]

@interface DetailView() {
    
}

@property (strong, nonatomic) UIButton *btnSlider;
@property NSDictionary *viewsDictionary;

@property (strong, nonatomic) UIView *headerBackgroundView;
@property (strong, nonatomic) HeaderView *headerView;
@property (strong, nonatomic) GraphView *graphView;
@property (strong, nonatomic) TabView *tabView;

@end


@implementation DetailView

- (id)initWithFrame:(CGRect)frame {
    
    
    self = [super initWithFrame:frame];
    
    
    if (self) {
        
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGFloat screenWidth = screenRect.size.width;
        CGFloat screenHeight = screenRect.size.width;
        
        CGFloat buttonWidth = screenWidth / 16.0f;
        CGFloat buttonHeight = 6.0f * buttonWidth;
        
        self.btnSlider = [UIButton buttonWithType:UIButtonTypeCustom];
        self.btnSlider.frame = CGRectMake(screenWidth-buttonWidth, 0.15*screenHeight, buttonWidth, buttonHeight);
        [self.btnSlider setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
        
        [self.btnSlider addTarget:self
                           action:@selector(hideDetailView:)
                 forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:self.btnSlider];
        
        
        _viewsDictionary = @{ @"header"      : self.headerView,
                              @"graph"       : self.graphView,
                              @"tab"         : self.tabView};
        
        [self addSubview:self.headerView];
        [self addSubview:self.graphView];
        [self addSubview:self.tabView];
        
        [self setupLayoutConstraints];
        
        //_headerView.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"headerPattern.png"]];
        
  
 
    }
    return self;
}

-(void)hideDetailView:(id)sender{
    
    
    [UIView animateWithDuration:2.0 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGFloat screenWidth = screenRect.size.width;
        //CGFloat borderX = screenRect.size.width / 15.0f;
        self.frame  =  CGRectOffset(self.frame, -screenWidth, 0.0);
        
    } completion:^(BOOL finished) {
        
        id<DetailViewDelegate> delegate = self.delegate;
        
        if ([delegate respondsToSelector:@selector(closeDetailView)]) {
            [delegate closeDetailView];
        }
    }];
}

- (HeaderView*) headerView {
    if (_headerView == nil) {
        _headerView = [HeaderView new];
        _headerView.layer.borderColor = [UIColor whiteColor].CGColor;
        //_headerView.layer.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"headerPattern"]].CGColor;
        [_headerView setTranslatesAutoresizingMaskIntoConstraints:NO];
    }
    return _headerView;
}

- (GraphView*) graphView {
    if (_graphView == nil) {
        _graphView = [GraphView new];
        _graphView.layer.borderColor = [UIColor whiteColor].CGColor;
        [_graphView setTranslatesAutoresizingMaskIntoConstraints:NO];
    }
    return _graphView;
}

- (TabView*) tabView {
    if (_tabView == nil) {
        _tabView = [TabView new];
        _tabView.layer.borderColor = [UIColor whiteColor].CGColor;
        [_tabView setTranslatesAutoresizingMaskIntoConstraints:NO];
    }
    return _tabView;
}

- (void)setupLayoutConstraints {
    
    CGSize size = [[UIScreen mainScreen] bounds].size;
    CGFloat screenHeight = size.height;
    // let a space on top and bottom of the display
    CGFloat effectiveScreenHeight = screenHeight;// - 2*MARGIN;
    CGFloat minFactor = effectiveScreenHeight/screenHeight;
    
    NSString* verticalVisualFormatText = [NSString stringWithFormat:@"V:|-%d-[header]-%d-[graph]-%d-[tab]", 0, 0, 0];
    
    NSArray *verticalPositionConstraints = [NSLayoutConstraint constraintsWithVisualFormat:verticalVisualFormatText
                                                                                   options:0
                                                                                   metrics:nil
                                                                                     views:_viewsDictionary];
    
    NSArray* viewsArray = @[self.headerView, self.graphView, self.tabView];
    
    
    for (NSInteger i=0; i<SUBVIEW_PROPORTIONS_DEATILVIEW.count;i++) {
        
        CGFloat factor = [SUBVIEW_PROPORTIONS_DEATILVIEW[i] floatValue];
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




@end
