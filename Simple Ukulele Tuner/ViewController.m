//
//  ViewController.m
//  Simple Ukulele Tuner
//
//  Created by Ulrich Vormbrock on 16.03.16.
//  Copyright © 2016 Ulrich Vormbrock. All rights reserved.
//

#import "ViewController.h"
@import GoogleMobileAds;


@interface ViewController ()<GADBannerViewDelegate> {
    
}

@property (nonatomic, strong) UIWebView *webView;
@property(nonatomic) GADBannerView *bannerView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSString* currentVersion = [SHARED_VERSION_MANAGER getVersion];

    //if (YES) {
    if ([version_lite isEqualToString:currentVersion]) {
        CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
#if defined(TARGET_VIOLIN)  ||  defined(TARGET_MANDOLIN)
        CGFloat headerHeight = 4.0;
#else
        CGFloat headerHeight = [SUBVIEW_PROPORTIONS[0] floatValue] + 0.05;
#endif
        CGFloat bannerOffset = screenHeight * headerHeight / 100.0;
        
     
        if (_bannerView == nil) {
            
            _bannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner origin:CGPointMake(0.0f, bannerOffset)];
            _bannerView.rootViewController = self;
            _bannerView.delegate = self;
            
            GADRequest *request = [GADRequest request];
#if defined(TARGET_UKULELE)
            _bannerView.adUnitID = @"ca-app-pub-1849205192643985/8684225641";
#elif defined(TARGET_GUITAR)
            _bannerView.adUnitID = @"ca-app-pub-1849205192643985/4161514944";
#elif defined(TARGET_MANDOLIN)
            _bannerView.adUnitID = @"ca-app-pub-1849205192643985/6462107166";
#elif defined(TARGET_BANJO)
            _bannerView.adUnitID = @"ca-app-pub-1849205192643985/5176403083";
#elif defined(TARGET_VIOLIN)
            _bannerView.adUnitID = @"ca-app-pub-1849205192643985/1602654424";
#elif defined(TARGET_BALALAIKA)
            _bannerView.adUnitID = @"ca-app-pub-1849205192643985/7512235465";
#endif
            request.testDevices = @[@"374cad9f371b2fbc6d624bd254eda28b"];  // Rookie's iPhone
            [_bannerView loadRequest:request];
            [self.view addSubview:_bannerView];
        }
    }
}

- (void)adViewDidReceiveAd:(GADBannerView *)bannerView {
    NSLog(@"did successfully receive AD");
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
        [_bannerView removeFromSuperview];
    }
    
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
