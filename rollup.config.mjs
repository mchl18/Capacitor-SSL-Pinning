export default [
  {
    input: 'dist/esm/index.js',
    output: [
      {
        file: 'dist/plugin.js',
        format: 'iife',
        name: 'capacitorSSLCertificateChecker',
        globals: {
          '@capacitor/core': 'capacitorExports',
        },
        sourcemap: true,
        inlineDynamicImports: true,
      },
      {
        file: 'dist/plugin.cjs.js',
        format: 'cjs',
        sourcemap: true,
        inlineDynamicImports: true,
      },
    ],
    external: ['@capacitor/core'],
  },
  {
    input: 'dist/esm/cli/fingerprint.js',
    output: {
      file: 'dist/cli/fingerprint.js',
      format: 'commonjs',
      banner: '#!/usr/bin/env node',
    },
    external: ['https', 'crypto', 'fs/promises', 'yargs', 'yargs/helpers'],
  }
];
