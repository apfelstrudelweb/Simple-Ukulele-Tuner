//
//  Balalaika_Constants.h
//  Simple Ukulele Tuner
//
//  Created by Ulrich Vormbrock on 18.02.17.
//  Copyright © 2017 Ulrich Vormbrock. All rights reserved.
//

#ifndef Balalaika_Constants_h
#define Balalaika_Constants_h

#define APPSTORE_ID              @"1135724767"
#define STANDARD_SUBTYPE         @[@2] // Standard Prima (E - E - A)


#define KEY_BALALAIKA_TYPE          @"balalaikaType"
// 3 String Acoustic
#define BALALAIKA_TYPE_01           @"3 - Descant (E5 - E5 - A5)"
#define BALALAIKA_TYPE_02           @"3 - Piccolo (H4 - E5 - A5)"
#define BALALAIKA_TYPE_03           @"3 - Prima (E4 - E4 - A4)"    // Standard
#define BALALAIKA_TYPE_04           @"3 - Guitar Style (G3 - H3 - D4)"
#define BALALAIKA_TYPE_05           @"3 - Secunda (A3 - A3 - D4)"
#define BALALAIKA_TYPE_06           @"3 - Alto (E3 - E3 - A3)"
#define BALALAIKA_TYPE_07           @"3 - Tenor (E3 - A3 - E4)"
#define BALALAIKA_TYPE_08           @"3 - Bass (E2 - A2 - D3)"
#define BALALAIKA_TYPE_09           @"3 - Contrabass (E1 - A1 - D2)"


// Version
#define version_lite                @"lite"
#define version_instrument          @"instrument"
#define version_signal              @"signal"
#define version_premium             @"premium"


#define balalaika_inAppPurchaseBalalaika       @"ch.vormbrock.simplebalalaikatuner.allbalalaika"
#define balalaika_inAppPurchaseSignal          @"ch.vormbrock.simplebalalaikatuner.signalplus"
#define balalaika_inAppPurchasePremium         @"ch.vormbrock.simplebalalaikatuner.premium"
#define BALALAIKA_INAPP_PURCHASE_ARRAY         @[balalaika_inAppPurchasePremium, balalaika_inAppPurchaseBalalaika, balalaika_inAppPurchaseSignal]

#endif /* Balalaika_Constants_h */
