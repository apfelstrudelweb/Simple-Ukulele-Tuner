//
//  premiumView.m
//  Simple Ukulele Tuner
//
//  Created by Ulrich Vormbrock on 19.08.17.
//  Copyright © 2017 Ulrich Vormbrock. All rights reserved.
//

#import "PremiumView.h"
#import "DetailView.h"

@interface PremiumView()<DetailViewDelegate> {
 
}

@property (strong, nonatomic) DetailView *detailView;
@property (strong, nonatomic) UIButton *btnSlider;
@property (nonatomic) CGRect mainFrame;
@property (nonatomic) CGFloat screenWidth;
@property (nonatomic) CGFloat borderX;
@property (nonatomic) CGFloat borderY;

@end

@implementation PremiumView


- (id)initWithFrame:(CGRect)frame {
    
    
    self = [super initWithFrame:frame];

    
    if (self) {
        
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        self.screenWidth = screenRect.size.width;
        CGFloat screenHeight = screenRect.size.height;
        
        CGFloat buttonWidth = self.screenWidth / 10.0f;
        CGFloat buttonHeight = (443.0f/107.0f) * buttonWidth;

        self.btnSlider = [UIButton buttonWithType:UIButtonTypeCustom];
        self.btnSlider.frame = CGRectMake(0, 0.09*screenHeight, buttonWidth, buttonHeight);
        [self.btnSlider setImage:[UIImage imageNamed:@"slider"] forState:UIControlStateNormal];
        
        [self.btnSlider addTarget:self
                      action:@selector(showDetailView:)
         forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:self.btnSlider];
        
        
        self.borderX = screenRect.size.width / 15.0f;
        self.borderY = 0.0f;//screenRect.size.height / 20.0f;
       
        //self.detailView.frame  =  self.mainFrame;
        self.detailView.delegate = self;
        
        [self addSubview:self.detailView];
        
        NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:self.detailView
                                                                           attribute:NSLayoutAttributeWidth
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:self
                                                                           attribute:NSLayoutAttributeWidth
                                                                          multiplier:1.0
                                                                            constant:0];
        NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:self.detailView
                                                                           attribute:NSLayoutAttributeHeight
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:self
                                                                           attribute:NSLayoutAttributeHeight
                                                                          multiplier:1.0
                                                                            constant:0];
        
        NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:self.detailView
                                                                            attribute:NSLayoutAttributeLeft
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:self
                                                                            attribute:NSLayoutAttributeLeft
                                                                           multiplier:1.0
                                                                             constant:-self.screenWidth];
        
        [self addConstraint:widthConstraint];
        [self addConstraint:heightConstraint];
        [self addConstraint:leftConstraint];
    }
    return self;
}



-(void)showDetailView:(id)sender{
    
    self.mainFrame = CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height);
    
    [UIView animateWithDuration:2.0 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{

        self.detailView.frame  =  self.mainFrame; //CGRectOffset(self.mainFrame, self.screenWidth + self.borderX, 0.0);

    } completion:^(BOOL finished) {
        
        self.btnSlider.alpha = 0.0f;
        self.btnSlider.userInteractionEnabled = NO;
    }];
}

#pragma -mark DetailViewDelegate
- (void)closeDetailView {
    //[self.detailView removeFromSuperview];
    self.btnSlider.alpha = 1.0f;
    self.btnSlider.userInteractionEnabled = YES;
}

#pragma mark -view instantiations

- (DetailView*) detailView {
    if (_detailView == nil) {
        _detailView = [DetailView new];
        [_detailView setTranslatesAutoresizingMaskIntoConstraints:NO];
        //_detailView.backgroundColor = [UIColor blueColor];
    }
    return _detailView;
}


@end
