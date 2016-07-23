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
#define STANDARD_SUBTYPE             @[@5] // 5 - Standard (G4 - D3 - G3 - B3 - D4)

#define KEY_BANJO_TYPE             @"banjoType"
// 4 string
#define BANJO_TYPE_01              @"4 - Chicago (D3 - G3 - B3 - E4)"
#define BANJO_TYPE_02              @"4 - C (C3 - G3 - B3 - D4)"
#define BANJO_TYPE_03              @"4 - Irish Tenor (G2 - D3 - A3 - E4)"
#define BANJO_TYPE_04              @"4 - Open G (D3 - G3 - B3 - D4)"
#define BANJO_TYPE_05              @"4 - Tenor (C3 - G3 - D4 - A4)"
// 5 string
#define BANJO_TYPE_06              @"5 - Standard (G4 - D3 - G3 - B3 - D4)"
#define BANJO_TYPE_07              @"5 - C (G4 - C3 - G3 - B3 - D4)"
#define BANJO_TYPE_08              @"5 - Double C (G4 - C3 - G3 - C4 - D4)"
#define BANJO_TYPE_09              @"5 - Oldtime D (A4 - D3 - A3 - D4 - E4)"
#define BANJO_TYPE_10              @"5 - Open A (A4 - E3 - A3 - C#4 - E4)"
#define BANJO_TYPE_11              @"5 - Open D (F#4 - D3 - F#3 - A3 - D4)"
#define BANJO_TYPE_12              @"5 - Sawmill (G4 - D3 - G3 - C4 - D4)"
// 6 string
#define BANJO_TYPE_13              @"6 - Open G (G4 - G2 - D3 - G3 - B3 - D4)"
#define BANJO_TYPE_14              @"6 - Banjo Guitar (E2 - A2 - D3 - G3 - B3 - E4)"

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
