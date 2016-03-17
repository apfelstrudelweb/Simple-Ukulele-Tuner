//
//  ViewController.m
//  Simple Ukulele Tuner
//
//  Created by Ulrich Vormbrock on 16.03.16.
//  Copyright © 2016 Ulrich Vormbrock. All rights reserved.
//

#import "ViewController.h"
#import <iAd/iAd.h>

@interface ViewController () {
    BOOL isBannerVisible;
    ADBannerView *_adBanner;
    NSInteger bannerWidth;
    NSInteger bannerHeight;
    CGFloat bannerOffset;
    
    BOOL isBannerAdRemoved;
}

@property (nonatomic, strong) UIWebView *webView;

@end

@implementation ViewController

- (void)loadView {
    
    [super loadView];
    [self checkVersion];
    
    [SHARED_MANAGER setFFT:YES];
    
    self.view = [BackgroundView new];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadBanner:)
                                                 name:@"ApplicationDidFinishLoading"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateVersion:)
                                                 name:@"UpdateVersionNotification"
                                               object:nil];
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)checkVersion {
    NSString* currentVersion = [SHARED_VERSION_MANAGER getVersion];
    
    if ([version_signal isEqualToString:currentVersion] || [version_uke isEqualToString:currentVersion] || [version_premium isEqualToString:currentVersion]) {
        isBannerAdRemoved = YES;
    }
}

#pragma mark - Notification
- (void) updateVersion:(NSNotification *) notification {
    
    [self checkVersion];
    
    if (isBannerAdRemoved==YES) {
        _adBanner.delegate = nil;
        [_adBanner removeFromSuperview];
        _adBanner = nil;
        
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}

- (void)loadBanner:(NSNotification *) notification {
    
    if (isBannerAdRemoved==NO) {
        CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
        CGFloat headerHeight = [SUBVIEW_PROPORTIONS[0] floatValue] + 0.05;
        
        bannerOffset = screenHeight * headerHeight / 100.0;
        
        _adBanner = [[ADBannerView alloc] initWithFrame:CGRectMake(0, bannerOffset, bannerWidth, bannerHeight)];
        _adBanner.delegate = self;
    }
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner {
    
    if (isBannerVisible==NO) {
        // If banner isn't part of view hierarchy, add it
        if (_adBanner.superview == nil) {
            [self.view addSubview:_adBanner];
        }
        
        [UIView beginAnimations:@"animateAdBannerOn" context:NULL];
        
        // Assumes the banner view is just at the top of the screen.
        banner.frame = CGRectOffset(banner.frame, 0, 0);
        
        [UIView commitAnimations];
        
        isBannerVisible = YES;
    }
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error {
    NSLog(@"Failed to retrieve ad");
}

- (void)bannerViewWillLoadAd:(ADBannerView *)banner {
    NSLog(@"bannerViewWillLoadAd");
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

@end