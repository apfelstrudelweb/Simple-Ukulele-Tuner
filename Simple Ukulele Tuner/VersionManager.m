//
//  VersionManager.m
//  Simple Ukulele Tuner
//
//  Created by Ulrich Vormbrock on 05.08.15.
//  Copyright (c) 2015 Vormbrock. All rights reserved.
//

#import "VersionManager.h"




@implementation VersionManager

#pragma mark Singleton Methods

+ (id)sharedManager {
    static VersionManager *versionManager = nil;
    @synchronized(self) {
        if (versionManager == nil)
            versionManager = [[self alloc] init];
    }
    return versionManager;
}

- (id)init {
    if (self = [super init]) {
        
        // 1. get current version (lite, uke, signal or premium)
        self.bindings = [PDKeychainBindings sharedKeychainBindings];
        NSString* version = [self.bindings objectForKey:UPGRADE_TYPE];
        
        self.version = version ? version : version_lite;
        
        // 2. get available versions from the App Store
        NSArray* inAppPurchaseArray;
        
#if defined(TARGET_UKULELE)
        inAppPurchaseArray = UKE_INAPP_PURCHASE_ARRAY;
#elif defined(TARGET_GUITAR)
        inAppPurchaseArray = GUITAR_INAPP_PURCHASE_ARRAY;
#elif defined(TARGET_MANDOLIN)
        inAppPurchaseArray = MANDOLIN_INAPP_PURCHASE_ARRAY;
#elif defined(TARGET_BANJO)
        inAppPurchaseArray = BANJO_INAPP_PURCHASE_ARRAY;
#elif defined(TARGET_VIOLIN)
        inAppPurchaseArray = VIOLIN_INAPP_PURCHASE_ARRAY;
#elif defined(TARGET_BALALAIKA)
        inAppPurchaseArray = BALALAIKA_INAPP_PURCHASE_ARRAY;
#endif
        
        self.availableProducts = [NSMutableArray new];
        
        for (NSString* productId in inAppPurchaseArray) {
            if([SKPaymentQueue canMakePayments]){
                NSLog(@"User can make payments");
                
                SKProductsRequest *productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:productId]];
                productsRequest.delegate = self;
                [productsRequest start];
            }
            else{
                //the user is not allowed to make payments
                NSLog(@"User cannot make payments due to parental controls");
            }
        }
    }
    return self;
}

#pragma mark -SKProductsRequestDelegate
- (void) productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    SKProduct *validProduct = nil;
    
    NSInteger count = (NSInteger)[response.products count];
    if(count > 0) {
        validProduct = [response.products objectAtIndex:0];
        [self.availableProducts addObject:validProduct];
    } else if(!validProduct){
        NSLog(@"No products available");
        //this is called if your product id is not valid, this shouldn't be called unless that happens.
    }
}

- (void) setCurrentVersion:(NSString*)version {
    
    if ([version_instrument isEqualToString:self.version]) {
        self.version = version_premium;
    } else if ([version_signal isEqualToString:self.version]) {
        self.version = version_premium;
    } else {
        self.version = version;
    }
    
    // inform key chain bindings -> important when app is restarted again (initial settings)
    [self.bindings setObject:self.version forKey:UPGRADE_TYPE];
}

-(NSString*) getVersion {
    
    if (!self.version) {
        self.version = version_lite;
    }
    
    return self.version;
}

// returns an array of ordered products: 1. premium, 2. uke, 3. signal
-(NSArray*) getAvailableProducts {
    
    // if products could not be completly loaded from the AppStore, don't continue - but disable the shopping carts
    
    NSUInteger numProducts = 3;
#if defined(TARGET_VIOLIN) || defined(TARGET_MANDOLIN)
    numProducts = 1;
#endif

    if (self.availableProducts.count < numProducts) {
        return nil;
    }
    
    NSMutableArray* orderedProducts = [NSMutableArray new];
    
    SKProduct *product1, *product2, *product3;
    
    
    NSString *upgradeOptionPremium;
    NSString *upgradeOptionInstrument;
    NSString *upgradeOptionSignal;
    
#if defined(TARGET_UKULELE)
    upgradeOptionPremium = uke_inAppPurchasePremium;
    upgradeOptionInstrument = uke_inAppPurchaseUke;
    upgradeOptionSignal = uke_inAppPurchaseSignal;
#elif defined(TARGET_GUITAR)
    upgradeOptionPremium = guitar_inAppPurchasePremium;
    upgradeOptionInstrument = guitar_inAppPurchaseGuitar;
    upgradeOptionSignal = guitar_inAppPurchaseSignal;
#elif defined(TARGET_MANDOLIN)
    
#elif defined(TARGET_BANJO)
    upgradeOptionPremium = banjo_inAppPurchasePremium;
    upgradeOptionInstrument = banjo_inAppPurchaseBanjo;
    upgradeOptionSignal = banjo_inAppPurchaseSignal;
#elif defined(TARGET_VIOLIN)
    upgradeOptionPremium = violin_inAppPurchasePremium;
#elif defined(TARGET_BALALAIKA)
    upgradeOptionPremium = balalaika_inAppPurchasePremium;
    upgradeOptionInstrument = balalaika_inAppPurchaseBalalaika;
    upgradeOptionSignal = balalaika_inAppPurchaseSignal;
#endif
    
    for (SKProduct* product in self.availableProducts) {
        if ([product.productIdentifier isEqualToString:upgradeOptionPremium]) {
            product1 = product;
        } else if ([product.productIdentifier isEqualToString:upgradeOptionInstrument]) {
            product2 = product;
        } else if ([product.productIdentifier isEqualToString:upgradeOptionSignal]) {
            product3 = product;
        }
    }

#if defined(TARGET_VIOLIN)
    if ([version_lite isEqualToString:self.version] && product1) {
        [orderedProducts insertObject:product1 atIndex:0];
#else
    if ([version_lite isEqualToString:self.version] && product1 && product2 && product3) {
        [orderedProducts insertObject:product1 atIndex:0];
        [orderedProducts insertObject:product2 atIndex:1];
        [orderedProducts insertObject:product3 atIndex:2];
#endif
    } else if ([version_instrument isEqualToString:self.version] && product3) {
        //[orderedProducts insertObject:product1 atIndex:0];
        [orderedProducts insertObject:product3 atIndex:0];
    } else if ([version_signal isEqualToString:self.version] && product2) {
        //[orderedProducts insertObject:product1 atIndex:0];
        [orderedProducts insertObject:product2 atIndex:0];
    }
    
    
    return orderedProducts;
}


@end
