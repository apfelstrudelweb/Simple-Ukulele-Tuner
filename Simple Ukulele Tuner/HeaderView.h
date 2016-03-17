//
//  HeaderView.h
//  Diapason
//
//  Created by imac on 13.03.15.
//  Copyright (c) 2015 Vormbrock. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InfoIconView.h"

@interface HeaderView : UIView

@property (strong, retain) UILabel* frequencyLabel;
@property (strong, retain) UILabel* diffLabel;
@property (strong, retain) UILabel* calibrationLabel;
@property (strong, nonatomic) InfoIconView *infoIconView;

@end
