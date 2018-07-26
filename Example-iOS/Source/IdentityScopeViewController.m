#import "IdentityScopeViewController.h"

#import "Scope.h"

@interface IdentityScopeViewController ()

@property (nonatomic, strong) ComplexScope *scope;

@end

@implementation IdentityScopeViewController

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (self.finishedWithScope != nil)
        self.finishedWithScope(self.scope);
}

- (void)updateWithScope:(ComplexScope *)scope {
    self.scope = scope;
    [self.tableView reloadData];
    
    self.selfieSwitchView.on = [scope.passportScope containsObject:TGPScopeIdSelfie];
}

- (IBAction)selfieValueChanged:(UISwitch *)sender {
    NSMutableArray *scope = [self.scope.passportScope mutableCopy];
    if (sender.on && ![scope containsObject:TGPScopeIdSelfie])
        [scope addObject:TGPScopeIdSelfie];
    else if (!sender.on && [scope containsObject:TGPScopeIdSelfie])
        [scope removeObject:TGPScopeIdSelfie];
    [self updateWithScope:[self.scope updateWithScope:scope]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray<NSString *> *scope = self.scope.passportScope;
    
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    bool checked = false;
    bool enabled = true;
    
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
                checked = scope.count == 0;
                break;
                
            case 1:
                checked = [scope containsObject:TGPScopePersonalDetails];
                break;
                
            case 2:
                checked = [scope containsObject:TGPScopeIdDocument];
                break;
                
            case 3:
                checked = [scope containsObject:TGPScopePassport] || [scope containsObject:TGPScopeIdentityCard] || [scope containsObject:TGPScopeDriverLicense];
                break;
                
            default:
                break;
        }
    } else if (indexPath.section == 1) {
        enabled = [scope containsObject:TGPScopePassport] || [scope containsObject:TGPScopeIdentityCard] || [scope containsObject:TGPScopeDriverLicense];
        switch (indexPath.row) {
            case 0:
                checked = [scope containsObject:TGPScopePassport];
                break;
                
            case 1:
                checked = [scope containsObject:TGPScopeIdentityCard];
                break;
                
            case 2:
                checked = [scope containsObject:TGPScopeDriverLicense];
                break;
                
            default:
                break;
        }
    } else if (indexPath.section == 2) {
        enabled = [scope containsObject:TGPScopePassport] || [scope containsObject:TGPScopeIdentityCard] || [scope containsObject:TGPScopeDriverLicense] || [scope containsObject:TGPScopeIdDocument];
        cell.contentView.userInteractionEnabled = enabled;
    }
    
    cell.accessoryType = checked ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    cell.contentView.alpha = enabled ? 1.0f : 0.4f;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:true];
    
    NSArray<NSString *> *currentScope = self.scope.passportScope;
    bool selfie = [currentScope containsObject:TGPScopeIdSelfie];
    
    if (indexPath.section == 0) {
        NSMutableArray<NSString *> *scope = [[NSMutableArray alloc] init];
        switch (indexPath.row) {
            case 1:
                [scope addObject:TGPScopePersonalDetails];
                selfie = false;
                break;
                
            case 2:
                [scope addObject:TGPScopeIdDocument];
                break;
                
            case 3: {
                if (![scope containsObject:TGPScopePassport] && ![scope containsObject:TGPScopeIdentityCard] && ![scope containsObject:TGPScopeDriverLicense]) {
                    [scope addObject:TGPScopePassport];
                } else {
                    [scope addObjectsFromArray:currentScope];
                }
            }
                break;
                
            default:
                selfie = false;
                break;
        }
        if (selfie) {
            [scope addObject:TGPScopeIdSelfie];
        }
        [self updateWithScope:[self.scope updateWithScope:scope]];
    } else if (indexPath.section == 1) {
        NSMutableArray<NSString *> *scope = [currentScope mutableCopy];
        [scope removeObject:TGPScopeIdDocument];
        
        switch (indexPath.row) {
            case 0:
                [self toggleType:TGPScopePassport inScope:scope];
                break;
                
            case 1:
                [self toggleType:TGPScopeIdentityCard inScope:scope];
                break;
                
            case 2:
                [self toggleType:TGPScopeDriverLicense inScope:scope];
                break;
                
            default:
                break;
        }
        if (![scope containsObject:TGPScopePassport] && ![scope containsObject:TGPScopeIdentityCard] && ![scope containsObject:TGPScopeDriverLicense]) {
            [scope addObjectsFromArray:currentScope];
        }
        [self updateWithScope:[self.scope updateWithScope:scope]];
    }
}

- (void)toggleType:(NSString *)type inScope:(NSMutableArray *)scope
{
    if ([scope containsObject:type])
        [scope removeObject:type];
    else
        [scope addObject:type];
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.section != 2;
}

@end
