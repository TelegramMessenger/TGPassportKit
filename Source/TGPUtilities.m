#import "TGPUtilities.h"
#import "TGPAppDelegate.h"

NSString *const TGPTableName = @"TGPassportKit";
NSString *const TGPStringsBundleName = @"TGPassportKitStrings";
NSString *const TGPBundleExtension = @"bundle";
NSString *const TGPLocalizedStringPrefix = @"PassportKit.";

@implementation TGPUtilities

+ (NSString *)localizedStringForKey:(NSString *)key defaultValue:(NSString *)defaultValue {
    return NSLocalizedStringWithDefaultValue([TGPLocalizedStringPrefix stringByAppendingString:key], TGPTableName, [self stringsBundle], defaultValue, @"");
}

+ (NSBundle *)stringsBundle {
    static NSBundle *bundle;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *stringsBundlePath = [[NSBundle bundleForClass:[TGPAppDelegate class]] pathForResource:TGPStringsBundleName ofType:TGPBundleExtension];
        bundle = [NSBundle bundleWithPath:stringsBundlePath] ?: [NSBundle mainBundle];
    });
    return bundle;
}

@end


NSString *TGPLocalized(NSString *key, NSString *defaultValue) {
    return [TGPUtilities localizedStringForKey:key defaultValue:defaultValue];
}
