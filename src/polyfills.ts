// Polyfills for React Native
// This file must be imported FIRST before any other imports

import { Buffer } from 'buffer';

// Make Buffer available globally
if (typeof global.Buffer === 'undefined') {
  global.Buffer = Buffer;
}

console.log('[Polyfills] Buffer polyfill loaded');
