import Cocoa
import TGPassportKit

let ExampleBotId : Int32 = 543260180
let ExampleBotPublicKey = """
-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAv6m1zBF8lZOCqcxf8hnj
kvHwuWdU8s4rBWaxKXH/vDDUklcCS5uhSnmjhxWca9suubaG3lW4HxlCilkeJPVf
jimg5Q8ZqWrR3OoOihEpcG9iJZTOEpsEk7VtEiabgacBG3Quv9JslTrDe95Fn801
t9d21HXwgMrHeHpWDOn31Dr+woEH+kwySUWa6L/ZbnGwSNP7eeDTE7Amz1RMDk3t
8EWGq58u0IQatPcEH09aUQlKzk6MIiALkZ9ILBKCBk6d2WCokKnsdBctovNbxwSx
hP1qst1r+Yc8iPBZozsDC0ZsC5jXCkcODI3OC0tkNtYzN2XKalW5R0DjDRUDmGhT
zQIDAQAB
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
        
        var scopeTypes: [TGPScopeType] = []
        if (personalDetailsCheckView.state == .on) {
            scopeTypes.append(TGPPersonalDetails(nativeNames: nativeNamesCheckView.state == .on))
        }
        
        let oneOfIdentityDocuments = identityOneOfCheckView.state == .on
        let identityIndividualSelfie = identitySelfieCheckView.state == .on && !oneOfIdentityDocuments
        let identityOneOfSelfie = identitySelfieCheckView.state == .on && oneOfIdentityDocuments
        let identityIndividualTranslation = identityTranslationCheckView.state == .on && !oneOfIdentityDocuments
        let identityOneOfTranslation = identityTranslationCheckView.state == .on && oneOfIdentityDocuments
        var identityTypes: [TGPScopeType] = []
        if passportCheckView.state == .on {
            identityTypes.append(TGPIdentityDocument(type: .passport, selfie: identityIndividualSelfie, translation: identityIndividualTranslation))
        }
        if identityCardCheckView.state == .on {
            identityTypes.append(TGPIdentityDocument(type: .identityCard, selfie: identityIndividualSelfie, translation: identityIndividualTranslation))
        }
        if driversLicenseCheckView.state == .on {
            identityTypes.append(TGPIdentityDocument(type: .driversLicense, selfie: identityIndividualSelfie, translation: identityIndividualTranslation))
        }
        if oneOfIdentityDocuments {
            scopeTypes.append(TGPOneOfScopeType(types: identityTypes, selfie: identityOneOfSelfie, translation: identityOneOfTranslation))
        } else {
            scopeTypes.append(contentsOf: identityTypes)
        }
        
        if (addressCheckView.state == .on) {
            scopeTypes.append(TGPAddress())
        }
        
        let oneOfAddressDocuments = addressOneOfCheckView.state == .on
        let addressIndividualTranslation = addressTranslationCheckView.state == .on && !oneOfAddressDocuments
        let addressOneOfTranslation = addressTranslationCheckView.state == .on && oneOfAddressDocuments
        var addressTypes: [TGPScopeType] = []
        
        if (utilityBillCheckView.state == .on) {
            addressTypes.append(TGPAddressDocument(type: .utilityBill, translation: addressIndividualTranslation))
        }
        if (bankStatementCheckView.state == .on) {
            addressTypes.append(TGPAddressDocument(type: .bankStatement, translation: addressIndividualTranslation))
        }
        if (rentalAgreementCheckView.state == .on) {
            addressTypes.append(TGPAddressDocument(type: .rentalAgreement, translation: addressIndividualTranslation))
        }
        if oneOfAddressDocuments {
            scopeTypes.append(TGPOneOfScopeType(types: addressTypes, selfie: false, translation: addressOneOfTranslation))
        } else {
            scopeTypes.append(contentsOf: addressTypes)
        }
        
        if (phoneNumberCheckView.state == .on) {
            scopeTypes.append(TGPPhoneNumber())
        }
        if (emailAddressCheckView.state == .on) {
            scopeTypes.append(TGPEmailAddress())
        }
    
        let scope = TGPScope(types: scopeTypes)
        
        let botConfig = TGPBotConfig(botId: ExampleBotId, publicKey: ExampleBotPublicKey)
        let nonce = UUID.init().uuidString
        
        if let scope = scope {
            let request = TGPRequest(botConfig: botConfig)
            request.perform(with: scope, nonce: nonce) { (result, error) in
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
    }
    
    func showResultAlert(message: String) {
        let alert = NSAlert()
        alert.messageText = "Telegram Passport Result"
        alert.informativeText = message
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
    
    @IBOutlet weak var personalDetailsCheckView: NSButton!
    @IBOutlet weak var nativeNamesCheckView: NSButton!
    @IBOutlet weak var passportCheckView: NSButton!
    @IBOutlet weak var identityCardCheckView: NSButton!
    @IBOutlet weak var driversLicenseCheckView: NSButton!
    @IBOutlet weak var identityOneOfCheckView: NSButton!
    @IBOutlet weak var identityTranslationCheckView: NSButton!
    @IBOutlet weak var identitySelfieCheckView: NSButton!
    @IBOutlet weak var addressCheckView: NSButton!
    @IBOutlet weak var utilityBillCheckView: NSButton!
    @IBOutlet weak var bankStatementCheckView: NSButton!
    @IBOutlet weak var rentalAgreementCheckView: NSButton!
    @IBOutlet weak var addressOneOfCheckView: NSButton!
    @IBOutlet weak var addressTranslationCheckView: NSButton!
    @IBOutlet weak var phoneNumberCheckView: NSButton!
    @IBOutlet weak var emailAddressCheckView: NSButton!
}
