import Foundation
import Capacitor
import CryptoKit
import Security

/**
 * @file SSLCertificateChecker.swift
 * This file implements the core functionality for SSL certificate validation.
 * It provides a method to verify the fingerprint of an SSL certificate for a given URL.
 * The primary class, `SSLCertificateChecker`, performs the validation using a custom URL session delegate.
 */

/**
 * The `SSLCertificateChecker` class provides a method to check the SSL certificate of a given URL
 * against an expected fingerprint. It handles the asynchronous operation of certificate validation
 * and returns the result as a dictionary.
 */
class SSLCertificateChecker {
    /**
     * Validates the SSL certificate of a given URL against an expected fingerprint.
     *
     * - Parameters:
     *   - urlString: The URL of the server whose SSL certificate needs to be validated.
     *   - expectedFingerprint: The expected SHA-256 fingerprint of the SSL certificate.
     * - Returns: A dictionary containing the validation result:
     *   - `expectedFingerprint`: The expected fingerprint provided for validation.
     *   - `actualFingerprint`: The actual fingerprint of the certificate obtained from the server.
     *   - `fingerprintMatched`: A Boolean indicating whether the fingerprints matched.
     *   - `subject`: The subject of the certificate (derived from the URL).
     *   - `issuer`: The issuer of the certificate.
     *   - `error`: An error message, if the validation fails.
     */
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

        // Create a custom session with the CertificateCheckDelegate.
        let session = URLSession(configuration: .ephemeral, delegate: CertificateCheckDelegate(expectedFingerprint: expectedFingerprint) { isValid, actualFingerprint, issuer in
            result = [
                "expectedFingerprint": expectedFingerprint.uppercased(),
                "actualFingerprint": actualFingerprint.uppercased(),
                "fingerprintMatched": isValid,
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

/**
 * A custom URL session delegate that handles SSL certificate validation.
 * It validates the certificate fingerprint against an expected value.
 */
class CertificateCheckDelegate: NSObject, URLSessionDelegate {
    private let expectedFingerprint: String
    private let completion: (Bool, String, String) -> Void

    /**
     * Initializes the delegate with the expected fingerprint and a completion handler.
     *
     * - Parameters:
     *   - expectedFingerprint: The expected SHA-256 fingerprint of the SSL certificate.
     *   - completion: A closure that returns the validation result, the actual fingerprint, and the issuer.
     */
    init(expectedFingerprint: String, completion: @escaping (Bool, String, String) -> Void) {
        self.expectedFingerprint = expectedFingerprint
        self.completion = completion
    }

    /**
     * Handles server trust challenges during the URL session's SSL handshake.
     *
     * - Parameters:
     *   - session: The URL session.
     *   - challenge: The server trust challenge.
     *   - completionHandler: A closure that indicates whether the challenge is accepted or rejected.
     */
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

    /**
     * Computes the SHA-256 fingerprint of a certificate.
     *
     * - Parameter certificate: The certificate to hash.
     * - Returns: The computed SHA-256 fingerprint as a string.
     */
    private func certificateFingerprint(_ certificate: SecCertificate) -> String {
        if let data = SecCertificateCopyData(certificate) as Data? {
            let hash = SHA256.hash(data: data)
            return hash.compactMap { String(format: "%02x", $0) }.joined(separator: ":")
        }
        return ""
    }

    /**
     * Extracts the issuer of a certificate.
     *
     * - Parameter certificate: The certificate to parse.
     * - Returns: A string representation of the issuer.
     */
    private func certificateIssuer(_ certificate: SecCertificate) -> String {
        guard let certificateData = SecCertificateCopyData(certificate) as Data? else {
            return "Unknown Issuer"
        }

        guard let subject = SecCertificateCopyNormalizedSubjectSequence(certificate) as Data?,
              let issuer = SecCertificateCopyNormalizedIssuerSequence(certificate) as Data? else {
            return "Unknown Issuer"
        }

        let readableStrings = extractReadableStrings(from: issuer)
        return readableStrings.joined(separator: ", ")
    }

    /**
     * Extracts readable strings from binary data.
     *
     * - Parameter data: The data to parse.
     * - Returns: An array of readable strings.
     */
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
