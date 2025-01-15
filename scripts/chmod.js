#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

const cliPath = path.join(__dirname, '..', 'dist', 'cli', 'fingerprint.js');

try {
  if (fs.existsSync(cliPath)) {
    // 0o755 = rwxr-xr-x
    fs.chmodSync(cliPath, 0o755);
    console.log('Successfully set permissions for CLI tool');
  }
} catch (error) {
  // Don't fail the install if we can't set permissions
  console.warn('Warning: Could not set CLI tool permissions:', error.message);
} 