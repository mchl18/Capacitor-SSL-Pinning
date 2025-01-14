/**
 * This module provides a web implementation of the SSLCertificateCheckerPlugin.
 * The functionality is limited in a web context due to the lack of SSL certificate inspection capabilities in browsers.
 *
 * The implementation adheres to the SSLCertificateCheckerPlugin interface but provides fallback behavior
 * because browsers do not allow direct inspection of SSL certificate details.
 */

import { CapacitorException, ExceptionCode, WebPlugin } from '@capacitor/core';

import type { SSLCertificateCheckerPlugin } from './definitions';
import type { SSLCertificateCheckerResult } from './types';

/**
 * Web implementation of the SSLCertificateCheckerPlugin interface.
 *
 * This class is intended to be used in a browser environment and handles scenarios where SSL certificate
 * checking is unsupported. It implements the methods defined by the SSLCertificateCheckerPlugin
 * interface but returns standardized error responses to indicate the lack of functionality in web contexts.
 */
export class SSLCertificateCheckerWeb
  extends WebPlugin
  implements SSLCertificateCheckerPlugin
{
  /**
   * Checks the SSL certificate for a given URL.
   *
   * This method is a placeholder for SSL certificate validation functionality.
   * In a web environment, this is not supported due to browser security restrictions.
   *
   * @param options - An object containing the `url` to check.
   *                  Example: `{ url: 'https://example.com' }`
   *
   * @returns A promise that rejects with a standardized error message indicating
   *          that the method is not implemented.
   *
   * @throws {CapacitorException} Always throws an exception with code `Unimplemented`.
   */
  async checkCertificate(options: { url: string }): Promise<SSLCertificateCheckerResult> {
    // Ensure the parameter is used to comply with linting rules.
    options;

    // Always throw an error since the feature is unavailable in this context.
    throw this.createUnimplementedError();
  }

  /**
   * Creates a standardized exception for unimplemented methods.
   *
   * This utility method centralizes the creation of exceptions for functionality that is not supported
   * on the current platform, ensuring consistency in error reporting.
   *
   * @returns {CapacitorException} An exception with the code `Unimplemented` and a descriptive message.
   */
  private createUnimplementedError(): CapacitorException {
    return new CapacitorException(
      'This plugin method is not implemented on this platform.',
      ExceptionCode.Unimplemented,
    );
  }
}
