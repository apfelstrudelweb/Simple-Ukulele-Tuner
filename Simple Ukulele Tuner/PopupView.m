//
//  PopupHandler.m
//  Diapaxon
//
//  Created by imac on 06.05.15.
//  Copyright (c) 2015 Vormbrock. All rights reserved.
//

#import "PopupView.h"

#define MANUAL_BG_COLOR [UIColor colorWithRed:0.271 green:0.282 blue:0.318 alpha:1] /*#454851*/


@interface PopupView() {
    NSMutableArray* htmlPages;
    NSInteger activePage;
    
    CGFloat toolbarHeight;
    CGFloat bottomToolbarY;
    CGFloat screenWidth;
    
    UIBarButtonItem *flexibleSpace;
    CGRect mainFrame;
    
    UIView* loadingView;
 
}

@end

@implementation PopupView


- (void)viewDidLoad {
    [super viewDidLoad];

    toolbarHeight = IS_IPAD ? 120 : 60;
    
    // make distinction between locals
    
    htmlPages = [NSMutableArray new];
    NSMutableArray* _htmlPages = HTML_PAGES;
    
    NSString *language = [[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0];
    NSString *prefix = [language isEqualToString:@"de"] ? @"de" : @"en";
    
    for (NSString *page in _htmlPages) {
        NSString *locPage = [NSString stringWithFormat:@"%@_%@", prefix, page];
        [htmlPages addObject:locPage];
    }
    
    activePage = 0; // start page
    
    mainFrame = [[UIScreen mainScreen] bounds];
    NSInteger fact = 1;
    CGFloat w = mainFrame.size.width;
    CGFloat h = mainFrame.size.height - fact*toolbarHeight;
    CGFloat x = mainFrame.origin.x;
    CGFloat y = mainFrame.origin.y + toolbarHeight;
    
    CGRect webFrame = CGRectMake(x, y, w, h);
    
    bottomToolbarY = mainFrame.size.height - toolbarHeight;
    screenWidth = w;
    
    self.view.backgroundColor = MANUAL_BG_COLOR;
    
    flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    
    [self loadHTML:webFrame];
    
    [self createTopBarButtons];
    [self createTopToolbar];

}

-(void) createTopToolbar {
    self.topToolbar = [[UIToolbar alloc] init];
    
    self.topToolbar.frame = CGRectMake(0, 0, self.view.frame.size.width, toolbarHeight);

    self.topToolbar.translucent = NO;
    self.topToolbar.barTintColor = HEADER_BACKGROUND_COLOR_01;
    
    [self.topToolbar setItems:[[NSArray alloc] initWithObjects:self.backBtn,flexibleSpace,self.closeBtn,flexibleSpace,self.forwardBtn, nil]];
    
    
    [self.view addSubview:self.topToolbar];
}

-(void) createTopBarButtons {
    
    UIImage *imageBackBtn = [[UIImage imageNamed:@"arrowLeft.png"] imageWithRenderingMode:UIImageRenderingModeAutomatic];
    UIImage *imageCloseBtn = [[UIImage imageNamed:@"close.png"] imageWithRenderingMode:UIImageRenderingModeAutomatic];
    UIImage *imageStopBtn = [[UIImage imageNamed:@"arrowRight.png"] imageWithRenderingMode:UIImageRenderingModeAutomatic];
    
    if (!IS_IPAD) {
        imageBackBtn =  [self resizeImage:imageBackBtn toScale:0.5];
        imageCloseBtn = [self resizeImage:imageCloseBtn toScale:0.5];
        imageStopBtn =  [self resizeImage:imageStopBtn toScale:0.5];
    }
    
    UIEdgeInsets imageInsets = IS_IPAD ? UIEdgeInsetsMake(50, 0, 20, 0) : UIEdgeInsetsMake(30, 0, 10, 0);
    
    
    self.backBtn = [[UIBarButtonItem alloc] initWithImage:imageBackBtn style:UIBarButtonItemStylePlain target:self action:@selector(actionBack:)];
    self.backBtn.enabled = NO;
    self.backBtn.imageInsets = imageInsets;
    self.backBtn.tintColor = [UIColor whiteColor];
    
    
    self.closeBtn = [[UIBarButtonItem alloc] initWithImage:imageCloseBtn style:UIBarButtonItemStylePlain target:self action:@selector(actionClose:)];
    self.closeBtn.imageInsets = imageInsets;
    self.closeBtn.tintColor = [UIColor whiteColor];
    
    self.forwardBtn = [[UIBarButtonItem alloc] initWithImage:imageStopBtn style:UIBarButtonItemStylePlain target:self action:@selector(actionForward:)];
    self.forwardBtn.imageInsets = imageInsets;
    self.forwardBtn.tintColor = [UIColor whiteColor];
    
}



-(void) loadHTML:(CGRect) frame {
    
    self.webView = [[UIWebView alloc] initWithFrame:frame];
    
    self.webView.delegate = self;
    self.webView.scrollView.scrollEnabled = YES;
    //self.webView.scalesPageToFit=YES;

    [self loadResources];
    [self.view addSubview:self.webView];
}




#pragma mark -button events
- (void)actionClose:(UIBarButtonItem*)button {
    
    [self removeView];
}

- (void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    [self.webView loadHTMLString:@"" baseURL:nil];
    [self.webView stopLoading];
    self.webView.delegate = nil;
    [self.webView removeFromSuperview];
    self.webView = nil;
}

- (void) removeView {
    [self.view removeFromSuperview];

    [[NSNotificationCenter defaultCenter] postNotificationName:@"PopupRemovalNotification" object:nil];
}

- (void)actionBack:(UIBarButtonItem*)button {
    
    if (activePage > 0) {
        activePage--;
        self.forwardBtn.enabled = YES;
        if (activePage==0) {
            self.backBtn.enabled = NO;
        }
    } else {
        return;
    }
    
    [self loadResources];
    
}

- (void)actionForward:(UIBarButtonItem*)button {
    
    if (activePage < htmlPages.count-1) {
        activePage++;
        self.backBtn.enabled = YES;
        if (activePage==htmlPages.count-1) {
            self.forwardBtn.enabled = NO;
        }
    } else {
        return;
    }
    
    [self loadResources];
    
}


- (void)webViewDidStartLoad:(UIWebView *)webView {
    [loadingView setHidden:NO];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [loadingView setHidden:YES];
}

-(void) loadResources {
    
    NSString* htmlString = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:htmlPages[activePage] ofType:@"html"] encoding:NSUTF8StringEncoding error:nil];
    self.webView.backgroundColor = MANUAL_BG_COLOR;
    [self.webView loadHTMLString:htmlString baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]]];
}

#pragma mark -image processing
- (UIImage *)resizeImage:(UIImage *)image toScale: (CGFloat) scale {
    
    CGSize oldSize = image.size;
    CGFloat w = oldSize.width;
    CGFloat h = oldSize.height;
    
    CGSize newSize = CGSizeMake(scale*w, scale*h);
    
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}



@end
