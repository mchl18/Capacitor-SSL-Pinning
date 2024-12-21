export type SSLCertificateCheckerOptions = {
  /**
   * The URL of the server whose SSL certificate needs to be checked.
   * Example: "https://example.com"
   */
  url: string;

  /**
   * The expected fingerprint of the SSL certificate to validate against.
   * This is typically a hash string such as SHA-256.
   */
  fingerprint: string;
};

export type SSLCertificateCheckerResult = {
  /**
   * The subject of the certificate, representing the entity the certificate is issued to.
   * @platform Android
   * Example: "CN=example.com, O=Example Corp, C=US"
   */
  subject?: string;

  /**
   * The issuer of the certificate, indicating the certificate authority that issued it.
   * Results may vary slightly between iOS and Android platforms.
   * Example: "CN=Example CA, O=Example Corp, C=US"
   */
  issuer?: string;

  /**
   * The start date from which the certificate is valid.
   * Format: ISO 8601 string or platform-specific date representation.
   * @platform Android
   * Example: "2023-01-01T00:00:00Z"
   */
  validFrom?: string;

  /**
   * The end date until which the certificate is valid.
   * Format: ISO 8601 string or platform-specific date representation.
   * @platform Android
   * Example: "2024-01-01T00:00:00Z"
   */
  validTo?: string;

  /**
   * The fingerprint that is expected to match the certificate's actual fingerprint.
   * This is typically provided in the SSLCertificateCheckerOptions.
   */
  expectedFingerprint?: string;

  /**
   * The actual fingerprint of the SSL certificate retrieved from the server.
   * Example: "50:4B:A1:B5:48:96:71:F3:9F:87:7E:0A:09:FD:3E:1B:C0:4F:AA:9F:FC:83:3E:A9:3A:00:78:88:F8:BA:60:26"
   */
  actualFingerprint?: string;

  /**
   * Indicates whether the actual fingerprint matches the expected fingerprint.
   * `true` if they match, `false` otherwise.
   */
  fingerprintMatched?: boolean;

  /**
   * A descriptive error message if an issue occurred during the SSL certificate check.
   * Example: "Unable to retrieve certificate from the server."
   */
  error?: string;
};
