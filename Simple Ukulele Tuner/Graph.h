//
//  Graph.h
//  Diapason
//
//  Created by imac on 22.03.15.
//  Copyright (c) 2015 Vormbrock. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Graph : NSObject

@property CGFloat min;
@property CGFloat max;
@property CGFloat delta;
@property NSInteger nMin;

-(CGFloat) getDelta;
@end
