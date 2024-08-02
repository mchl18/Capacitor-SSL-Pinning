export type SSLCertificateCheckerOptions = {
  url: string;
  fingerprint: string;
};

export type SSLCertificateCheckerResult = {
  /**
   * The subject of the certificate
   * @platform Android
   */
  subject?: string;
  /**
   * The issuer of the certificate
   * @platform Android
   */
  issuer?: string;
  /**
   * The valid from date of the certificate
   * @platform Android
   */
  validFrom?: string;
  /**
   * The valid to date of the certificate
   * @platform Android
   */
  validTo?: string;
  /**
   * The fingerprint of the certificate
   * @platform Android
   */
  fingerprint?: string;
  /**
   * Whether the fingerprint matches the expected fingerprint
   */
  fingerprintMatched?: boolean;
  /**
   * The error that occurred while checking the certificate
   */
  error?: string;
};
