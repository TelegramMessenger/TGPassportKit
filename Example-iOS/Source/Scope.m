#import "Scope.h"

@interface Scope ()

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSArray<id<TGPScopeType>> *scope;

@end

@implementation Scope

- (NSArray<NSString *> *)passportScope {
    return @[];
}

@end


@interface ComplexScope ()

@property (nonatomic, assign) BOOL oneOf;
@property (nonatomic, assign) BOOL translation;
@property (nonatomic, assign) BOOL selfie;

@end

@implementation ComplexScope

- (NSArray<id<TGPScopeType>> *)passportScope {
    NSMutableArray *scope = [[NSMutableArray alloc] init];
    NSMutableArray *documentTypes = [[NSMutableArray alloc] init];
    for (id<TGPScopeType> type in self.scope) {
        if ([type isKindOfClass:[TGPIdentityDocument class]] || [type isKindOfClass:[TGPAddressDocument class]]) {
            if (self.oneOf) {
                [documentTypes addObject:type];
            } else {
                if ([type isKindOfClass:[TGPIdentityDocument class]]) {
                    [documentTypes addObject:[[TGPIdentityDocument alloc] initWithType:((TGPIdentityDocument *)type).type selfie:self.selfie translation:self.translation]];
                } else if ([type isKindOfClass:[TGPAddressDocument class]]) {
                    [documentTypes addObject:[[TGPAddressDocument alloc] initWithType:((TGPAddressDocument *)type).type translation:self.translation]];
                }
            }
        } else {
            [scope addObject:type];
        }
    }
    if (self.oneOf) {
        [scope addObject:[[TGPOneOfScopeType alloc] initWithTypes:documentTypes selfie:self.selfie translation:self.translation]];
    } else {
        [scope addObjectsFromArray:documentTypes];
    }
    return scope;
}

- (NSArray *)types {
    return self.scope;
}

- (instancetype)updateWithScope:(NSArray<id<TGPScopeType>> *)scope oneOf:(bool)oneOf translation:(bool)translation selfie:(bool)selfie {
    ComplexScope *value = [ComplexScope new];
    value.title = self.title;
    value.scope = scope;
    value.oneOf = oneOf;
    value.translation = translation;
    value.selfie = selfie;
    return value;
}

+ (instancetype)scopeWithTitle:(NSString *)title scope:(NSArray<id<TGPScopeType>> *)scope oneOf:(bool)oneOf translation:(bool)translation selfie:(bool)selfie {
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

- (NSArray<id<TGPScopeType>> *)passportScope {
    return self.enabled ? self.scope : @[];
}

- (instancetype)updateWithEnabled:(bool)enabled {
    SwitchableScope *value = [SwitchableScope new];
    value.title = self.title;
    value.scope = self.scope;
    value.enabled = enabled;
    return value;
}

+ (instancetype)scopeWithTitle:(NSString *)title scope:(id<TGPScopeType>)scope enabled:(bool)enabled {
    SwitchableScope *value = [SwitchableScope new];
    value.title = title;
    if (scope != nil) {
        value.scope = @[scope];
    }
    value.enabled = enabled;
    return value;
}

@end
