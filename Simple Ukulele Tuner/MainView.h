//
//  MainView.h
//  Diapason
//
//  Created by imac on 13.03.15.
//  Copyright (c) 2015 Vormbrock. All rights reserved.
//




//#import "LedView.h"
//#import "InfoView.h"
//#import "CommandView.h"
//#import "SoundButtonsView.h"

@interface MainView : UIView

@property (strong, nonatomic) UIView *headerBackgroundView;
@property (strong, nonatomic) HeaderView *headerView;
@property (strong, nonatomic) GraphView *graphView;
@property (strong, nonatomic) TabView *tabView;
@property (strong, nonatomic) BridgeView *bridgeView;
@property (strong, nonatomic) UkeTypeView *ukeTypeView;
@property (strong, nonatomic) MeterView *meterView;
@property (strong, nonatomic) DeviationView *deviationView;
@property (strong, nonatomic) GaugeView *gaugeView;
@property (strong, nonatomic) ButtonView *buttonView;

@end
