//
//  UkeTypeView.m
//  Simple Ukulele Tuner
//
//  Created by imac on 20.07.15.
//  Copyright (c) 2015 Vormbrock. All rights reserved.
//

#import "UkeTypeView.h"

#define OCTAVE_COLOR [UIColor colorWithRed:172.0/255.0 green:174.0/255.0 blue:178.0/255.0 alpha:1.0]

@interface UkeTypeView() {
    CGFloat shadowRadius, shadowOffset;
    NSString* ukeType;
}
@end

@implementation UkeTypeView


- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setUkeType];
        
        shadowRadius = IS_IPAD ? 0.4 : 0.2;
        shadowOffset = IS_IPAD ? 0.7 : 0.5;
        
        self.ukeTypeLabel = [[UILabel alloc] initWithFrame:frame];
        
        self.ukeTypeLabel.textAlignment = NSTextAlignmentCenter;
        self.ukeTypeLabel.textColor = OCTAVE_COLOR;
        [self.ukeTypeLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        self.ukeTypeLabel.text = ukeType;
        
        self.ukeTypeLabel.font = [UIFont fontWithName:FONT size:[UILabel getFontSizeForToneName]];
        
        self.ukeTypeLabel.layer.shadowColor = [UIColor blackColor].CGColor;
        self.ukeTypeLabel.layer.shadowRadius = shadowRadius;
        self.ukeTypeLabel.layer.shadowOpacity = 1;
        self.ukeTypeLabel.layer.shadowOffset = CGSizeMake(shadowOffset, shadowOffset);
        self.ukeTypeLabel.layer.masksToBounds = NO;
        
        
        [self addSubview:self.ukeTypeLabel];
        [self setupLabelConstraints];
        
        
        // input coming from config menu
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateUkeType:)
                                                     name:@"UpdateDefaultsNotification"
                                                   object:nil];

        
    }
    return self;
}

-(void)setUkeType {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString* defaultSubtype;
#if defined(TARGET_UKULELE)
    defaultSubtype = [defaults stringForKey:KEY_UKE_TYPE];
#elif defined(TARGET_GUITAR)
    defaultSubtype = [[defaults stringForKey:KEY_GUITAR_TYPE] substringFromIndex:4];
#elif defined(TARGET_MANDOLIN)
    
#elif defined(TARGET_BANJO)
    
#elif defined(TARGET_VIOLIN)
    
#elif defined(TARGET_BALALAIKA)
    
#endif
    NSArray *stringSplitArray = [defaultSubtype componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"("]];
    ukeType = stringSplitArray[0];
   
}

#pragma mark - Notification
-(void) updateUkeType:(NSNotification *) notification {
    
    [self setUkeType];
    self.ukeTypeLabel.text = ukeType;
}


#pragma mark - layout constraints
- (void)setupLabelConstraints {
    
    [self removeConstraints:[self constraints]];
    
    NSMutableArray *layoutConstraints = [NSMutableArray new];
    
    
    // Center vertically
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.ukeTypeLabel
                                                              attribute:NSLayoutAttributeCenterY
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeCenterY
                                                             multiplier:1.2
                                                               constant:0.0]];
    
    // Center horizontally
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.ukeTypeLabel
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
