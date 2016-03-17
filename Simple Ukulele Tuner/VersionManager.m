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
        NSArray* inAppPurchaseArray = INAPP_PURCHASE_ARRAY;
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
    
    if ([version_uke isEqualToString:self.version]) {
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
    if (self.availableProducts.count < 3) {
        return nil;
    }
    
    NSMutableArray* orderedProducts = [NSMutableArray new];
    
    SKProduct *product1, *product2, *product3;
    
    for (SKProduct* product in self.availableProducts) {
        if ([product.productIdentifier isEqualToString:inAppPurchasePremium]) {
            product1 = product;
        } else if ([product.productIdentifier isEqualToString:inAppPurchaseUke]) {
            product2 = product;
        } else if ([product.productIdentifier isEqualToString:inAppPurchaseSignal]) {
            product3 = product;
        }
    }
    
    
    if ([version_lite isEqualToString:self.version] && product1 && product2 && product3) {
        [orderedProducts insertObject:product1 atIndex:0];
        [orderedProducts insertObject:product2 atIndex:1];
        [orderedProducts insertObject:product3 atIndex:2];
    } else if ([version_uke isEqualToString:self.version] && product3) {
        //[orderedProducts insertObject:product1 atIndex:0];
        [orderedProducts insertObject:product3 atIndex:0];
    } else if ([version_signal isEqualToString:self.version] && product2) {
        //[orderedProducts insertObject:product1 atIndex:0];
        [orderedProducts insertObject:product2 atIndex:0];
    }
    
    
    return orderedProducts;
}


@end