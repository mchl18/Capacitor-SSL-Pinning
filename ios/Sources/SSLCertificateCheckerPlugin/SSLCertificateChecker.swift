import Foundation
import CryptoKit

class SSLCertificateChecker {
    func checkCertificate(_ urlString: String, expectedFingerprint: String) -> Bool {
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return false
        }

        let semaphore = DispatchSemaphore(value: 0)
        var result = false

        let session = URLSession(configuration: .ephemeral, delegate: CertificateCheckDelegate(expectedFingerprint: expectedFingerprint) { isValid in
            result = isValid
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
    private let completion: (Bool) -> Void

    // init is the initializer for the class
    init(expectedFingerprint: String, completion: @escaping (Bool) -> Void) {
        self.expectedFingerprint = expectedFingerprint
        self.completion = completion
    }

    // urlSession is the method that is called when a URLSession receives a challenge
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        guard let serverTrust = challenge.protectionSpace.serverTrust,
              let certificate = SecTrustGetCertificateAtIndex(serverTrust, 0) else {
            completion(false)
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        let fingerprint = certificateFingerprint(certificate)
        print("Fingerprint: \(fingerprint)")
        print("Expected fingerprint: \(expectedFingerprint)")
        let isValid = fingerprint.lowercased() == expectedFingerprint.lowercased()

        completion(isValid)

        if isValid {
            completionHandler(.useCredential, URLCredential(trust: serverTrust))
        } else {
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
    }

    // certificateFingerprint is the method that gets the fingerprint of the certificate
    private func certificateFingerprint(_ certificate: SecCertificate) -> String {
        if let data = SecCertificateCopyData(certificate) as Data? {
            let hash = SHA256.hash(data: data)
            return hash.compactMap { String(format: "%02x", $0) }.joined(separator: ":")
        }
        return ""
    }
}