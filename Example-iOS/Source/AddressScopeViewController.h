#import <UIKit/UIKit.h>

@class ComplexScope;

@interface AddressScopeViewController : UITableViewController

@property (nonatomic, copy) void (^finishedWithScope)(ComplexScope *);
- (void)updateWithScope:(ComplexScope *)scope;

@end
