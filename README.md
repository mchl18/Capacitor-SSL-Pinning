# Capacitor SSL Pinning

Ionic Capacitor Plugin to perform SSL checking/pinning.
Will soon be published to npm.

## Install

```bash
npm install capacitor-ssl-pinning
npx cap sync
```

## Obtain fingerprint

### via website

- go to https://www.samltool.com/fingerprint.php
- enter domain name
- copy fingerprint (with colons)

### via command line

- get cert via browser: https://superuser.com/questions/1833063/how-to-get-a-certificate-out-of-chrome-now-the-padlock-has-gone
- get fingerprint: `openssl x509 -noout -fingerprint -sha256 -inform pem -in /path/to/cert.pem`

## API

<docgen-index>

- [`checkCertificate(...)`](#checkcertificate)

</docgen-index>

<docgen-api>
<!--Update the source file JSDoc comments and rerun docgen to update the docs below-->

### checkCertificate(...)

```typescript

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


checkCertificate(options: SSLCertificateCheckerOptions) => Promise<SSLCertificateCheckerResult>
```

| Param         | Type                                      |
| ------------- | ----------------------------------------- |
| **`options`** | <code>SSLCertificateCheckerOptions</code> |

**Returns:** <code>Promise&lt;SSLCertificateCheckerResult&gt;</code>

---

</docgen-api>

## Usage

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
