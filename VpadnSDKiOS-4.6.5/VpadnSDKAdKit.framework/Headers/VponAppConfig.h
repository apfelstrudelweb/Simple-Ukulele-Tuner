//
//  VponAppConfig.h
//  iphone-vpon-sdk
//
//  Created by vpon on 12/11/6.
//  Copyright (c) 2012年 com.vpon. All rights reserved.
//

#pragma mark SDK 基本通用設定.

//#pragma mark SDK版號
//static NSString* _version = @"4.2.0";

#import <Foundation/Foundation.h>

typedef enum {
    VpadnLogLevelOfDebug = 0,
    VpadnLogLevelOfDefault,
    VpadnLogLevelOfWarning,
    VpadnLogLevelOfOnlyError,
} VpadnLogLevel;

@interface VponAppConfig : NSObject

+ (void) setVponLogLevel:(VpadnLogLevel)vpadnLogLevel;


@end
