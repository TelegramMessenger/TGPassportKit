#import <Foundation/Foundation.h>
#import <TGPassportKit/TGPScope.h>

@interface Scope : NSObject

@property (nonatomic, readonly, strong) NSString *title;

- (NSArray<NSString *> *)passportScope;

@end


@interface ComplexScope : Scope

- (instancetype)updateWithScope:(NSArray<NSString *> *)scope;
+ (instancetype)scopeWithTitle:(NSString *)title scope:(NSArray<NSString *> *)scope;

@end


@interface SwitchableScope : Scope

@property (nonatomic, readonly) bool enabled;

- (instancetype)updateWithEnabled:(bool)enabled;
+ (instancetype)scopeWithTitle:(NSString *)title scope:(NSString *)scope enabled:(bool)enabled;

@end
