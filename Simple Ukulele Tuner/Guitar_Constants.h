//
//  Guitar_Constants.h
//  Simple Ukulele Tuner
//
//  Created by Ulrich Vormbrock on 27.06.16.
//  Copyright © 2016 Ulrich Vormbrock. All rights reserved.
//

#ifndef Guitar_Constants_h
#define Guitar_Constants_h


#define APPSTORE_ID @"1128226635"
#define STANDARD_SUBTYPE             @[@0, @5] // Acoustic Standard (E - A - D - G - B - E) and Bass Standard (E - A - D -G)


#define KEY_GUITAR_TYPE          @"guitarType"
#define GUITAR_TYPE_01           @"6 - Classical / Acoustic (E - A - D - G - B - E)"
// 5 String Bass
#define GUITAR_TYPE_02           @"5 - Bass Standard (B - E - A - D - G)"
#define GUITAR_TYPE_03           @"5 - Bass High C (E - A - D - G - C)"
#define GUITAR_TYPE_04           @"5 - Bass Half Step Down (A# - D# - G# - F - F#)"
#define GUITAR_TYPE_05           @"5 - Bass Full Step Down (A - D - G - C - F)"
// 4 String Bass
#define GUITAR_TYPE_06           @"4 - Bass Standard (E - A - D - G)"
#define GUITAR_TYPE_07           @"4 - Bass Drop D (D - A - D - G)"
#define GUITAR_TYPE_08           @"4 - Bass Half Step Down (D# - G# - C# - A#)"
#define GUITAR_TYPE_09           @"4 - Bass Full Step Down (D - G - C - A)"
#define GUITAR_TYPE_10           @"4 - Bass Low B (B - E - A - D)"
#define GUITAR_TYPE_11           @"4 - Bass Drop C (C - A - D - G)"



#define guitar_inAppPurchaseGuitar     @"ch.vormbrock.simpleguitartuner.allguitar"
#define guitar_inAppPurchaseSignal     @"ch.vormbrock.simpleguitartuner.signalplus"
#define guitar_inAppPurchasePremium    @"ch.vormbrock.simpleguitartuner.premium"
#define GUITAR_INAPP_PURCHASE_ARRAY    @[guitar_inAppPurchasePremium, guitar_inAppPurchaseGuitar, guitar_inAppPurchaseSignal]

#endif /* Guitar_Constants_h */
