#import <TGPassportKit/TGPBotConfig.h>
#import <TGPassportKit/TGPScope.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Describes a result of a request
 */
typedef NS_ENUM(NSUInteger, TGPRequestResult) {
    /**
     The request was cancelled by the user
    */
    TGPRequestResultFailed,
    /**
     The request was authorized by the user and encrypted data was sent to the bot
     */
    TGPRequestResultCancelled,
    /**
     The request failed
     */
    TGPRequestResultSucceed
};


/**
 Request error codes
 */
typedef NS_ENUM(NSUInteger, TGPRequestErrorCode) {
    TGPRequestUnknownErrorCode,
    TGPRequestBotInvalidErrorCode,
    TGPRequestPublicKeyRequiredErrorCode,
    TGPRequestPublicKeyInvalidErrorCode,
    TGPRequestScopeEmptyErrorCode,
    TGPRequestNonceEmptyErrorCode,
    TGPRequestTelegramNotInstalledErrorCode,
    TGPRequestUserNotLoggedInErrorCode
};

/**
 Responsible for sending a request to Telegram client and receiving a callback.
 
 @warning TGPassportKit is **NOT** thread safe and all methods should be called on the main thread!
 */
@interface TGPRequest : NSObject

/**
 Prototype of a callback function used to handle a result of a request.

 @param result the result of the request
 @param error the error, if any
 */
typedef void (^TGPRequestCompletionHandler)(TGPRequestResult result, NSError * _Nullable error);

/**
 The bot configuration used for the request
 */
@property (nonatomic, readonly) TGPBotConfig *botConfig;

/**
 Initializes and returns a new request instance with specified bot configuration
 
 @param botConfig the bot configuration
 */
- (instancetype)initWithBotConfig:(TGPBotConfig *)botConfig;

/**
 Initiates a Telegram Passport request with specified scope, nonce and completion handler

 @param scope the scope of the request
 @param nonce the cryptographically secure unique identifier which allows the service to identify a request
 @param completionHandler the callback
 */
- (void)performWithScope:(TGPScope *)scope nonce:(NSString *)nonce completionHandler:(TGPRequestCompletionHandler)completionHandler;

@end

extern NSString *const TGPURLScheme;

extern NSString *const TGPErrorDomain;

extern NSString *const TGPErrorMessageKey;

NS_ASSUME_NONNULL_END
