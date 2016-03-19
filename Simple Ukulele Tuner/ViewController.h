//
//  ViewController.h
//  Simple Ukulele Tuner
//
//  Created by Ulrich Vormbrock on 16.03.16.
//  Copyright © 2016 Ulrich Vormbrock. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StartApp/StartApp.h>

@interface ViewController : UIViewController <STADelegateProtocol> {
    
    /* Declaration of STAStartAppNativeAd which will load and store all the ads we intend to display */
    STAStartAppNativeAd *startAppNativeAd;
}
@end

