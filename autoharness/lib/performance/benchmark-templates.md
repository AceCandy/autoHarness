# Benchmark Templates

> Ready-to-use templates for performance benchmarking.

---

## Template Categories

1. API Benchmarks
2. Page Load Benchmarks
3. Database Benchmarks
4. Resource Benchmarks
5. Concurrent Load Benchmarks
6. Memory Benchmarks

---

## 1. API Benchmarks

### Single Endpoint Benchmark

```javascript
// benchmarks/api/single-endpoint.spec.js
import { test, expect } from '@playwright/test';

test.describe('Single Endpoint Benchmark', () => {
  test('GET /api/users benchmark', async ({ request }) => {
    const iterations = 100;
    const responseTimes = [];
    
    // Warm-up
    for (let i = 0; i < 10; i++) {
      await request.get('/api/users');
    }
    
    // Benchmark
    for (let i = 0; i < iterations; i++) {
      const startTime = performance.now();
      const response = await request.get('/api/users');
      const endTime = performance.now();
      
      expect(response.status()).toBe(200);
      responseTimes.push(endTime - startTime);
    }
    
    const metrics = calculateMetrics(responseTimes);
    
    console.log('Benchmark Results:');
    console.log(`  Average: ${metrics.avg.toFixed(2)}ms`);
    console.log(`  Median (p50): ${metrics.p50.toFixed(2)}ms`);
    console.log(`  p95: ${metrics.p95.toFixed(2)}ms`);
    console.log(`  p99: ${metrics.p99.toFixed(2)}ms`);
    console.log(`  Min: ${metrics.min.toFixed(2)}ms`);
    console.log(`  Max: ${metrics.max.toFixed(2)}ms`);
    console.log(`  Std Dev: ${metrics.stdDev.toFixed(2)}ms`);
    
    expect(metrics.avg).toBeLessThan(200);
    expect(metrics.p95).toBeLessThan(500);
  });
});

function calculateMetrics(times) {
  const sorted = [...times].sort((a, b) => a - b);
  const avg = times.reduce((a, b) => a + b, 0) / times.length;
  const variance = times.reduce((sum, t) => sum + Math.pow(t - avg, 2), 0) / times.length;
  
  return {
    avg,
    min: sorted[0],
    max: sorted[sorted.length - 1],
    p50: sorted[Math.floor(times.length * 0.5)],
    p95: sorted[Math.floor(times.length * 0.95)],
    p99: sorted[Math.floor(times.length * 0.99)],
    stdDev: Math.sqrt(variance),
  };
}
```

---

### Multiple Endpoints Benchmark

```javascript
// benchmarks/api/multiple-endpoints.spec.js
import { test, expect } from '@playwright/test';

test.describe('Multiple Endpoints Benchmark', () => {
  const endpoints = [
    { name: 'Users', method: 'GET', url: '/api/users' },
    { name: 'Products', method: 'GET', url: '/api/products' },
    { name: 'Orders', method: 'GET', url: '/api/orders' },
    { name: 'Categories', method: 'GET', url: '/api/categories' },
  ];
  
  for (const endpoint of endpoints) {
    test(`benchmark: ${endpoint.name}`, async ({ request }) => {
      const iterations = 100;
      const times = [];
      
      for (let i = 0; i < iterations; i++) {
        const start = performance.now();
        await request.get(endpoint.url);
        times.push(performance.now() - start);
      }
      
      const metrics = calculateMetrics(times);
      
      console.log(`${endpoint.name}:`);
      console.log(`  Avg: ${metrics.avg.toFixed(2)}ms, p95: ${metrics.p95.toFixed(2)}ms`);
      
      expect(metrics.avg).toBeLessThan(200);
    });
  }
});
```

---

### POST/PUT Benchmark

```javascript
// benchmarks/api/write-operations.spec.js
import { test, expect } from '@playwright/test';

test.describe('Write Operations Benchmark', () => {
  test('POST /api/users benchmark', async ({ request }) => {
    const iterations = 50;
    const times = [];
    
    for (let i = 0; i < iterations; i++) {
      const start = performance.now();
      const response = await request.post('/api/users', {
        data: {
          name: `Test User ${i}`,
          email: `test${i}@example.com`,
        },
      });
      times.push(performance.now() - start);
      
      expect(response.status()).toBe(201);
    }
    
    const avg = times.reduce((a, b) => a + b, 0) / iterations;
    expect(avg).toBeLessThan(300);
  });
  
  test('PUT /api/users/:id benchmark', async ({ request }) => {
    const iterations = 50;
    const times = [];
    
    for (let i = 0; i < iterations; i++) {
      const start = performance.now();
      const response = await request.put(`/api/users/${i + 1}`, {
        data: {
          name: `Updated User ${i}`,
        },
      });
      times.push(performance.now() - start);
      
      expect(response.status()).toBe(200);
    }
    
    const avg = times.reduce((a, b) => a + b, 0) / iterations;
    expect(avg).toBeLessThan(300);
  });
});
```

---

## 2. Page Load Benchmarks

### Basic Page Load

```javascript
// benchmarks/page-load/basic.spec.js
import { test, expect } from '@playwright/test';

test.describe('Page Load Benchmarks', () => {
  test('homepage load time', async ({ page }) => {
    const iterations = 10;
    const loadTimes = [];
    
    for (let i = 0; i < iterations; i++) {
      const start = performance.now();
      await page.goto('/', { waitUntil: 'networkidle' });
      loadTimes.push(performance.now() - start);
      
      await page.close();
    }
    
    const avg = loadTimes.reduce((a, b) => a + b, 0) / iterations;
    const max = Math.max(...loadTimes);
    
    console.log(`Homepage load time:`);
    console.log(`  Average: ${avg.toFixed(0)}ms`);
    console.log(`  Max: ${max.toFixed(0)}ms`);
    
    expect(avg).toBeLessThan(3000);
    expect(max).toBeLessThan(5000);
  });
});
```

---

### Detailed Page Timing

```javascript
// benchmarks/page-load/detailed-timing.spec.js
import { test, expect } from '@playwright/test';

test.describe('Detailed Page Timing', () => {
  test('homepage timing breakdown', async ({ page }) => {
    await page.goto('/');
    
    const timing = await page.evaluate(() => {
      const t = performance.timing;
      return {
        DNS: t.domainLookupEnd - t.domainLookupStart,
        TCP: t.connectEnd - t.connectStart,
        Request: t.responseStart - t.requestStart,
        Response: t.responseEnd - t.responseStart,
        DOMProcessing: t.domComplete - t.domLoading,
        LoadEvent: t.loadEventEnd - t.loadEventStart,
        Total: t.loadEventEnd - t.navigationStart,
      };
    });
    
    console.log('Timing Breakdown:');
    console.log(`  DNS Lookup: ${timing.DNS}ms`);
    console.log(`  TCP Connection: ${timing.TCP}ms`);
    console.log(`  Request: ${timing.Request}ms`);
    console.log(`  Response: ${timing.Response}ms`);
    console.log(`  DOM Processing: ${timing.DOMProcessing}ms`);
    console.log(`  Load Event: ${timing.LoadEvent}ms`);
    console.log(`  Total: ${timing.Total}ms`);
    
    expect(timing.DNS).toBeLessThan(100);
    expect(timing.TCP).toBeLessThan(200);
    expect(timing.Request).toBeLessThan(100);
    expect(timing.Response).toBeLessThan(500);
    expect(timing.DOMProcessing).toBeLessThan(1000);
    expect(timing.Total).toBeLessThan(3000);
  });
});
```

---

### Resource Timing

```javascript
// benchmarks/page-load/resource-timing.spec.js
import { test, expect } from '@playwright/test';

test.describe('Resource Timing', () => {
  test('resource load times', async ({ page }) => {
    await page.goto('/');
    
    const resources = await page.evaluate(() => {
      return performance.getEntriesByType('resource').map(r => ({
        name: r.name,
        duration: r.duration,
        size: (r as any).transferSize || 0,
      }));
    });
    
    console.log('Resource Load Times:');
    resources.forEach(r => {
      console.log(`  ${r.name}: ${r.duration.toFixed(0)}ms (${(r.size / 1024).toFixed(2)}KB)`);
    });
    
    // Check for slow resources
    const slowResources = resources.filter(r => r.duration > 1000);
    expect(slowResources.length).toBe(0);
  });
});
```

---

## 3. Database Benchmarks

### Query Performance

```javascript
// benchmarks/database/queries.spec.js
import { test, expect } from '@playwright/test';

test.describe('Database Query Performance', () => {
  test('SELECT users query performance', async ({ request }) => {
    const iterations = 100;
    const times = [];
    
    for (let i = 0; i < iterations; i++) {
      const start = performance.now();
      await request.get('/api/db-test/select-users');
      times.push(performance.now() - start);
    }
    
    const avg = times.reduce((a, b) => a + b, 0) / iterations;
    
    console.log(`SELECT users: ${avg.toFixed(2)}ms average`);
    
    expect(avg).toBeLessThan(50);
  });
  
  test('JOIN query performance', async ({ request }) => {
    const iterations = 50;
    const times = [];
    
    for (let i = 0; i < iterations; i++) {
      const start = performance.now();
      await request.get('/api/db-test/join-users-orders');
      times.push(performance.now() - start);
    }
    
    const avg = times.reduce((a, b) => a + b, 0) / iterations;
    
    console.log(`JOIN query: ${avg.toFixed(2)}ms average`);
    
    expect(avg).toBeLessThan(100);
  });
});
```

---

### Database Connection Pool

```javascript
// benchmarks/database/connection-pool.spec.js
import { test, expect } from '@playwright/test';

test.describe('Database Connection Pool', () => {
  test('concurrent connections', async ({ request }) => {
    const concurrent = 20;
    const promises = [];
    
    for (let i = 0; i < concurrent; i++) {
      promises.push(request.get('/api/db-test/query'));
    }
    
    const start = performance.now();
    const responses = await Promise.all(promises);
    const totalTime = performance.now() - start;
    
    console.log(`${concurrent} concurrent queries: ${totalTime.toFixed(0)}ms total`);
    
    for (const response of responses) {
      expect(response.status()).toBe(200);
    }
    
    expect(totalTime).toBeLessThan(5000);
  });
});
```

---

## 4. Resource Benchmarks

### Memory Usage

```javascript
// benchmarks/resources/memory.spec.js
import { test, expect } from '@playwright/test';

test.describe('Memory Usage Benchmark', () => {
  test('memory after page load', async ({ page }) => {
    await page.goto('/');
    
    const memory = await page.evaluate(() => {
      const m = (performance as any).memory;
      return {
        usedJSHeapSize: m.usedJSHeapSize,
        totalJSHeapSize: m.totalJSHeapSize,
        jsHeapSizeLimit: m.jsHeapSizeLimit,
      };
    });
    
    console.log('Memory Usage:');
    console.log(`  Used: ${(memory.usedJSHeapSize / 1024 / 1024).toFixed(2)}MB`);
    console.log(`  Total: ${(memory.totalJSHeapSize / 1024 / 1024).toFixed(2)}MB`);
    console.log(`  Limit: ${(memory.jsHeapSizeLimit / 1024 / 1024).toFixed(2)}MB`);
    
    expect(memory.usedJSHeapSize).toBeLessThan(50 * 1024 * 1024); // < 50MB
  });
  
  test('memory leak detection', async ({ page }) => {
    await page.goto('/');
    
    const initialMemory = await page.evaluate(() => {
      return (performance as any).memory.usedJSHeapSize;
    });
    
    // Perform operation 100 times
    for (let i = 0; i < 100; i++) {
      await page.click('#load-data-button');
      await page.waitForSelector('.data-loaded');
      await page.click('#clear-data-button');
    }
    
    // Force garbage collection (Chrome only)
    await page.evaluate(() => {
      if ((window as any).gc) (window as any).gc();
    });
    
    const finalMemory = await page.evaluate(() => {
      return (performance as any).memory.usedJSHeapSize;
    });
    
    const memoryIncrease = finalMemory - initialMemory;
    
    console.log(`Memory increase: ${(memoryIncrease / 1024 / 1024).toFixed(2)}MB`);
    
    expect(memoryIncrease).toBeLessThan(10 * 1024 * 1024); // < 10MB increase
  });
});
```

---

### CPU Usage

```javascript
// benchmarks/resources/cpu.spec.js
import { test, expect } from '@playwright/test';

test.describe('CPU Usage Benchmark', () => {
  test('CPU during heavy operation', async ({ page }) => {
    await page.goto('/');
    
    // Measure task duration (proxy for CPU usage)
    const start = performance.now();
    await page.evaluate(() => {
      // Simulate heavy computation
      let sum = 0;
      for (let i = 0; i < 1000000; i++) {
        sum += i;
      }
      return sum;
    });
    const duration = performance.now() - start;
    
    console.log(`Heavy computation: ${duration.toFixed(0)}ms`);
    
    expect(duration).toBeLessThan(1000);
  });
});
```

---

## 5. Concurrent Load Benchmarks

### API Concurrent Requests

```javascript
// benchmarks/concurrent/api.spec.js
import { test, expect } from '@playwright/test';

test.describe('Concurrent API Requests', () => {
  test('50 concurrent GET requests', async ({ request }) => {
    const concurrent = 50;
    const promises = [];
    
    for (let i = 0; i < concurrent; i++) {
      promises.push(request.get('/api/users'));
    }
    
    const start = performance.now();
    const responses = await Promise.all(promises);
    const totalTime = performance.now() - start;
    
    console.log(`${concurrent} concurrent requests: ${totalTime.toFixed(0)}ms`);
    console.log(`Average per request: ${(totalTime / concurrent).toFixed(0)}ms`);
    
    for (const response of responses) {
      expect(response.status()).toBe(200);
    }
    
    expect(totalTime).toBeLessThan(10000);
  });
  
  test('sustained load: 100 requests over 10s', async ({ request }) => {
    const totalRequests = 100;
    const duration = 10000; // 10 seconds
    const interval = duration / totalRequests;
    
    const times = [];
    
    for (let i = 0; i < totalRequests; i++) {
      setTimeout(async () => {
        const start = performance.now();
        await request.get('/api/users');
        times.push(performance.now() - start);
      }, i * interval);
    }
    
    await new Promise(resolve => setTimeout(resolve, duration + 1000));
    
    const avg = times.reduce((a, b) => a + b, 0) / times.length;
    console.log(`Sustained load average: ${avg.toFixed(2)}ms`);
    
    expect(avg).toBeLessThan(500);
  });
});
```

---

### Page Concurrent Loads

```javascript
// benchmarks/concurrent/pages.spec.js
import { test, expect, chromium } from '@playwright/test';

test.describe('Concurrent Page Loads', () => {
  test('10 concurrent page loads', async () => {
    const concurrent = 10;
    const browser = await chromium.launch();
    
    const contexts = [];
    const pages = [];
    
    // Create contexts and pages
    for (let i = 0; i < concurrent; i++) {
      const context = await browser.newContext();
      contexts.push(context);
      pages.push(await context.newPage());
    }
    
    // Load all pages concurrently
    const start = performance.now();
    await Promise.all(pages.map(page => page.goto('/')));
    const totalTime = performance.now() - start;
    
    console.log(`${concurrent} concurrent page loads: ${totalTime.toFixed(0)}ms`);
    
    // Cleanup
    await Promise.all(contexts.map(context => context.close()));
    await browser.close();
    
    expect(totalTime).toBeLessThan(30000);
  });
});
```

---

## 6. Memory Benchmarks

### Heap Snapshot

```javascript
// benchmarks/memory/heap-snapshot.spec.js
import { test, expect } from '@playwright/test';

test.describe('Heap Snapshot', () => {
  test('heap snapshot after load', async ({ page }) => {
    await page.goto('/');
    
    // Get heap snapshot
    const heapSnapshot = await page.evaluate(() => {
      const m = (performance as any).memory;
      return {
        used: m.usedJSHeapSize,
        total: m.totalJSHeapSize,
        limit: m.jsHeapSizeLimit,
      };
    });
    
    console.log('Heap Snapshot:');
    console.log(`  Used: ${(heapSnapshot.used / 1024 / 1024).toFixed(2)}MB`);
    console.log(`  Total: ${(heapSnapshot.total / 1024 / 1024).toFixed(2)}MB`);
    
    expect(heapSnapshot.used).toBeLessThan(100 * 1024 * 1024); // < 100MB
  });
});
```

---

## Utility Functions

### Calculate Metrics

```javascript
function calculateMetrics(times) {
  const sorted = [...times].sort((a, b) => a - b);
  const sum = times.reduce((a, b) => a + b, 0);
  const avg = sum / times.length;
  const variance = times.reduce((acc, t) => acc + Math.pow(t - avg, 2), 0) / times.length;
  const stdDev = Math.sqrt(variance);
  
  return {
    count: times.length,
    sum,
    avg,
    min: sorted[0],
    max: sorted[sorted.length - 1],
    p50: sorted[Math.floor(times.length * 0.5)],
    p75: sorted[Math.floor(times.length * 0.75)],
    p90: sorted[Math.floor(times.length * 0.90)],
    p95: sorted[Math.floor(times.length * 0.95)],
    p99: sorted[Math.floor(times.length * 0.99)],
    stdDev,
    variance,
  };
}
```

---

### Format Results

```javascript
function formatResults(name, metrics) {
  console.log(`\n${name}:`);
  console.log(`  Count: ${metrics.count}`);
  console.log(`  Average: ${metrics.avg.toFixed(2)}ms`);
  console.log(`  Median: ${metrics.p50.toFixed(2)}ms`);
  console.log(`  p95: ${metrics.p95.toFixed(2)}ms`);
  console.log(`  p99: ${metrics.p99.toFixed(2)}ms`);
  console.log(`  Min: ${metrics.min.toFixed(2)}ms`);
  console.log(`  Max: ${metrics.max.toFixed(2)}ms`);
  console.log(`  Std Dev: ${metrics.stdDev.toFixed(2)}ms`);
}
```

---

### Save Baseline

```javascript
// Save baseline to file
import fs from 'fs';

function saveBaseline(name, metrics) {
  const baseline = {
    timestamp: new Date().toISOString(),
    name,
    metrics,
  };
  
  fs.writeFileSync(
    `baselines/${name}.json`,
    JSON.stringify(baseline, null, 2)
  );
}

// Load baseline from file
function loadBaseline(name) {
  const data = fs.readFileSync(`baselines/${name}.json`, 'utf-8');
  return JSON.parse(data);
}

// Compare with baseline
function compareWithBaseline(current, baseline, threshold = 0.2) {
  const regression = current.avg > baseline.metrics.avg * (1 + threshold);
  
  return {
    current: current.avg,
    baseline: baseline.metrics.avg,
    change: ((current.avg - baseline.metrics.avg) / baseline.metrics.avg) * 100,
    regression,
  };
}
```

---

## Running Benchmarks

### Run All Benchmarks

```bash
# Run all benchmarks
npx playwright test benchmarks/

# Run specific benchmark
npx playwright test benchmarks/api/single-endpoint.spec.js

# Run with report
npx playwright test benchmarks/ --reporter=html
```

---

### Save Baseline

```bash
# Create baseline
npx playwright test benchmarks/ --reporter=json > baseline.json
```

---

### Compare with Baseline

```bash
# Compare current with baseline
npx playwright test benchmarks/compare.spec.js
```

---

## Notes

- Warm up before benchmarking (10+ requests)
- Use performance.now() for high-precision timing
- Run multiple iterations for statistical significance
- Exclude outliers (min/max) for stable metrics
- Save baseline for regression detection
- Run benchmarks in CI/CD for continuous monitoring