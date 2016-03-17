//
//  UILabel+uvo.h
//  Diapason
//
//  Created by imac on 13.03.15.
//  Copyright (c) 2015 Vormbrock. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (uvo)
+(CGFloat) getFontSizeForHeadline;
+(CGFloat) getFontSizeForSubHeadline;
+(CGFloat) getFontSizeForInfotext;
+(CGFloat) getFontSizeForButton;
+(CGFloat) getFontSizeForStrings;
+(CGFloat) getFontSizeForPicker;
+(CGFloat) getFontSizeForOctave;
+(CGFloat) getFontSizeForToneName;
+(CGFloat) getSmallFontSizeForToneName;
+(CGFloat) getFontSizeForTabButton;
@end
