#import "AddressScopeViewController.h"

#import "Scope.h"

@interface AddressScopeViewController ()

@property (nonatomic, strong) ComplexScope *scope;

@end

@implementation AddressScopeViewController

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (self.finishedWithScope != nil)
        self.finishedWithScope(self.scope);
}

- (void)updateWithScope:(ComplexScope *)scope {
    self.scope = scope;
    [self.tableView reloadData];
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
                checked = [scope containsObject:TGPScopeAddress];
                break;
                
            case 2:
                checked = [scope containsObject:TGPScopeAddressDocument];
                break;
                
            case 3:
                checked = [scope containsObject:TGPScopeUtilityBill] || [scope containsObject:TGPScopeBankStatement] || [scope containsObject:TGPScopeRentalAgreement];
                break;
                
            default:
                break;
        }
    } else if (indexPath.section == 1) {
        enabled = [scope containsObject:TGPScopeUtilityBill] || [scope containsObject:TGPScopeBankStatement] || [scope containsObject:TGPScopeRentalAgreement];
        switch (indexPath.row) {
            case 0:
                checked = [scope containsObject:TGPScopeUtilityBill];
                break;
                
            case 1:
                checked = [scope containsObject:TGPScopeBankStatement];
                break;
                
            case 2:
                checked = [scope containsObject:TGPScopeRentalAgreement];
                break;
                
            default:
                break;
        }
    }
    
    cell.accessoryType = checked ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    cell.contentView.alpha = enabled ? 1.0f : 0.4f;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:true];
    
    NSArray<NSString *> *currentScope = self.scope.passportScope;
    
    if (indexPath.section == 0) {
        NSMutableArray<NSString *> *scope = [[NSMutableArray alloc] init];
        switch (indexPath.row) {
            case 1:
                [scope addObject:TGPScopeAddress];
                break;

            case 2:
                [scope addObject:TGPScopeAddressDocument];
                break;
                
            case 3: {
                if (![scope containsObject:TGPScopeUtilityBill] && ![scope containsObject:TGPScopeBankStatement] && ![scope containsObject:TGPScopeRentalAgreement]) {
                    [scope addObject:TGPScopeUtilityBill];
                } else {
                    [scope addObjectsFromArray:currentScope];
                }
            }
                break;
                
            default:
                break;
        }
        [self updateWithScope:[self.scope updateWithScope:scope]];
    } else if (indexPath.section == 1) {
        NSMutableArray<NSString *> *scope = [currentScope mutableCopy];
        [scope removeObject:TGPScopeAddressDocument];
        
        switch (indexPath.row) {
            case 0:
                [self toggleType:TGPScopeUtilityBill inScope:scope];
                break;
                
            case 1:
                [self toggleType:TGPScopeBankStatement inScope:scope];
                break;
                
            case 2:
                [self toggleType:TGPScopeRentalAgreement inScope:scope];
                break;
                
            default:
                break;
        }
        if (![scope containsObject:TGPScopeUtilityBill] && ![scope containsObject:TGPScopeBankStatement] && ![scope containsObject:TGPScopeRentalAgreement]) {
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

@end
