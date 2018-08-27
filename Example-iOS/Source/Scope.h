#import <Foundation/Foundation.h>
#import <TGPassportKit/TGPScope.h>

@interface Scope : NSObject

@property (nonatomic, readonly, strong) NSString *title;

- (NSArray<id<TGPScopeType>> *)passportScope;

@end


@interface ComplexScope : Scope

@property (nonatomic, readonly) NSArray *types;
@property (nonatomic, readonly) BOOL oneOf;
@property (nonatomic, readonly) BOOL translation;
@property (nonatomic, readonly) BOOL selfie;

- (instancetype)updateWithScope:(NSArray<id<TGPScopeType>> *)scope oneOf:(bool)oneOf translation:(bool)translation selfie:(bool)selfie;
+ (instancetype)scopeWithTitle:(NSString *)title scope:(NSArray<id<TGPScopeType>> *)scope oneOf:(bool)oneOf translation:(bool)translation selfie:(bool)selfie;

@end


@interface SwitchableScope : Scope

@property (nonatomic, readonly) bool enabled;

- (instancetype)updateWithEnabled:(bool)enabled;
+ (instancetype)scopeWithTitle:(NSString *)title scope:(id<TGPScopeType>)scope enabled:(bool)enabled;

@end
