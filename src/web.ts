import { WebPlugin } from '@capacitor/core';

import type { SSLCertificateCheckerPlugin } from './definitions';

export class SSLCertificateCheckerWeb
  extends WebPlugin
  implements SSLCertificateCheckerPlugin
{
  // @ts-ignore
  async checkCertificate(options: { url: string }): Promise<any> {
    console.warn('Certificate checking is not available in the browser.');
    return { error: 'not available in the browser' };
  }
}
