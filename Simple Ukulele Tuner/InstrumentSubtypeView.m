//
//  InstrumentSubtypeView.m
//  Simple Ukulele Tuner
//
//  Created by imac on 20.07.15.
//  Copyright (c) 2015 Vormbrock. All rights reserved.
//

#import "InstrumentSubtypeView.h"

#define OCTAVE_COLOR [UIColor colorWithRed:172.0/255.0 green:174.0/255.0 blue:178.0/255.0 alpha:1.0]

@interface InstrumentSubtypeView() {
    CGFloat shadowRadius, shadowOffset;
    NSString *instrumentSubtype;
}
@end

@implementation InstrumentSubtypeView


- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setInstrumentSubtype];
        
        shadowRadius = IS_IPAD ? 0.4 : 0.2;
        shadowOffset = IS_IPAD ? 0.7 : 0.5;
        
        self.subtypeLabel = [[UILabel alloc] initWithFrame:frame];
        
        self.subtypeLabel.textAlignment = NSTextAlignmentCenter;
        self.subtypeLabel.textColor = OCTAVE_COLOR;
        
#if defined(TARGET_BANJO)
        self.subtypeLabel.textColor = [UIColor colorWithRed:0.35 green:0.35 blue:0.35 alpha:1.0];
#endif
        
        [self.subtypeLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        self.subtypeLabel.text = instrumentSubtype;
        
        self.subtypeLabel.font = [UIFont fontWithName:FONT size:[UILabel getFontSizeForToneName]];
        
        self.subtypeLabel.layer.shadowColor = [UIColor blackColor].CGColor;
        self.subtypeLabel.layer.shadowRadius = shadowRadius;
        self.subtypeLabel.layer.shadowOpacity = 1;
        self.subtypeLabel.layer.shadowOffset = CGSizeMake(shadowOffset, shadowOffset);
        self.subtypeLabel.layer.masksToBounds = NO;
        
        
        [self addSubview:self.subtypeLabel];
        [self setupLabelConstraints];
        
        
        // input coming from config menu
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateInstrumentSubtype:)
                                                     name:@"UpdateDefaultsNotification"
                                                   object:nil];

        
    }
    return self;
}

-(void)setInstrumentSubtype {
    
    //NSString *subtype = [[SHARED_CONTEXT getInstrumentSubtype] substringFromIndex:4];
    NSString *subtype = [SHARED_CONTEXT getInstrumentSubtype];
    
    
    // Remove number (of strings) - we only want to see the subtype of the instrument
    NSString *expression = @"[0-9]";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:expression options:NSRegularExpressionCaseInsensitive error:nil];
    NSTextCheckingResult *match = [regex firstMatchInString:subtype options:0 range:NSMakeRange(0, 1)];
    
    if (match) {
        subtype = [subtype substringFromIndex:4];
    }
    
    NSArray *stringSplitArray = [subtype componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"("]];
    instrumentSubtype = stringSplitArray[0];
   
}

#pragma mark - Notification
-(void) updateInstrumentSubtype:(NSNotification *) notification {
    
    [self setInstrumentSubtype];
    self.subtypeLabel.text = instrumentSubtype;
}


#pragma mark - layout constraints
- (void)setupLabelConstraints {
    
    [self removeConstraints:[self constraints]];
    
    NSMutableArray *layoutConstraints = [NSMutableArray new];
    
    
    // Center vertically
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.subtypeLabel
                                                              attribute:NSLayoutAttributeCenterY
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeCenterY
                                                             multiplier:1.2
                                                               constant:0.0]];
    
    // Center horizontally
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.subtypeLabel
                                                              attribute:NSLayoutAttributeCenterX
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeCenterX
                                                             multiplier:1.0
                                                               constant:0.0]];
    
    // add all constraints at once
    [self addConstraints:layoutConstraints];
    
}


-(void)dealloc {
    //NSLog(@"%s", __PRETTY_FUNCTION__);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
