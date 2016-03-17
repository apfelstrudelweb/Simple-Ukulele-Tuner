//
//  CoordinateSystemView.h 
//  
//
//  Created by imac on 17.06.15.
//
//

#import <UIKit/UIKit.h>

@interface CoordinateSystemView : UIView
@property CGContextRef context;
@property (strong, nonatomic) CurveSubView *curveView;
@property (strong, nonatomic) NSMutableArray *layers;

@end
