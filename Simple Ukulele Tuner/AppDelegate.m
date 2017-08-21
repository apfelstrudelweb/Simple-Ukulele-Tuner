//
//  AppDelegate.m
//  Diapason
//
//  Created by imac on 13.03.15.
//  Copyright (c) 2015 Vormbrock. All rights reserved.
//

#import "AppDelegate.h"
@import GoogleMobileAds;

@interface AppDelegate () {
    int numberOfAwakenings;
}

@end

@implementation AppDelegate


+ (void)initialize {
    
    [iRate sharedInstance].appStoreID = [APPSTORE_ID integerValue]; // App ID from App Store
    
    [iRate sharedInstance].daysUntilPrompt = 5;
    [iRate sharedInstance].usesUntilPrompt = 10;
    
    [iRate sharedInstance].promptForNewVersionIfUserRated = YES;
    
    //[iRate sharedInstance].previewMode = YES;
    
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    //    // TODO: REMOVE LATER, it's only for testing!
//    PDKeychainBindings *bindings = [PDKeychainBindings sharedKeychainBindings];
//    [bindings setObject:version_premium forKey:UPGRADE_TYPE];
    //[bindings setObject:version_instrument forKey:UPGRADE_TYPE];
    //[bindings setObject:version_signal forKey:UPGRADE_TYPE];
//    [bindings removeObjectForKey:UPGRADE_TYPE];
    
    // Set the application defaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *instrumentDefaults;
    
    
#if defined(TARGET_UKULELE)
    instrumentDefaults = [NSDictionary dictionaryWithObject:@"Soprano (G4 - C4 - E4 - A4)"
                                                      forKey:@"ukuleleType"];
#elif defined(TARGET_GUITAR)
    instrumentDefaults = [NSDictionary dictionaryWithObject:@"6 - Classical / Acoustic (E - A - D - G - B - E)"
                                                     forKey:@"guitarType"];
#elif defined(TARGET_MANDOLIN)
    
#elif defined(TARGET_BANJO)
    instrumentDefaults = [NSDictionary dictionaryWithObject:@"5 - Standard (G4 - D3 - G3 - B3 - D4)"
                                                     forKey:@"banjoType"];
#elif defined(TARGET_VIOLIN)
    instrumentDefaults = [NSDictionary dictionaryWithObject:@"4 - Standard (G3 - D4 - A4 - E5)"
                                                     forKey:@"violinType"];
#elif defined(TARGET_BALALAIKA)
    instrumentDefaults = [NSDictionary dictionaryWithObject:@"3 - Prima (E4 - E4 - A4)"
                                                     forKey:@"balalaikaType"];
#endif
    
    
    NSDictionary *colorDefaults = [NSDictionary dictionaryWithObject:@"default"
                                                              forKey:@"instrumentColor"];
    
    NSDictionary *calFreqDefaults = [NSDictionary dictionaryWithObject:@"440.0"
                                                                forKey:KEY_CALIBRATED_FREQUENCY];
    
    NSDictionary *sensitivityDefaults = [NSDictionary dictionaryWithObject:@"3"
                                                                forKey:KEY_SENSITIVITY];
    
    [defaults registerDefaults:instrumentDefaults];
    [defaults registerDefaults:colorDefaults];
    [defaults registerDefaults:calFreqDefaults];
    [defaults registerDefaults:sensitivityDefaults];
    [defaults synchronize];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    ViewController *rootViewController = [ViewController new];
    self.window.rootViewController = rootViewController;
    
    [self.window makeKeyAndVisible];
    
    NSString* currentVersion = [SHARED_VERSION_MANAGER getVersion];
    
    if ([version_lite isEqualToString:currentVersion]) {
        

        
#if defined(TARGET_UKULELE)
    [GADMobileAds configureWithApplicationID:@"ca-app-pub-1849205192643985~9210661648"];
#elif defined(TARGET_GUITAR)
    [GADMobileAds configureWithApplicationID:@"ca-app-pub-1849205192643985~2845575608"];
#elif defined(TARGET_MANDOLIN)
       
#elif defined(TARGET_BANJO)
    [GADMobileAds configureWithApplicationID:@"ca-app-pub-1849205192643985~7994138115"];
#elif defined(TARGET_VIOLIN)
      
#elif defined(TARGET_BALALAIKA)
    [GADMobileAds configureWithApplicationID:@"ca-app-pub-1849205192643985~7073251764"];
#endif

        
        
    } else {
        [NSThread sleepForTimeInterval:TIME_SPLASHSCREEN];
    }
    [SHARED_MANAGER setCurrentSamplingRate:PREFERRED_SAMPLING_RATE];
    
    return YES;
}


- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    //NSLog(@"applicationWillResignActive");
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    //NSLog(@"applicationDidEnterBackground");
    
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"ApplicationDidEnterBackgroundNotfication" object:nil];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    //NSLog(@"applicationWillEnterForeground");
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    //NSLog(@"applicationWillTerminate");
}

@end
