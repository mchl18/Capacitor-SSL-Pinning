# Capacitor SSL Pinning

Ionic Capacitor Plugin to perform SSL checking/pinning.
Checks the SSL certificate SHA256 fingerprint of a server and compares it to a provided fingerprint.
On Android, the plugin also returns some additional information about the certificate.

This software implements SSL (Secure Sockets Layer) pinning as a security measure. It is provided under the MIT License. The SSL pinning code included in this project is provided "as is" without warranty of any kind, express or implied.
Important Notes:

Security Measure: SSL pinning is designed to enhance security by validating server certificates against known, trusted certificates or public keys. However, it is not a guarantee of absolute security.
Implementation Responsibility: The effectiveness of SSL pinning depends on correct implementation and maintenance. Users of this code are responsible for ensuring proper implementation and regular updates to the pinned certificates or keys.
Maintenance Requirements: SSL pinning requires ongoing maintenance. Failure to update pinned certificates before they expire can result in app failure or inability to connect to servers.
No Warranty: The authors and copyright holders of this software do not warrant that the SSL pinning code will meet your requirements, operate without interruption, or be error-free.
Limitation of Liability: In no event shall the authors or copyright holders be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.
Testing and Verification: Users of this code are responsible for thoroughly testing the SSL pinning implementation in their specific environment and use case.
Compliance: Ensure that your use of SSL pinning complies with all applicable laws, regulations, and platform policies.
No Guarantee Against All Attacks: While SSL pinning can protect against certain types of attacks, it does not guarantee protection against all possible security threats or vulnerabilities.
Potential Impact on Functionality: Be aware that SSL pinning may interfere with certain development tools, debugging processes, or network inspection tools. Ensure you have a way to disable pinning for development and testing purposes.

By using this SSL pinning code, you acknowledge that you have read this disclaimer and agree to its terms. It is recommended to seek the advice of security professionals for critical implementations and to stay informed about best practices in mobile and network security.

Note: 
- On Fingerprints: There are different ways of expressing the fingerprint, some may use colons and others may not. This plugin normalizes the fingerprint to lowercase and removes colons for comparison. While it expects uppercase, it should not make a difference if you use colons or not. However it is recommended to use the format from the docs.
- On Subject: The subject is the hostname of the certificate. On Android, the plugin returns the hostname of the certificate. On iOS, the plugin returns URL it was given.
- On Issuer: The issuer is the issuer of the certificate. There are different formats on iOS and Android, their results are not guaranteed to be the same.

[![HitCount](https://hits.dwyl.com/mchl18/capacitor-ssl-pinning.svg)](https://hits.dwyl.com/mchl18/capacitor-ssl-pinning)


[![https://nodei.co/npm/capacitor-ssl-pinning.png?downloads=true&downloadRank=true&stars=true](https://nodei.co/npm/capacitor-ssl-pinning.png?downloads=true&downloadRank=true&stars=true)](https://www.npmjs.com/package/capacitor-ssl-pinning)

## Install

```bash
npm install capacitor-ssl-pinning
npx cap sync
```

## Obtain fingerprint

### via website

- get cert via browser: https://superuser.com/questions/1833063/how-to-get-a-certificate-out-of-chrome-now-the-padlock-has-gone
- open cert in text editor, copy public key to clipboard
- go to https://www.samltool.com/fingerprint.php
- paste public key into textarea
- select SHA-256 as Algorithm
- copy fingerprint (with colons)

### via command line

- get cert via browser: https://superuser.com/questions/1833063/how-to-get-a-certificate-out-of-chrome-now-the-padlock-has-gone
- get fingerprint: `openssl x509 -noout -fingerprint -sha256 -inform pem -in /path/to/cert.pem`



## API

checkCertificate(...)
```
checkCertificate(options: SSLCertificateCheckerOptions) => Promise<SSLCertificateCheckerResult>
```



#### SSLCertificateCheckerResult

```typescript
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

```
#### SSLCertificateCheckerOptions

```typescript
export type SSLCertificateCheckerOptions = {
  url: string;
  fingerprint: string;
};
```

## Usage

Note:

```typescript
SSLCertificateChecker.checkCertificate({
  url: 'https://example.com', // replace with your server url
  fingerprint:
    '50:4B:A1:B5:48:96:71:F3:9F:87:7E:0A:09:FD:3E:1B:C0:4F:AA:9F:FC:83:3E:A9:3A:00:78:88:F8:BA:60:26', // replace with your server fingerprint
}).then(res => {
  console.log(res.fingerprintMatched);
});
```

## Example Interceptor:

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
    // only available on android/ios
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
