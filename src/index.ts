/**
 * Import the `registerPlugin` method from the Capacitor core library.
 * This method is used to register a custom plugin.
 */
import { registerPlugin } from '@capacitor/core';

/**
 * Import the `SSLCertificateCheckerPlugin` type definition.
 * This defines the shape of the plugin implementation, ensuring type safety.
 */
import type { SSLCertificateCheckerPlugin } from './definitions';

/**
 * Register the `SSLCertificateChecker` plugin.
 * - The first argument is the plugin's name as used in native platforms.
 * - The second argument is an optional configuration object, where a web implementation is dynamically imported.
 */
const SSLCertificateChecker = registerPlugin<SSLCertificateCheckerPlugin>(
  'SSLCertificateChecker',
  {
    /**
     * Provide a web implementation of the `SSLCertificateChecker` plugin.
     * The implementation is dynamically imported to optimize performance.
     * @returns A promise that resolves to an instance of `SSLCertificateCheckerWeb`.
     */
    web: () => import('./web').then(m => new m.SSLCertificateCheckerWeb()),
  },
);

/**
 * Re-export everything from the `definitions` file.
 * This allows consumers of the plugin to access the type definitions directly.
 */
export * from './definitions';

/**
 * Re-export everything from the `types` file.
 * This allows consumers to use additional related types.
 */
export * from './types';

/**
 * Export the `SSLCertificateChecker` plugin as the default export.
 * This is the main entry point for interacting with the plugin in client code.
 */
export { SSLCertificateChecker };
