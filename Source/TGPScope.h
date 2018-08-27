#import <Foundation/Foundation.h>
#import <TGPassportKit/TGPUtilities.h>

@protocol TGPScopeType <NSObject>

- (id<TGPJSONSerializable>)jsonValue;

@end

/**
 Represents the scope of requested data
 */
@interface TGPScope : NSObject

/**
 The JSON string describing the scope
 */
@property (nonatomic, readonly) NSString *jsonString;

/**
 Initializes and returns a new instance of request scope
 
 This is the recommended way to initialize a scope as you can generate it dynamically on your server
 and also use future versions of scope format without updating the SDK and your app.
 
 @param jsonString the JSON string describing the scope
 */
- (instancetype)initWithJSONString:(NSString *)jsonString;

/**
 Initializes and returns a new instance of request scope
 
 @param types the array of required types
 */
- (instancetype)initWithTypes:(NSArray<id<TGPScopeType>> *)types;

@end


/**
 Used to add any of specified documents to the scope of requested data
 */
@interface TGPOneOfScopeType : NSObject <TGPScopeType>

/**
 Specifies which document types are accepted
 */
@property (nonatomic, readonly) NSArray<id<TGPScopeType>> *types;

/**
 Specifies whether selfie verification of the document is required
 */
@property (nonatomic, readonly) BOOL selfie;

/**
 Specifies whether translation of the document is required
 */
@property (nonatomic, readonly) BOOL translation;

/**
 Initializes and returns a new "one of types" type instance
 
 @param types the array of accepted types
 @param selfie if selfie verification is required
 @param translation if translation of the document is required
 */
- (instancetype)initWithTypes:(NSArray<id<TGPScopeType>> *)types selfie:(BOOL)selfie translation:(BOOL)translation;

@end


/**
 Used to add personal details to the scope of requested data
 */
@interface TGPPersonalDetails : NSObject <TGPScopeType>

/**
 Specifies whether person's name in the original language of the provided document is required
 */
@property (nonatomic, readonly) BOOL nativeNames;

/**
 Initializes and returns a new personal details type instance
 
 @param nativeNames if a name in the document language is required
 */
- (instancetype)initWithNativeNames:(BOOL)nativeNames;

@end


/**
 Identity document types
 */
typedef NS_ENUM(NSUInteger, TGPIdentityDocumentType) {
    /**
     Passport as a proof of identity
     */
    TGPIdentityDocumentTypePassport,
    
    /**
     Driver's license as a proof of identity
     */
    TGPIdentityDocumentTypeDriversLicense,
    
    /**
     Identity card as a proof of identity
     */
    TGPIdentityDocumentTypeIdentityCard,
    
    /**
     Internal passport as a proof of identity
     */
    TGPIdentityDocumentTypeInternalPassport
};


/**
 Used to add specified proof of identity to the scope of requested data
 */
@interface TGPIdentityDocument : NSObject <TGPScopeType>

/**
 Specifies the required identity document type
 */
@property (nonatomic, readonly) TGPIdentityDocumentType type;

/**
 Specifies whether selfie verification of the document is required
 */
@property (nonatomic, readonly) BOOL selfie;

/**
 Specifies whether translation of the document is required
 */
@property (nonatomic, readonly) BOOL translation;

/**
 Initializes and returns a new identity document type instance
 
 @param type the type of required identity document
 @param selfie if selfie verification is required
 @param translation if translation of the document is required
 */
- (instancetype)initWithType:(TGPIdentityDocumentType)type selfie:(BOOL)selfie translation:(BOOL)translation;

@end


/**
 Used to add residential address to the scope of requested data
 */
@interface TGPAddress : NSObject <TGPScopeType>

@end


/**
 Address document types
 */
typedef NS_ENUM(NSUInteger, TGPAddressDocumentType) {
    /**
     Utility bill as a proof of address
     */
    TGPAddressDocumentTypeUtilityBill,
    
    /**
     Bank statement as a proof of address
     */
    TGPAddressDocumentTypeBankStatement,
    
    /**
     Rental agreement as a proof of address
     */
    TGPAddressDocumentTypeRentalAgreement,
    
    /**
     Passport registration as a proof of address
     */
    TGPAddressDocumentTypePassportRegistration,
    
    /**
     Temporary registration as a proof of address
     */
    TGPAddressDocumentTypeTemporaryRegistration
};


/**
 Used to add specified proof of address to the scope of requested data
 */
@interface TGPAddressDocument : NSObject <TGPScopeType>

/**
 Specifies the required address document type
 */
@property (nonatomic, readonly) TGPAddressDocumentType type;

/**
 Specifies whether translation of the document is required
 */
@property (nonatomic, readonly) BOOL translation;

/**
 Initializes and returns a new address document type instance
 
 @param type the type of required address document
 @param translation if translation of the document is required
 */
- (instancetype)initWithType:(TGPAddressDocumentType)type translation:(BOOL)translation;

@end


/**
 Used to add phone number to the scope of requested data
 */
@interface TGPPhoneNumber : NSObject <TGPScopeType>

@end


/**
 Used to add email address to the scope of requested data
 */
@interface TGPEmailAddress : NSObject <TGPScopeType>

@end
