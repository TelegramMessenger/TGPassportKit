#import "TGPBotConfig.h"

@implementation TGPBotConfig

- (instancetype)initWithBotId:(int32_t)botId publicKey:(NSString *)publicKey {
    self = [super init];
    if (self != nil) {
        _botId = botId;
        _publicKey = publicKey;
    }
    return self;
}

@end
