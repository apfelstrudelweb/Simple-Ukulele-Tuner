//
//  GraphView.h
//  Diapason
//
//  Created by imac on 13.03.15.
//  Copyright (c) 2015 Vormbrock. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CurveSubView.h"
#import "TabView.h"
#import "CoordinateSystemView.h"

@interface GraphView : UIView
@property CGContextRef context;
@property (strong, nonatomic) TabView *tabView;
@property (strong, nonatomic) CoordinateSystemView *coordView;
@property (strong, nonatomic) NSMutableArray *layers;

@end
