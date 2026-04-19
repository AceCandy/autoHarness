# Playwright Configuration Guide

> Setup and configuration for browser testing with Playwright.

---

## Installation

### Quick Install

```bash
# Initialize Playwright (recommended)
npm init playwright@latest

# This will:
# 1. Install @playwright/test
# 2. Install browsers (chromium, firefox, webkit)
# 3. Create playwright.config.js
# 4. Create example tests
```

---

### Manual Install

```bash
# Install Playwright
npm install -D @playwright/test

# Install browsers
npx playwright install

# Install system dependencies (Linux only)
npx playwright install-deps
```

---

## Configuration File

### Basic Configuration

```javascript
// playwright.config.js
import { defineConfig } from '@playwright/test';

export default defineConfig({
  testDir: './tests',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: 'html',
  use: {
    baseURL: 'http://localhost:3000',
    trace: 'on-first-retry',
  },
});
```

---

### Advanced Configuration

```javascript
// playwright.config.js (advanced)
import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  // Test directory
  testDir: './tests',
  
  // Parallel execution
  fullyParallel: true,
  
  // Fail build on .only in CI
  forbidOnly: !!process.env.CI,
  
  // Retries in CI
  retries: process.env.CI ? 2 : 0,
  
  // Workers (parallelism)
  workers: process.env.CI ? 1 : undefined,
  
  // Reporter
  reporter: [
    ['html'],
    ['json', { outputFile: 'test-results.json' }],
    ['list'],
  ],
  
  // Shared settings
  use: {
    // Base URL
    baseURL: process.env.BASE_URL || 'http://localhost:3000',
    
    // Browser context
    browserName: 'chromium',
    headless: true,
    
    // Viewport
    viewport: { width: 1280, height: 720 },
    
    // Ignore HTTPS errors (for local testing)
    ignoreHTTPSErrors: true,
    
    // Screenshot on failure
    screenshot: 'only-on-failure',
    
    // Video on failure
    video: 'retain-on-failure',
    
    // Trace on first retry
    trace: 'on-first-retry',
    
    // Action timeout
    actionTimeout: 10000,
    
    // Navigation timeout
    navigationTimeout: 30000,
  },
  
  // Projects (browsers)
  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
    },
    {
      name: 'firefox',
      use: { ...devices['Desktop Firefox'] },
    },
    {
      name: 'webkit',
      use: { ...devices['Desktop Safari'] },
    },
    {
      name: 'Mobile Chrome',
      use: { ...devices['Pixel 5'] },
    },
    {
      name: 'Mobile Safari',
      use: { ...devices['iPhone 12'] },
    },
    {
      name: 'iPad',
      use: { ...devices['iPad Pro'] },
    },
  ],
  
  // Web server (for local testing)
  webServer: {
    command: 'npm run dev',
    url: 'http://localhost:3000',
    reuseExistingServer: !process.env.CI,
    timeout: 120000,
  },
});
```

---

## Project Configuration

### Desktop Browsers

```javascript
projects: [
  {
    name: 'chromium',
    use: {
      browserName: 'chromium',
      viewport: { width: 1280, height: 720 },
    },
  },
  {
    name: 'firefox',
    use: {
      browserName: 'firefox',
      viewport: { width: 1280, height: 720 },
    },
  },
  {
    name: 'webkit',
    use: {
      browserName: 'webkit', // Safari
      viewport: { width: 1280, height: 720 },
    },
  },
];
```

---

### Mobile Browsers

```javascript
projects: [
  {
    name: 'iphone-12',
    use: {
      browserName: 'webkit',
      ...devices['iPhone 12'], // 390x844
    },
  },
  {
    name: 'iphone-se',
    use: {
      browserName: 'webkit',
      viewport: { width: 375, height: 667 },
    },
  },
  {
    name: 'pixel-5',
    use: {
      browserName: 'chromium',
      ...devices['Pixel 5'], // 393x851
    },
  },
];
```

---

### Tablet Browsers

```javascript
projects: [
  {
    name: 'ipad-pro',
    use: {
      browserName: 'webkit',
      ...devices['iPad Pro'], // 1024x1366
    },
  },
  {
    name: 'ipad',
    use: {
      browserName: 'webkit',
      viewport: { width: 768, height: 1024 },
    },
  },
];
```

---

## Viewport Sizes

### Common Desktop Sizes

| Name | Width | Height |
|------|-------|--------|
| Desktop HD | 1920 | 1080 |
| Desktop SD | 1280 | 720 |
| Desktop Mini | 1024 | 768 |
| Laptop | 1366 | 768 |

---

### Common Mobile Sizes

| Device | Width | Height |
|--------|-------|--------|
| iPhone SE | 375 | 667 |
| iPhone 12 | 390 | 844 |
| iPhone 14 Pro | 393 | 852 |
| Pixel 5 | 393 | 851 |
| Galaxy S21 | 360 | 800 |

---

### Common Tablet Sizes

| Device | Width | Height |
|--------|-------|--------|
| iPad Mini | 768 | 1024 |
| iPad | 810 | 1080 |
| iPad Pro | 1024 | 1366 |

---

## Web Server Configuration

### Local Development Server

```javascript
webServer: {
  command: 'npm run dev',
  url: 'http://localhost:3000',
  reuseExistingServer: !process.env.CI,
  timeout: 120000,
};
```

---

### Multiple Servers

```javascript
webServer: [
  {
    command: 'npm run backend',
    url: 'http://localhost:8080',
    reuseExistingServer: !process.env.CI,
  },
  {
    command: 'npm run frontend',
    url: 'http://localhost:3000',
    reuseExistingServer: !process.env.CI,
  },
];
```

---

## Reporter Configuration

### HTML Reporter

```javascript
reporter: 'html';

// View report
npx playwright show-report
```

---

### JSON Reporter

```javascript
reporter: [['json', { outputFile: 'test-results.json' }]];
```

---

### Multiple Reporters

```javascript
reporter: [
  ['list'], // Console output
  ['html'], // HTML report
  ['json', { outputFile: 'test-results.json' }], // JSON report
  ['junit', { outputFile: 'junit-results.xml' }], // JUnit XML
];
```

---

## Environment Variables

### Base URL

```bash
# Set base URL
BASE_URL=https://your-app.com npx playwright test

# Or in playwright.config.js
use: {
  baseURL: process.env.BASE_URL || 'http://localhost:3000',
};
```

---

### CI Mode

```bash
# CI mode (more retries, single worker)
CI=true npx playwright test
```

---

### Headless Mode

```bash
# Headless (no browser window)
HEADLESS=true npx playwright test

# Headed (show browser window)
HEADLESS=false npx playwright test

# Or in playwright.config.js
use: {
  headless: process.env.HEADLESS !== 'false',
};
```

---

## Timeout Configuration

### Global Timeout

```javascript
export default defineConfig({
  timeout: 60000, // 60 seconds per test
});
```

---

### Action Timeout

```javascript
use: {
  actionTimeout: 10000, // 10 seconds for each action
};
```

---

### Navigation Timeout

```javascript
use: {
  navigationTimeout: 30000, // 30 seconds for page.goto()
};
```

---

### Expect Timeout

```javascript
use: {
  expect: {
    timeout: 5000, // 5 seconds for assertions
  },
};
```

---

## Screenshots and Videos

### Screenshot Configuration

```javascript
use: {
  // Off (no screenshots)
  screenshot: 'off',
  
  // On (always take screenshots)
  screenshot: 'on',
  
  // Only-on-failure (take screenshots on failure)
  screenshot: 'only-on-failure',
};
```

---

### Video Configuration

```javascript
use: {
  // Off (no videos)
  video: 'off',
  
  // On (always record videos)
  video: 'on',
  
  // Retain-on-failure (keep videos on failure)
  video: 'retain-on-failure',
  
  // On-first-retry (record video on first retry)
  video: 'on-first-retry',
};
```

---

### Trace Configuration

```javascript
use: {
  // Off (no traces)
  trace: 'off',
  
  // On (always record traces)
  trace: 'on',
  
  // Retain-on-failure (keep traces on failure)
  trace: 'retain-on-failure',
  
  // On-first-retry (record trace on first retry)
  trace: 'on-first-retry',
};
```

---

## Browser Launch Options

### Launch Options

```javascript
use: {
  launchOptions: {
    headless: true,
    slowMo: 100, // Slow down actions by 100ms
    devtools: false,
    args: [
      '--disable-web-security',
      '--disable-features=IsolateOrigins,site-per-process',
    ],
  },
};
```

---

### Context Options

```javascript
use: {
  contextOptions: {
    ignoreHTTPSErrors: true,
    acceptDownloads: true,
    offline: false,
    javaScriptEnabled: true,
    bypassCSP: true,
  },
};
```

---

## Authentication Setup

### Storage State (Login Once)

```javascript
// tests/auth.setup.js
import { test as setup } from '@playwright/test';

const authFile = 'playwright/.auth/user.json';

setup('authenticate', async ({ page }) => {
  await page.goto('http://localhost:3000/login');
  await page.fill('#username', 'testuser');
  await page.fill('#password', 'testpass');
  await page.click('#login-button');
  
  // Save authentication state
  await page.context().storageState({ path: authFile });
});
```

---

### Use Authentication State

```javascript
// playwright.config.js
projects: [
  {
    name: 'authenticated',
    use: {
      storageState: 'playwright/.auth/user.json',
    },
    dependencies: ['setup'],
  },
];

// In tests
import { test } from '@playwright/test';

test.use({ storageState: 'playwright/.auth/user.json' });

test('authenticated test', async ({ page }) => {
  // Already logged in
  await page.goto('http://localhost:3000/dashboard');
});
```

---

## Visual Regression Configuration

### Screenshot Comparison

```javascript
// In tests
await expect(page).toHaveScreenshot('homepage.png', {
  maxDiffPixels: 100,
  maxDiffPixelRatio: 0.01,
  threshold: 0.2,
});
```

---

### Update Screenshots

```bash
# Update all screenshots
npx playwright test --update-snapshots

# Update specific test
npx playwright test tests/homepage.spec.js --update-snapshots
```

---

## Accessibility Configuration

### Install axe-core

```bash
npm install -D @axe-core/playwright
```

---

### axe-core Configuration

```javascript
import AxeBuilder from '@axe-core/playwright';

const results = await new AxeBuilder({ page })
  .withTags(['wcag2a', 'wcag2aa', 'wcag21aa'])
  .disableRules(['color-contrast']) // Skip specific rules
  .include('.main-content') // Test specific element
  .exclude('.ads') // Exclude specific element
  .analyze();
```

---

## Performance Configuration

### Performance Metrics

```javascript
// Measure performance
const metrics = await page.evaluate(() => {
  return new Promise((resolve) => {
    new PerformanceObserver((list) => {
      const entries = list.getEntries();
      resolve({
        FCP: entries.find(e => e.name === 'first-contentful-paint')?.startTime,
        LCP: entries.find(e => e.name === 'largest-contentful-paint')?.startTime,
      });
    }).observe({ type: 'paint', buffered: true });
  });
});
```

---

### Lighthouse Integration

```bash
# Install Lighthouse
npm install -D lighthouse

# Run Lighthouse in Playwright
import lighthouse from 'lighthouse';

const result = await lighthouse(page.url(), {
  port: 9222,
  onlyCategories: ['performance', 'accessibility'],
});
```

---

## CI Configuration

### GitHub Actions

```yaml
name: Browser Tests

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - uses: actions/setup-node@v3
        with:
          node-version: 18
      
      - name: Install dependencies
        run: npm ci
      
      - name: Install Playwright browsers
        run: npx playwright install --with-deps
      
      - name: Run tests
        run: npx playwright test
      
      - name: Upload test results
        if: always()
        uses: actions/upload-artifact@v3
        with:
          name: playwright-report
          path: playwright-report/
```

---

### GitLab CI

```yaml
browser-tests:
  image: mcr.microsoft.com/playwright:v1.40.0-focal
  stage: test
  script:
    - npm ci
    - npx playwright test
  artifacts:
    when: always
    paths:
      - playwright-report/
```

---

## Docker Configuration

### Playwright Docker Image

```bash
# Use official Playwright Docker image
docker run -it --rm \
  -v $(pwd):/app \
  -w /app \
  mcr.microsoft.com/playwright:v1.40.0-focal \
  npx playwright test
```

---

### Dockerfile

```dockerfile
FROM mcr.microsoft.com/playwright:v1.40.0-focal

WORKDIR /app

COPY package*.json ./
RUN npm ci

COPY . .

RUN npx playwright install

CMD ["npx", "playwright", "test"]
```

---

## Debugging

### UI Mode (Interactive)

```bash
# Run in UI mode
npx playwright test --ui
```

---

### Debug Mode

```bash
# Debug specific test
npx playwright test --debug tests/homepage.spec.js
```

---

### Trace Viewer

```bash
# View trace
npx playwright show-trace trace.zip
```

---

### Codegen (Generate Tests)

```bash
# Generate tests by recording actions
npx playwright codegen https://your-app.com
```

---

## Best Practices

### 1. Use Page Object Model

```javascript
// pages/LoginPage.js
export class LoginPage {
  constructor(page) {
    this.page = page;
    this.usernameInput = page.locator('#username');
    this.passwordInput = page.locator('#password');
    this.loginButton = page.locator('#login-button');
  }
  
  async login(username, password) {
    await this.usernameInput.fill(username);
    await this.passwordInput.fill(password);
    await this.loginButton.click();
  }
}

// tests/login.spec.js
import { test } from '@playwright/test';
import { LoginPage } from '../pages/LoginPage';

test('login', async ({ page }) => {
  const loginPage = new LoginPage(page);
  await loginPage.login('testuser', 'testpass');
});
```

---

### 2. Use Test Fixtures

```javascript
// fixtures.js
import { test as base } from '@playwright/test';
import { LoginPage } from './pages/LoginPage';

export const test = base.extend({
  loginPage: async ({ page }, use) => {
    const loginPage = new LoginPage(page);
    await use(loginPage);
  },
});

// tests/login.spec.js
import { test } from '../fixtures';

test('login with fixture', async ({ loginPage }) => {
  await loginPage.login('testuser', 'testpass');
});
```

---

### 3. Use beforeEach for Setup

```javascript
test.describe('Dashboard', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('http://localhost:3000/login');
    await page.fill('#username', 'testuser');
    await page.fill('#password', 'testpass');
    await page.click('#login-button');
  });
  
  test('dashboard loads', async ({ page }) => {
    await expect(page).toHaveURL(/.*dashboard/);
  });
});
```

---

### 4. Use describe for Organization

```javascript
test.describe('User Management', () => {
  test.describe('Authentication', () => {
    test('login', async ({ page }) => { ... });
    test('logout', async ({ page }) => { ... });
  });
  
  test.describe('Profile', () => {
    test('view profile', async ({ page }) => { ... });
    test('update profile', async ({ page }) => { ... });
  });
});
```

---

## Notes

- Playwright auto-waits for elements (no need for explicit waits)
- Use `await expect()` for assertions (auto-retry)
- Run `npx playwright test --ui` for interactive debugging
- Use `npx playwright codegen` to generate tests by recording
- Visual regression requires baseline screenshots (`--update-snapshots`)
- Combine with unit tests for comprehensive coverage