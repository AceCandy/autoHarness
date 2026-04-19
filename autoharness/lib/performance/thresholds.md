# Performance Thresholds

> Default and configurable thresholds for performance benchmarks.

## API Response Time

| Metric | Threshold | Notes |
|--------|-----------|-------|
| Average | < 200ms | Mean response time |
| p50 | < 150ms | Median |
| p95 | < 500ms | 95th percentile |
| p99 | < 1000ms | 99th percentile |
| Max | < 2000ms | Maximum |

## Page Load Time

| Metric | Threshold | Notes |
|--------|-----------|-------|
| Average | < 3000ms | Mean load time |
| Max | < 5000ms | Maximum load time |

## Core Web Vitals

| Metric | Threshold | Notes |
|--------|-----------|-------|
| FCP | < 2000ms | First Contentful Paint |
| LCP | < 2500ms | Largest Contentful Paint |
| CLS | < 0.1 | Cumulative Layout Shift |
| TBT | < 300ms | Total Blocking Time |
| FID | < 100ms | First Input Delay |

## Concurrent Requests

| Metric | Threshold | Notes |
|--------|-----------|-------|
| 50 API requests | < 10000ms | Total time |
| 10 page loads | < 30000ms | Total time |

## Regression Threshold

| Metric | Threshold | Notes |
|--------|-----------|-------|
| Regression | > 20% | Slower than baseline |
| Critical regression | > 50% | Block ship |

## Custom Thresholds

Edit this file to customize thresholds for your project:

```markdown
## Your Custom Thresholds

### API Response Time
- Average: < 150ms ( stricter )
- p95: < 400ms

### Page Load Time
- Average: < 2500ms ( stricter )

### Core Web Vitals
- FCP: < 1800ms
- LCP: < 2200ms
```