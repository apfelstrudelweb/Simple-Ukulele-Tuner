//
//  Banjo_Constants.h
//  Simple Ukulele Tuner
//
//  Created by Ulrich Vormbrock on 27.06.16.
//  Copyright © 2016 Ulrich Vormbrock. All rights reserved.
//

#ifndef Banjo_Constants_h
#define Banjo_Constants_h

#define APPSTORE_ID @"1095159631"
#define STANDARD_SUBTYPE             @[@1] // Open G (G4 - D3 - G3 - B3 - D4)

#define KEY_BANJO_TYPE             @"banjoType"
// 4 string
#define BANJO_TYPE_01              @"Chicago (D3 - G3 - B3 - E4)"
// 5 string
#define BANJO_TYPE_02              @"Open G (G4 - D3 - G3 - B3 - D4)"
// 6 string
#define BANJO_TYPE_03              @"Open G (G4 - G2 - D3 - G3 - B3 - D4)"

// Version
#define version_lite            @"lite"
#define version_instrument      @"instrument"
#define version_signal          @"signal"
#define version_premium         @"premium"

#define banjo_inAppPurchaseUke        @"ch.vormbrock.simplebanjotuner.allbanjo"
#define banjo_inAppPurchaseSignal     @"ch.vormbrock.simplebanjotuner.signalplus"
#define banjo_inAppPurchasePremium    @"ch.vormbrock.simplebanjotuner.premium"
#define BANJO_INAPP_PURCHASE_ARRAY    @[banjo_inAppPurchasePremium, banjo_inAppPurchaseBanjo, banjo_inAppPurchaseSignal]




#endif /* Uke_Constants_h */
