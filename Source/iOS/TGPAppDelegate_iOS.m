#import "TGPAppDelegate.h"
#import "TGPRequest.h"

static NSString *const TGPAppStoreURL = @"itms-apps://itunes.apple.com/app/id686449807";

static NSString *const TGPIncorrectSetupException = @"IncorrectSetupException";

@interface TGPAppDelegate ()

@property (nonatomic, strong) id<TGPOpenURLResponseHandler> pendingResponseHandler;

@end

@implementation TGPAppDelegate

- (instancetype)init {
    return nil;
}

- (instancetype)_init {
    return [super init];
}

- (void)openURL:(NSURL *)url responseHandler:(id<TGPOpenURLResponseHandler>)responseHandler completionHandler:(void (^)(BOOL))completionHandler {
    self.pendingResponseHandler = responseHandler;
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
    UIApplication *application = [UIApplication sharedApplication];
    if ([application respondsToSelector:@selector(openURL:options:completionHandler:)]) {
        [application openURL:url options:@{} completionHandler:completionHandler];
    } else {
        [application openURL:url];
    }
#pragma clang diagnostic pop
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
    if (![TGPAppDelegate isTelegramAppBundleIdentifier:options[UIApplicationOpenURLOptionsSourceApplicationKey]]) {
        return NO;
    }
#pragma clang diagnostic pop
    if (self.pendingResponseHandler != nil) {
        BOOL handled = [self.pendingResponseHandler handleResponse:url];
        if (handled) {
            self.pendingResponseHandler = nil;
        }
    }
    return NO;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    if (![TGPAppDelegate isTelegramAppBundleIdentifier:sourceApplication]) {
        return NO;
    }
    if (self.pendingResponseHandler != nil) {
        BOOL handled = [self.pendingResponseHandler handleResponse:url];
        if (handled) {
            self.pendingResponseHandler = nil;
        }
    }
    return NO;
}

+ (void)validateSetupWithRequiredURLScheme:(NSString *)requiredURLScheme {
    if (![TGPAppDelegate isRegisteredURLScheme:requiredURLScheme]) {
        NSString *reason = [NSString stringWithFormat:@"%@ must be registered as a URL scheme in your application's Info.plist", requiredURLScheme];
        @throw [NSException exceptionWithName:TGPIncorrectSetupException reason:reason userInfo:nil];
    }
    [TGPAppDelegate isTelegramAppInstalled];
}

+ (void)openTelegramAppStorePage {
    NSURL *appStoreURL = [NSURL URLWithString:TGPAppStoreURL];
    [[TGPAppDelegate sharedDelegate] openURL:appStoreURL responseHandler:nil completionHandler:nil];
}

+ (BOOL)isTelegramAppInstalled {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (![TGPAppDelegate isRegisteredQueriesScheme:TGPURLScheme]) {
            NSString *reason = [NSString stringWithFormat:@"As of iOS 9.0 %@ must be added in LSApplicationQueriesSchemes of your application's Info.plist", TGPURLScheme];
            @throw [NSException exceptionWithName:TGPIncorrectSetupException reason:reason userInfo:nil];
        }
    });
    NSURL *telegramAppURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@://", TGPURLScheme]];
    return [[UIApplication sharedApplication] canOpenURL:telegramAppURL];
}

+ (bool)isTelegramAppBundleIdentifier:(NSString *)bundleIdentifer {
    static NSArray *bundleIdentifiers;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        bundleIdentifiers = @[
            @"ph.telegra.Telegraph",
            @"org.telegram.TelegramEnterprise",
            @"org.telegram.Telegram-iOS",
        ];
    });
    return [bundleIdentifiers containsObject:bundleIdentifer];
}

+ (BOOL)isRegisteredURLScheme:(NSString *)urlScheme {
    static NSArray *bundleURLTypes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        bundleURLTypes = [[NSBundle mainBundle] infoDictionary][@"CFBundleURLTypes"];
    });
    for (NSDictionary *urlType in bundleURLTypes) {
        if ([urlType[@"CFBundleURLSchemes"] containsObject:urlScheme]) {
            return YES;
        }
    }
    return NO;
}

+ (BOOL)isRegisteredQueriesScheme:(NSString *)urlScheme {
    static NSArray *appQueriesSchemes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        appQueriesSchemes = [[NSBundle mainBundle] infoDictionary][@"LSApplicationQueriesSchemes"];
    });
    return [appQueriesSchemes containsObject:urlScheme];
}

+ (instancetype)sharedDelegate {
    static TGPAppDelegate *sharedDelegate;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedDelegate = [[self alloc] _init];
    });
    return sharedDelegate;
}

@end
