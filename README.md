# Capacitor SSL Pinning

Ionic Capacitor Plugin to perform SSL certificate checking/pinning.  
This plugin validates the SHA256 fingerprint of a server's SSL certificate and compares it to a provided fingerprint.  
On Android, the plugin also provides additional certificate information.

This software implements SSL (Secure Sockets Layer) pinning as a security measure. It is provided under the MIT License. The SSL pinning code included in this project is provided "as is" without any warranty, express or implied.

## Important Notes

- **Security Measure**: SSL pinning enhances security by validating server certificates against known, trusted certificates or public keys. However, it does not guarantee absolute security.
- **Implementation Responsibility**: The effectiveness of SSL pinning depends on correct implementation and maintenance. Users are responsible for proper setup and regular updates to pinned certificates or keys.
- **Maintenance Requirements**: SSL pinning requires ongoing maintenance. Failure to update pinned certificates before they expire can result in app failure or loss of connectivity.
- **No Warranty**: The authors and copyright holders of this software provide it without warranty and do not guarantee it will meet your requirements or operate error-free.
- **Limitation of Liability**: The authors and copyright holders are not liable for claims, damages, or liabilities arising from the use or performance of this software.
- **Testing and Verification**: Users must thoroughly test SSL pinning in their specific environment.
- **Compliance**: Ensure your use of SSL pinning complies with all applicable laws, regulations, and platform policies.
- **No Guarantee Against All Attacks**: While SSL pinning can mitigate certain attacks, it cannot protect against all security threats.
- **Potential Impact on Functionality**: SSL pinning may interfere with development tools, debugging, or network inspection. Ensure you have a way to disable pinning during development and testing.

By using this SSL pinning code, you acknowledge reading this disclaimer and agreeing to its terms. Seek professional security advice for critical implementations and follow best practices for mobile and network security.

## Notes

- **On Fingerprints**: Fingerprints can be expressed in different formats (e.g., with or without colons). This plugin normalizes fingerprints to lowercase and removes colons for comparison. While uppercase is preferred, colons are optional. Use the format recommended in the documentation.
- **On Subject**: The "subject" represents the hostname of the certificate. On Android, the plugin returns the certificate hostname; on iOS, it returns the provided URL.
- **On Issuer**: The "issuer" represents the certificate authority. Formats differ between iOS and Android, and results may not match exactly.

[![HitCount](https://hits.dwyl.com/mchl18/capacitor-ssl-pinning.svg)](https://hits.dwyl.com/mchl18/capacitor-ssl-pinning)  
[![npm](https://nodei.co/npm/capacitor-ssl-pinning.png?downloads=true&downloadRank=true&stars=true)](https://www.npmjs.com/package/capacitor-ssl-pinning)

## Installation

Using npm:

```bash
npm install capacitor-ssl-pinning
```

Using yarn:

```bash
yarn add capacitor-ssl-pinning
```

Sync native files:

```bash
npx cap sync
```

## Obtain Fingerprint

### Via Website

1. Obtain the certificate using a browser. See: [How to get a certificate](https://superuser.com/questions/1833063/how-to-get-a-certificate-out-of-chrome-now-the-padlock-has-gone).
2. Open the certificate in a text editor and copy the public key to the clipboard.
3. Visit [SAML Tool](https://www.samltool.com/fingerprint.php).
4. Paste the public key into the text area.
5. Select `SHA-256` as the algorithm.
6. Copy the fingerprint (with colons).

### Via Command Line

1. Obtain the certificate using a browser. See: [How to get a certificate](https://superuser.com/questions/1833063/how-to-get-a-certificate-out-of-chrome-now-the-padlock-has-gone).
2. Generate the fingerprint:

```bash
openssl x509 -noout -fingerprint -sha256 -inform pem -in /path/to/cert.pem
```

### Via Built-in CLI Tool

This package includes a CLI tool that can fetch and display SSL certificate information for any domain.

Install globally:
```bash
npm install -g capacitor-ssl-pinning
# or
yarn global add capacitor-ssl-pinning
```

Or use it in your project:
```bash
npm install capacitor-ssl-pinning
# or
yarn add capacitor-ssl-pinning
```

Usage:
```bash
# Using npx command
npx ssl-fingerprint example.com

# Multiple domains
npx ssl-fingerprint example.com example.org example.net

# Or if installed globally
ssl-fingerprint example.com

# Save output to a file
ssl-fingerprint example.com --out certs.json

# Save multiple domains to file
ssl-fingerprint example.com example.org example.net --out certs.json

# Save just the fingerprints in TypeScript format
ssl-fingerprint example.com --out fingerprints.ts --format fingerprints
```

You can also add it as a script in your package.json:
```json
{
  "scripts": {
    "generate-fingerprint": "ssl-fingerprint example.com",
    "generate-all-fingerprints": "ssl-fingerprint example.com example.org example.net"
  }
}
```

Then run it with:
```bash
npm run generate-fingerprint
# or for multiple domains
npm run generate-all-fingerprints
```

The tool will display:
- Domain name
- Certificate subject
- Certificate issuer
- Valid from date
- Valid to date
- SHA256 fingerprint

Example output:
```json
[
  {
    "domain": "example.com",
    "subject": {
      "C": "US",
      "ST": "California",
      "L": "Los Angeles",
      "O": "Internet Corporation for Assigned Names and Numbers",
      "CN": "www.example.org"
    },
    "issuer": {
      "C": "US",
      "O": "DigiCert Inc",
      "CN": "DigiCert Global G2 TLS RSA SHA256 2020 CA1"
    },
    "validFrom": "Jan 30 00:00:00 2024 GMT",
    "validTo": "Mar  1 23:59:59 2025 GMT",
    "fingerprint": "EF:BA:26:D8:C1:CE:37:79:AC:77:63:0A:90:F8:21:63:A3:D6:89:2E:D6:AF:EE:40:86:72:CF:19:EB:A7:A3:62"
  }
]
```

When using `--format fingerprints`, the output will be in TypeScript format:
```typescript
export const fingerprints = [
  "EF:BA:26:D8:C1:CE:37:79:AC:77:63:0A:90:F8:21:63:A3:D6:89:2E:D6:AF:EE:40:86:72:CF:19:EB:A7:A3:62"
];
```

## API

### `checkCertificate`

```typescript
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
checkCertificate(options: SSLCertificateCheckerOptions) => Promise<SSLCertificateCheckerResult>
```

#### SSLCertificateCheckerResult

```typescript
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
```

#### SSLCertificateCheckerOptions

```typescript
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
```

## Usage

Example:

```typescript
SSLCertificateChecker.checkCertificate({
  url: 'https://example.com', // Replace with your server URL
  fingerprint:
    '50:4B:A1:B5:48:96:71:F3:9F:87:7E:0A:09:FD:3E:1B:C0:4F:AA:9F:FC:83:3E:A9:3A:00:78:88:F8:BA:60:26', // Replace with your server fingerprint
}).then(res => {
  console.log(res.fingerprintMatched);
});
```

## Example Interceptor

```typescript
// src/app/interceptors/ssl-pinning.interceptor.ts

import { Injectable } from '@angular/core';
import {
  HttpRequest,
  HttpHandler,
  HttpEvent,
  HttpInterceptor,
} from '@angular/common/http';
import { from, Observable, switchMap, throwError } from 'rxjs';
import { SSLCertificateChecker } from 'capacitor-ssl-pinning';
import { environment } from 'src/environments/environment';
import { Capacitor } from '@capacitor/core';

@Injectable()
export class SslPinningInterceptor implements HttpInterceptor {
  intercept(
    request: HttpRequest<any>,
    next: HttpHandler
  ): Observable<HttpEvent<any>> {
    // Only available on Android/iOS
    if (Capacitor.getPlatform() === 'web') {
      return next.handle(request);
    }
    return from(
      SSLCertificateChecker.checkCertificate({
        url: environment.baseUrlBase,
        fingerprint: environment.fingerprint,
      })
    ).pipe(
      switchMap((res) => {
        if (res.fingerprintMatched) {
          return next.handle(request);
        }
        return throwError(() => new Error('Fingerprint not matched'));
      })
    );
  }
}
```