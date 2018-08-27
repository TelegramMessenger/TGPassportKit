#import <UIKit/UIKit.h>
#import <TGPassportKit/TGPScope.h>
#import <TGPassportKit/TGPRequest.h>

@protocol TGPButtonDelegate;

/**
 Defines style of the button

 - TGPButtonStyleDefault: button style with slightly rounded corners
 - TGPButtonStyleRound: button style with fully rounded corners
 */
typedef NS_OPTIONS(NSUInteger, TGPButtonStyle)
{
    TGPButtonStyleDefault,
    TGPButtonStyleRound,
};

/**
 Telegram-branded button that initiates a Telegram Passport request.
 */
@interface TGPButton : UIButton

/**
 The delegate of the button
 */
@property (nonatomic, weak) IBOutlet id<TGPButtonDelegate> delegate;

/**
 The bot configuration used for Telegram Passport request
 */
@property (nonatomic, strong) TGPBotConfig *botConfig;

/**
 The scope of requested Telegram Passport data
 */
@property (nonatomic, strong) TGPScope *scope;

/**
 Bot specified nonce
 */
@property (nonatomic, strong) NSString *nonce;

/**
 The desired button style
 */
@property (nonatomic, assign) TGPButtonStyle style;

- (instancetype)initWithFrame:(CGRect)frame style:(TGPButtonStyle)style;

@end


/**
 Defines result handling
 */
@protocol TGPButtonDelegate <NSObject>

/**
 Description

 @param passportButton the passport button
 @param result the result of the request
 @param error the error, if any
 */
- (void)passportButton:(TGPButton *)passportButton didCompleteWithResult:(TGPRequestResult)result error:(NSError *)error;

@optional

/**
 Optional parent view controller for alert view presentation. The default is the key window's root controller.

 @return custom view controller for presenting alert views
 */
- (UIViewController *)viewControllerForAlertView;

@end
