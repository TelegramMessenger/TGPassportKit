import Cocoa
import TGPassportKit

let ExampleBotId : Int32 = 443863171
let ExampleBotPublicKey = """
-----BEGIN PUBLIC KEY-----
MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAzmgKr0fPP4rB/TsNEweC
hoG3ntUxuBTmHsFBW6CpABGdaTmKZSjAI/cTofhBgtRQIOdX0YRGHHHhwyLf49Wv
9l+XexbJOa0lTsJSNMj8Y/9sZbqUl5ur8ZOTM0sxbXC0XKexu1tM9YavH+Lbrobk
jt0+cmo/zEYZWNtLVihnR2IDv+7tSgiDoFWi/koAUdfJ1VMw+hReUaLg3vE9CmPK
tQiTy+NvmrYaBPb75I0Jz3Lrz1+mZSjLKO25iT84RIsxarBDd8iYh2avWkCmvtiR
Lcif8wLxi2QWC1rZoCA3Ip+Hg9J9vxHlzl6xT01WjUStMhfwrUW6QBpur7FJ+aKM
oaMoHieFNCG4qIkWVEHHSsUpLum4SYuEnyNH3tkjbrdldZanCvanGq+TZyX0buRt
4zk7FGcu8iulUkAP/o/WZM0HKinFN/vuzNVA8iqcO/BBhewhzpqmmTMnWmAO8WPP
DJMABRtXJnVuPh1CI5pValzomLJM4/YvnJGppzI1QiHHNA9JtxVmj2xf8jaXa1LJ
WUNJK+RvUWkRUxpWiKQQO9FAyTPLRtDQGN9eUeDR1U0jqRk/gNT8smHGN6I4H+NR
3X3/1lMfcm1dvk654ql8mxjCA54IpTPr/icUMc7cSzyIiQ7Tp9PZTl1gHh281ZWf
P7d2+fuJMlkjtM7oAwf+tI8CAwEAAQ==
-----END PUBLIC KEY-----
"""

class ViewController: NSViewController {
    
    @IBAction func loginPressed(_ sender: Any) {
        guard TGPAppDelegate.isTelegramAppInstalled() else {
            let alert = NSAlert()
            alert.messageText = "Get Telegram Messenger"
            alert.informativeText = "You need to have Telegram Messenger installed to log in with Telegram Passport"
            alert.addButton(withTitle: "Install")
            alert.addButton(withTitle: "Not Now")
            if alert.runModal() == NSApplication.ModalResponse.alertFirstButtonReturn {
                TGPAppDelegate.openTelegramAppStorePage()
            }
            return
        }
        
        var scope: [String] = []
        
        if (personalDetailsCheckView.state == .on) {
            scope.append(TGPScopePersonalDetails)
        }
        if (passportCheckView.state == .on) {
            scope.append(TGPScopePassport)
        }
        if (identityCardCheckView.state == .on) {
            scope.append(TGPScopeIdentityCard)
        }
        if (driversLicenseCheckView.state == .on) {
            scope.append(TGPScopeDriverLicense)
        }
        if (selfieCheckView.state == .on) {
            scope.append(TGPScopeIdSelfie)
        }
        if (addressCheckView.state == .on) {
            scope.append(TGPScopeAddress)
        }
        if (utilityBillCheckView.state == .on) {
            scope.append(TGPScopeUtilityBill)
        }
        if (bankStatementCheckView.state == .on) {
            scope.append(TGPScopeBankStatement)
        }
        if (rentalAgreementCheckView.state == .on) {
            scope.append(TGPScopeRentalAgreement)
        }
        if (phoneNumberCheckView.state == .on) {
            scope.append(TGPScopePhoneNumber)
        }
        if (emailAddressCheckView.state == .on) {
            scope.append(TGPScopeEmailAddress)
        }
        
        let botConfig = TGPBotConfig(botId: ExampleBotId, publicKey: ExampleBotPublicKey)
        let payload = "abcdef"
        
        let request = TGPRequest(botConfig: botConfig)
        request.perform(withScope: scope, payload: payload) { (result, error) in
            switch result {
            case .succeed:
                self.showResultAlert(message: "Succeed")
            case .cancelled:
                self.showResultAlert(message: "Cancelled")
            default:
                if let error = error {
                    self.showResultAlert(message: "Failed: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func showResultAlert(message: String) {
        let alert = NSAlert()
        alert.messageText = "Telegram Passport Result"
        alert.informativeText = message
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
    
    @IBOutlet weak var personalDetailsCheckView: NSButton!
    @IBOutlet weak var passportCheckView: NSButton!
    @IBOutlet weak var identityCardCheckView: NSButton!
    @IBOutlet weak var driversLicenseCheckView: NSButton!
    @IBOutlet weak var selfieCheckView: NSButton!
    @IBOutlet weak var addressCheckView: NSButton!
    @IBOutlet weak var utilityBillCheckView: NSButton!
    @IBOutlet weak var bankStatementCheckView: NSButton!
    @IBOutlet weak var rentalAgreementCheckView: NSButton!
    @IBOutlet weak var phoneNumberCheckView: NSButton!
    @IBOutlet weak var emailAddressCheckView: NSButton!
}
