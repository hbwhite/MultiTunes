//
//  ADFBannerView.h
//  Ad browser
//
//  Created by Mohsen Ramezanpoor on 14/02/2011.
//  Copyright 2011 Adfonic Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <MediaPlayer/MediaPlayer.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreLocation/CoreLocation.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>

/// Protocol for ADFBannerView's calls to its delegate.
/**
 */
@protocol ADFBannerViewDelegate;

typedef enum {
	ADFGenderUnknown = 0,
	ADFGenderFemale,
	ADFGenderMale,
} ADFGender;

typedef struct {
	NSUInteger low;
	NSUInteger high;
} ADFAgeRange;

/// A view for displaying Ad Banners
/** 
 ADFBannerView class can be used to display advertisement banners on iOS devices.
 
 @see Installation
 @see AddingBannerViews
 */
@interface ADFBannerView : UIView

#pragma mark Creating Ad Views
/// @name Creating Ad Views

/** Creates and returns a new banner with the specified slot identifier

 You may set type to `nil` if slot identifiers are loaded from configuration file.

 @param type The slot Type. Local name defined for a type of ad view in the configuration file.
 @return A newly created Ad View.
 */
+ (id)bannerViewWithType:(NSString *)type;


#pragma mark Delegate
/// @name Setting and Getting the banner's delegate

/** The delegate of the banner.
 */
@property (nonatomic, assign) NSObject<ADFBannerViewDelegate> * delegate;


#pragma mark Ad Slot Identifier
///@name Identifying the banner


/** The slot identifier of the banner.
 */
@property (nonatomic, readonly) NSString * slotIdentifier;

/** The type of the banner.
 
 @see bannerWithSlotIdentifier:
 */
@property (nonatomic, readonly) NSString * type;

/** Size identifier of the banner.
 
 size identifier for each slot identifier should be provided in the configuration file.
 
 Valid values are `ADFBannerContentSizeIdentifierPhonePortrait`, `ADFBannerContentSizeIdentifierMPU`,
 `ADFBannerContentSizeIdentifierLeaderboard`, `ADFBannerContentSizeIdentifierSkyscraper`, and
 `ADFBannerContentSizeIdentifierBanner`.
 */
@property (nonatomic, readonly) NSString *currentContentSizeIdentifier;

#pragma mark Banner status
///@name Banner Status

/** Indicates whether the banner has loaded any advertisment.

 This property will be set to `YES` when the banner has loaded an advertisment.
 */
@property (nonatomic, readonly, getter=isBannerViewLoaded) BOOL bannerViewLoaded;

/** Forces a refresh of the banner.
 
 Hints the banner that it can change the advertisment it's displaying at the moment.
 
 The banner might decide that it's not appropriate to refresh the advertisment.
 For example, minimum refresh time might not have passed.
 
 @see bannerViewAutorefreshTime
 @see minimumRefreshTime
 */
- (void)refresh;
/** The autorefresh time of the banner.
 
 Setting this to a value smaller than #minimumRefreshTime# causes the value to be reset to its default.
 A special case is when it's set to zero, in which case no autorefresh will happen.
 
 @see refreshBanner
 @see minimumRefreshTime
 */
@property (nonatomic) NSTimeInterval bannerViewAutorefreshTime;
/** The minimum time before the advertisment in a banner can be changed.

 @return The minimum time a banner has to be displayed before it can be changed.
 @see bannerViewAutorefreshTime
 */
+ (NSTimeInterval)minimumRefreshTime;

/** Indicates whether the ad is currently performing an action in response to user interaction.
 */
@property (nonatomic, readonly, getter=isBannerViewActionInProgress) BOOL bannerViewActionInProgress;


#pragma mark Hints
///@name Ad Loading Hints

/** Banner's context tags.
 
 This can be used as hints for the banner to try and load ads related to the context.
 
 If this is set to `nil`, it will try to load tags from the configuration file.
 Set this to an empty array if you want to override configuration file for empty values.
 */
@property (nonatomic, copy) NSArray * tags;
/** Banner's color scheme.
 
 The banner will try to load advertisments with a the specified color scheme.
 
 If this is set to `nil`, it will try to load color schemes from the configuration file.
 Set this to an empty string if you want to override configuration file for empty values.
 
 Valid values are `ADFColorSchemeBlue`, `ADFColorSchemeGreen`, `ADFColorSchemeOrange`,
  `ADFColorSchemePurple`, `ADFColorSchemeRed`, and `ADFColorSchemeYellow`.
 */
@property (nonatomic, copy) NSString * colorScheme;
/** User's gender. */
@property (nonatomic) ADFGender gender;
/** User's date of birth. */
@property (nonatomic, copy) NSDate * dateOfBirth;
/** User's age, in years. */
@property (nonatomic) NSUInteger age;
/** User's age range.
 
 If range is equal to `{0,0}`, the receiver will try to load age range from the configuration file.
 Set the ageRange's location to `NSNotFound` if you want to override configuration file for empty values.
 */
@property (nonatomic) ADFAgeRange ageRange;
/** Indicates whether user's location information can be used if available.

 If set to `YES`, will use the device's location to load ads local to the user.
 Setting this to `YES` will never cause a request dialoge to be shown to the user.
 It will use location only if the user has already granted permission to the App to use location.
 */
@property (nonatomic, getter=isLocationLookupEnabled) BOOL locationLookupEnabled;


@end

/// Protocol for ADFBannerView's calls to its delegate.
@protocol ADFBannerViewDelegate <NSObject>
@optional

#pragma mark Ad loading notifications
///@name Loading Notifications

/** Called when a new ad is loaded.
 
 This will be called everytime the banner's ad is refreshed.

 @param banner The banner that loaded a new ad.
 */
- (void)bannerViewDidLoadAd:(ADFBannerView *)banner;

/** Called when a banner view fails to load an ad.

 @param banner The banner that failed to load an ad.
 @param error The error describing the reason for failure.
 */
- (void)bannerView:(ADFBannerView *)banner didFailToReceiveAdWithError:(NSError *)error;


#pragma mark Ad action notifications
///@name Action Notifications

/** Called before the banner performs an action.

 @param banner The banner that will perform an action.
 @param willLeave Indicates whether the action will cause another application to be launched.
 */
- (void)bannerViewActionWillBegin:(ADFBannerView *)banner willLeaveApplication:(BOOL)willLeave;

/** Called when the banner is finished performing an action.

 @param banner The banner that finished performing an action.
 */
- (void)bannerViewActionDidFinish:(ADFBannerView *)banner;

@end

extern NSString * const ADFErrorDomain;

// size identifiers
extern NSString * const ADFBannerContentSizeIdentifierPhonePortrait;
extern NSString * const ADFBannerContentSizeIdentifierMPU;
extern NSString * const ADFBannerContentSizeIdentifierLeaderboard;
extern NSString * const ADFBannerContentSizeIdentifierSkyscraper;
extern NSString * const ADFBannerContentSizeIdentifierBanner;

// color schemes
extern NSString * const ADFColorSchemeBlue;
extern NSString * const ADFColorSchemeGreen;
extern NSString * const ADFColorSchemeOrange;
extern NSString * const ADFColorSchemePurple;
extern NSString * const ADFColorSchemeRed;
extern NSString * const ADFColorSchemeYellow;


