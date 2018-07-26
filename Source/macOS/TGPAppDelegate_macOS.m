#import "TGPAppDelegate.h"
#import "TGPRequest.h"

#include <ApplicationServices/ApplicationServices.h>

static NSString *const TGPAppStoreURL = @"https://telegram.org";

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
    
    [[NSWorkspace sharedWorkspace] openURL:url];
}

- (void)handleGetURLEvent:(NSAppleEventDescriptor *)event withReplyEvent:(NSAppleEventDescriptor *)replyEvent {
    NSURL *url = [NSURL URLWithString:[[event paramDescriptorForKeyword:keyDirectObject] stringValue]];
    if (self.pendingResponseHandler != nil) {
        BOOL handled = [self.pendingResponseHandler handleResponse:url];
        if (handled) {
            self.pendingResponseHandler = nil;
        }
    }
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    [[NSAppleEventManager sharedAppleEventManager] setEventHandler:self andSelector:@selector(handleGetURLEvent:withReplyEvent:) forEventClass:kInternetEventClass andEventID:kAEGetURL];
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
    CFStringRef handler = LSCopyDefaultHandlerForURLScheme((__bridge CFStringRef)TGPURLScheme);
    if (handler != NULL) {
        CFRelease(handler);
        return YES;
    }
    return NO;
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

+ (instancetype)sharedDelegate {
    static TGPAppDelegate *sharedDelegate;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedDelegate = [[self alloc] _init];
    });
    return sharedDelegate;
}

@end
