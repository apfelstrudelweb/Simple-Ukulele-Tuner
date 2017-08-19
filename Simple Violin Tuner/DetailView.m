//
//  DetailView.m
//  Simple Ukulele Tuner
//
//  Created by Ulrich Vormbrock on 19.08.17.
//  Copyright © 2017 Ulrich Vormbrock. All rights reserved.
//

#import "DetailView.h"

@interface DetailView() {
    
}

@property (strong, nonatomic) UIButton *btnSlider;

@end


@implementation DetailView

- (id)initWithFrame:(CGRect)frame {
    
    
    self = [super initWithFrame:frame];
    
    
    if (self) {
        
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGFloat screenWidth = screenRect.size.width;
        //CGFloat screenHeight = screenRect.size.width;
        
        CGFloat buttonWidth = screenWidth / 16.0f;
        CGFloat buttonHeight = (856.0f/83.0f) * buttonWidth;
        
        self.btnSlider = [UIButton buttonWithType:UIButtonTypeCustom];
        self.btnSlider.frame = CGRectMake(screenWidth-2*buttonWidth, buttonWidth, buttonWidth, buttonHeight);
        [self.btnSlider setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
        
        [self.btnSlider addTarget:self
                           action:@selector(hideDetailView:)
                 forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:self.btnSlider];
 
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


@end
