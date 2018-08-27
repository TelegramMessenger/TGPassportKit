#import <Foundation/Foundation.h>

extern NSString *TGPLocalized(NSString *key, NSString *defaultValue);

@interface TGPUtilities : NSObject

@end


@protocol TGPJSONSerializable <NSObject>

@end


@interface NSString (TGPJSONSerializable) <TGPJSONSerializable>

@end


@interface NSArray (TGPJSONSerializable) <TGPJSONSerializable>

@end


@interface NSDictionary (TGPJSONSerializable)  <TGPJSONSerializable>

@end
