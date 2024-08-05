import Foundation
import Capacitor
import CryptoKit
import Security

class SSLCertificateChecker {
    func checkCertificate(_ urlString: String, expectedFingerprint: String) -> [String: Any] {
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return ["error": "Invalid URL"]
        }
        guard url.scheme == "https" else {
            print("URL is not HTTPS")
            return ["error": "URL is not HTTPS"]
        }

        let semaphore = DispatchSemaphore(value: 0)
        var result: [String: Any] = [:]

        let session = URLSession(configuration: .ephemeral, delegate: CertificateCheckDelegate(expectedFingerprint: expectedFingerprint) { isValid, actualFingerprint, issuer in
            result = [
                "expectedFingerprint": expectedFingerprint.uppercased(),
                "actualFingerprint": actualFingerprint.uppercased(),
                "fingerprintMatched": isValid,
                // this should be coming from the delegate
                "subject": urlString.replacingOccurrences(of: "https://", with: ""),
                "issuer": issuer
            ]
            semaphore.signal()
        }, delegateQueue: nil)

        let task = session.dataTask(with: url) { _, _, _ in
            semaphore.signal()
        }

        task.resume()
        semaphore.wait()

        return result
    }
}


class CertificateCheckDelegate: NSObject, URLSessionDelegate {
    private let expectedFingerprint: String
    private let completion: (Bool, String, String) -> Void

    init(expectedFingerprint: String, completion: @escaping (Bool, String, String) -> Void) {
        self.expectedFingerprint = expectedFingerprint
        self.completion = completion
    }

    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        guard let serverTrust = challenge.protectionSpace.serverTrust,
              let certificate = SecTrustGetCertificateAtIndex(serverTrust, 0) else {
            completion(false, "", "")
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        let actualFingerprint = certificateFingerprint(certificate)
        let issuer = certificateIssuer(certificate)
        print("Actual Fingerprint: \(actualFingerprint)")
        print("Expected fingerprint: \(expectedFingerprint)")
        print("Issuer: \(issuer)")
        let isValid = actualFingerprint.lowercased() == expectedFingerprint.lowercased()

        completion(isValid, actualFingerprint, issuer)

        if isValid {
            completionHandler(.useCredential, URLCredential(trust: serverTrust))
        } else {
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
    }

    private func certificateFingerprint(_ certificate: SecCertificate) -> String {
        if let data = SecCertificateCopyData(certificate) as Data? {
            let hash = SHA256.hash(data: data)
            return hash.compactMap { String(format: "%02x", $0) }.joined(separator: ":")
        }
        return ""
    }

   
    private func certificateIssuer(_ certificate: SecCertificate) -> String {
        guard let certificateData = SecCertificateCopyData(certificate) as Data? else {
            return "Unknown Issuer"
        }
    
        guard let subject = SecCertificateCopyNormalizedSubjectSequence(certificate) as Data?,
              let issuer = SecCertificateCopyNormalizedIssuerSequence(certificate) as Data? else {
            return "Unknown Issuer"
        }
    
        let subjectString = subject.map { String(format: "%02X", $0) }.joined()
        let issuerString = issuer.map { String(format: "%02X", $0) }.joined()
    
        let readableStrings = extractReadableStrings(from: issuer)
        return readableStrings.joined(separator: ", ")
    }

    private func extractReadableStrings(from data: Data) -> [String] {
    var strings: [String] = []
    var currentString = ""
    
    for byte in data {
        if (32...126).contains(byte) {
            currentString.append(Character(UnicodeScalar(byte)))
        } else if !currentString.isEmpty {
            strings.append(currentString)
            currentString = ""
        }
    }
    
        if !currentString.isEmpty {
            strings.append(currentString)
        }
    
        return strings.filter { $0.count > 1 }
    }
}