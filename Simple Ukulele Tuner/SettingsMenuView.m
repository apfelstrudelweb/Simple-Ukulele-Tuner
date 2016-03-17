//
//  SettingsMenuView.m
//  Simple Guitar Tuner
//
//  Created by imac on 03.07.15.
//  Copyright (c) 2015 Vormbrock. All rights reserved.
//


#import "SettingsMenuView.h"


#define TEXT_COLOR [UIColor colorWithRed:161.0/255.0 green:161.0/255.0 blue:161.0/255.0 alpha:1.0]
#define HIGHLIGHT_TEXT_COLOR [UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1.0]

#define SWITCH_ON   [UIImage imageNamed:@"onButton.png"]
#define SWITCH_OFF  [UIImage imageNamed:@"offButton.png"]
#define PURCHASE    [UIImage imageNamed:@"shoppingCart.png"]
#define RESTORE     [UIImage imageNamed:@"restoreButton.png"]

enum {
    INSTRUMENT_TYPE = 0,
    CALIBRATION = 1,
    THEME = 2,
    RESTORE_BTN = 3
};
typedef NSUInteger SECTION_DESCR;

@interface SettingsMenuView() <SKPaymentTransactionObserver, CalibratorDelegate> {
    CGFloat shadowRadius, shadowOffset;
    CGFloat cellHeight;
    
    NSMutableDictionary* switchDict;
    NSArray* ukeTypesArray;
    NSArray* colorsArray;
    NSDictionary* colorsDict;
    CAGradientLayer *gradient;
    
    CGFloat colorPrevCornerRadius;
    
    
    NSString* version;
    BOOL enableUkeTypes;
    BOOL enableThemes;
    BOOL enableCalibration;
    
    BOOL blockUserInteraction;
    
    CalibrationPicker *picker;
    CGFloat calibratedFrequency;
    CGFloat yPicker;
}

@end

@implementation SettingsMenuView


// from picker popup view
- (void)setCalibratedFrequeny:(CGFloat)frequency {
    calibratedFrequency = frequency;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@(frequency) forKey:KEY_CALIBRATED_FREQUENCY];
    
    picker = nil;
    [self.tableView reloadData];
    
    NSNumber* freqNumber = [NSNumber numberWithFloat:calibratedFrequency];
    
    // inform header view
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateCalibratedFrequencyNotification" object:freqNumber];
}

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        [self getCurrentVersion];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        calibratedFrequency = [[defaults stringForKey:KEY_CALIBRATED_FREQUENCY] floatValue];
        
        ukeTypesArray = [SHARED_MANAGER getUkuleleTypesArray];
        colorsArray = [SHARED_MANAGER getColorsArray];
        colorsDict = [SHARED_MANAGER getColorsDict];
        
        NSArray* availableProducts = [SHARED_VERSION_MANAGER getAvailableProducts];
        if (!availableProducts) {
            blockUserInteraction = YES;
        }
        
        switchDict = [NSMutableDictionary new];
        
        cellHeight = IS_IPAD ? 84.0 : 42.0;
        
        shadowRadius = IS_IPAD ? 0.4 : 0.2;
        shadowOffset = IS_IPAD ? 1.8 : 1.0;
        
        colorPrevCornerRadius = IS_IPAD ? 10.0 : 5.0;
        
        //self.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"settingsPattern.png"]];
        
        self.layer.cornerRadius = IS_IPAD ? 20.0 : 10.0;
        
        
        self.layer.shadowColor = [[UIColor blackColor] CGColor];
        self.layer.shadowRadius = shadowRadius;
        self.layer.shadowOpacity = 1;
        self.layer.shadowOffset = CGSizeMake(0.0, shadowOffset);
        self.layer.masksToBounds = NO;
        
        self.tableView=[[UITableView alloc] initWithFrame:self.frame style:UITableViewStyleGrouped];
        self.tableView.backgroundColor = [UIColor clearColor];
        self.tableView.dataSource=self;
        self.tableView.delegate=self;
        //        tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
        [self.tableView reloadData];
        // prevents to add more rows than specified
        [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
        
        [self.tableView setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        [self addSubview:self.tableView];
        
        [self setupConstraints];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateVersion:)
                                                     name:@"UpdateVersionNotification"
                                                   object:nil];
        
    }
    return self;
}

#pragma mark - Notification
- (void)getCurrentVersion {
    version = [SHARED_VERSION_MANAGER getVersion];
    
    if ([version_premium isEqualToString:version] || [version_uke isEqualToString:version]) {
        enableUkeTypes = YES;
    }
    if ([version_premium isEqualToString:version] || [version_signal isEqualToString:version]) {
        enableThemes = YES;
        enableCalibration = YES;
    }
}

- (void) updateVersion:(NSNotification *) notification {
    
    [self getCurrentVersion];
    [self.tableView reloadData];
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    switch (section) {
        case INSTRUMENT_TYPE: return ukeTypesArray.count; // for ukulele types
        case CALIBRATION: return 1;                       // for calibration
        case THEME: return colorsDict.count;    // for background colors
        default: return 1;                       // for restore button
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    // do not use this - see http://stackoverflow.com/questions/7911625/data-are-overlapping-when-i-am-scrolling-in-uitableview-why
    //    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier   forIndexPath:indexPath] ;
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    cell.backgroundColor = [UIColor clearColor];
    
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    
    // Highlight the default (Soprano) Ukulele
    UIColor* textColor = (section == INSTRUMENT_TYPE && row == 3) ? HIGHLIGHT_TEXT_COLOR: TEXT_COLOR;
    
    cell.textLabel.textColor = textColor;
    cell.detailTextLabel.textColor = textColor;
    cell.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"settingsPattern.png"]];
    
    UIImage* switchImage = [UIImage imageNamed:@"onButton.png"];
    UIImage* pickerImage = [UIImage imageNamed:@"calibrationButton.png"];
    
    CGFloat w = switchImage.size.width;
    CGFloat h = switchImage.size.height;
    CGFloat ratio = w/h;
    
    CGFloat iconHeight = 0.6*cellHeight;
    CGFloat y = 0.55 * (cellHeight - iconHeight);
    
    UIImageView *imv = [[UIImageView alloc] initWithFrame:CGRectMake(0.75*self.tableView.bounds.size.width,y, iconHeight*ratio, iconHeight)];
    // for restore button
    UIImageView *imvRes = [[UIImageView alloc] initWithFrame:CGRectMake(0.05*self.tableView.bounds.size.width,y, 2.0*iconHeight*ratio, iconHeight)];
    
    // for picker button (calibration)
    CGFloat fact = IS_IPAD ? 0.58 : 0.55;
    UIImageView *imvPick;
    
    if (enableCalibration==NO) {
        imvPick = [[UIImageView alloc] initWithFrame:imv.frame];
    } else {
        imvPick = [[UIImageView alloc] initWithFrame:CGRectMake(fact*self.tableView.bounds.size.width,y, 2.0*iconHeight*ratio, iconHeight)];
    }
    
    imvPick.image = pickerImage;
    
    if (section == INSTRUMENT_TYPE) {
        // Label only for sound types
        NSString* ukeType = ukeTypesArray[row];
        NSArray *stringSplitArray = [ukeType componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"("]];
        NSString* ukeTypeName = stringSplitArray[0];
        NSString* fullString = stringSplitArray[1];
        NSString* ukeTypeNotes = [fullString substringToIndex:fullString.length-1];
        
        NSString *language = [[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0];
        
        if ([language isEqualToString:@"de"]) {
            ukeTypeNotes = [ukeTypeNotes stringByReplacingOccurrencesOfString:@"B" withString:@"H"];
        }
        
        cell.textLabel.text = ukeTypeName;//formattedString;
        cell.detailTextLabel.text = ukeTypeNotes;
        
        UIFont* font = [UIFont fontWithName:FONT_BOLD size:[UILabel getFontSizeForSubHeadline]];
        
        cell.textLabel.font = font;
        cell.detailTextLabel.font = font;
        
    } else if (section == CALIBRATION) {
        // calibration (440 Hz)
        UIFont* font = [UIFont fontWithName:FONT_BOLD size:[UILabel getFontSizeForSubHeadline]];
        cell.textLabel.font = font;
        cell.textLabel.text = [NSString stringWithFormat:@"%.1f Hz", calibratedFrequency];
    } else if (section == THEME) {
        // images for color issues
        UIView* colorPrevView = [[UIView alloc] initWithFrame:CGRectMake(0.05*cell.bounds.size.width, y, 2.0*iconHeight*ratio, iconHeight)];
        colorPrevView.layer.cornerRadius = colorPrevCornerRadius;
        colorPrevView.layer.borderColor = [UIColor blackColor].CGColor;
        colorPrevView.layer.borderWidth = IS_IPAD ? 3.0 : 1.5;
        
        for (NSInteger i=0; i<colorsArray.count; i++) {
            if (i == row) {
                //cell.textLabel.text = colorsArray[i];
                
                NSString* colorString = colorsArray[i];
                
                id color = [colorsDict objectForKey:colorString];
                
                if ([GUITAR_COLOR_GAY isEqual:color]) {
                    [self makeBackgroundGay:colorPrevView];
                } else {
                    colorPrevView.backgroundColor = (UIColor*)color;
                }
                [cell.contentView addSubview:colorPrevView];
            }
        }
    } else {
        // restore button only (in app purchase)
        imvRes.image = RESTORE;
        if (blockUserInteraction) imvRes.alpha = 0.2;
    }
    
    UIImage* lineImage = [UIImage imageNamed:@"linePattern.png"];
    CGFloat h1 = lineImage.size.height;
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, h1)];
    lineView.backgroundColor = [[UIColor alloc] initWithPatternImage:lineImage];
    [cell.contentView addSubview:lineView];

    
    // get the data from user config!
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString* defaultUkeType = [defaults stringForKey:KEY_UKE_TYPE];
    NSString* defaultColorString = [defaults stringForKey:KEY_GUITAR_COLOR];
    
    NSString* trimmedDefaultUkeType = [defaultUkeType stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    // show switches or purchase button dependent on the current version
    // uke type
    if (section == INSTRUMENT_TYPE) {
        NSString* ukeType = [ukeTypesArray objectAtIndex:row];
        NSString* trimmedUkeType = [ukeType stringByReplacingOccurrencesOfString:@" " withString:@""];
        
        if ([trimmedUkeType isEqualToString:trimmedDefaultUkeType]) {
            imv.image = SWITCH_ON;
        } else {
            imv.image = SWITCH_OFF;
        }
    }
    // background color
    if (section == THEME) {
        NSString* rowColor = [colorsArray objectAtIndex:row];
        
        if ([rowColor isEqualToString:defaultColorString]) {
            imv.image = SWITCH_ON;
        } else {
            imv.image = SWITCH_OFF;
        }
    }
    // if not upgraded, block the options
    if (enableUkeTypes==NO && (section == INSTRUMENT_TYPE && row != 3)) {
        imv.image = PURCHASE;
        if (blockUserInteraction==YES) {
            imv.alpha = 0.2;
        }
    }
    if (enableCalibration==NO && section == CALIBRATION) {
        imvPick.image = PURCHASE;
        if (blockUserInteraction==YES) {
            imvPick.alpha = 0.2;
        }
    }
    if (enableThemes==NO && section == THEME && row != 0) {
        imv.image = PURCHASE;
        if (blockUserInteraction==YES) imv.alpha = 0.2;
    }
    
    
    /*
     * IMPORTANT: check if an icon has been already added, otherwise
     * another icon would be added after scroll decelerating !!!
     */
    BOOL cellHasIcon = NO;
    
    for (UIView* view in cell.contentView.subviews) {
        if ([view class] == [UIImageView class]) {
            cellHasIcon = YES;
            break;
        }
    }
    
    if (cellHasIcon==NO) {
        if (section==CALIBRATION) {
            // picker
            [cell.contentView addSubview:imvPick];
        } else if (section==RESTORE_BTN) {
            // restore button
            [cell.contentView addSubview:imvRes];
        } else {
            // switch
            [cell.contentView addSubview:imv];
        }
    }
    
    
    return cell;
}


#pragma mark - UITableViewDelegate

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    
    
    UILabel* headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, self.bounds.size.width, cellHeight)];
    headerLabel.textAlignment = NSTextAlignmentLeft;
    headerLabel.textColor = TEXT_COLOR_HEADER;
    
    NSString* labelText = @"";
    
    switch (section) {
        case INSTRUMENT_TYPE:  labelText = @"Ukulele Type"; break;     // for ukulele types
        case CALIBRATION:  labelText = @"Calibration"; break;    // for calibration
        case THEME:  labelText = @"Ukulele Color"; break;    // for background colors
        default: labelText = @"Purchase already done?";  // for restore button
    }
    
    headerLabel.text = labelText;
    
    headerLabel.font = [UIFont fontWithName:FONT_BOLD size:[UILabel getFontSizeForSubHeadline]];
    
    [view addSubview:headerLabel];
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return cellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return cellHeight;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    UITableViewCell*  selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    
    BOOL isShoppingCartSymbol = NO;
    
    // check if it deals with shopping cart - otherwise, don't block the switches!
    for (UIView* view in selectedCell.contentView.subviews) {
        if ([view class] == [UIImageView class]) {
            UIImage* img = ((UIImageView*)view).image;
            
            if ([img isEqual:PURCHASE] ) {
                isShoppingCartSymbol = YES;
            }
            break;
        }
    }
    
    if (blockUserInteraction==YES && isShoppingCartSymbol==YES) {
        
        // Display an error here.
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No data available"
                                                        message:@"The products could not be loaded from the App Store. Please try again later."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        
        return;
    }
 
    NSInteger touchedSection = indexPath.section;
    NSInteger touchedRow = indexPath.row;
    
    if (touchedSection == RESTORE_BTN) {
        [self restore];
        return;
    }
    
    // if options are blocked, only show upgrade menu, but don't change the button's state!
    if (enableUkeTypes==NO && touchedSection == INSTRUMENT_TYPE && touchedRow != 3) {
        [self showUpgrades];
        return;
    } else if (enableUkeTypes==NO && touchedSection == INSTRUMENT_TYPE && touchedRow == 3) {
        return;
    }
    if (enableCalibration==NO && touchedSection == CALIBRATION) {
        [self showUpgrades];
        return;
    }
    if (enableThemes==NO && touchedSection == THEME && touchedRow != 0) {
        [self showUpgrades];
        return;
    }

    
    if (touchedSection != CALIBRATION) {
    for (UIView* view in selectedCell.contentView.subviews) {
        if ([view class] == [UIImageView class]) {
            UIImage* img = ((UIImageView*)view).image;
            
            if ([img isEqual:SWITCH_ON] ) {
                ((UIImageView*)view).image = SWITCH_OFF;
            } else {
                ((UIImageView*)view).image = SWITCH_ON;
            }
            break;
        }
    }
    }
    
    BOOL hasActiveSwitch = NO;
    UITableViewCell* firstCell;
    
    if (touchedSection == CALIBRATION) {
        
        CGFloat factPickerWidth = IS_IPAD ? 0.75 : 1.0;
        // an UIPicker has only predefined heights
        CGFloat pickerHeight = IS_IPAD ? 216.0 : 180.0;
        
        yPicker = [tableView rectForRowAtIndexPath:indexPath].origin.y - [self.tableView contentOffset].y;
        
        if (yPicker + pickerHeight > self.frame.size.height) {
            yPicker = self.frame.size.height - pickerHeight;
        }
        
        CGRect rect = CGRectMake(0.0, yPicker, factPickerWidth*self.frame.size.width, pickerHeight);
        
        if (!picker) {
            picker = [[CalibrationPicker alloc] initWithFrame:rect];
            picker.delegate = self;
            [self addSubview:picker];
        }
    } else {
        NSInteger rows =  [tableView numberOfRowsInSection:touchedSection];
        for (NSInteger row = 0; row < rows; row++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:touchedSection];
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            
            if (row == 0) {
                firstCell = cell;
            }
            
            if (![cell isEqual:selectedCell]) {
                for (UIView* view in cell.contentView.subviews) {
                    if ([view class] == [UIImageView class]) {
                        UIImage* img = ((UIImageView*)view).image;
                        
                        if ([img isEqual:SWITCH_ON] ) {
                            ((UIImageView*)view).image = SWITCH_OFF;
                            hasActiveSwitch = YES;
                        }
                        break;
                    }
                }
            }
        }
        // if no switch is on, enable the first (=default) switch
        if (hasActiveSwitch==NO) {
            
            for (UIView* view in firstCell.contentView.subviews) {
                if ([view class] == [UIImageView class]) {
                    ((UIImageView*)view).image = SWITCH_ON;
                    touchedRow = 0;
                    break;
                }
            }
            
        }
    }

    // now evaluate
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // Ukulele Type
    if (touchedSection == INSTRUMENT_TYPE) {
        NSString* ukeType = [ukeTypesArray objectAtIndex:touchedRow];
        [defaults setObject:ukeType forKey:KEY_UKE_TYPE];
    }

    
    // Background Color
    if (touchedSection == THEME) {
        NSString* selectedColor = [colorsArray objectAtIndex:touchedRow];
        [defaults setObject:selectedColor forKey:KEY_GUITAR_COLOR];
    }
    
    [defaults synchronize];
    
    // inform BackgroundView of color change
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateDefaultsNotification" object:nil];
    
}


- (void)restore {
    
    if (blockUserInteraction) return;
    
    [self addThrobber];
    
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}


#pragma mark -SKPaymentTransactionObserver
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions{
    for(SKPaymentTransaction *transaction in transactions){

        switch((NSInteger)transaction.transactionState){
            case SKPaymentTransactionStatePurchasing: NSLog(@"Transaction state -> Purchasing");
                //called when the user is in the process of purchasing, do not add any of your own code here.
                break;
            case SKPaymentTransactionStatePurchased:
                NSLog(@"Transaction state -> Purchased");
                //this is called when the user has successfully purchased the package
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                // called when user restores the content he purchased previously
                NSLog(@"Transaction state -> Restored");
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                NSLog(@"Transaction state -> Failed");
                //called when the transaction does not finish
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
        }
    }
    
}


- (void) paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue {
    
    [self.loadingView removeFromSuperview];
    
    NSLog(@"received restored transactions: %lu", (unsigned long)queue.transactions.count);
    
    if (queue.transactions.count == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Restore"
                                                        message:@"You have no available features to restore."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    for (SKPaymentTransaction *transaction in queue.transactions) {
        NSString *productID = transaction.payment.productIdentifier;
        //[purchasedItemIDs addObject:productID];
        if ([productID isEqualToString:inAppPurchasePremium]) {
            [SHARED_VERSION_MANAGER setCurrentVersion:version_premium];
            // if premium version, no other updates are required!
            break;
        } else if ([productID isEqualToString:inAppPurchaseUke]) {
            [SHARED_VERSION_MANAGER setCurrentVersion:version_uke];
        } else if ([productID isEqualToString:inAppPurchaseSignal]) {
            [SHARED_VERSION_MANAGER setCurrentVersion:version_signal];
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        // IMPORTANT: inform previous views about the update and unlock the features!
        [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateVersionNotification" object:nil];
    });
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Restore Successful"
                                                    message:@"Your restore has been successfully completed."
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    
}

#pragma mark -SKPaymentTransactionObserver
- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error {
    [self.loadingView removeFromSuperview];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Restore Unsuccessful"
                                                    message:@"Your restore could not be completed."
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

- (void) addThrobber {
    
    self.loadingView = [[UIView alloc]initWithFrame:self.superview.frame];
    self.loadingView.backgroundColor = [UIColor colorWithWhite:0. alpha:0.6];
    self.loadingView.layer.cornerRadius = 5;
    
    UIActivityIndicatorView *activityView=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityView.center = CGPointMake(self.loadingView.frame.size.width / 2.0, self.loadingView.frame.size.height / 2.0);
    [activityView startAnimating];
    activityView.tag = 100;
    [self.loadingView addSubview:activityView];
    
    [self.superview addSubview:self.loadingView];
}

// make modal window for user defined settings
- (void) showUpgrades {
    UIWindow* window = [UIApplication sharedApplication].keyWindow;
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    self.upgradeView = [[UpgradeView alloc] initWithFrame: CGRectMake ( 0, 0, screenWidth, screenHeight)];
    
    [window addSubview:self.upgradeView];
}


#pragma mark - layout constraints
- (void)setupConstraints {
    
    
    NSMutableArray *layoutConstraints = [NSMutableArray new];
    
    
    
    // Center horizontally
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.tableView
                                                              attribute:NSLayoutAttributeLeft
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeLeft
                                                             multiplier:1.0
                                                               constant:0.0]];
    // Center vertically
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.tableView
                                                              attribute:NSLayoutAttributeTop
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeTop
                                                             multiplier:1.0
                                                               constant:0.0]];
    // Width
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.tableView
                                                              attribute:NSLayoutAttributeWidth
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeWidth
                                                             multiplier:1.0
                                                               constant:0.0]];
    
    // Height
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.tableView
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeHeight
                                                             multiplier:1.0
                                                               constant:0.0]];
    
    
    
    
    
    // add all constraints at once
    [self addConstraints:layoutConstraints];
    
}

- (void) makeBackgroundGay:(UIView*)view {
    
    gradient = [CAGradientLayer layer];
    
    UIColor *c1 = [UIColor colorWithRed:0.60 green:0.00 blue:1.00 alpha:1.0]; // lila
    UIColor *c2 = [UIColor colorWithRed:0.23 green:0.23 blue:0.91 alpha:1.0]; // blue
    UIColor *c3 = [UIColor colorWithRed:0.32 green:0.84 blue:0.09 alpha:1.0]; // green
    UIColor *c4 = [UIColor colorWithRed:1.00 green:1.00 blue:0.00 alpha:1.0]; // yellow
    UIColor *c5 = [UIColor colorWithRed:1.00 green:0.62 blue:0.00 alpha:1.0]; // orange
    UIColor *c6 = [UIColor colorWithRed:1.00 green:0.00 blue:0.00 alpha:1.0]; // red
    
    gradient.colors = [NSArray arrayWithObjects:(id)[c1 CGColor],(id)[c2 CGColor], (id)[c3 CGColor], (id)[c4 CGColor],(id)[c5 CGColor],(id)[c6 CGColor], nil];
    
    
    CGFloat width = view.bounds.size.width;
    CGFloat height = view.bounds.size.height;
    
    
    CGRect bounds = CGRectMake(0.0, 0.0, width, height);
    gradient.bounds = bounds;
    
    gradient.anchorPoint = CGPointZero;
    
    gradient.startPoint = CGPointMake(0.0, 0.5);
    gradient.endPoint = CGPointMake(1.0, 0.5);
    
    NSMutableArray* locationsarray = [NSMutableArray new];
    
    CGFloat fact = 1.0/6.0;
    CGFloat pos = 0.0;
    
    for (NSInteger i=0; i<6; i++) {
        [locationsarray addObject:[NSNumber numberWithFloat:pos]];
        pos += fact;
    }
    
    gradient.locations = locationsarray;
    
    gradient.cornerRadius = colorPrevCornerRadius;
    
    [view.layer insertSublayer:gradient atIndex:0];
}

-(void)dealloc {
    //NSLog(@"%s", __PRETTY_FUNCTION__);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
