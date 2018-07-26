#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Represents a Telegram bot configuration
 
 To use Telegram Passport you need to create a Telegram bot and provide a public key
 */
@interface TGPBotConfig : NSObject

/**
 The bot ID
 */
@property (nonatomic, readonly) int32_t botId;

/**
 The bot public key
 
 The public key used for encrypted transmission of passport data.
 */
@property (nonatomic, readonly) NSString *publicKey;

/**
 Initializes and returns a new instance of bot configuration

 @param botId the bot ID
 @param publicKey the bot public key
 */
- (instancetype)initWithBotId:(int32_t)botId publicKey:(NSString *)publicKey;

@end

NS_ASSUME_NONNULL_END
