//
//  AppDelegate.m
//  Diapason
//
//  Created by imac on 13.03.15.
//  Copyright (c) 2015 Vormbrock. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate () {
    int numberOfAwakenings;
}

@end

@implementation AppDelegate


+ (void)initialize {
    
    [iRate sharedInstance].appStoreID = 1022749854; // Simple Ukulele Tuner Pro on the App Store
    
    [iRate sharedInstance].daysUntilPrompt = 5;
    [iRate sharedInstance].usesUntilPrompt = 10;
    
    [iRate sharedInstance].promptForNewVersionIfUserRated = YES;
    
    //    //enable preview mode
    //    [iRate sharedInstance].previewMode = YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    //    // TODO: REMOVE LATER, it's only for testing!
    PDKeychainBindings *bindings = [PDKeychainBindings sharedKeychainBindings];
    [bindings setObject:version_premium forKey:UPGRADE_TYPE];
    //[bindings setObject:version_uke forKey:UPGRADE_TYPE];
    //[bindings setObject:version_signal forKey:UPGRADE_TYPE];
    //[bindings removeObjectForKey:UPGRADE_TYPE];
    
    // Set the application defaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *ukeDefaults = [NSDictionary dictionaryWithObject:@"Soprano (G4-C4-E4-A4)"
                                                            forKey:@"ukuleleType"];
    
    NSDictionary *colorDefaults = [NSDictionary dictionaryWithObject:@"default"
                                                              forKey:@"guitarColor"];
    
    NSDictionary *calFreqDefaults = [NSDictionary dictionaryWithObject:@"440.0"
                                                                forKey:KEY_CALIBRATED_FREQUENCY];
    
    [defaults registerDefaults:ukeDefaults];
    [defaults registerDefaults:colorDefaults];
    [defaults registerDefaults:calFreqDefaults];
    [defaults synchronize];
    
    [NSThread sleepForTimeInterval:TIME_SPLASHSCREEN];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    ViewController *rootViewController = [ViewController new];
    self.window.rootViewController = rootViewController;
    
    [self.window makeKeyAndVisible];
    
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
