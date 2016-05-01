//
//  AppDelegate.m
//  Diapason
//
//  Created by imac on 13.03.15.
//  Copyright (c) 2015 Vormbrock. All rights reserved.
//

#import "AppDelegate.h"
#import <StartApp/StartApp.h>
#import <HockeySDK/HockeySDK.h>

@interface AppDelegate () {
    int numberOfAwakenings;
}

@end

@implementation AppDelegate


+ (void)initialize {
    
    [iRate sharedInstance].appStoreID = [APPSTORE_ID integerValue]; // Simple Ukulele Tuner on the App Store
    
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
    
    NSDictionary *sensitivityDefaults = [NSDictionary dictionaryWithObject:@"3"
                                                                forKey:KEY_SENSITIVITY];
    
    [defaults registerDefaults:ukeDefaults];
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
        
        // initialize the SDK with your appID and devID
        STAStartAppSDK* sdk = [STAStartAppSDK sharedInstance];
        sdk.appID = @"203844333";
        //sdk.devID = @"ulrich.vormbrock@gmail.com";
        //sdk.preferences = [STASDKPreferences prefrencesWithAge:22 andGender:STAGender_Male];
 
        STASplashPreferences *splashPreferences = [[STASplashPreferences alloc] init];
        splashPreferences.splashMode = STASplashModeTemplate;
        splashPreferences.splashTemplateTheme = STASplashTemplateThemeDeepBlue;
        splashPreferences.splashLoadingIndicatorType = STASplashLoadingIndicatorTypeIOS;
        splashPreferences.splashTemplateAppName = @"Simple Ukulele Tuner";

        [sdk showSplashAdWithPreferences:splashPreferences];
        
    } else {
        [NSThread sleepForTimeInterval:TIME_SPLASHSCREEN];
    }
    
    [[BITHockeyManager sharedHockeyManager] configureWithIdentifier:@"bb70efab0ba040dca1f36838915d24f2"];
    [[BITHockeyManager sharedHockeyManager] startManager];
    [[BITHockeyManager sharedHockeyManager].authenticator authenticateInstallation];
    
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
