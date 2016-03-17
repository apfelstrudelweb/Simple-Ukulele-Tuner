//
//  PopupHandler.h
//  Diapaxon
//
//  Created by imac on 06.05.15.
//  Copyright (c) 2015 Vormbrock. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface PopupView : UIViewController <UIWebViewDelegate>
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) UIWebView *externalWebView;
@property (nonatomic, strong) UIToolbar *topToolbar;
@property (nonatomic, strong) UIToolbar *bottomToolbar;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *forwardBtn;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *backBtn;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *closeBtn;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *upgradeBtn;
@end
