//
//  UpgradeView.m
//  Simple Ukulele Tuner
//
//  Created by Ulrich Vormbrock on 03.08.15.
//  Copyright (c) 2015 Vormbrock. All rights reserved.
//

#import "UpgradeMenuView.h"
#import <StoreKit/StoreKit.h>


#define kInAppPurchaseId "ch.vormbrock.simpleukuleletunerpro.premium"

#define TEXT_COLOR [UIColor colorWithRed:161.0/255.0 green:161.0/255.0 blue:161.0/255.0 alpha:1.0]
#define HEADER_COLOR [UIColor colorWithRed:0.471 green:0.937 blue:0.086 alpha:1] /*#78ef16*/

#define PURCHASE [UIImage imageNamed:@"shoppingCart.png"]

@interface UpgradeMenuView() <SKPaymentTransactionObserver> {

    CGFloat headerHeight, cellHeight;
    NSArray *availableProducts;
}

@end

@implementation UpgradeMenuView


- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {

        headerHeight = IS_IPAD ? 90 : 50;
        cellHeight = IS_IPAD ? 150 : 110;
        
        // get all available updates from the App Store by Singleton
        availableProducts = [SHARED_VERSION_MANAGER getAvailableProducts];
        
        self.backgroundColor = SETTINGS_BG_COLOR;

        self.tableView=[[UITableView alloc] initWithFrame:self.frame style:UITableViewStyleGrouped];
        self.tableView.backgroundColor = [UIColor clearColor];
        self.tableView.dataSource=self;
        self.tableView.delegate=self;
        [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
        [self.tableView reloadData];
        // prevents to add more rows than specified
        [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
        
        [self.tableView setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.tableView.sectionFooterHeight = 0.0;
        
        [self addSubview:self.tableView];
        
        [self setupConstraints];
   
    }
    return self;
}


#pragma mark -SKPaymentTransactionObserver
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions{
    for(SKPaymentTransaction *transaction in transactions){
        
        NSString *productID = transaction.payment.productIdentifier;
        
        switch((NSInteger)transaction.transactionState){
            case SKPaymentTransactionStatePurchasing: NSLog(@"Transaction state -> Purchasing");
                //called when the user is in the process of purchasing, do not add any of your own code here.
                break;
            case SKPaymentTransactionStatePurchased:
                NSLog(@"Transaction state -> Purchased");
                [self clearTransaction];
                //this is called when the user has successfully purchased the package
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                [self performUpgrade:productID]; //you can add your code for what you want to happen when the user buys the purchase here, for this tutorial we use removing ads
                break;
            case SKPaymentTransactionStateRestored:
                // called when user restores the content he purchased previously
                NSLog(@"Transaction state -> Restored");
                [self clearTransaction];
                //add the same code as you did from SKPaymentTransactionStatePurchased here
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                [self performUpgrade:productID]; //you can add your code for what you want to happen when the user buys the purchase here, for this tutorial we use removing ads
                break;
            case SKPaymentTransactionStateFailed:
                NSLog(@"Transaction state -> Failed");
                [self clearTransaction];
                //called when the transaction does not finish
                [self showFailedTransaction:transaction];
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
        }
    }
    
}

- (void) showFailedTransaction: (SKPaymentTransaction *)transaction {
    
    if (transaction.error.code != SKErrorPaymentCancelled){
        // Display an error here.
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Purchase Unsuccessful"
                                                        message:@"Your purchase failed. Please try again."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // (title in header)
    // 1. description
    // 2. price and "buy-button"
    return 2;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return availableProducts.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    
    cell.backgroundColor = [UIColor clearColor];
    
    cell.textLabel.textColor = TEXT_COLOR;
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.textLabel.numberOfLines = 0;
    //cell.detailTextLabel.textColor = TEXT_COLOR;
    
    NSInteger row = indexPath.row;
    NSInteger sec = indexPath.section;

    cell.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"settingsPattern.png"]];

    // retrieve product infos from the Store
    SKProduct *product = [availableProducts objectAtIndex:sec];
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numberFormatter setLocale:product.priceLocale];

    NSString *decription = product.localizedDescription;
    NSString *price = [numberFormatter stringFromNumber:product.price];
    
    UIFont* font = (row == 0) ? [UIFont fontWithName:FONT_BOLD size:[UILabel getFontSizeForSubHeadline]] : [UIFont fontWithName:FONT_BOLD size:[UILabel getFontSizeForHeadline]];
    cell.textLabel.font = font;
    cell.textLabel.text = (row == 0) ? decription : price;
    
    CGFloat diminFact = IS_IPAD ? 0.8 : 0.5;
    CGFloat buttonX = IS_IPAD ? 0.75 : 0.6;
    
    CGFloat width = self.bounds.size.width;
    
    if (row == 1) {
        
        NSString* productTitel = product.localizedTitle;
        NSLog(@"Purchase Item: %@", productTitel);
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        button.tag = sec; // parameter "section" in order to evaluate the right product
        
        [button addTarget:self
                   action:@selector(purchase:)
         forControlEvents:UIControlEventTouchUpInside];
        UIImage *buttonImage = PURCHASE;
        [button setBackgroundImage:buttonImage forState:UIControlStateNormal];
        button.frame = CGRectMake(buttonX*width, 0.25*cell.frame.size.height, diminFact*buttonImage.size.width, diminFact*buttonImage.size.height);
        [cell.contentView addSubview:button];
    }

    return cell;
}

- (void)purchase:(UIButton*)sender{
    
    [self addThrobber];
    
    NSInteger index = sender.tag;
    SKProduct *selectedProduct = availableProducts[index];

//    // REMOVE later - it's only for test issues ...
//    [self performUpgrade:selectedProduct.productIdentifier];
//    return;
    
    SKPayment *payment = [SKPayment paymentWithProduct:selectedProduct];
    
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (void) performUpgrade:(NSString*) productID {

    if ([productID isEqualToString:inAppPurchasePremium]) {
        [SHARED_VERSION_MANAGER setCurrentVersion:version_premium];
    } else if ([productID isEqualToString:inAppPurchaseUke]) {
        [SHARED_VERSION_MANAGER setCurrentVersion:version_uke];
    } else if ([productID isEqualToString:inAppPurchaseSignal]) {
        [SHARED_VERSION_MANAGER setCurrentVersion:version_signal];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        // IMPORTANT: inform previous views about the update and unlock the features!
        [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateVersionNotification" object:nil];
        
        [self.superview removeFromSuperview];
    });
    
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

- (void) clearTransaction {
    
    // IMPORTANT: remove transaction observer after transaction - otherwise
    // system crashes if user tries to perform another transaction
    // see http://stackoverflow.com/questions/4150926/in-app-purchase-crashes-on-skpaymentqueue-defaultqueue-addpaymentpayment
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
    // remove throbber
    [self.loadingView removeFromSuperview];
}


#pragma mark - UITableViewDelegate
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    
    SKProduct *product = [availableProducts objectAtIndex:section];
    NSString *title = product.localizedTitle;
    
    NSInteger posX = 0;//15;
    
    UILabel* headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(posX, 5, self.bounds.size.width, headerHeight)];
    headerLabel.textAlignment = NSTextAlignmentLeft;
    headerLabel.textColor = HEADER_COLOR;
    headerLabel.text = title;
    
    headerLabel.font = [UIFont fontWithName:FONT_BOLD size:[UILabel getFontSizeForHeadline]];
    
    [view addSubview:headerLabel];

    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return headerHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger row = indexPath.row;
    NSInteger sec = indexPath.section;
    
    SKProduct *product = availableProducts[sec];
    NSString *description = product.localizedDescription;
    NSUInteger descLen = description.length;
    NSInteger height = (descLen > cellHeight) ? cellHeight : descLen;
    if (IS_IPAD) height *= 1.2;
    
    return row == 0 ? height : 0.6*cellHeight;
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
                                                             multiplier:0.9
                                                               constant:0.0]];

    
    // add all constraints at once
    [self addConstraints:layoutConstraints];
    
}

@end
