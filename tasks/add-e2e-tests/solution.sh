#!/bin/bash

# Install Playwright
npm init playwright@latest -- --quiet --browser=chromium

# Create Playwright config
cat > playwright.config.ts << EOL
import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './e2e',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  reporter: 'html',
  use: {
    baseURL: 'http://localhost:3000',
    trace: 'on-first-retry',
  },
  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
    },
  ],
  webServer: {
    command: 'npm run dev',
    url: 'http://localhost:3000',
    reuseExistingServer: !process.env.CI,
  },
});
EOL

# Create the E2E test file
mkdir -p e2e
cat > e2e/auth.spec.ts << EOL
import { test, expect } from '@playwright/test';

test('should allow a user to register, login, and see the dashboard', async ({ page }) => {
  const email = \`user-\${Date.now()}@example.com\`;
  const password = 'password123';

  // Register
  await page.goto('/register');
  await page.fill('input[name="email"]', email);
  await page.fill('input[name="password"]', password);
  await page.click('button[type="submit"]');
  await expect(page).toHaveURL('/login');

  // Login
  await page.goto('/login');
  await page.fill('input[name="email"]', email);
  await page.fill('input[name="password"]', password);
  await page.click('button[type="submit"]');
  await expect(page).toHaveURL('/dashboard');

  // Dashboard
  await expect(page.locator('h1')).toContainText(\`Welcome, \${email}\`);
});
EOL
