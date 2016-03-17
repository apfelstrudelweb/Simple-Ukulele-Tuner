//
//  UILabel+uvo.m
//  Diapason
//
//  Created by imac on 13.03.15.
//  Copyright (c) 2015 Vormbrock. All rights reserved.
//

#import "UILabel+uvo.h"

@implementation UILabel (uvo)

+(CGFloat) getFontSizeForHeadline {
    CGFloat size = IS_IPAD ? 35 : 24;
    return size;
}

+(CGFloat) getFontSizeForSubHeadline {
    CGFloat size = IS_IPAD ? 28 : 15;
    return size;
}

+(CGFloat) getFontSizeForInfotext {
    CGFloat size = IS_IPAD ? 25 : 15;
    return size;
}

+(CGFloat) getFontSizeForButton {
    CGFloat size = IS_IPAD ? 50 : 30;
    return size;
}

+(CGFloat) getFontSizeForStrings {
    CGFloat size = IS_IPAD ? 30 : 18;
    return size;
}

+(CGFloat) getFontSizeForPicker {
    CGFloat size = IS_IPAD ? 24 : 12;
    return size;
}

+(CGFloat) getFontSizeForOctave {
    CGFloat size = IS_IPAD ? 40 : 26;
    return size;
}

+(CGFloat) getSmallFontSizeForToneName {
    CGFloat size = IS_IPAD ? 20 : 10;
    return size;
}


+(CGFloat) getFontSizeForToneName {
    CGFloat size = IS_IPAD ? 30 : 16;
    return size;
}

+(CGFloat) getFontSizeForTabButton {
    CGFloat size = IS_IPAD ? 26 : 14;
    return size;
}

@end
