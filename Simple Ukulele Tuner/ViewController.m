//
//  ViewController.m
//  Simple Ukulele Tuner
//
//  Created by Ulrich Vormbrock on 16.03.16.
//  Copyright © 2016 Ulrich Vormbrock. All rights reserved.
//

#import "ViewController.h"


@interface ViewController () {
    STABannerView* bannerView;
}

@property (nonatomic, strong) UIWebView *webView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    startAppNativeAd = [[STAStartAppNativeAd alloc] init];
    [startAppNativeAd loadAd];
    
    
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSString* currentVersion = [SHARED_VERSION_MANAGER getVersion];
    
    if ([version_lite isEqualToString:currentVersion]) {
        CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
        CGFloat headerHeight = [SUBVIEW_PROPORTIONS[0] floatValue] + 0.05;
        CGFloat bannerOffset = screenHeight * headerHeight / 100.0;
        
        if (bannerView == nil) {
            
            bannerView = [[STABannerView alloc] initWithSize:STA_AutoAdSize
                                                      origin:CGPointMake(0, bannerOffset)
                                                    withView:self.view
                                                withDelegate:nil];
            [self.view addSubview:bannerView];
        }
    }
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
