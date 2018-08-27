#import "RequestViewController.h"

#import <TGPassportKit/TGPButton.h>
#import "ScopeCell.h"

#import "Constants.h"
#import "Scope.h"

#import "IdentityScopeViewController.h"
#import "AddressScopeViewController.h"
#import "SettingsViewController.h"

@interface RequestViewController () <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, TGPButtonDelegate>

@property (nonatomic, strong) NSArray<Scope *> *scopes;
@property (nonatomic, strong) SwitchableScope *roundScope;
@property (nonatomic, strong) NSString *nonce;

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
@property (nonatomic, strong) UIAlertView *alertView;
#pragma clang diagnostic pop

@end


@implementation RequestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.nonce = [[[NSUUID alloc] init] UUIDString];
    self.scopes = @[
        [ComplexScope scopeWithTitle:@"Identity" scope:@[[[TGPPersonalDetails alloc] init], [[TGPIdentityDocument alloc] initWithType:TGPIdentityDocumentTypePassport selfie:false translation:false]] oneOf:false translation:false selfie:false],
        [ComplexScope scopeWithTitle:@"Address" scope:@[[[TGPAddress alloc] init]] oneOf:false translation:false selfie:false],
        [SwitchableScope scopeWithTitle:@"Phone Number" scope:[[TGPPhoneNumber alloc] init] enabled:true],
        [SwitchableScope scopeWithTitle:@"Email Address" scope:[[TGPEmailAddress alloc] init] enabled:true]
    ];
    
    self.roundScope = [SwitchableScope scopeWithTitle:@"Round" scope:nil enabled:false];
    
    self.passportButton.delegate = self;
    self.passportButton.botConfig = [[TGPBotConfig alloc] initWithBotId:ExampleBotId publicKey:ExampleBotPublicKey];
    self.passportButton.nonce = self.nonce;

    [self updateButtonScope];
}

- (void)updateButtonScope {
    NSMutableArray *finalScope = [[NSMutableArray alloc] init];
    for (Scope *scope in self.scopes) {
        [finalScope addObjectsFromArray:scope.passportScope];
    }
    self.passportButton.scope = [[TGPScope alloc] initWithTypes:finalScope];
}

- (void)updateScopeAtIndex:(NSUInteger)index withScope:(Scope *)scope {
    NSMutableArray *newScopes = [self.scopes mutableCopy];
    [newScopes replaceObjectAtIndex:index withObject:scope];
    self.scopes = newScopes;
    [self updateButtonScope];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:true];
}

- (void)passportButton:(TGPButton *)passportButton didCompleteWithResult:(TGPRequestResult)result error:(NSError *)error {
    NSString *message = nil;
    switch (result) {
        case TGPRequestResultSucceed:
            message = @"Succeed";
            break;
        
        case TGPRequestResultCancelled:
            message = @"Cancelled";
            break;
            
        case TGPRequestResultFailed:
            message = [NSString stringWithFormat:@"Failed: %@", error.localizedDescription];
            break;
        
        default:
            break;
    }
    [self presentResultAlertViewWithMessage:message];
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    ScopeCell *cell = nil;
    if (indexPath.section == 0) {
        Scope *scope = self.scopes[indexPath.row];
        
        NSString *identifier = nil;
        if ([scope isKindOfClass:[ComplexScope class]]) {
            identifier = [ComplexScopeCell identifier];
        } else if ([scope isKindOfClass:[SwitchableScope class]]) {
            identifier = [SwitchableScopeCell identifier];
        }
        
        cell = (ScopeCell *)[tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
        
        if ([cell isKindOfClass:[SwitchableScopeCell class]]) {
            __weak RequestViewController *weakSelf = self;
            ((SwitchableScopeCell *)cell).valueChanged = ^(bool on) {
                __strong RequestViewController *strongSelf = weakSelf;
                if (strongSelf != nil) {
                    SwitchableScope *switchableScope = (SwitchableScope *)scope;
                    [strongSelf updateScopeAtIndex:indexPath.row withScope:[switchableScope updateWithEnabled:on]];
                }
            };
        }
        
        [cell setScope:scope];
    } else if (indexPath.section == 1) {
        NSString *identifier = [SwitchableScopeCell identifier];
        cell = (SwitchableScopeCell *)[tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
        [cell setScope:self.roundScope];
        
        __weak RequestViewController *weakSelf = self;
        ((SwitchableScopeCell *)cell).valueChanged = ^(bool on) {
            __strong RequestViewController *strongSelf = weakSelf;
            if (strongSelf != nil)
                strongSelf->_passportButton.style = on ? TGPButtonStyleRound : TGPButtonStyleDefault;
        };
    }
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return self.scopes.count;
            
        case 1:
            return 1;
            
        default:
            return 0;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            [self performSegueWithIdentifier:@"presentIdentitySegue" sender:nil];
        } else if (indexPath.row == 1) {
            [self performSegueWithIdentifier:@"presentAddressSegue" sender:nil];
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return [self.scopes[indexPath.row] isKindOfClass:[ComplexScope class]];
    }
    else {
        return NO;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return @"Required Information";
            
        case 2:
            return @"Payload";
            
        case 1:
            return @"Button Style";
            
        default:
            return nil;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    __weak RequestViewController *weakSelf = self;
    if ([segue.destinationViewController respondsToSelector:@selector(updateWithScope:)]) {
        Scope *scope = nil;
        if ([segue.destinationViewController isKindOfClass:[IdentityScopeViewController class]]) {
            scope = self.scopes[0];
            ((IdentityScopeViewController *)segue.destinationViewController).finishedWithScope = ^(ComplexScope *scope)
            {
                __strong RequestViewController *strongSelf = weakSelf;
                [strongSelf updateScopeAtIndex:0 withScope:scope];
            };
        } else if ([segue.destinationViewController isKindOfClass:[AddressScopeViewController class]]) {
            scope = self.scopes[1];
            ((AddressScopeViewController *)segue.destinationViewController).finishedWithScope = ^(ComplexScope *scope)
            {
                __strong RequestViewController *strongSelf = weakSelf;
                [strongSelf updateScopeAtIndex:1 withScope:scope];
            };
        }
        [segue.destinationViewController performSelector:@selector(updateWithScope:) withObject:scope];
    }
}

- (void)presentResultAlertViewWithMessage:(NSString *)message {
    NSString *title = NSLocalizedString(@"Telegram Passport Result", @"");
    NSString *okTitle = NSLocalizedString(@"OK", @"");
    
    if ([UIAlertController class]) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:okTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alertController addAction:cancelAction];
        [self presentViewController:alertController animated:YES completion:nil];
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        self.alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:okTitle otherButtonTitles:nil];
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

@end
