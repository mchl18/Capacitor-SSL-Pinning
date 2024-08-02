import { registerPlugin } from '@capacitor/core';

import type { SSLCertificateCheckerPlugin } from './definitions';

const SSLCertificateChecker = registerPlugin<SSLCertificateCheckerPlugin>(
  'SSLCertificateChecker',
  {
    web: () => import('./web').then(m => new m.SSLCertificateCheckerWeb()),
  },
);

export * from './definitions';
export * from './types';
export { SSLCertificateChecker };
