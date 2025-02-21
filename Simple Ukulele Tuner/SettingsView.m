//
//  SettingsView.m
//  Simple Guitar Tuner
//
//  Created by imac on 02.07.15.
//  Copyright (c) 2015 Vormbrock. All rights reserved.
//

#import "SettingsView.h"


@interface SettingsView() {
    CGFloat headerHeight;
    UITableView* tableView;
    
    NSUserDefaults *defaults;
}
@property NSDictionary *viewsDictionary;
@end

@implementation SettingsView



- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        _viewsDictionary = @{ @"header"      : self.headerView,
                              @"menu"       : self.menuView};
        
        self.backgroundColor = SETTINGS_BG_COLOR;
        
        
        CGSize size = [[UIScreen mainScreen] bounds].size;
        
        defaults = [NSUserDefaults standardUserDefaults];
        
        
#if defined(TARGET_VIOLIN) || defined(TARGET_MANDOLIN)
        headerHeight = 0.01*11.86*size.height;
        // make header's background color red -> entire width
        self.headerBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, size.width, headerHeight)];
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = self.headerBackgroundView.bounds;
        gradient.colors = [NSArray arrayWithObjects:
                           (id)[[UIColor colorWithRed:0.73 green:0.31 blue:0.00 alpha:1.0] CGColor],
                           (id)[[UIColor colorWithRed:0.91 green:0.76 blue:0.36 alpha:1.0] CGColor], nil];
        [self.headerBackgroundView.layer insertSublayer:gradient atIndex:0];
#else
        headerHeight = 0.01*[SUBVIEW_PROPORTIONS[0] floatValue]*size.height;
        // make header's background color red -> entire width
        self.headerBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, size.width, 0.01*[SUBVIEW_PROPORTIONS[0] floatValue]*size.height)];
        NSString* colorString = [defaults stringForKey:KEY_INSTRUMENT_COLOR];
        [self.headerBackgroundView setBackgroundColor:[SHARED_MANAGER getHeaderColor:colorString]];
#endif
        
        
        

        //[self.headerBackgroundView setBackgroundColor:HEADER_BACKGROUND_COLOR_02];
        
 
        
        
        [self addSubview:self.headerBackgroundView];
        
        [self addSubview:self.headerView];
        [self addSubview:self.menuView];

        [self setupConstraints];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateBackground:)
                                                     name:@"UpdateDefaultsNotification"
                                                   object:nil];

        
    }
    return self;
    
}



#pragma mark -view instantiations
- (SettingsHeaderView*) headerView {
    if (_headerView == nil) {
        _headerView = [SettingsHeaderView new];
        [_headerView setTranslatesAutoresizingMaskIntoConstraints:NO];
    }
    return _headerView;
}

- (SettingsMenuView*) menuView {
    if (_menuView == nil) {
        _menuView = [SettingsMenuView new];
        [_menuView setTranslatesAutoresizingMaskIntoConstraints:NO];
    }
    return _menuView;
}

- (void)setupConstraints {
    
    [self removeConstraints:[self constraints]];
    
    NSMutableArray *layoutConstraints = [NSMutableArray new];
    
    CGFloat width = CONTENT_WIDTH;
    
    CGSize size = [[UIScreen mainScreen] bounds].size;
    CGFloat screenHeight = size.height;
    
    
    NSString* verticalVisualFormatText = [NSString stringWithFormat:@"V:|-%d-[header]-%f-[menu]", 0, 0.06*screenHeight];
    
    NSArray *verticalPositionConstraints = [NSLayoutConstraint constraintsWithVisualFormat:verticalVisualFormatText
                                                                                   options:0
                                                                                   metrics:nil
                                                                                     views:_viewsDictionary];
    
    
    
    // 1. HEADER
    // Center horizontally
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.headerView
                                                              attribute:NSLayoutAttributeCenterX
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeCenterX
                                                             multiplier:1.0
                                                               constant:0.0]];

    // Width
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.headerView
                                                              attribute:NSLayoutAttributeWidth
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeWidth
                                                             multiplier:width
                                                               constant:0.0]];
    
    
    
    // Height
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.headerView
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeHeight
                                                             multiplier:0.0
                                                               constant:headerHeight]];
    
    // 2. MENU
    // Center horizontally
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.menuView
                                                              attribute:NSLayoutAttributeCenterX
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeCenterX
                                                             multiplier:1.0
                                                               constant:0.0]];

    // Width
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.menuView
                                                              attribute:NSLayoutAttributeWidth
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeWidth
                                                             multiplier:width
                                                               constant:0.0]];
    
    
    
    // Height
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.menuView
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeHeight
                                                             multiplier:0.8
                                                               constant:0.0]];
    

    
    
    // add all constraints at once
    [self addConstraints:layoutConstraints];
    
    for (NSInteger i = 0; i<verticalPositionConstraints.count; i++) {
        [self addConstraint:verticalPositionConstraints[i]];
    }
    
}

#pragma mark - Notification
- (void) updateBackground:(NSNotification *) notification {
    
    NSString* colorString = [defaults stringForKey:KEY_INSTRUMENT_COLOR];
    [self.headerBackgroundView setBackgroundColor:[SHARED_MANAGER getHeaderColor:colorString]];
    
    // special default header for balalaika
#if defined(TARGET_BALALAIKA)
    if ([[SHARED_MANAGER getHeaderColor:colorString] isEqual:HEADER_BACKGROUND_COLOR_01]) {
        UIGraphicsBeginImageContext(self.headerBackgroundView.frame.size);
        [[UIImage imageNamed:@"header.png"] drawInRect:self.headerBackgroundView.bounds];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        self.headerBackgroundView.backgroundColor = [UIColor colorWithPatternImage:image];
    }
#endif
    
    [self setNeedsDisplay];
}

-(void)dealloc {
    //NSLog(@"%s", __PRETTY_FUNCTION__);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
