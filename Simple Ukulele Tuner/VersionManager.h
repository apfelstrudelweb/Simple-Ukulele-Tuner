//
//  VersionManager.h
//  Simple Ukulele Tuner
//
//  Created by Ulrich Vormbrock on 05.08.15.
//  Copyright (c) 2015 Vormbrock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PDKeychainBindings.h"
#import <StoreKit/StoreKit.h>

@interface VersionManager : NSObject <SKProductsRequestDelegate> 

@property(nonatomic, assign) NSString* version;
@property(nonatomic, assign) PDKeychainBindings *bindings;
@property(nonatomic, retain) NSMutableArray* availableProducts;

+ (id) sharedManager;
- (id) init;
- (void) setCurrentVersion:(NSString*)version;
- (NSString*) getVersion;
- (NSArray*) getAvailableProducts;

@end
