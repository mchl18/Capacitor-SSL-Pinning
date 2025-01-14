import { SSLCertificateCheckerOptions, SSLCertificateCheckerResult } from './types';

/**
 * Interface defining the structure of an SSL Certificate Checker Plugin.
 *
 * Implementations of this interface should provide the logic for checking
 * the status and details of an SSL certificate based on the provided options.
 */
export interface SSLCertificateCheckerPlugin {
  /**
   * Checks the SSL certificate for a given domain or IP address.
   *
   * @param options - Configuration options that determine the behavior of the SSL check.
   * These options may include properties such as the target domain, port,
   * and other settings required for certificate validation.
   *
   * @returns A promise that resolves to an SSLCertificateCheckerResult object,
   * which contains information about the certificate, including its validity,
   * expiration date, and potential issues.
   */
  checkCertificate(options: SSLCertificateCheckerOptions): Promise<SSLCertificateCheckerResult>;
}
