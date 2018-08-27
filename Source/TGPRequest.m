#import "TGPRequest.h"
#import "TGPAppDelegate.h"

NSString *const TGPURLScheme = @"tg";
static NSString *const TGPBotURLSchemeFormat = @"tgbot%d";

const BOOL TGPUseModernRequestURL = false;
static NSString *const TGPModernRequestHost = @"passport";
static NSString *const TGPLegacyRequestHost = @"resolve";
static NSString *const TGPLegacyRequestQueryParameter = @"domain";
static NSString *const TGPLegacyRequestQueryArgument = @"telegrampassport";

static NSString *const TGPQueryBotIdKey = @"bot_id";
static NSString *const TGPQueryScopeKey = @"scope";
static NSString *const TGPQueryCallbackURLKey = @"callback_url";
static NSString *const TGPQueryPublicKeyKey = @"public_key";
static NSString *const TGPQueryNonceKey = @"nonce";
static NSString *const TGPQueryPayloadKey = @"payload";
static NSString *const TGPQueryPayloadArgument = @"nonce";

static NSString *const TGPResultHost = @"passport";
static NSString *const TGPResultSuccessPath = @"/success";
static NSString *const TGPResultCancelPath = @"/cancel";
static NSString *const TGPResultErrorPath = @"/error";
static NSString *const TGPResultErrorParameter = @"error";

NSString *const TGPErrorDomain = @"TGPassportErrorDomain";
NSString *const TGPErrorMessageKey = @"TGPassportErrorMessage";

static NSString *const TGPErrorMessageBotInvalid = @"BOT_INVALID";
static NSString *const TGPErrorMessagePublicKeyRequired = @"PUBLIC_KEY_REQUIRED";
static NSString *const TGPErrorMessagePublicKeyInvalid = @"PUBLIC_KEY_INVALID";
static NSString *const TGPErrorMessageScopeEmpty = @"SCOPE_EMPTY";
static NSString *const TGPErrorMessageNonceEmpty = @"NONCE_EMPTY";
static NSString *const TGPErrorMessageTelegramNotInstalled = @"TELEGRAM_NOT_INSTALLED";
static NSString *const TGPErrorMessageUserNotLoggedIn = @"USER_NOT_LOGGED_IN";


@interface TGPRequest () <TGPOpenURLResponseHandler>

@property (nonatomic, copy) TGPRequestCompletionHandler currentCompletionHandler;

@end


@implementation TGPRequest

- (instancetype)initWithBotConfig:(TGPBotConfig *)botConfig {
    self = [super init];
    if (self != nil) {
        _botConfig = botConfig;
        [TGPAppDelegate validateSetupWithRequiredURLScheme:self.botURLScheme];
    }
    return self;
}

- (NSString *)botURLScheme {
    return [NSString stringWithFormat:TGPBotURLSchemeFormat, self.botConfig.botId];
}

#pragma mark - Request Execution

- (void)performWithScope:(TGPScope *)scope nonce:(NSString *)nonce completionHandler:(TGPRequestCompletionHandler)completionHandler {
    if (![TGPAppDelegate isTelegramAppInstalled]) {
        completionHandler(TGPRequestResultFailed, [TGPRequest errorWithMessage:TGPErrorMessageTelegramNotInstalled]);
        return;
    }
    
    if (self.botConfig.botId <= 0) {
        completionHandler(TGPRequestResultFailed, [TGPRequest errorWithMessage:TGPErrorMessageBotInvalid]);
        return;
    }
    
    if (self.botConfig.publicKey.length == 0) {
        completionHandler(TGPRequestResultFailed, [TGPRequest errorWithMessage:TGPErrorMessagePublicKeyRequired]);
        return;
    }
    
    if (nonce.length == 0) {
        completionHandler(TGPRequestResultFailed, [TGPRequest errorWithMessage:TGPErrorMessageNonceEmpty]);
        return;
    }
    
    if (scope == nil) {
        completionHandler(TGPRequestResultFailed, [TGPRequest errorWithMessage:TGPErrorMessageScopeEmpty]);
        return;
    }
        
    NSMutableDictionary *queryArguments = [NSMutableDictionary new];
    queryArguments[TGPQueryBotIdKey] = @(self.botConfig.botId);
    queryArguments[TGPQueryPublicKeyKey] = self.botConfig.publicKey;
    queryArguments[TGPQueryScopeKey] = scope.jsonString;
    queryArguments[TGPQueryNonceKey] = nonce;
    queryArguments[TGPQueryPayloadKey] = TGPQueryPayloadArgument;
    
    NSURL *callbackURL = [TGPRequest URLWithScheme:self.botURLScheme host:TGPResultHost path:nil queryArguments:nil];
    queryArguments[TGPQueryCallbackURLKey] = callbackURL.absoluteString;
    
    NSString *host = TGPUseModernRequestURL ? TGPModernRequestHost : TGPLegacyRequestHost;
    if (!TGPUseModernRequestURL) {
        queryArguments[TGPLegacyRequestQueryParameter] = TGPLegacyRequestQueryArgument;
    }
    
    self.currentCompletionHandler = completionHandler;
    NSURL *requestURL = [TGPRequest URLWithScheme:TGPURLScheme host:host path:nil queryArguments:queryArguments];
    [[TGPAppDelegate sharedDelegate] openURL:requestURL responseHandler:self completionHandler:^(BOOL succeed) {
        if (!succeed) {
            completionHandler(TGPRequestResultCancelled, nil);
            self.currentCompletionHandler = nil;
        }
    }];
}

#pragma mark - Response Handling

- (BOOL)handleResponse:(NSURL *)responseURL {
    if (![responseURL.host isEqualToString:TGPResultHost]) {
        return NO;
    }
    
    TGPRequestResult result = TGPRequestResultFailed;
    NSError *error;
    
    if ([responseURL.path isEqualToString:TGPResultSuccessPath]) {
        result = TGPRequestResultSucceed;
    } else if ([responseURL.path isEqualToString:TGPResultCancelPath]) {
        result = TGPRequestResultCancelled;
    } else if ([responseURL.path isEqualToString:TGPResultErrorPath]) {
        result = TGPRequestResultFailed;
        
        NSDictionary *queryParameters = [TGPRequest queryParametersFromURL:responseURL];
        NSString *errorMessage = queryParameters[TGPResultErrorParameter];
        if (errorMessage.length > 0) {
            error = [TGPRequest errorWithMessage:errorMessage];
        }
    }
    
    TGPRequestCompletionHandler completionHandler = [self.currentCompletionHandler copy];
    self.currentCompletionHandler = nil;
    completionHandler(result, error);
    
    return YES;
}

#pragma mark - Error Helpers

+ (NSError *)errorWithMessage:(NSString *)errorMessage {
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
    NSString *errorDomain = TGPErrorDomain;
    NSString *localizedDescription = @"";
    
    TGPRequestErrorCode errorCode = TGPRequestUnknownErrorCode;
    if ([errorMessage isEqualToString:TGPErrorMessageBotInvalid]) {
        errorCode = TGPRequestBotInvalidErrorCode;
    } else if ([errorMessage isEqualToString:TGPErrorMessagePublicKeyRequired]) {
        errorCode = TGPRequestPublicKeyRequiredErrorCode;
    } else if ([errorMessage isEqualToString:TGPErrorMessagePublicKeyInvalid]) {
        errorCode = TGPRequestPublicKeyInvalidErrorCode;
    } else if ([errorMessage isEqualToString:TGPErrorMessageScopeEmpty]) {
        errorCode = TGPRequestScopeEmptyErrorCode;
    } else if ([errorMessage isEqualToString:TGPErrorMessageNonceEmpty]) {
        errorCode = TGPRequestNonceEmptyErrorCode;
    } else if ([errorMessage isEqualToString:TGPErrorMessageTelegramNotInstalled]) {
        errorCode = TGPRequestTelegramNotInstalledErrorCode;
    } else if ([errorMessage isEqualToString:TGPErrorMessageUserNotLoggedIn]) {
        errorCode = TGPRequestUserNotLoggedInErrorCode;
    }
    
    switch (errorCode) {
        case TGPRequestBotInvalidErrorCode:
            localizedDescription = NSLocalizedString(@"Provided bot id is invalid", @"");
            break;
            
        case TGPRequestPublicKeyRequiredErrorCode:
            localizedDescription = NSLocalizedString(@"Public key can not be empty", @"");
            break;
            
        case TGPRequestPublicKeyInvalidErrorCode:
            localizedDescription = NSLocalizedString(@"Public key is invalid", @"");
            break;
            
        case TGPRequestScopeEmptyErrorCode:
            localizedDescription = NSLocalizedString(@"Scope can not be empty", @"");
            break;
            
        case TGPRequestNonceEmptyErrorCode:
            localizedDescription = NSLocalizedString(@"Bot nonce can not be empty", @"");
            break;
            
        case TGPRequestTelegramNotInstalledErrorCode:
            localizedDescription = NSLocalizedString(@"Telegram Messenger should be installed", @"");
            break;
            
        case TGPRequestUserNotLoggedInErrorCode:
            localizedDescription = NSLocalizedString(@"User is not logged in Telegram Messenger app", @"");
            break;
            
        default:
            break;
    }
    
    if (localizedDescription != nil) {
        userInfo[NSLocalizedDescriptionKey] = localizedDescription;
    }
    if (errorMessage != nil) {
        userInfo[TGPErrorMessageKey] = errorMessage;
    }
    
    return [NSError errorWithDomain:errorDomain code:errorCode userInfo:userInfo];
}

#pragma mark - URL Helpers

+ (NSURL *)URLWithScheme:(NSString *)scheme host:(NSString *)host path:(NSString *)path queryArguments:(NSDictionary *)queryArguments {
    if (path != nil && ![path hasPrefix:@"/"]) {
        path = [@"/" stringByAppendingString:path];
    }
    
    NSMutableString *query = [NSMutableString new];
    [queryArguments enumerateKeysAndObjectsUsingBlock:^(id parameter, id argument, __unused BOOL *stop) {
        if (query.length != 0) {
            [query appendString:@"&"];
        }
        [query appendString:[TGPRequest stringByEscapingForURL:[NSString stringWithFormat:@"%@", parameter]]];
        [query appendString:@"="];
        [query appendString:[TGPRequest stringByEscapingForURL:[NSString stringWithFormat:@"%@", argument]]];
    }];
    
    if (query.length > 0) {
        [query insertString:@"?" atIndex:0];
    }
    return [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@://%@%@%@", scheme ?: @"", host ?: @"", path ?: @"", query ?: @""]];
}

+ (NSString *)jsonStringWithObject:(id)object {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object options:kNilOptions error:&error];
    if (jsonData != nil && error == nil) {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return nil;
}

+ (NSString *)stringByEscapingForURL:(NSString *)string {
    static NSString * const escapedCharacters = @"?!@#$^&%*+=,.:;'\"`<>()[]{}/\\|~ ";
    NSString *unescapedString = [string stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    if (unescapedString == nil) {
        unescapedString = string;
    }
    return (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (__bridge CFStringRef)unescapedString, NULL, (CFStringRef)escapedCharacters, CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
}

+ (NSDictionary *)queryParametersFromURL:(NSURL *)url {
    if (url == nil || url.query.length == 0) {
        return @{};
    }
    
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    NSArray *queryComponents = [url.query componentsSeparatedByString:@"&"];
    
    for (NSString *keyValuePair in queryComponents) {
        NSRange equalsSignRange = [keyValuePair rangeOfString:@"="];
        if (equalsSignRange.location != NSNotFound) {
            NSString *key = [keyValuePair substringToIndex:equalsSignRange.location];
            NSString *value = [[[keyValuePair substringFromIndex:equalsSignRange.location + equalsSignRange.length] stringByReplacingOccurrencesOfString:@"+" withString:@" "] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            if (value != nil) {
                [result setObject:value forKey:key];
            }
        }
    }
    return result;
}

@end
