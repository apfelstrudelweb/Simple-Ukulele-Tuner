//
//  DetailView.h
//  Simple Ukulele Tuner
//
//  Created by Ulrich Vormbrock on 19.08.17.
//  Copyright © 2017 Ulrich Vormbrock. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DetailViewDelegate <NSObject>

- (void)closeDetailView;

@end

@interface DetailView : UIView

@property (nonatomic, weak) id<DetailViewDelegate> delegate;

@end
