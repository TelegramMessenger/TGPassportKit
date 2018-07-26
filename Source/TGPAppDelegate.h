#if TARGET_OS_IOS
#import <UIKit/UIKit.h>
#elif TARGET_OS_MAC
#import <Cocoa/Cocoa.h>
#endif

NS_ASSUME_NONNULL_BEGIN

/**
 Description
 */
@protocol TGPOpenURLResponseHandler <NSObject>

/**
 Tries to handle the incoming openURL request

 @param responseURL the URL used for opening the application
 @return YES if the URL was meant for the handler, otherwise NO
 */
- (BOOL)handleResponse:(NSURL *)responseURL;

@end

/**
 Responsible for receiving result callbacks for Telegram Passport requests.
 */
@interface TGPAppDelegate : NSObject

#if TARGET_OS_IOS
/**
 Should be called from the [UIApplicationDelegate application:openURL:sourceApplication:annotation:] method
 of your UIApplicationDelegate implementation.

 @param application the application as passed from your UIApplicationDelegate
 @param url the URL as passed from your UIApplicationDelegate
 @param sourceApplication the source application as passed from your UIApplicationDelegate
 @param annotation the annotation as passed from your UIApplicationDelegate
 @return YES if the URL was meant for TGPassportKit, otherwise NO
 */
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(nullable NSString *)sourceApplication annotation:(nonnull id)annotation;


/**
 Should be called from the [UIApplicationDelegate application:openURL:options:] method of your
 UIApplicationDelegate implementation.

 @param application the application as passed from your UIApplicationDelegate
 @param url the URL as passed from your UIApplicationDelegate
 @param options the options as passed from your UIApplicationDelegate
 @return YES if the URL was meant for TGPassportKit, otherwise NO
 */
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options;

#elif TARGET_OS_MAC


/**
 Should be called from the [NSApplicationDelegate applicationDidFinishLaunching:] method of your
 NSApplicationDelegate implementation.
 
 @param notification the notifcation as passed from your NSApplicationDelegate
 */
- (void)applicationDidFinishLaunching:(NSNotification *)notification;

#endif

- (void)openURL:(NSURL *)url responseHandler:(nullable id<TGPOpenURLResponseHandler>)responseHandler completionHandler:(void (^ _Nullable)(BOOL))completionHandler;

+ (void)validateSetupWithRequiredURLScheme:(NSString *)requiredURLScheme;

/**
 Opens Telegram Messenger AppStore page
 */
+ (void)openTelegramAppStorePage;

/**
 Determines if Telegram Messenger application is installed
 
 @return YES if Telegram Messenger is installed, otherwise NO
 */
+ (BOOL)isTelegramAppInstalled;

/**
 Returns the singleton delegate instance
 */
+ (instancetype)sharedDelegate;

@end


NS_ASSUME_NONNULL_END
