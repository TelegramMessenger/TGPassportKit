#import "AppDelegate.h"
#import <TGPassportKit/TGPAppDelegate.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options {
    return [[TGPAppDelegate sharedDelegate] application:application openURL:url options:options];
}

@end
