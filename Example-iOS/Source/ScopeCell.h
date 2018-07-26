#import <UIKit/UIKit.h>
#import "Scope.h"

@interface ScopeCell : UITableViewCell

- (void)setScope:(Scope *)scope;
+ (NSString *)identifier;

@end


@interface ComplexScopeCell : ScopeCell

@property (weak, nonatomic) IBOutlet UILabel *detailLabel;

@end


@interface SwitchableScopeCell : ScopeCell

@property (nonatomic, copy) void (^valueChanged)(bool on);
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UISwitch *switchView;

@end
