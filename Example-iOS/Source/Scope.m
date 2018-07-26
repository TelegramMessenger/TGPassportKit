#import "Scope.h"

@interface Scope ()

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSArray<NSString *> *scope;

@end

@implementation Scope

- (NSArray<NSString *> *)passportScope {
    return @[];
}

@end


@implementation ComplexScope

- (NSArray<NSString *> *)passportScope {
    return self.scope;
}

- (instancetype)updateWithScope:(NSArray<NSString *> *)scope {
    ComplexScope *value = [ComplexScope new];
    value.title = self.title;
    value.scope = scope;
    return value;
}

+ (instancetype)scopeWithTitle:(NSString *)title scope:(NSArray<NSString *> *)scope {
    ComplexScope *value = [ComplexScope new];
    value.title = title;
    value.scope = scope;
    return value;
}

@end


@interface SwitchableScope ()

@property (nonatomic, assign) bool enabled;

@end

@implementation SwitchableScope

- (NSArray<NSString *> *)passportScope {
    return self.enabled ? self.scope : @[];
}

- (instancetype)updateWithEnabled:(bool)enabled {
    SwitchableScope *value = [SwitchableScope new];
    value.title = self.title;
    value.scope = self.scope;
    value.enabled = enabled;
    return value;
}

+ (instancetype)scopeWithTitle:(NSString *)title scope:(NSString *)scope enabled:(bool)enabled {
    SwitchableScope *value = [SwitchableScope new];
    value.title = title;
    value.scope = @[scope];
    value.enabled = enabled;
    return value;
}

@end
