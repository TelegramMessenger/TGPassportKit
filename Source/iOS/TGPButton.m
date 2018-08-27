#import "TGPButton.h"
#import "TGPAppDelegate.h"
#import "TGPUtilities.h"

const CGFloat TGPassportButtonSmallCornerRadius = 8.0f;
const CGFloat TGPassportButtonLeftMargin = 16.0f;
const CGFloat TGPassportButtonLogoSize = 27.0f;
const CGFloat TGPassportButtonLogoSpacing = 16.0f;
const CGFloat TGPassportButtonContentOffset = 3.0f;
const CGFloat TGPassportButtonRightMargin = 16.0f;
const CGFloat TGPassportButtonHeight = 50.0f;

@interface TGPButton () <UIAlertViewDelegate>

@property (nonatomic, strong) UIAlertView *alertView;

@end

@implementation TGPButton

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame style:TGPButtonStyleDefault];
}

- (instancetype)initWithFrame:(CGRect)frame style:(TGPButtonStyle)style {
    self = [super initWithFrame:frame];
    if (self != nil) {
        _style = style;
        [self setup];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setup];
}

- (void)setup {
    self.adjustsImageWhenDisabled = NO;
    self.adjustsImageWhenHighlighted = NO;
    self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    self.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.titleEdgeInsets = UIEdgeInsetsMake(0.0f, TGPassportButtonLogoSpacing, 0.0f, TGPassportButtonContentOffset);
    self.imageEdgeInsets = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, TGPassportButtonLogoSpacing + TGPassportButtonContentOffset);
    self.contentEdgeInsets = UIEdgeInsetsMake(0.0f, TGPassportButtonLeftMargin, 0.0f, TGPassportButtonRightMargin);
    self.tintColor = [self defaultTextColor];
    self.titleLabel.font = [self defaultFont];
    
    CGFloat cornerRadius = self.style == TGPButtonStyleRound ? self.frame.size.height / 2.0f : TGPassportButtonSmallCornerRadius;
    UIImage *backgroundImage = [self backgroundImageWithColor:[self defaultBackgroundColor] cornerRadius:cornerRadius];
    UIImage *highlightedBackgroundImage = [self backgroundImageWithColor:[self defaultHighlightedBackgroundColor] cornerRadius:cornerRadius];
    [self setBackgroundImage:backgroundImage forState:UIControlStateNormal];
    [self setBackgroundImage:highlightedBackgroundImage forState:UIControlStateHighlighted];
    
    [self setImage:[TGPButton iconImage] forState:UIControlStateNormal];
    [self setTitle:[self defaultButtonTitle] forState:UIControlStateNormal];
    [self setTitleColor:[self defaultTextColor] forState:UIControlStateNormal];
    
    [self addTarget:self action:@selector(_buttonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    if (CGRectIsEmpty(self.bounds)) {
        [self sizeToFit];
    }
}

- (void)setStyle:(TGPButtonStyle)style {
    _style = style;
    [self setup];
}

- (void)_buttonPressed {
    if ([TGPAppDelegate isTelegramAppInstalled]) {
        TGPRequest *request = [[TGPRequest alloc] initWithBotConfig:self.botConfig];
        
        __weak id<TGPButtonDelegate> delegate = self.delegate;
        [request performWithScope:self.scope nonce:self.nonce completionHandler:^(TGPRequestResult result, NSError * _Nullable error) {
            id strongDelegate = delegate;
            if ([strongDelegate respondsToSelector:@selector(passportButton:didCompleteWithResult:error:)]) {
                [strongDelegate passportButton:self didCompleteWithResult:result error:error];
            }
        }];
    } else {
        [self presentInstallTelegramAlertView];
    }
}

- (void)sizeToFit {
    CGRect bounds = self.bounds;
    bounds.size = [self sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
    self.bounds = bounds;
}

- (CGSize)sizeThatFits:(CGSize)size {
    if (self.isHidden) {
        return CGSizeZero;
    }
    
    UIFont *font = self.titleLabel.font ?: [self defaultFont];
    CGSize titleSize = [TGPButton sizeForText:[self titleForState:UIControlStateNormal] font:font constrainedSize:size];
    CGFloat buttonWidth = TGPassportButtonLeftMargin + TGPassportButtonLogoSize + TGPassportButtonLogoSpacing + titleSize.width + TGPassportButtonRightMargin;
    return CGSizeMake(buttonWidth, TGPassportButtonHeight);
}

+ (CGSize)sizeForText:(NSString *)text font:(UIFont *)font constrainedSize:(CGSize)constrainedSize {
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    NSDictionary *attributes = @{ NSFontAttributeName: font, NSParagraphStyleAttributeName: paragraphStyle };
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:text attributes:attributes];
    NSStringDrawingOptions options = NSStringDrawingUsesDeviceMetrics | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
    CGSize size = [attributedString boundingRectWithSize:constrainedSize options:options context:NULL].size;
    return CGSizeMake(ceil(size.width), ceil(size.height));
}

- (void)presentInstallTelegramAlertView {
    NSString *title = TGPLocalized(@"Button.GetTelegramAlertTitle", @"Get Telegram Messenger");
    NSString *message = TGPLocalized(@"Button.GetTelegramAlertMessage", @"You need to have Telegram Messenger installed to log in with Telegram Passport");
    NSString *cancelTitle = TGPLocalized(@"Button.GetTelegramAlertNotNow", @"Not Now");
    NSString *installTitle = TGPLocalized(@"Button.GetTelegramAlertInstall", @"Install");
    
    if ([UIAlertController class]) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alertController addAction:cancelAction];
        UIAlertAction *installAction = [UIAlertAction actionWithTitle:installTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [TGPAppDelegate openTelegramAppStorePage];
        }];
        [alertController addAction:installAction];
        UIViewController *viewController = [self viewControllerForAlertView];
        [viewController presentViewController:alertController animated:YES completion:nil];
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        self.alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cancelTitle otherButtonTitles:installTitle, nil];
        [self.alertView show];
#pragma clang diagnostic pop
    }
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (self.alertView != nil) {
        self.alertView.delegate = nil;
        self.alertView = nil;
    }
}
#pragma clang diagnostic pop

- (UIViewController *)viewControllerForAlertView {
    UIViewController *parentViewController = nil;
    id strongDelegate = self.delegate;
    if ([strongDelegate respondsToSelector:@selector(viewControllerForAlertView)]) {
        parentViewController = [strongDelegate viewControllerForAlertView];
    }
    
    if (parentViewController == nil) {
        parentViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    }
    
    if (parentViewController.presentedViewController != nil) {
        parentViewController = parentViewController.presentedViewController;
    }
    
    return parentViewController;
}

- (NSString *)defaultButtonTitle {
    return TGPLocalized(@"Button.Title", @"Log in with Telegram");
}

- (UIColor *)defaultBackgroundColor {
    return [UIColor colorWithRed:52.0f / 255.0f green:159.0f / 255.0f blue:249.0f / 255.0f alpha:1.0f];
}

- (UIColor *)defaultHighlightedBackgroundColor {
    return [UIColor colorWithRed:49.0f / 255.0f green:150.0f / 255.0f blue:230.0f / 255.0f alpha:1.0f];
}

- (UIColor *)defaultTextColor {
    return [UIColor whiteColor];
}

- (UIFont *)defaultFont {
    return [UIFont boldSystemFontOfSize:17.0f];
}

+ (UIImage *)iconImage {
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(27.0f, 27.0f), false, 0.0f);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextTranslateCTM(context, 0.0f, 2.0f);
    CGContextScaleCTM(context, 0.3333f, 0.3333f);
    
    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:193.0f / 255.0f green:216.0f / 255.0f blue:236.0f / 255.0f alpha:1.0f].CGColor);
    NSString *path1 = @"M30.7112861,63.126359 C29.3405627,63.4156726 28.0601967,62.5827726 27.4150071,60.7396472 L22.8060628,47.9191034 L20.460145,40.87156 L68.1485161,8.1672785 C68.1485161,8.1672785 68.536535,13.2555953 66.9614397,15.7077455 C62.6090917,22.4835965 47.3233712,34.6341262 41.1950824,43.5860144 C35.8058512,51.4583252 32.4534626,58.784974 30.7112861,63.126359 Z";
    [self drawSVGPath:context path:path1];
    
    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:157.0f / 255.0f green:195.0f / 255.0f blue:226.0f / 255.0f alpha:1.0f].CGColor);
    NSString *path2 = @"M46.6205599,46.8082136 L32.763745,61.8403038 C31.610995,63.090825 30.3208279,63.4498695 29.251865,62.9911521 C29.452738,61.6146197 29.6653591,60.0476142 29.845558,58.4760264 C30.3650879,53.9449953 31.0221844,44.5871564 31.0221844,44.5871564 L46.6205599,46.8082136 Z";
    [self drawSVGPath:context path:path2];
    
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    NSString *path3 = @"M4.90912279,35.5541483 C-1.32172999,33.3808742 -1.36169104,29.7315609 4.81204831,27.4061241 L75.9122393,0.625110216 C79.3390791,-0.665663446 81.4815184,1.17879614 80.6970899,4.74674143 L68.1447549,61.8405943 C67.0461088,66.8377476 62.8185503,68.4044828 58.7046113,65.3417619 L31.0221838,44.7329119 L60.3777618,17.9369435 C66.8684187,12.0122286 66.1587727,11.0995557 58.790243,15.9000476 L20.4601444,40.8715596 L11.1288361,37.7235372 L4.90912279,35.5541483 Z";
    [self drawSVGPath:context path:path3];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (UIImage *)backgroundImageWithColor:(UIColor *)color cornerRadius:(CGFloat)cornerRadius {
    CGFloat size = 1.0f + 2.0f * cornerRadius;
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(size, size), NO, 0.0f);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, cornerRadius + 1.0f, 0.0f);
    CGPathAddArcToPoint(path, NULL, size, 0.0f, size, cornerRadius, cornerRadius);
    CGPathAddLineToPoint(path, NULL, size, cornerRadius + 1.0f);
    CGPathAddArcToPoint(path, NULL, size, size, cornerRadius + 1.0f, size, cornerRadius);
    CGPathAddLineToPoint(path, NULL, cornerRadius, size);
    CGPathAddArcToPoint(path, NULL, 0.0f, size, 0.0f, cornerRadius + 1.0f, cornerRadius);
    CGPathAddLineToPoint(path, NULL, 0.0f, cornerRadius);
    CGPathAddArcToPoint(path, NULL, 0.0f, 0.0f, cornerRadius, 0.0f, cornerRadius);
    CGPathCloseSubpath(path);
    CGContextAddPath(context, path);
    CGPathRelease(path);
    CGContextFillPath(context);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return [image stretchableImageWithLeftCapWidth:cornerRadius topCapHeight:cornerRadius];
}

+ (BOOL)readCGFloat:(NSString *)string position:(int *)position result:(CGFloat *)result {
    int start = *position;
    bool seenDot = false;
    int length = (int)string.length;
    while (*position < length) {
        unichar c = [string characterAtIndex:*position];
        *position = *position + 1;
        
        if (c == '.') {
            if (seenDot) {
                return NO;
            } else {
                seenDot = YES;
            }
        } else if ((c < '0' || c > '9') && c != '-') {
            if (*position == start) {
                *result = 0.0f;
                return YES;
            } else {
                *result = [[string substringWithRange:NSMakeRange(start, *position - start)] floatValue];
                return YES;
            }
        }
    }
    if (*position == start) {
        *result = 0.0f;
        return YES;
    } else {
        *result = [[string substringWithRange:NSMakeRange(start, *position - start)] floatValue];
        return YES;
    }
    return YES;
}

+ (void)drawSVGPath:(CGContextRef)context path:(NSString *)path {
    int position = 0;
    int length = (int)path.length;
    
    while (position < length) {
        unichar c = [path characterAtIndex:position];
        position++;
        
        if (c == ' ') {
            continue;
        }
        
        if (c == 'M') { 
            CGFloat x = 0.0f;
            CGFloat y = 0.0f;
            [self readCGFloat:path position:&position result:&x];
            [self readCGFloat:path position:&position result:&y];
            CGContextMoveToPoint(context, x, y);
        } else if (c == 'L') {
            CGFloat x = 0.0f;
            CGFloat y = 0.0f;
            [self readCGFloat:path position:&position result:&x];
            [self readCGFloat:path position:&position result:&y];
            CGContextAddLineToPoint(context, x, y);
        } else if (c == 'C') {
            CGFloat x1 = 0.0f;
            CGFloat y1 = 0.0f;
            CGFloat x2 = 0.0f;
            CGFloat y2 = 0.0f;
            CGFloat x = 0.0f;
            CGFloat y = 0.0f;
            [self readCGFloat:path position:&position result:&x1];
            [self readCGFloat:path position:&position result:&y1];
            [self readCGFloat:path position:&position result:&x2];
            [self readCGFloat:path position:&position result:&y2];
            [self readCGFloat:path position:&position result:&x];
            [self readCGFloat:path position:&position result:&y];
            
            CGContextAddCurveToPoint(context, x1, y1, x2, y2, x, y);
        } else if (c == 'Z') {
            CGContextClosePath(context);
            CGContextFillPath(context);
            CGContextBeginPath(context);
        } else if (c == 'S') {
            CGContextClosePath(context);
            CGContextStrokePath(context);
            CGContextBeginPath(context);
        } else if (c == 'U') {
            CGContextStrokePath(context);
            CGContextBeginPath(context);
        }
    }
}

@end
