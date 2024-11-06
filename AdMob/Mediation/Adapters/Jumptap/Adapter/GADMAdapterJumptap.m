/*

 GADMAdapterJumptap.m

 Copyright 2011 Google, Inc.


*/

#import "GADMAdapterJumptap.h"

@implementation GADMAdapterJumptap

@synthesize adView;

+ (void)initialize {
  [super initialize];

  // Do not query for location.
  [JTAdWidget initializeAdService:NO];
}

+ (NSString *)adapterVersion {

  // CHANGE THIS: Change to return a string representing a version. Make sure to
  // update this every time you distribute a new adapter.

  NSString *dateString =
      [NSString stringWithCString:__DATE__ encoding:NSASCIIStringEncoding];
  return [dateString stringByReplacingOccurrencesOfString:@" "
                                               withString:@""];
}

+ (Class<GADAdNetworkExtras>)networkExtrasClass {

  // OPTIONAL: Create your own class implementating GADAdNetworkExtras and
  // return that class type here for your publishers to use.

  return nil;
}

- (id)initWithGADMAdNetworkConnector:(id<GADMAdNetworkConnector>)c {
  self = [super init];
  if (self != nil) {
    connector = c;
  }
  return self;
}

- (void)getInterstitial {

  // CHANGE THIS: call your own interstitial

  [connector adapter:self didFailInterstitial:nil];
}

- (void)getBannerWithSize:(GADAdSize)adSize {
  // Check for a standard ad size.
  if (!GADAdSizeEqualToSize(adSize, kGADAdSizeBanner) &&
      !GADAdSizeEqualToSize(adSize, kGADAdSizeMediumRectangle) &&
      !GADAdSizeEqualToSize(adSize, kGADAdSizeFullBanner) &&
      !GADAdSizeEqualToSize(adSize, kGADAdSizeLeaderboard) &&
      !GADAdSizeEqualToSize(adSize, kGADAdSizeSkyscraper)) {
    NSString *errorDesc = [NSString stringWithFormat:
                           @"Invalid ad type %@, not going to get ad.",
                           NSStringFromGADAdSize(adSize)];
    NSDictionary *errorInfo =
        [NSDictionary dictionaryWithObjectsAndKeys:errorDesc,
         NSLocalizedDescriptionKey, nil];
    NSError *error = [NSError errorWithDomain:@"ad_mediation"
                                         code:1
                                     userInfo:errorInfo];
    [connector adapter:self didFailAd:error];
    return;
  }

  JTAdWidget *widget = [[JTAdWidget alloc] initWithDelegate:self
                                         shouldStartLoading:YES];

  // CHANGE THIS: create an initiate ad fetch of the appropriate size
  CGSize size = CGSizeFromGADAdSize(adSize);
  widget.frame = CGRectMake(0, 0, size.width, size.height);
  widget.refreshInterval = 0;   // do not self-refresh
  self.adView = widget;
  [widget release];
}

- (void)stopBeingDelegate {
  // no way to remove delegate from widget
}

- (BOOL)isBannerAnimationOK:(GADMBannerAnimationType)animType {
  return YES;
}

- (void)presentInterstitialFromRootViewController:
    (UIViewController *)rootViewController {

  // CHANGE THIS: If your SDK supports interstitials, present the interstitial
  // here.

  NSLog(@"%s called. Present your interstitial here.", __PRETTY_FUNCTION__);
}

- (void)dealloc {
  [adView release], adView = nil;
  [self stopBeingDelegate];
  [super dealloc];
}

#pragma mark JTAdWidgetDelegate methods

- (NSString *)publisherId:(id)theWidget {
  return [connector publisherId];
}

- (NSString *)site:(id)theWidget {
  return [[connector credentials] objectForKey:@"siteId"];
}

- (NSString *)adSpot:(id)theWidget {
  return [[connector credentials] objectForKey:@"adSpotId"];
}

- (BOOL)shouldRenderAd:(id)theWidget {
  [connector adapter:self didReceiveAdView:(JTAdWidget *)theWidget];
  return YES;
}

- (void)beginAdInteraction:(id)theWidget {
  [connector adapter:self clickDidOccurInBanner:adView];
  [connector adapterWillPresentFullScreenModal:self];
}

- (void)endAdInteraction:(id)theWidget {
  [connector adapterDidDismissFullScreenModal:self];
}

- (void)beginDisplayingInterstitial:(id)theWidget {
  [connector adapterWillPresentInterstitial:self];
}

- (void)endDisplayingInterstitial:(id)theWidget {
  [connector adapterDidDismissInterstitial:self];
}

- (void)adWidget:(id)widget orientationHasChangedTo:(UIInterfaceOrientation)o {
  // do we need this?
}

- (void)adWidget:(id)theWidget didFailToShowAd:(NSError *)error {
  [connector adapter:self didFailAd:error];
}

- (void)adWidget:(id)theWidget didFailToRequestAd:(NSError *)error {
  [connector adapter:self didFailAd:error];
}

- (UIViewController*)adViewController:(id)theWidget {
  return [connector viewControllerForPresentingModalView];
}

@end
