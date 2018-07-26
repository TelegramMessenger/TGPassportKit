#import <UIKit/UIKit.h>

@class TGPButton;

@interface RequestViewController : UIViewController

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet TGPButton *passportButton;

@end
