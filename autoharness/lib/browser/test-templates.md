# Browser Test Templates

> Ready-to-use templates for common browser testing scenarios.

---

## Template Categories

1. Visual Regression Tests
2. Functional Tests
3. Accessibility Tests
4. Performance Tests
5. Responsive Tests
6. API Tests
7. E2E User Flows

---

## 1. Visual Regression Tests

### Homepage Visual Test

```javascript
// tests/visual/homepage.spec.js
import { test, expect } from '@playwright/test';

test.describe('Homepage Visual Tests', () => {
  test('homepage visual regression', async ({ page }) => {
    await page.goto('/');
    
    // Wait for page to be fully loaded
    await page.waitForLoadState('networkidle');
    
    // Take screenshot and compare with baseline
    await expect(page).toHaveScreenshot('homepage.png', {
      maxDiffPixels: 100,
      maxDiffPixelRatio: 0.01,
    });
  });
  
  test('homepage dark mode visual regression', async ({ page }) => {
    await page.goto('/');
    await page.click('#dark-mode-toggle');
    
    await expect(page).toHaveScreenshot('homepage-dark.png', {
      maxDiffPixels: 100,
    });
  });
});
```

---

### Component Visual Test

```javascript
// tests/visual/components.spec.js
import { test, expect } from '@playwright/test';

test.describe('Component Visual Tests', () => {
  test('button states visual test', async ({ page }) => {
    await page.goto('/components/buttons');
    
    // Test primary button
    const primaryButton = page.locator('.btn-primary');
    await expect(primaryButton).toHaveScreenshot('button-primary.png');
    
    // Test hovered state
    await primaryButton.hover();
    await expect(primaryButton).toHaveScreenshot('button-primary-hover.png');
    
    // Test disabled state
    await page.evaluate(() => {
      document.querySelector('.btn-primary').disabled = true;
    });
    await expect(primaryButton).toHaveScreenshot('button-primary-disabled.png');
  });
  
  test('card visual test', async ({ page }) => {
    await page.goto('/components/cards');
    
    const card = page.locator('.card').first();
    await expect(card).toHaveScreenshot('card-default.png');
    
    // Test card with image
    const cardWithImage = page.locator('.card.has-image').first();
    await expect(cardWithImage).toHaveScreenshot('card-with-image.png');
  });
});
```

---

### Mobile Visual Test

```javascript
// tests/visual/mobile.spec.js
import { test, expect } from '@playwright/test';

test.describe('Mobile Visual Tests', () => {
  test.use({ viewport: { width: 375, height: 667 } });
  
  test('mobile homepage visual', async ({ page }) => {
    await page.goto('/');
    await page.waitForLoadState('networkidle');
    
    await expect(page).toHaveScreenshot('homepage-mobile.png', {
      maxDiffPixels: 50,
    });
  });
  
  test('mobile navigation visual', async ({ page }) => {
    await page.goto('/');
    
    // Open mobile menu
    await page.click('#mobile-menu-toggle');
    
    const mobileMenu = page.locator('.mobile-menu');
    await expect(mobileMenu).toHaveScreenshot('mobile-menu.png');
  });
});
```

---

## 2. Functional Tests

### Login Flow Test

```javascript
// tests/e2e/login.spec.js
import { test, expect } from '@playwright/test';

test.describe('Login Flow', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/login');
  });
  
  test('successful login', async ({ page }) => {
    await page.fill('#username', 'testuser');
    await page.fill('#password', 'testpass');
    await page.click('#login-button');
    
    await expect(page).toHaveURL(/.*dashboard/);
    await expect(page.locator('.user-name')).toContainText('testuser');
  });
  
  test('failed login: wrong password', async ({ page }) => {
    await page.fill('#username', 'testuser');
    await page.fill('#password', 'wrongpass');
    await page.click('#login-button');
    
    await expect(page.locator('.error-message')).toBeVisible();
    await expect(page).toHaveURL(/.*login/);
  });
  
  test('validation: empty fields', async ({ page }) => {
    await page.click('#login-button');
    
    await expect(page.locator('#username-error')).toBeVisible();
    await expect(page.locator('#password-error')).toBeVisible();
  });
  
  test('remember me checkbox', async ({ page }) => {
    await page.fill('#username', 'testuser');
    await page.fill('#password', 'testpass');
    await page.check('#remember-me');
    await page.click('#login-button');
    
    // Verify cookie is set
    const cookies = await page.context().cookies();
    expect(cookies.find(c => c.name === 'remember_token')).toBeTruthy();
  });
  
  test('logout', async ({ page }) => {
    // Login first
    await page.fill('#username', 'testuser');
    await page.fill('#password', 'testpass');
    await page.click('#login-button');
    
    await expect(page).toHaveURL(/.*dashboard/);
    
    // Logout
    await page.click('#logout-button');
    
    await expect(page).toHaveURL(/.*login/);
    await expect(page.locator('.logout-message')).toBeVisible();
  });
});
```

---

### Search Flow Test

```javascript
// tests/e2e/search.spec.js
import { test, expect } from '@playwright/test';

test.describe('Search Flow', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/');
  });
  
  test('search with results', async ({ page }) => {
    await page.fill('#search-input', 'test query');
    await page.press('#search-input', 'Enter');
    
    await expect(page.locator('.search-results')).toBeVisible();
    await expect(page.locator('.search-result-item').first()).toBeVisible();
  });
  
  test('search with no results', async ({ page }) => {
    await page.fill('#search-input', 'nonexistent item xyz');
    await page.press('#search-input', 'Enter');
    
    await expect(page.locator('.no-results-message')).toBeVisible();
  });
  
  test('search filters', async ({ page }) => {
    await page.fill('#search-input', 'test query');
    await page.press('#search-input', 'Enter');
    
    // Apply filter
    await page.click('#filter-price-high');
    
    await expect(page.locator('.search-results')).toBeVisible();
    
    // Verify filter applied
    const results = await page.locator('.search-result-item').all();
    for (const result of results) {
      const price = await result.locator('.price').textContent();
      expect(parseFloat(price)).toBeGreaterThan(100);
    }
  });
  
  test('search autocomplete', async ({ page }) => {
    await page.fill('#search-input', 'te');
    
    await expect(page.locator('.search-autocomplete')).toBeVisible();
    await expect(page.locator('.autocomplete-item').first()).toContainText('test');
  });
});
```

---

### Form Submission Test

```javascript
// tests/e2e/form.spec.js
import { test, expect } from '@playwright/test';

test.describe('Form Submission', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/contact');
  });
  
  test('valid form submission', async ({ page }) => {
    await page.fill('#name', 'John Doe');
    await page.fill('#email', 'john@example.com');
    await page.fill('#message', 'Test message');
    await page.click('#submit-button');
    
    await expect(page.locator('.success-message')).toBeVisible();
  });
  
  test('validation: required fields', async ({ page }) => {
    await page.click('#submit-button');
    
    await expect(page.locator('#name-error')).toBeVisible();
    await expect(page.locator('#email-error')).toBeVisible();
    await expect(page.locator('#message-error')).toBeVisible();
  });
  
  test('validation: invalid email', async ({ page }) => {
    await page.fill('#name', 'John Doe');
    await page.fill('#email', 'invalid-email');
    await page.fill('#message', 'Test message');
    await page.click('#submit-button');
    
    await expect(page.locator('#email-error')).toContainText('valid email');
  });
  
  test('file upload', async ({ page }) => {
    await page.fill('#name', 'John Doe');
    await page.fill('#email', 'john@example.com');
    await page.fill('#message', 'Test message');
    
    // Upload file
    await page.setInputFiles('#attachment', 'test-files/sample.pdf');
    
    await page.click('#submit-button');
    
    await expect(page.locator('.success-message')).toBeVisible();
  });
});
```

---

## 3. Accessibility Tests

### WCAG 2.1 A Test

```javascript
// tests/accessibility/wcag2a.spec.js
import { test, expect } from '@playwright/test';
import AxeBuilder from '@axe-core/playwright';

test.describe('WCAG 2.1 Level A Tests', () => {
  test('homepage accessibility A', async ({ page }) => {
    await page.goto('/');
    
    const results = await new AxeBuilder({ page })
      .withTags(['wcag2a'])
      .analyze();
    
    expect(results.violations).toEqual([]);
  });
  
  test('login page accessibility A', async ({ page }) => {
    await page.goto('/login');
    
    const results = await new AxeBuilder({ page })
      .withTags(['wcag2a'])
      .analyze();
    
    expect(results.violations).toEqual([]);
  });
  
  test('dashboard accessibility A', async ({ page }) => {
    await page.goto('/login');
    await page.fill('#username', 'testuser');
    await page.fill('#password', 'testpass');
    await page.click('#login-button');
    
    const results = await new AxeBuilder({ page })
      .withTags(['wcag2a'])
      .analyze();
    
    expect(results.violations).toEqual([]);
  });
});
```

---

### WCAG 2.1 AA Test

```javascript
// tests/accessibility/wcag2aa.spec.js
import { test, expect } from '@playwright/test';
import AxeBuilder from '@axe-core/playwright';

test.describe('WCAG 2.1 Level AA Tests', () => {
  test('homepage accessibility AA', async ({ page }) => {
    await page.goto('/');
    
    const results = await new AxeBuilder({ page })
      .withTags(['wcag2a', 'wcag2aa'])
      .analyze();
    
    expect(results.violations).toEqual([]);
  });
  
  test('color contrast', async ({ page }) => {
    await page.goto('/');
    
    const results = await new AxeBuilder({ page })
      .withRules(['color-contrast'])
      .analyze();
    
    expect(results.violations).toEqual([]);
  });
  
  test('focus management', async ({ page }) => {
    await page.goto('/');
    
    // Test focus is visible
    await page.keyboard.press('Tab');
    
    const focusedElement = await page.evaluate(() => {
      return document.activeElement.tagName;
    });
    
    expect(focusedElement).toBeTruthy();
    
    // Test focus indicator is visible
    const focusVisible = await page.evaluate(() => {
      const el = document.activeElement;
      const styles = window.getComputedStyle(el);
      return styles.outline !== 'none' || styles.boxShadow !== 'none';
    });
    
    expect(focusVisible).toBeTruthy();
  });
});
```

---

### Keyboard Navigation Test

```javascript
// tests/accessibility/keyboard.spec.js
import { test, expect } from '@playwright/test';

test.describe('Keyboard Navigation', () => {
  test('tab navigation', async ({ page }) => {
    await page.goto('/');
    
    // Tab through all interactive elements
    const tabCount = await page.evaluate(() => {
      let count = 0;
      const interactiveElements = document.querySelectorAll(
        'a, button, input, select, textarea, [tabindex]:not([tabindex="-1"])'
      );
      return interactiveElements.length;
    });
    
    for (let i = 0; i < tabCount; i++) {
      await page.keyboard.press('Tab');
      
      const focused = await page.evaluate(() => {
        return document.activeElement !== document.body;
      });
      
      expect(focused).toBeTruthy();
    }
  });
  
  test('enter activates buttons', async ({ page }) => {
    await page.goto('/');
    
    await page.keyboard.press('Tab'); // Focus first button
    await page.keyboard.press('Enter');
    
    // Verify button action occurred
    await expect(page).toHaveURL(/.*\?action=/);
  });
  
  test('escape closes modal', async ({ page }) => {
    await page.goto('/');
    await page.click('#open-modal-button');
    
    await expect(page.locator('.modal')).toBeVisible();
    
    await page.keyboard.press('Escape');
    
    await expect(page.locator('.modal')).not.toBeVisible();
  });
});
```

---

## 4. Performance Tests

### Core Web Vitals Test

```javascript
// tests/performance/web-vitals.spec.js
import { test, expect } from '@playwright/test';

test.describe('Core Web Vitals', () => {
  test('FCP (First Contentful Paint)', async ({ page }) => {
    await page.goto('/');
    
    const FCP = await page.evaluate(() => {
      return new Promise((resolve) => {
        new PerformanceObserver((list) => {
          const entries = list.getEntries();
          const fcp = entries.find(e => e.name === 'first-contentful-paint');
          if (fcp) resolve(fcp.startTime);
        }).observe({ type: 'paint', buffered: true });
      });
    });
    
    expect(FCP).toBeLessThan(2000); // < 2s
  });
  
  test('LCP (Largest Contentful Paint)', async ({ page }) => {
    await page.goto('/');
    
    const LCP = await page.evaluate(() => {
      return new Promise((resolve) => {
        new PerformanceObserver((list) => {
          const entries = list.getEntries();
          const lcp = entries.find(e => e.entryType === 'largest-contentful-paint');
          if (lcp) resolve(lcp.startTime);
        }).observe({ type: 'largest-contentful-paint', buffered: true });
      });
    });
    
    expect(LCP).toBeLessThan(2500); // < 2.5s
  });
  
  test('CLS (Cumulative Layout Shift)', async ({ page }) => {
    await page.goto('/');
    
    const CLS = await page.evaluate(() => {
      return new Promise((resolve) => {
        let clsValue = 0;
        
        new PerformanceObserver((list) => {
          for (const entry of list.getEntries()) {
            if (!entry.hadRecentInput) {
              clsValue += entry.value;
            }
          }
        }).observe({ type: 'layout-shift', buffered: true });
        
        // Wait for page to stabilize
        setTimeout(() => resolve(clsValue), 3000);
      });
    });
    
    expect(CLS).toBeLessThan(0.1); // < 0.1
  });
  
  test('TBT (Total Blocking Time)', async ({ page }) => {
    await page.goto('/');
    
    const TBT = await page.evaluate(() => {
      return new Promise((resolve) => {
        let tbtValue = 0;
        
        new PerformanceObserver((list) => {
          for (const entry of list.getEntries()) {
            if (entry.entryType === 'longtask') {
              tbtValue += entry.duration - 50;
            }
          }
        }).observe({ type: 'longtask', buffered: true });
        
        setTimeout(() => resolve(tbtValue), 5000);
      });
    });
    
    expect(TBT).toBeLessThan(300); // < 300ms
  });
});
```

---

### Page Load Time Test

```javascript
// tests/performance/page-load.spec.js
import { test, expect } from '@playwright/test';

test.describe('Page Load Performance', () => {
  test('homepage load time', async ({ page }) => {
    const startTime = Date.now();
    await page.goto('/', { waitUntil: 'networkidle' });
    const loadTime = Date.now() - startTime;
    
    expect(loadTime).toBeLessThan(5000); // < 5s
  });
  
  test('API response time', async ({ page }) => {
    await page.goto('/');
    
    const startTime = Date.now();
    await page.click('#fetch-data-button');
    await page.waitForSelector('.data-loaded');
    const responseTime = Date.now() - startTime;
    
    expect(responseTime).toBeLessThan(1000); // < 1s
  });
  
  test('image load time', async ({ page }) => {
    await page.goto('/');
    
    const images = await page.locator('img').all();
    
    for (const image of images) {
      const startTime = Date.now();
      await image.waitFor({ state: 'visible' });
      const loadTime = Date.now() - startTime;
      
      expect(loadTime).toBeLessThan(2000); // < 2s per image
    }
  });
});
```

---

## 5. Responsive Tests

### Desktop vs Mobile Test

```javascript
// tests/responsive/responsive.spec.js
import { test, expect } from '@playwright/test';

test.describe('Responsive Design', () => {
  test('desktop layout', async ({ page }) => {
    await page.setViewportSize({ width: 1280, height: 720 });
    await page.goto('/');
    
    await expect(page.locator('.desktop-nav')).toBeVisible();
    await expect(page.locator('.mobile-nav')).not.toBeVisible();
    await expect(page.locator('.sidebar')).toBeVisible();
  });
  
  test('mobile layout', async ({ page }) => {
    await page.setViewportSize({ width: 375, height: 667 });
    await page.goto('/');
    
    await expect(page.locator('.mobile-nav')).toBeVisible();
    await expect(page.locator('.desktop-nav')).not.toBeVisible();
    await expect(page.locator('.sidebar')).not.toBeVisible();
  });
  
  test('tablet layout', async ({ page }) => {
    await page.setViewportSize({ width: 768, height: 1024 });
    await page.goto('/');
    
    await expect(page.locator('.tablet-nav')).toBeVisible();
    await expect(page.locator('.sidebar')).toBeVisible();
  });
});
```

---

### Touch Events Test

```javascript
// tests/responsive/touch.spec.js
import { test, expect } from '@playwright/test';

test.describe('Touch Events', () => {
  test.use({ viewport: { width: 375, height: 667 } });
  
  test('touch tap', async ({ page }) => {
    await page.goto('/');
    
    // Simulate touch tap
    await page.tap('#button');
    
    await expect(page.locator('.result')).toBeVisible();
  });
  
  test('touch swipe', async ({ page }) => {
    await page.goto('/gallery');
    
    // Simulate touch swipe
    await page.touchscreen.tap(100, 200);
    await page.touchscreen.move(300, 200);
    await page.touchscreen.end();
    
    await expect(page.locator('.gallery-item').nth(1)).toBeVisible();
  });
});
```

---

## 6. API Tests

### API Response Test

```javascript
// tests/api/api.spec.js
import { test, expect } from '@playwright/test';

test.describe('API Tests', () => {
  test('GET /api/users', async ({ request }) => {
    const response = await request.get('/api/users');
    
    expect(response.status()).toBe(200);
    
    const users = await response.json();
    expect(users.length).toBeGreaterThan(0);
    expect(users[0]).toHaveProperty('id');
    expect(users[0]).toHaveProperty('name');
  });
  
  test('POST /api/users', async ({ request }) => {
    const response = await request.post('/api/users', {
      data: {
        name: 'Test User',
        email: 'test@example.com',
      },
    });
    
    expect(response.status()).toBe(201);
    
    const user = await response.json();
    expect(user.name).toBe('Test User');
    expect(user.email).toBe('test@example.com');
  });
  
  test('PUT /api/users/:id', async ({ request }) => {
    const response = await request.put('/api/users/1', {
      data: {
        name: 'Updated User',
      },
    });
    
    expect(response.status()).toBe(200);
    
    const user = await response.json();
    expect(user.name).toBe('Updated User');
  });
  
  test('DELETE /api/users/:id', async ({ request }) => {
    const response = await request.delete('/api/users/1');
    
    expect(response.status()).toBe(204);
  });
  
  test('API authentication', async ({ request }) => {
    const response = await request.get('/api/admin', {
      headers: {
        Authorization: 'Bearer invalid-token',
      },
    });
    
    expect(response.status()).toBe(401);
  });
});
```

---

## 7. E2E User Flows

### Complete User Journey

```javascript
// tests/e2e/user-journey.spec.js
import { test, expect } from '@playwright/test';

test.describe('Complete User Journey', () => {
  test('register → login → browse → purchase → logout', async ({ page }) => {
    // Step 1: Register
    await page.goto('/register');
    await page.fill('#username', 'newuser');
    await page.fill('#email', 'newuser@example.com');
    await page.fill('#password', 'newpass123');
    await page.click('#register-button');
    
    await expect(page).toHaveURL(/.*login/);
    await expect(page.locator('.registration-success')).toBeVisible();
    
    // Step 2: Login
    await page.fill('#username', 'newuser');
    await page.fill('#password', 'newpass123');
    await page.click('#login-button');
    
    await expect(page).toHaveURL(/.*dashboard/);
    
    // Step 3: Browse products
    await page.click('#products-link');
    await expect(page).toHaveURL(/.*products/);
    
    await page.click('.product-item:nth-child(1)');
    await expect(page).toHaveURL(/.*product\/\d+/);
    
    // Step 4: Add to cart
    await page.click('#add-to-cart-button');
    await expect(page.locator('.cart-count')).toContainText('1');
    
    // Step 5: View cart
    await page.click('#cart-link');
    await expect(page).toHaveURL(/.*cart/);
    
    // Step 6: Checkout
    await page.click('#checkout-button');
    await expect(page).toHaveURL(/.*checkout/);
    
    await page.fill('#card-number', '4111111111111111');
    await page.fill('#card-expiry', '12/25');
    await page.fill('#card-cvc', '123');
    await page.click('#place-order-button');
    
    await expect(page).toHaveURL(/.*order-success/);
    
    // Step 7: Logout
    await page.click('#logout-button');
    await expect(page).toHaveURL(/.*login/);
  });
});
```

---

### Admin Flow

```javascript
// tests/e2e/admin.spec.js
import { test, expect } from '@playwright/test';

test.describe('Admin Flow', () => {
  test.use({ storageState: 'playwright/.auth/admin.json' });
  
  test('admin dashboard access', async ({ page }) => {
    await page.goto('/admin');
    
    await expect(page).toHaveURL(/.*admin/);
    await expect(page.locator('.admin-nav')).toBeVisible();
  });
  
  test('create product', async ({ page }) => {
    await page.goto('/admin/products/new');
    
    await page.fill('#product-name', 'New Product');
    await page.fill('#product-price', '99.99');
    await page.fill('#product-description', 'Test description');
    await page.setInputFiles('#product-image', 'test-files/product.jpg');
    await page.click('#save-product-button');
    
    await expect(page.locator('.success-message')).toBeVisible();
    await expect(page).toHaveURL(/.*admin\/products/);
  });
  
  test('manage orders', async ({ page }) => {
    await page.goto('/admin/orders');
    
    await expect(page.locator('.orders-table')).toBeVisible();
    
    // View order details
    await page.click('.order-row:nth-child(1)');
    await expect(page.locator('.order-details')).toBeVisible();
    
    // Update order status
    await page.selectOption('#order-status', 'shipped');
    await page.click('#update-status-button');
    
    await expect(page.locator('.success-message')).toBeVisible();
  });
});
```

---

## Best Practices

### 1. Use Page Object Model

```javascript
// pages/DashboardPage.js
export class DashboardPage {
  constructor(page) {
    this.page = page;
    this.userMenu = page.locator('.user-menu');
    this.logoutButton = page.locator('#logout-button');
    this.navLinks = page.locator('.nav-link');
  }
  
  async logout() {
    await this.userMenu.click();
    await this.logoutButton.click();
  }
  
  async navigateTo(section) {
    await this.navLinks.filter({ hasText: section }).click();
  }
}
```

---

### 2. Use Test Fixtures

```javascript
// fixtures.js
import { test as base } from '@playwright/test';
import { LoginPage } from './pages/LoginPage';
import { DashboardPage } from './pages/DashboardPage';

export const test = base.extend({
  loginPage: async ({ page }, use) => {
    await use(new LoginPage(page));
  },
  
  dashboardPage: async ({ page }, use) => {
    await use(new DashboardPage(page));
  },
  
  authenticatedPage: async ({ page }, use) => {
    await page.goto('/login');
    await page.fill('#username', 'testuser');
    await page.fill('#password', 'testpass');
    await page.click('#login-button');
    await use(page);
  },
});
```

---

### 3. Use Data-Driven Tests

```javascript
test.describe('Data-driven tests', () => {
  const users = [
    { username: 'user1', password: 'pass1' },
    { username: 'user2', password: 'pass2' },
    { username: 'user3', password: 'pass3' },
  ];
  
  for (const user of users) {
    test(`login as ${user.username}`, async ({ page }) => {
      await page.goto('/login');
      await page.fill('#username', user.username);
      await page.fill('#password', user.password);
      await page.click('#login-button');
      
      await expect(page).toHaveURL(/.*dashboard/);
    });
  }
});
```

---

## Notes

- Use `await page.waitForLoadState('networkidle')` for fully loaded pages
- Use `await expect().toHaveScreenshot()` for visual regression
- Use AxeBuilder for accessibility tests
- Use PerformanceObserver for Core Web Vitals
- Combine templates for comprehensive testing
- Run tests in CI with `CI=true npx playwright test`