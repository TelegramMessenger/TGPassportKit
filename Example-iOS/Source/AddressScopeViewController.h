#import <UIKit/UIKit.h>

@class ComplexScope;

@interface AddressScopeViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UISwitch *oneOfSwitchView;
@property (weak, nonatomic) IBOutlet UISwitch *translationSwitchView;

@property (nonatomic, copy) void (^finishedWithScope)(ComplexScope *);
- (void)updateWithScope:(ComplexScope *)scope;

@end
