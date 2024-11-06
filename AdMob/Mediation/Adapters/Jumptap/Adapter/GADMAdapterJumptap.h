/*

 GADMAdapterJumptap.h

 Copyright 2011 Google, Inc.

*/

#import "GADMAdNetworkAdapterProtocol.h"
#import "GADMAdNetworkConnectorProtocol.h"
#import "JTAdWidget.h"

@interface GADMAdapterJumptap : NSObject <GADMAdNetworkAdapter,
    JTAdWidgetDelegate> {
  id<GADMAdNetworkConnector> connector;
  JTAdWidget *adView;
}

@property (nonatomic, retain) JTAdWidget *adView;

@end
