// vitest.config.ts

import { defineConfig, loadEnv } from 'vite';
import react from '@vitejs/plugin-react';
import path from 'path';

export default defineConfig(({ mode }) => {
  // Load env variables for testing (e.g., Redis credentials)
  process.env = { ...process.env, ...loadEnv(mode, process.cwd()) };

  return {
    plugins: [react()],
    test: {
      globals: true,
      environment: 'jsdom',
      testTimeout: 15000,
    },
    resolve: {
      alias: {
        '@': path.resolve(__dirname, './src'),
        'next/server': path.resolve(__dirname, './tests/mocks/next/server.ts'),
        'next/cache': path.resolve(__dirname, './tests/mocks/next/cache.ts'),
      },
    },
  };
});
