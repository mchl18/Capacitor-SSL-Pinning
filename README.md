# Capacitor SSL Pinning

Ionic Capacitor Plugin to perform SSL checking/pinning.
Checks the SSL certificate SHA256 fingerprint of a server and compares it to a provided fingerprint.
On Android, the plugin also returns some additional information about the certificate.

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
