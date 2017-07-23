//
//  ViewController.m
//  Simple Ukulele Tuner
//
//  Created by Ulrich Vormbrock on 16.03.16.
//  Copyright © 2016 Ulrich Vormbrock. All rights reserved.
//

#import "ViewController.h"

// Import header files from the SDK
#import "VpadnBanner.h"
#import "VpadnInterstitial.h"
@import VpadnSDKAdKit;


@interface ViewController ()<VpadnBannerDelegate, VpadnInterstitialDelegate> {
    UIView* bannerView;
    VpadnBanner*    vpadnAd; // Declare the instance of Vpadn's banner Ads
    VpadnInterstitial*    vpadnInterstitial; // Declare the instance of Vpadn's interstitial Ads
}

@property (nonatomic, strong) UIWebView *webView;

// Addition SDK
@property (nonatomic, strong) VpadnBanner *bannerAd;
@property (nonatomic, strong) VpadnInterstitial *interstitialAd;
//@property (weak, nonatomic) UIView *bannerView;

@end

@implementation ViewController

//- (void)viewDidLoad {
//    [super viewDidLoad];
//    // Do any additional setup after loading the view, typically from a nib.
//    
////    startAppNativeAd = [[STAStartAppNativeAd alloc] init];
////    [startAppNativeAd loadAd];
//    
//    
//}

- (void)viewDidLoad {
    [super viewDidLoad];

    NSString* currentVersion = [SHARED_VERSION_MANAGER getVersion];
    
    //if ([version_lite isEqualToString:currentVersion]) {
    
    
    CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
    CGFloat headerHeight = [SUBVIEW_PROPORTIONS[0] floatValue] + 0.05;
    CGFloat bannerOffset = screenHeight * headerHeight / 100.0;
    
    if (bannerView == nil) {
        
        bannerView = [[UIView alloc] initWithFrame:CGRectMake(0, bannerOffset, VpadnAdSizeSmartBannerPortrait.size.width, VpadnAdSizeBanner.size.height)];
        [self.view addSubview:bannerView];
    }
    

    // Set up bannerAd
    _bannerAd = [[VpadnBanner alloc] initWithAdSize:VpadnAdSizeSmartBannerPortrait origin:bannerView.frame.origin];

#if defined(TARGET_UKULELE)
    _bannerAd.strBannerId = @"8a8081825d545237015d6ef74ad51a43";
#elif defined(TARGET_GUITAR)
    _bannerAd.strBannerId = @"8a8081825d545237015d6f541cd21a51"; 
#endif
    
    _bannerAd.platform = @"TW"; // registered in Taiwan website
    _bannerAd.delegate = self;
    [_bannerAd setAdAutoRefresh:YES];
    [_bannerAd setRootViewController:self];

    [_bannerAd startGetAd:[self getTestIdentifiers]];
    [bannerView addSubview:[_bannerAd getVpadnAdView]];
    //}
}

- (NSArray *)getTestIdentifiers {
    
    NSString* uniqueIdentifier = [[[UIDevice currentDevice] identifierForVendor] UUIDString]; // IOS 6+
    NSLog(@"UDID:: %@", uniqueIdentifier);
    
    return [NSArray arrayWithObjects:
            uniqueIdentifier,
            nil];
}

#pragma mark VpadAdDelegate method. Add this when use banner Ads
- (void)onVpadnAdReceived:(UIView *)bannerView{
    NSLog(@"VpadnAdReceived");
}

- (void)onVpadnAdFailed:(UIView *)bannerView didFailToReceiveAdWithError:(NSError *)error{
    NSLog(@"VpadnAdFailed");
}


- (void)loadView {
    
    [super loadView];
    
    [SHARED_MANAGER setFFT:YES];
    
    self.view = [BackgroundView new];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateVersion:)
                                                 name:@"UpdateVersionNotification"
                                               object:nil];
    
}


#pragma mark - Notification
- (void) updateVersion:(NSNotification *) notification {
    
    NSString* currentVersion = [SHARED_VERSION_MANAGER getVersion];
    
    if (![version_lite isEqualToString:currentVersion]) {
        [bannerView removeFromSuperview];
    }
    
}


// Delegate method to know when the ad finished loading
- (void)didLoadAd:(STAAbstractAd *)ad {
    //NSLog(@"didLoadAd");
}

- (void)failedLoadAd:(STAAbstractAd *)ad withError:(NSError *)error {
    // Failed loading the ad, do something else.
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
    
    // Use this to allow upside down as well
    //return (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
}


- (UIInterfaceOrientationMask) supportedInterfaceOrientations {
    // Return a bitmask of supported orientations. If you need more,
    // use bitwise or (see the commented return).
    return UIInterfaceOrientationMaskPortrait;
    // return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
}

- (UIInterfaceOrientation) preferredInterfaceOrientationForPresentation {
    // Return the orientation you'd prefer - this is what it launches to. The
    // user can still rotate. You don't have to implement this method, in which
    // case it launches in the current orientation
    return UIInterfaceOrientationPortrait;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// sets the font color of the top bar to white
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
