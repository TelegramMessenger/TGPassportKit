#import "TGPScope.h"

static NSString *const TGPScopeTypeKey = @"type";
static NSString *const TGPScopeNativeNamesKey = @"native_names";
static NSString *const TGPScopeSelfieKey = @"selfie";
static NSString *const TGPScopeTranslationKey = @"translation";
static NSString *const TGPScopeOneOfKey = @"one_of";

static NSString *const TGPScopeDataKey = @"data";
static NSString *const TGPScopeVersionKey = @"v";
const NSInteger TGPScopeVersion = 1;

static NSString *const TGPInvalidScopeException = @"InvalidScopeException";

NSString *const TGPScopePersonalDetails = @"personal_details";
NSString *const TGPScopePassport = @"passport";
NSString *const TGPScopeDriverLicense = @"driver_license";
NSString *const TGPScopeIdentityCard = @"identity_card";
NSString *const TGPScopeInternalPassport = @"internal_passport";
NSString *const TGPScopeIdDocument = @"id_document";
NSString *const TGPScopeAddress = @"address";
NSString *const TGPScopeUtilityBill = @"utility_bill";
NSString *const TGPScopeBankStatement = @"bank_statement";
NSString *const TGPScopeRentalAgreement = @"rental_agreement";
NSString *const TGPScopePassportRegistration = @"passport_registration";
NSString *const TGPScopeTemporaryRegistration = @"temporary_registration";
NSString *const TGPScopeAddressDocument = @"address_document";
NSString *const TGPScopePhoneNumber = @"phone_number";
NSString *const TGPScopeEmailAddress = @"email";

@implementation TGPScope

- (instancetype)initWithTypes:(NSArray<id<TGPScopeType>> *)types {
    self = [super init];
    if (self != nil) {
        if (types.count == 0) {
            @throw [NSException exceptionWithName:TGPInvalidScopeException reason:@"Scope can not be empty" userInfo:nil];
            return nil;
        }
        
        NSMutableArray<id<TGPJSONSerializable>> *scopeData = [[NSMutableArray alloc] init];
        for (id<TGPScopeType> type in types) {
            id<TGPJSONSerializable> jsonValue = type.jsonValue;
            if (jsonValue != nil) {
                [scopeData addObject:jsonValue];
            }
        }
        
        NSMutableDictionary *scopeDictionary = [[NSMutableDictionary alloc] init];
        scopeDictionary[TGPScopeDataKey] = scopeData;
        scopeDictionary[TGPScopeVersionKey] = @(TGPScopeVersion);
        
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:scopeDictionary options:kNilOptions error:&error];
        if (error != nil) {
            return nil;
        }
        
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        if (jsonString.length == 0) {
            return nil;
        }
        _jsonString = jsonString;
    }
    return self;
}

- (instancetype)initWithJSONString:(NSString *)jsonString {
    self = [super init];
    if (self != nil) {
        if (jsonString.length == 0) {
            @throw [NSException exceptionWithName:TGPInvalidScopeException reason:@"Scope can not be empty" userInfo:nil];
            return nil;
        }
        
        _jsonString = jsonString;
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    return [object isKindOfClass:[TGPScope class]] && ((TGPScope *)object).jsonString == self.jsonString;
}

@end


@implementation TGPOneOfScopeType

- (instancetype)initWithTypes:(NSArray<id<TGPScopeType>> *)types selfie:(BOOL)selfie translation:(BOOL)translation {
    self = [super init];
    if (self != nil) {
        bool hasIdentityType = false;
        bool hasAddressType = false;
        
        for (id<TGPScopeType> type in types) {
            if ([type isKindOfClass:[TGPOneOfScopeType class]]) {
                NSString *reason = @"TGPOneOfScopeType can not contain another TGPOneOfScopeType as a subtype";
                @throw [NSException exceptionWithName:TGPInvalidScopeException reason:reason userInfo:nil];
                return nil;
            }
            
            bool hasMixedTypes = false;
            if ([type isKindOfClass:[TGPIdentityDocument class]]) {
                hasIdentityType = true;
                if (hasAddressType) {
                    hasMixedTypes = true;
                }
            } else if ([type isKindOfClass:[TGPAddressDocument class]]) {
                hasAddressType = true;
                if (hasIdentityType) {
                    hasMixedTypes = true;
                }
            }
            
            if (hasMixedTypes) {
                NSString *reason = @"TGPOneOfScopeType can not containt types of identity and address documents simultaneously";
                @throw [NSException exceptionWithName:TGPInvalidScopeException reason:reason userInfo:nil];
                return nil;
            }
        }
        
        _types = types;
        _selfie = selfie;
        _translation = translation;
    }
    return self;
}

- (id<TGPJSONSerializable>)jsonValue {
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    NSMutableArray *types = [[NSMutableArray alloc] init];
    for (id<TGPScopeType> type in _types) {
        id<TGPJSONSerializable> jsonValue = type.jsonValue;
        if (jsonValue != nil) {
            [types addObject:jsonValue];
        }
    }
    dictionary[TGPScopeOneOfKey] = types;
    if (_selfie) {
        dictionary[TGPScopeSelfieKey] = @YES;
    }
    if (_translation) {
        dictionary[TGPScopeTranslationKey] = @YES;
    }
    return dictionary;
}

- (BOOL)isEqual:(id)object {
    return [object isKindOfClass:[TGPOneOfScopeType class]] && [((TGPOneOfScopeType *)object)->_types isEqual:_types] && ((TGPOneOfScopeType *)object)->_selfie == _selfie && ((TGPOneOfScopeType *)object)->_translation == _translation;
}

@end


@implementation TGPPersonalDetails

- (instancetype)initWithNativeNames:(BOOL)nativeNames {
    self = [super init];
    if (self != nil) {
        _nativeNames = nativeNames;
    }
    return self;
}

- (id<TGPJSONSerializable>)jsonValue {
    if (!_nativeNames) {
        return TGPScopePersonalDetails;
    } else {
        return @{ TGPScopeTypeKey:TGPScopePersonalDetails, TGPScopeNativeNamesKey: @YES };
    }
}

- (BOOL)isEqual:(id)object {
    return [object isKindOfClass:[TGPPersonalDetails class]] && ((TGPPersonalDetails *)object)->_nativeNames == _nativeNames;
}

@end


@implementation TGPIdentityDocument

- (instancetype)initWithType:(TGPIdentityDocumentType)type selfie:(BOOL)selfie translation:(BOOL)translation {
    self = [super init];
    if (self != nil) {
        _type = type;
        _selfie = selfie;
        _translation = translation;
    }
    return self;
}

- (id<TGPJSONSerializable>)jsonValue {
    if (!_selfie && !_translation) {
        return [self typeString];
    } else {
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
        dictionary[TGPScopeTypeKey] = [self typeString];
        if (_selfie) {
            dictionary[TGPScopeSelfieKey] = @YES;
        }
        if (_translation) {
            dictionary[TGPScopeTranslationKey] = @YES;
        }
        return dictionary;
    }
}

- (NSString *)typeString {
    switch (_type) {
        case TGPIdentityDocumentTypePassport:
            return TGPScopePassport;
            
        case TGPIdentityDocumentTypeDriversLicense:
            return TGPScopeDriverLicense;
            
        case TGPIdentityDocumentTypeIdentityCard:
            return TGPScopeIdentityCard;
            
        case TGPIdentityDocumentTypeInternalPassport:
            return TGPScopeInternalPassport;
            
        default:
            return nil;
    }
}

- (BOOL)isEqual:(id)object {
    return [object isKindOfClass:[TGPIdentityDocument class]] && ((TGPIdentityDocument *)object)->_type == _type && ((TGPIdentityDocument *)object)->_selfie == _selfie && ((TGPIdentityDocument *)object)->_translation == _translation;
}

@end


@implementation TGPAddress

- (id<TGPJSONSerializable>)jsonValue {
    return TGPScopeAddress;
}

- (BOOL)isEqual:(id)object {
    return [object isKindOfClass:[TGPAddress class]];
}

@end


@implementation TGPAddressDocument

- (instancetype)initWithType:(TGPAddressDocumentType)type translation:(BOOL)translation {
    self = [super init];
    if (self != nil) {
        _type = type;
        _translation = translation;
    }
    return self;
}

- (id<TGPJSONSerializable>)jsonValue {
    if (!_translation) {
        return [self typeString];
    } else {
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
        dictionary[TGPScopeTypeKey] = [self typeString];
        if (_translation) {
            dictionary[TGPScopeTranslationKey] = @YES;
        }
        return dictionary;
    }
}

- (NSString *)typeString {
    switch (_type) {
        case TGPAddressDocumentTypeUtilityBill:
            return TGPScopeUtilityBill;
            
        case TGPAddressDocumentTypeBankStatement:
            return TGPScopeBankStatement;
            
        case TGPAddressDocumentTypeRentalAgreement:
            return TGPScopeRentalAgreement;
            
        case TGPAddressDocumentTypePassportRegistration:
            return TGPScopePassportRegistration;
            
        case TGPAddressDocumentTypeTemporaryRegistration:
            return TGPScopeTemporaryRegistration;
            
        default:
            return nil;
    }
}

- (BOOL)isEqual:(id)object {
    return [object isKindOfClass:[TGPAddressDocument class]] && ((TGPAddressDocument *)object)->_type == _type && ((TGPAddressDocument *)object)->_translation == _translation;
}

@end


@implementation TGPPhoneNumber

- (id<TGPJSONSerializable>)jsonValue {
    return TGPScopePhoneNumber;
}

- (BOOL)isEqual:(id)object {
    return [object isKindOfClass:[TGPPhoneNumber class]];
}

@end


@implementation TGPEmailAddress

- (id<TGPJSONSerializable>)jsonValue {
    return TGPScopeEmailAddress;
}

- (BOOL)isEqual:(id)object {
    return [object isKindOfClass:[TGPEmailAddress class]];
}

@end
