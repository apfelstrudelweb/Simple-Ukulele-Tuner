
#import "HorizontalPicker.h"


#define BG_COLOR [UIColor whiteColor]
#define BORDER_COLOR [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0]
#define LINE_COLOR [UIColor colorWithRed:0.26 green:0.26 blue:0.26 alpha:1.0].CGColor

#define GAUGE_BG        @"gaugePattern.png"
#define GAUGE_BG_BINGO  @"gaugePatternGreen.png"

#define AVRG_OCT_CAP 5


@interface HorizontalPicker ()

@property (nonatomic) UIScrollView *scrollView;
@property (nonatomic) UIView *scrollViewMarkerContainerView;
@property (nonatomic) NSMutableArray *scrollViewMarkerLayerArray;
@property (nonatomic) NSMutableArray *avrgOctavesArray;

@property (nonatomic) CGFloat value;
@property (nonatomic) NSInteger steps;
@property (nonatomic) CGFloat minimumValue;
@property (nonatomic) CGFloat maximumValue;
@property (nonatomic) CGFloat fontSize;
@property (nonatomic) CGFloat scale;

@property (nonatomic) CGFloat distanceBetweenItems;
@property (nonatomic) CGFloat textLayerWidth;
@property (nonatomic) CGFloat borderWidth;
@property (nonatomic) NSInteger dataCount;

@end;

@implementation HorizontalPicker


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        // input from microphone
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateGauge:)
                                                     name:@"UpdateDataNotification"
                                                   object:nil];
        
        // fixed frequency from sound file (strings E A D G B E')
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateGauge:)
                                                     name:@"PlayToneNotification"
                                                   object:nil];

        self.dataCount = 0;
        self.avrgOctavesArray = [[NSMutableArray alloc] initWithCapacity:AVRG_OCT_CAP];
    }
    return self;
}

- (void)layoutSubviews {
    
    self.distanceBetweenItems = IS_IPAD ? 140.0 : 70.0;
    self.textLayerWidth = IS_IPAD ? 140.0 : 70.0;
    
    self.steps = 3*BASIC_FREQUENCIES.count;
    
    self.borderWidth = self.frame.size.height/8;
    
    CGFloat contentWidth = self.steps * self.distanceBetweenItems + self.textLayerWidth / 2;
    
    self.scale = [[UIScreen mainScreen] scale];
    
    CGRect frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:frame];
    self.scrollView.contentSize = CGSizeMake(contentWidth, self.frame.size.height);
    self.scrollView.layer.cornerRadius = self.frame.size.height/2.01;
    self.scrollView.layer.borderWidth = self.borderWidth;
    self.scrollView.layer.borderColor = BORDER_COLOR.CGColor;
    //self.scrollView.backgroundColor = [UIColor whiteColor];
    self.scrollView.layer.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:GAUGE_BG]].CGColor;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.pagingEnabled = NO;
    self.scrollView.userInteractionEnabled = NO;
    
    self.scrollViewMarkerContainerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, contentWidth, self.frame.size.height)];
    self.scrollViewMarkerLayerArray = [NSMutableArray arrayWithCapacity:self.steps];
    
    self.fontSize = [UILabel getFontSizeForPicker];
    
    [self.scrollView addSubview:self.scrollViewMarkerContainerView];
    [self addSubview:self.scrollView];
    
    
    [self snapToMarkerAnimated:YES];
    
    // range
    self.minimumValue = 0.0;
    self.maximumValue = 0.276;
    
    // black dirty layer above
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.contentsScale = self.scale;
    gradientLayer.cornerRadius = self.frame.size.height/2;
    gradientLayer.startPoint = CGPointMake(0.0f, 0.0f);
    gradientLayer.endPoint = CGPointMake(1.0f, 0.0f);
    gradientLayer.opacity = 1.0;
    gradientLayer.frame = CGRectMake(1.0f, 1.0f, self.frame.size.width - 2.0, self.frame.size.height - 2.0);
    gradientLayer.locations = [NSArray arrayWithObjects:
                               [NSNumber numberWithFloat:0.0f],
                               [NSNumber numberWithFloat:0.1f],
                               [NSNumber numberWithFloat:0.2f],
                               [NSNumber numberWithFloat:0.3f],
                               [NSNumber numberWithFloat:0.4f],
                               [NSNumber numberWithFloat:0.5f],
                               [NSNumber numberWithFloat:0.6f],
                               [NSNumber numberWithFloat:0.7f],
                               [NSNumber numberWithFloat:0.8f],
                               [NSNumber numberWithFloat:0.9f],
                               [NSNumber numberWithFloat:1.0f], nil];
    gradientLayer.colors = [NSArray arrayWithObjects:
                            (id)[[UIColor colorWithRed:0.05f green:0.05f blue:0.05f alpha:0.9] CGColor],
                            (id)[[UIColor colorWithRed:0.05f green:0.05f blue:0.05f alpha:0.8] CGColor],
                            (id)[[UIColor colorWithRed:0.05f green:0.05f blue:0.05f alpha:0.7] CGColor],
                            (id)[[UIColor colorWithRed:0.05f green:0.05f blue:0.05f alpha:0.35] CGColor],
                            (id)[[UIColor colorWithRed:0.05f green:0.05f blue:0.05f alpha:0.15] CGColor],
                            (id)[[UIColor colorWithRed:0.05f green:0.05f blue:0.05f alpha:0.0] CGColor],
                            (id)[[UIColor colorWithRed:0.05f green:0.05f blue:0.05f alpha:0.15] CGColor],
                            (id)[[UIColor colorWithRed:0.05f green:0.05f blue:0.05f alpha:0.35] CGColor],
                            (id)[[UIColor colorWithRed:0.05f green:0.05f blue:0.05f alpha:0.7] CGColor],
                             (id)[[UIColor colorWithRed:0.05f green:0.05f blue:0.05f alpha:0.8] CGColor],
                            (id)[[UIColor colorWithRed:0.05f green:0.05f blue:0.05f alpha:0.9] CGColor], nil];
    
    // add red vertical line
    CAShapeLayer *line = [CAShapeLayer layer];
    UIBezierPath *linePath=[UIBezierPath bezierPath];
    
    CGFloat offsetY = 1.0;
    
    [linePath moveToPoint: CGPointMake(gradientLayer.frame.size.width/2.0, self.borderWidth-offsetY)];
    [linePath addLineToPoint:CGPointMake(gradientLayer.frame.size.width/2.0, self.frame.size.height-self.borderWidth-offsetY)];
    line.path=linePath.CGPath;
    line.fillColor = nil;
    line.opacity = 0.5;
    line.lineWidth = IS_IPAD ? 4.0 : 2.0;
    line.strokeColor = [UIColor redColor].CGColor;
    [gradientLayer addSublayer:line];
    
    [self.layer addSublayer:gradientLayer];
    
    [self setValue:0.0 inOctave:0 fromSoundfile:YES];
    
}


- (void)snapToMarkerAnimated:(BOOL)animated {
    CGFloat position = [self.scrollView contentOffset].x;
    
    if (position < self.scrollViewMarkerContainerView.frame.size.width - self.frame.size.width / 2) {
        CGFloat newPosition = 0.0f;
        CGFloat offSet = position / self.distanceBetweenItems;
        NSUInteger target = (NSUInteger)(offSet + 0.35f);
        target = target > self.steps ? self.steps - 1 : target;
        newPosition = target * self.distanceBetweenItems + self.textLayerWidth / 2;
        [self.scrollView setContentOffset:CGPointMake(newPosition, 0.0f) animated:animated];
    }
}

- (void)removeAllMarkers {
    for (id marker in self.scrollViewMarkerLayerArray) {
        [(CATextLayer *)marker removeFromSuperlayer];
    }
    [self.scrollViewMarkerLayerArray removeAllObjects];
}

- (void)setupMarkers {
    [self removeAllMarkers];
    
    // Calculate the new size of the content
    CGFloat leftPadding = self.frame.size.width / 2;
    CGFloat rightPadding = leftPadding;
    CGFloat contentWidth = leftPadding + (self.steps * self.distanceBetweenItems) + rightPadding + self.textLayerWidth / 2;
    self.scrollView.contentSize = CGSizeMake(contentWidth, self.frame.size.height);
    
    // Set the size of the marker container view
    [self.scrollViewMarkerContainerView setFrame:CGRectMake(0.0f, 0.0f, contentWidth, self.frame.size.height)];
    
    // Configure the new markers
    self.scrollViewMarkerLayerArray = [NSMutableArray arrayWithCapacity:self.steps];
    
    for (NSInteger i = 0; i < self.steps; i++) {
        
        CATextLayer *textLayer = [CATextLayer layer];
        textLayer.contentsScale = self.scale;
        textLayer.frame = CGRectIntegral(CGRectMake(leftPadding + i*self.distanceBetweenItems, self.frame.size.height / 1.75 - self.fontSize / 2 + 1, self.textLayerWidth, 40));
        textLayer.foregroundColor = LINE_COLOR;
        textLayer.alignmentMode = kCAAlignmentCenter;
        textLayer.fontSize = self.fontSize;
        
        textLayer.font = (__bridge CFTypeRef)([UIFont fontWithName:FONT_BOLD size:self.fontSize]);
        
        NSInteger j = i % BASIC_FREQUENCIES.count;
        
        NSString* toneScale = [NSString stringWithFormat:NSLocalizedString(@"tone_scale", @"tone scale")];
        // use string tokenizer
        NSArray *toneScaleArray = [toneScale componentsSeparatedByString:@","];
        
        
        textLayer.string = toneScaleArray[j];
        
        // line top
        CAShapeLayer *line1 = [CAShapeLayer layer];
        UIBezierPath *linePath1=[UIBezierPath bezierPath];
        [linePath1 moveToPoint: CGPointMake(textLayer.frame.size.width/2.0, -self.frame.size.height / 1.5)];
        [linePath1 addLineToPoint:CGPointMake(textLayer.frame.size.width/2.0, 0.0)];
        line1.path=linePath1.CGPath;
        line1.fillColor = nil;
        line1.opacity = 1.0;
        line1.lineWidth = 2.0;
        line1.strokeColor = LINE_COLOR;
        [textLayer addSublayer:line1];
        
        
        // small lines
        for (NSInteger k=0; k<11; k++) {
            CAShapeLayer *line = [CAShapeLayer layer];
            UIBezierPath *linePath=[UIBezierPath bezierPath];
            [linePath moveToPoint: CGPointMake(textLayer.frame.size.width*(CGFloat) k/10, -self.frame.size.height / 6.0)];
            [linePath addLineToPoint:CGPointMake(textLayer.frame.size.width*(CGFloat) k/10, -40.0)];
            line.path=linePath.CGPath;
            line.fillColor = nil;
            line.opacity = 1.0;
            line.lineWidth = 1.0;
            line.strokeColor = LINE_COLOR;
            [textLayer addSublayer:line];
        }
        
        
        [self.scrollViewMarkerLayerArray addObject:textLayer];
        [self.scrollViewMarkerContainerView.layer addSublayer:textLayer];
    }
}


- (void)setMinimumValue:(CGFloat)newMin {
    _minimumValue = newMin;
    [self setupMarkers];
}

- (void)setMaximumValue:(CGFloat)newMax {
    _maximumValue = newMax;
    [self setupMarkers];
}


// if tone is precise enough, make the display green
- (void)setBackground:(NSInteger)deviation {
    self.scrollView.layer.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:GAUGE_BG]].CGColor;
}

- (void)setValue:(CGFloat)newValue inOctave:(NSInteger) octave fromSoundfile:(BOOL)sf {
   
    if (newValue==0.0) {
        newValue = 10.0;//16.35; // set to the first tone "C" of the scale
        //self.scrollView.backgroundColor = BG_COLOR;
    }
    
    newValue /= powf(2.0, octave);
    
    // now project values (16.35 - 987.8) to range 0 - 0.276
    newValue = log10f(newValue/16.35) * 1.375;
    
    
    
    //__weak __typeof(self)weakSelf = self;
    
//    value = newValue > maximumValue ? maximumValue : newValue; // 0.276 max
//    value = newValue < minimumValue ? minimumValue : newValue; // 0.0 min
    
    CGFloat xValue = (newValue - self.minimumValue) / ((self.maximumValue-self.minimumValue) / 8) * self.distanceBetweenItems + self.textLayerWidth / 2;
    

//    if (self.avrgOctavesArray.count == AVRG_OCT_CAP) {
//        NSLog(@"octave: %ld", (long)octave);
//        [self.avrgOctavesArray removeLastObject];
//    }
//    [self.avrgOctavesArray insertObject:[NSNumber numberWithInteger:octave] atIndex:0];
//    
//    
//    
//    if (self.avrgOctavesArray.count == AVRG_OCT_CAP) {
//        NSInteger refOctave = [[self.avrgOctavesArray lastObject] integerValue];
//        if (octave != refOctave) {
//            return;
//        }
//    }
    
//    if (xValue > 1000.0) {
//        NSLog(@"xValue: %f", xValue);
//    }
    
    if (!isnan(xValue)) {
        [self.scrollView setContentOffset:CGPointMake(xValue, 0.0f) animated:NO];
    }
}

#pragma mark - Notification
-(void) updateGauge:(NSNotification *) notification
{
    if ([notification.object isKindOfClass:[Spectrum class]]) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            Spectrum* spect = (Spectrum*)[notification object];

            CGFloat frequency = [spect.frequency floatValue];
            NSInteger octave = [spect.octave intValue];
            
//            if (fabsf(frequency-lastFrequency) > 50.0) {
//                //NSLog(@"HIGH FREQUENCY DEVIATION");
//                lastFrequency = frequency;
//                [self setValue:lastFrequency inOctave:octave fromSoundfile:NO];
//                return;
//            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self setValue:frequency inOctave:octave fromSoundfile:NO];
            });
            
            
//            lastFrequency = frequency;
            
        });
    } else if ([notification.object isKindOfClass:[SoundFile class]]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            SoundFile* sf = (SoundFile*)[notification object];
            
            NSNumber *freq = sf.frequency;
            NSNumber *oct = sf.octave;
            
            CGFloat frequency = [freq floatValue];
            NSInteger octave = [oct intValue];

            [self setValue:frequency inOctave:octave fromSoundfile:YES];
            
        });
    } else {
        NSLog(@"Error, object not recognised.");
    }
}


-(void)dealloc {
    //NSLog(@"%s", __PRETTY_FUNCTION__);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end