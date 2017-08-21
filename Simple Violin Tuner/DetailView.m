//
//  DetailView.m
//  Simple Ukulele Tuner
//
//  Created by Ulrich Vormbrock on 19.08.17.
//  Copyright © 2017 Ulrich Vormbrock. All rights reserved.
//

#import "DetailView.h"

#define SUBVIEW_PROPORTIONS_DETAILVIEW @[@24.0, @64.0, @12.0]

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
  
        _viewsDictionary = @{ @"header"      : self.headerView,
                              @"graph"       : self.graphView,
                              @"tab"         : self.tabView};
        
        [self addSubview:self.headerView];
        [self addSubview:self.graphView];
        [self addSubview:self.tabView];
        
        [self setupLayoutConstraints];
    
    }
    return self;
}


- (void)layoutSubviews {

    CGFloat screenWidth = self.frame.size.width;
    CGFloat screenHeight = self.frame.size.height;
    
    CGFloat buttonWidth = screenWidth / 16.0f;
    CGFloat buttonHeight = 0.00854f * [SUBVIEW_PROPORTIONS_DETAILVIEW[1] floatValue] * screenHeight;
    CGFloat buttonTop = 0.01f * [SUBVIEW_PROPORTIONS_DETAILVIEW[0] floatValue] * screenHeight;
    
    
    self.btnSlider = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnSlider.frame = CGRectMake(screenWidth-buttonWidth, buttonTop, buttonWidth, buttonHeight);
    [self.btnSlider setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
    
    [self.btnSlider addTarget:self
                       action:@selector(hideDetailView:)
             forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:self.btnSlider];
}

- (void)hideDetailView:(id)sender{
    
    
    [UIView animateWithDuration:2.0 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{

        CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
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
        [_headerView setTranslatesAutoresizingMaskIntoConstraints:NO];
    }
    return _headerView;
}

- (GraphView*) graphView {
    if (_graphView == nil) {
        _graphView = [GraphView new];
        _graphView.alpha = 0.9;
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
      
    NSString* verticalVisualFormatText = [NSString stringWithFormat:@"V:|-%d-[header]-%d-[graph]-%d-[tab]", 0, 0, 0];
    
    NSArray *verticalPositionConstraints = [NSLayoutConstraint constraintsWithVisualFormat:verticalVisualFormatText
                                                                                   options:0
                                                                                   metrics:nil
                                                                                     views:_viewsDictionary];
    
    NSArray* viewsArray = @[self.headerView, self.graphView, self.tabView];
    
    
    for (NSInteger i=0; i<SUBVIEW_PROPORTIONS_DETAILVIEW.count;i++) {
        
        CGFloat factor = [SUBVIEW_PROPORTIONS_DETAILVIEW[i] floatValue];
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
                                                                           multiplier:factor/100.0
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
