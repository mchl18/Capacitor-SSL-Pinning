import { WebPlugin } from '@capacitor/core';

import type { SSLCertificateCheckerPlugin } from './definitions';
import type { SSLCertificateCheckerResult } from './types';

export class SSLCertificateCheckerWeb
  extends WebPlugin
  implements SSLCertificateCheckerPlugin
{
  async checkCertificate(options: {
    url: string;
  }): Promise<SSLCertificateCheckerResult> {
    // statement is required to avoid linting error, better than @ts-ignore
    options;
    console.warn('Certificate checking is not available in the browser.');
    return { error: 'not available in the browser' };
  }
}
