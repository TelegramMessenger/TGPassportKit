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
    
    self.oneOfSwitchView.on = scope.oneOf;
    self.translationSwitchView.on = scope.translation;
}

- (IBAction)oneOfValueChanged:(UISwitch *)sender {
    [self updateWithScope:[self.scope updateWithScope:self.scope.types oneOf:sender.on translation:self.translationSwitchView.on selfie:false]];
}

- (IBAction)translationValueChanged:(UISwitch *)sender {
    [self updateWithScope:[self.scope updateWithScope:self.scope.types oneOf:self.oneOfSwitchView.on translation:sender.on selfie:false]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray<id<TGPScopeType>> *scope = self.scope.types;
    
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    bool checked = false;
    
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
                checked = [self scope:scope containsType:[[TGPAddress alloc] init]];
                break;
                
            case 1:
                checked = [self scope:scope containsType:[[TGPAddressDocument alloc] initWithType:TGPAddressDocumentTypeUtilityBill translation:false]];
                break;
                
            case 2:
                checked = [self scope:scope containsType:[[TGPAddressDocument alloc] initWithType:TGPAddressDocumentTypeBankStatement translation:false]];
                break;
                
            case 3:
                checked = [self scope:scope containsType:[[TGPAddressDocument alloc] initWithType:TGPAddressDocumentTypeRentalAgreement translation:false]];
                break;
                
            default:
                break;
        }
    }
    
    cell.accessoryType = checked ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:true];
    
    if (indexPath.section == 0) {
        NSMutableArray<id<TGPScopeType>> *scope = [self.scope.types mutableCopy];
        switch (indexPath.row) {
            case 0:
                [self toggleType:[[TGPAddress alloc] init] inScope:scope];
                break;
                
            case 1:
                [self toggleType:[[TGPAddressDocument alloc] initWithType:TGPAddressDocumentTypeUtilityBill translation:false] inScope:scope];
                break;
                
            case 2:
                [self toggleType:[[TGPAddressDocument alloc] initWithType:TGPAddressDocumentTypeBankStatement translation:false] inScope:scope];
                break;
                
            case 3:
                [self toggleType:[[TGPAddressDocument alloc] initWithType:TGPAddressDocumentTypeRentalAgreement translation:false] inScope:scope];
                break;
                
            default:
                break;
        }
        [self updateWithScope:[self.scope updateWithScope:scope oneOf:self.oneOfSwitchView.on translation:self.translationSwitchView.on selfie:false]];
    }
}

- (BOOL)scope:(NSArray<id<TGPScopeType>> *)scope containsType:(id<TGPScopeType>)type {
    return [scope containsObject:type];
}

- (void)toggleType:(id<TGPScopeType>)type inScope:(NSMutableArray *)scope {
    if ([scope containsObject:type])
        [scope removeObject:type];
    else
        [scope addObject:type];
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.section != 1;
}

@end
