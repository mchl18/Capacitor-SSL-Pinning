import Foundation
import Capacitor

@objc(SSLCertificateCheckerPlugin)
public class SSLCertificateCheckerPlugin: CAPPlugin, CAPBridgedPlugin {
    public let identifier = "SSLCertificateCheckerPlugin"
    public let jsName = "SSLCertificateChecker"
    public let pluginMethods: [CAPPluginMethod] = [
        CAPPluginMethod(name: "checkCertificate", returnType: CAPPluginReturnPromise)
    ]
    private let implementation = SSLCertificateChecker()

    @objc func checkCertificate(_ call: CAPPluginCall) {
        guard let url = call.getString("url"),
              let fingerprint = call.getString("fingerprint") else {
            call.reject("Must provide url and fingerprint")
            return
        }
        
        let result = implementation.checkCertificate(url, expectedFingerprint: fingerprint)
        call.resolve(result)
    }
}