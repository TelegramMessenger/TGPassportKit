#import "ScopeCell.h"

NSString *const ComplexScopeCellIdentifier = @"ComplexScopeCell";
NSString *const SwitchableScopeCellIdentifier = @"SwitchableScopeCell";

@implementation ScopeCell

- (void)setScope:(Scope *)scope {
}

+ (NSString *)identifier {
    return NSStringFromClass([self class]);
}

@end

@implementation ComplexScopeCell

- (void)setScope:(ComplexScope *)scope {
    self.textLabel.text = scope.title;
}

@end

@implementation SwitchableScopeCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self.switchView addTarget:self action:@selector(switchChanged) forControlEvents:UIControlEventValueChanged];
}

- (void)switchChanged {
    if (self.valueChanged != nil)
        self.valueChanged(self.switchView.isOn);
}

- (void)setScope:(SwitchableScope *)scope {
    self.titleLabel.text = scope.title;
    self.switchView.on = scope.enabled;
}

@end
