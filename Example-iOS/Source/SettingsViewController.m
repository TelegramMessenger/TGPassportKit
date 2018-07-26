#import "SettingsViewController.h"
#import "Constants.h"

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.botIdView.text = [NSString stringWithFormat:@"%d", ExampleBotId];
    self.publicKeyView.text = ExampleBotPublicKey;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

@end
