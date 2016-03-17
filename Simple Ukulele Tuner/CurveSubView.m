//
//  CurveView.m
//  Diapason
//
//  Created by imac on 13.03.15.
//  Copyright (c) 2015 Vormbrock. All rights reserved.
//

#import "CurveSubView.h"

#define CURVE_COLOR  {0.0/255.0, 238.0/255.0, 114.0/255.0, 1.0} // same color as green gauge
#define CURVE_WIDTH  IS_IPAD ? 4.0 : 2.0

#define START_BIN 1   // start frequency at ca. 10 Hz
#define END_BIN   188  // end frequency at 2.000 Hz

@interface CurveSubView() {
    NSArray *data;
    NSArray *graphData;
    NSNumber* bin;
    BOOL isFFT;
    
    NSMutableArray* binArray;
    CGFloat minLogBin;
    CGFloat maxLogBin;
    
    Spectrum* spect;
    
    BOOL isGraphEnabled;
}
@end;

@implementation CurveSubView

- (void)drawRect:(CGRect)rect {
    
    if ([SHARED_MANAGER isFFT]) {
        [self drawFFTCurve];
    } else {
        [self drawAutocorrelationCurve];
    }
    
}

- (id)init {
    return [self initWithFrame:CGRectZero];
}

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        [self checkVersion];
        
        graphData = [NSMutableArray new];
        
        
        [self setNeedsDisplay];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateGraph:)
                                                     name:@"UpdateDataNotification"
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateVersion:)
                                                     name:@"UpdateVersionNotification"
                                                   object:nil];
        
        
    }
    return self;
}

- (void)checkVersion {
    NSString* currentVersion = [SHARED_VERSION_MANAGER getVersion];
    
    if ([version_signal isEqualToString:currentVersion] || [version_premium isEqualToString:currentVersion]) {
        isGraphEnabled = YES;
    }
}

#pragma mark - Notification
- (void) updateVersion:(NSNotification *) notification {
    
    [self checkVersion];
    [self setNeedsDisplay];
}

-(void) updateGraph:(NSNotification *) notification {
    // don't show the graph (FFT or Autocorrelation) for the lite or solo-uke version!
    if (isGraphEnabled == NO) return;
    
    if ([notification.object isKindOfClass:[Spectrum class]]) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            spect = ((Spectrum*)[notification object]);
            data = spect.data;
            bin = spect.bin;
            isFFT = [SHARED_MANAGER isFFT];
            
            if (isFFT == YES){
                // FFT
                binArray = [NSMutableArray new];
                
                for (NSInteger i=START_BIN; i<END_BIN+1; i++) {
                    CGFloat logBin = log10f((CGFloat)i);
                    [binArray addObject:[NSNumber numberWithFloat:logBin]];
                    
                    if (i==START_BIN) {
                        minLogBin = logBin;
                    }
                    
                    if (i==END_BIN) {
                        maxLogBin = logBin;
                    }
                }
                
                /**
                 * Special procedure: get the exact frequency from YIN algorithm
                 * and calculate the idela bin. Then correct the bins from FFT,
                 * shifting the graph horizontally in order to get the correct
                 * mapping "peak" against "bin" or "frequency"
                 */
                
                // now extract position of absolute maxmimum
                CGFloat maxValue = -100.0;
                NSInteger realMaxBin = 0;
                
                for (NSInteger i=0; i<data.count; i++) {
                    if ([data[i] floatValue] > maxValue) {
                        maxValue = [data[i] floatValue];
                        realMaxBin = i;
                    }
                }
                
                //NSLog(@"realMaxBin = %d", realMaxBin);
                
                CGFloat frequency = [spect.frequency floatValue];
                
                NSInteger idealMaxBin = (int)((186.0/2000.0) * frequency);
                
                NSInteger binDifference = realMaxBin - idealMaxBin;
                
                CGFloat volume = [spect.volume floatValue];
                //NSLog(@"volume = %f", volume);
                
                // now shift the values horizontally dependent on deviation
                if (binDifference != 0 && volume > 0.1 && frequency != 0.0) {
                    graphData = shiftArray(data, binDifference);
                } else {
                    graphData = data;
                }
            } else {
                // AUTOCORRELATION
                graphData = data;
            }
            
            [self setNeedsDisplay];
        });
    } else {
        NSLog(@"Error, object not recognized.");
    }
}


- (void) drawFFTCurve {
    
    CGFloat maxValue = 0;
    CGFloat minValue = MAXFLOAT;
    
    for (NSInteger i=0;i<data.count;i++) {
        CGFloat result = [data[i] floatValue];
        
        if (maxValue < result) {
            maxValue = result;
        }
        if (minValue > result) {
            minValue = result;
        }
    }
    
    if (maxValue==0.0) maxValue = 0.2;
    
    CGFloat xSize = self.bounds.size.width;
    CGFloat ySize = self.bounds.size.height;
    
    CGFloat volume = [spect.volume floatValue];
    
    // make the range dependent on volume
    // nota bene: in order to make volume convergent towards a constant,
    // use tanh function, so the graph won't exceed the upper border on high volume
    CGFloat yRange = 1.2*maxValue * 1/tanhf(0.35*volume);
    
    CGFloat xUnit = xSize / (maxLogBin-minLogBin);
    CGFloat yUnit = ySize / yRange;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGFloat components[] = CURVE_COLOR;
    
    NSMutableArray* points = [NSMutableArray new];
    
    if (graphData.count > binArray.count-1) {
        for (NSInteger i=0; i<binArray.count; i++) {
            
            NSNumber *key = binArray[i];
            NSNumber *value = graphData[i];
            CGFloat logFrequency = [key floatValue] * xUnit;
            CGFloat amplitude = ySize - [value floatValue] * yUnit - 1;
            
            if (isnan(amplitude)) {
                amplitude = 0.0;
            }
            
            if (i==0) {
                amplitude = ySize;
            }
            
            CGPoint point = CGPointMake(logFrequency, amplitude);
            [points addObject:[NSValue valueWithCGPoint:point]];
        }
        
        CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
        CGColorRef color = CGColorCreate(colorspace, components);
        CGContextSetStrokeColorWithColor(context, color);
        
        UIBezierPath* bezierPath = [self quadCurvedPathWithPoints:points];
        bezierPath.lineWidth = CURVE_WIDTH;
        [bezierPath stroke];
        
        CGContextStrokePath(context);
        CGColorSpaceRelease(colorspace);
        CGColorRelease(color);
    }
}

- (void) drawAutocorrelationCurve {
    
    CGFloat maxValue = 0;
    CGFloat minValue = MAXFLOAT;
    
    for (NSInteger i=0;i<graphData.count;i++) {
        
        CGFloat result = [graphData[i] floatValue];
        
        if (maxValue < result) {
            maxValue = result;
        }
        if (minValue > result) {
            minValue = result;
        }
    }
    
    if (maxValue == 0.0){
        return;
    }
    
    CGFloat xSize = self.bounds.size.width;
    CGFloat ySize = self.bounds.size.height;
    
    NSInteger numberOfValues = (int)graphData.count;
    
    CGFloat xRange = (float)numberOfValues;
    CGFloat yRange = 2.5*maxValue;
    
    CGFloat zeroValue = 0.5 * yRange; // x-axis
    
    if (yRange==0) return;
    
    CGFloat xUnit = xSize / xRange;
    CGFloat yUnit = ySize / yRange;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(context, CURVE_WIDTH);
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    CGFloat components[] = CURVE_COLOR;
    CGColorRef color = CGColorCreate(colorspace, components);
    CGContextSetStrokeColorWithColor(context, color);
    
    for (NSInteger i=0; i<graphData.count; i++) {
        
        CGFloat value = -[graphData[i] floatValue] + zeroValue;
        
        if (i==0) {
            CGContextMoveToPoint(context, i*xUnit, value*yUnit);
        } else {
            CGContextAddLineToPoint(context, i*xUnit, value*yUnit);
        }
    }
    
    CGContextStrokePath(context);
    CGColorSpaceRelease(colorspace);
    CGColorRelease(color);
}

// Helper method: performs an element shift of an array to both directions
static NSArray *shiftArray(NSArray *array, NSInteger bit) {
    NSInteger length = [array count];
    NSArray *left;
    NSArray *right;
    
    BOOL forward = bit < 0;
    bit = abs(bit);
    
    if (length - bit < 0) return array;
    
    if (forward == YES) {
        //code for right shift
        right = [array subarrayWithRange:(NSRange){ .location = length - bit, .length = bit }];
        left = [array subarrayWithRange:(NSRange){ .location = 0, .length = length - bit}];
        return [right arrayByAddingObjectsFromArray:left];
    }else{
        //code for left shift
        left = [array subarrayWithRange:(NSRange){ .location =0, .length = bit }];
        right= [array subarrayWithRange:(NSRange){ .location = bit, .length = length - bit}];
        return [right arrayByAddingObjectsFromArray:left];
    }
}


-(UIBezierPath *)quadCurvedPathWithPoints:(NSArray *)points
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    NSValue *value = points[0];
    CGPoint p1 = [value CGPointValue];
    [path moveToPoint:p1];
    
    if (points.count == 2) {
        value = points[1];
        CGPoint p2 = [value CGPointValue];
        [path addLineToPoint:p2];
        return path;
    }
    
    for (NSInteger i = 1; i < points.count; i++) {
        value = points[i];
        CGPoint p2 = [value CGPointValue];
        
        CGPoint midPoint = midPointForPoints(p1, p2);
        [path addQuadCurveToPoint:midPoint controlPoint:controlPointForPoints(midPoint, p1)];
        [path addQuadCurveToPoint:p2 controlPoint:controlPointForPoints(midPoint, p2)];
        
        p1 = p2;
    }
    return path;
}

static CGPoint midPointForPoints(CGPoint p1, CGPoint p2) {
    return CGPointMake((p1.x + p2.x) / 2, (p1.y + p2.y) / 2);
}

static CGPoint controlPointForPoints(CGPoint p1, CGPoint p2) {
    CGPoint controlPoint = midPointForPoints(p1, p2);
    CGFloat diffY = fabs(p2.y - controlPoint.y);
    
    if (p1.y < p2.y)
        controlPoint.y += diffY;
    else if (p1.y > p2.y)
        controlPoint.y -= diffY;
    
    return controlPoint;
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
