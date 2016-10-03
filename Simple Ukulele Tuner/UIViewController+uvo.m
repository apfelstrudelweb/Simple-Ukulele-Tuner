//
//  UIViewController+uvo.m
//  Simple Ukulele Tuner
//
//  Created by Ulrich Vormbrock on 03.10.16.
//  Copyright © 2016 Ulrich Vormbrock. All rights reserved.
//

#import "UIViewController+uvo.h"

@implementation UIViewController (uvo)

+ (UIViewController *)currentTopViewController {
    
    UIViewController *topVC = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    while (topVC.presentedViewController)
    {
        topVC = topVC.presentedViewController;
    }
    return topVC;
}

@end
