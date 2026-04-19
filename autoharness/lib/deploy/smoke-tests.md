# Smoke Tests

> Basic sanity checks to verify deployment success.

---

## Purpose

Quick validation that deployment is healthy and core functionality works. Catch critical issues before users encounter them.

---

## Test Categories

### 1. Availability Tests

#### Homepage Load

```bash
# Basic HTTP check
curl -s -o /dev/null -w "%{http_code}" https://your-app.com

# Expected: 200, 301, 302

# Response time check
curl -s -o /dev/null -w "%{time_total}" https://your-app.com

# Expected: < 3 seconds

# Content validation (optional)
curl -s https://your-app.com | grep -q "<title>Your App</title>"
```

---

#### SSL Certificate Check

```bash
# Check SSL validity
openssl s_client -connect your-app.com:443 -servername your-app.com 2>/dev/null | openssl x509 -noout -dates

# Expected: Valid certificate, not expired

# Check SSL grade (using sslscan or testssl.sh)
sslscan your-app.com:443

# Expected: Grade A or B
```

---

#### DNS Resolution Check

```bash
# Check DNS resolves
nslookup your-app.com

# Expected: Resolves to IP address

# Check DNS response time
dig +stats your-app.com | grep "Query time"

# Expected: < 100ms
```

---

### 2. API Tests

#### Health Endpoint

```bash
# Health check endpoint
curl -s https://your-app.com/api/health

# Expected response:
{
  "status": "ok",
  "version": "1.0.0",
  "uptime": "5m",
  "timestamp": "2024-01-01T00:00:00Z"
}

# Check HTTP status
curl -s -o /dev/null -w "%{http_code}" https://your-app.com/api/health

# Expected: 200
```

---

#### API Version Check

```bash
# Version endpoint
curl -s https://your-app.com/api/version

# Expected response:
{
  "version": "v1.2.3",
  "commit": "abc1234",
  "deployed_at": "2024-01-01T00:00:00Z"
}

# Validate version matches deployment
```

---

#### API Response Time

```bash
# Measure API response time
curl -s -o /dev/null -w "%{time_total}" https://your-app.com/api/users

# Expected: < 1 second

# Multiple requests to check consistency
for i in {1..10}; do
  curl -s -o /dev/null -w "%{time_total}\n" https://your-app.com/api/users
done
```

---

### 3. Authentication Tests

#### Login Test

```bash
# Test login endpoint
curl -s -X POST https://your-app.com/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"testuser","password":"testpass"}'

# Expected response:
{
  "token": "eyJhbGciOiJIUzI1NiIs...",
  "user": {
    "id": 1,
    "username": "testuser"
  }
}

# Check token is valid JWT
echo "eyJ..." | cut -d. -f2 | base64 -d 2>/dev/null | jq .
```

---

#### Token Validation Test

```bash
# Test protected endpoint with token
TOKEN="eyJhbGciOiJIUzI1NiIs..."

curl -s https://your-app.com/api/users/me \
  -H "Authorization: Bearer $TOKEN"

# Expected response:
{
  "id": 1,
  "username": "testuser",
  "email": "test@example.com"
}

# Expected HTTP status: 200
```

---

#### Logout Test

```bash
# Test logout endpoint
curl -s -X POST https://your-app.com/api/auth/logout \
  -H "Authorization: Bearer $TOKEN"

# Expected response:
{
  "message": "Logged out successfully"
}

# Verify token is invalidated
curl -s https://your-app.com/api/users/me \
  -H "Authorization: Bearer $TOKEN"

# Expected HTTP status: 401
```

---

### 4. Database Tests

#### Database Connection Test

```bash
# Test database connection
curl -s https://your-app.com/api/db-test

# Expected response:
{
  "database": "connected",
  "type": "postgresql",
  "version": "14.0",
  "query_time": "10ms"
}

# Expected HTTP status: 200
```

---

#### Database Query Test

```bash
# Test simple query
curl -s https://your-app.com/api/db-query-test

# Expected response:
{
  "query": "SELECT 1",
  "result": 1,
  "query_time": "5ms"
}

# Expected HTTP status: 200
```

---

#### Database Migration Check

```bash
# Check migration status (if applicable)
curl -s https://your-app.com/api/migrations/status

# Expected response:
{
  "status": "applied",
  "latest_migration": "20240101_add_users_table",
  "pending_migrations": 0
}
```

---

### 5. Cache Tests

#### Cache Connection Test

```bash
# Test Redis/Memcached connection
curl -s https://your-app.com/api/cache-test

# Expected response:
{
  "cache": "connected",
  "type": "redis",
  "version": "7.0"
}
```

---

#### Cache Read/Write Test

```bash
# Test cache set/get
curl -s -X POST https://your-app.com/api/cache-test \
  -H "Content-Type: application/json" \
  -d '{"key":"test_key","value":"test_value"}'

curl -s https://your-app.com/api/cache-test?key=test_key

# Expected response:
{
  "key": "test_key",
  "value": "test_value",
  "ttl": 300
}
```

---

### 6. Static Asset Tests

#### CSS Files

```bash
# Check CSS file
curl -s -o /dev/null -w "%{http_code}" https://your-app.com/static/styles.css

# Expected: 200

# Check CSS content type
curl -s -I https://your-app.com/static/styles.css | grep -i "content-type"

# Expected: text/css
```

---

#### JavaScript Files

```bash
# Check JS file
curl -s -o /dev/null -w "%{http_code}" https://your-app.com/static/app.js

# Expected: 200

# Check JS content type
curl -s -I https://your-app.com/static/app.js | grep -i "content-type"

# Expected: application/javascript
```

---

#### Image Files

```bash
# Check image file
curl -s -o /dev/null -w "%{http_code}" https://your-app.com/static/logo.png

# Expected: 200

# Check image content type
curl -s -I https://your-app.com/static/logo.png | grep -i "content-type"

# Expected: image/png
```

---

#### Font Files

```bash
# Check font file
curl -s -o /dev/null -w "%{http_code}" https://your-app.com/static/fonts/roboto.woff2

# Expected: 200

# Check font content type
curl -s -I https://your-app.com/static/fonts/roboto.woff2 | grep -i "content-type"

# Expected: font/woff2
```

---

### 7. Third-Party Integration Tests

#### Email Service Test

```bash
# Test email service connection
curl -s https://your-app.com/api/email-test

# Expected response:
{
  "service": "sendgrid",
  "status": "connected",
  "test_email_sent": true
}
```

---

#### Payment Gateway Test

```bash
# Test payment service connection
curl -s https://your-app.com/api/payment-test

# Expected response:
{
  "service": "stripe",
  "status": "connected",
  "test_transaction": "txn_123456"
}
```

---

#### SMS Service Test

```bash
# Test SMS service connection
curl -s https://your-app.com/api/sms-test

# Expected response:
{
  "service": "twilio",
  "status": "connected",
  "test_sms_sent": true
}
```

---

### 8. Performance Tests

#### Response Time Benchmark

```bash
# Benchmark homepage
for i in {1..10}; do
  curl -s -o /dev/null -w "%{time_total}\n" https://your-app.com
done | awk '{sum+=$1; count++} END {print "avg: " sum/count "s"}'

# Expected: < 1s average
```

---

#### API Latency Benchmark

```bash
# Benchmark API endpoint
for i in {1..10}; do
  curl -s -o /dev/null -w "%{time_total}\n" https://your-app.com/api/users
done | awk '{sum+=$1; count++} END {print "avg: " sum/count "s"}'

# Expected: < 500ms average
```

---

#### Concurrent Request Test

```bash
# Test 10 concurrent requests
for i in {1..10}; do
  curl -s https://your-app.com/api/users &
done
wait

# Expected: All requests succeed
```

---

## Test Templates

### Basic Smoke Test Suite

```bash
#!/bin/bash
# Basic smoke test suite

APP_URL="https://your-app.com"

echo "Running smoke tests..."

# Test 1: Homepage
if curl -s -o /dev/null -w "%{http_code}" "$APP_URL" | grep -q "200"; then
  echo "✓ Homepage: Pass"
else
  echo "✗ Homepage: Fail"
  exit 1
fi

# Test 2: Health endpoint
if curl -s "$APP_URL/api/health" | grep -q "ok"; then
  echo "✓ Health check: Pass"
else
  echo "✗ Health check: Fail"
  exit 1
fi

# Test 3: Static assets
if curl -s -o /dev/null -w "%{http_code}" "$APP_URL/static/styles.css" | grep -q "200"; then
  echo "✓ Static assets: Pass"
else
  echo "✗ Static assets: Fail"
  exit 1
fi

echo "All smoke tests passed!"
```

---

### Full Smoke Test Suite

```bash
#!/bin/bash
# Full smoke test suite

APP_URL="https://your-app.com"

echo "Running full smoke tests..."

# Availability tests
echo "1. Availability tests..."
curl -s -o /dev/null -w "%{http_code}" "$APP_URL" || exit 1
openssl s_client -connect your-app.com:443 -servername your-app.com 2>/dev/null | openssl x509 -noout -checkend 0 || exit 1

# API tests
echo "2. API tests..."
curl -s "$APP_URL/api/health" | jq -e '.status == "ok"' || exit 1
curl -s "$APP_URL/api/version" | jq -e '.version' || exit 1

# Authentication tests
echo "3. Authentication tests..."
TOKEN=$(curl -s -X POST "$APP_URL/api/auth/login" -H "Content-Type: application/json" -d '{"username":"test","password":"test"}' | jq -r '.token')
curl -s "$APP_URL/api/users/me" -H "Authorization: Bearer $TOKEN" | jq -e '.id' || exit 1

# Database tests
echo "4. Database tests..."
curl -s "$APP_URL/api/db-test" | jq -e '.database == "connected"' || exit 1

# Static asset tests
echo "5. Static asset tests..."
curl -s -o /dev/null -w "%{http_code}" "$APP_URL/static/styles.css" || exit 1
curl -s -o /dev/null -w "%{http_code}" "$APP_URL/static/app.js" || exit 1
curl -s -o /dev/null -w "%{http_code}" "$APP_URL/static/logo.png" || exit 1

# Performance tests
echo "6. Performance tests..."
avg_time=$(for i in {1..10}; do curl -s -o /dev/null -w "%{time_total}\n" "$APP_URL"; done | awk '{sum+=$1; count++} END {print sum/count}')
if [ $(echo "$avg_time < 1" | bc) -eq 1 ]; then
  echo "✓ Response time: $avg_time (acceptable)"
else
  echo "✗ Response time: $avg_time (too slow)"
  exit 1
fi

echo "All smoke tests passed!"
```

---

## Test Configuration

### Timeout Settings

```bash
# Connection timeout: 5 seconds
curl --connect-timeout 5 https://your-app.com

# Total timeout: 30 seconds
curl --max-time 30 https://your-app.com

# Retry on failure: 3 times
curl --retry 3 https://your-app.com
```

---

### Expected Values

| Test | Expected Value | Threshold |
|------|----------------|-----------|
| Homepage HTTP | 200, 301, 302 | N/A |
| Health endpoint | "ok" status | N/A |
| API response time | < 1s | 3s max |
| SSL certificate | Valid, not expired | 30 days min |
| DNS resolution | Resolves to IP | 100ms max |
| Static assets | HTTP 200 | N/A |
| Auth token | Valid JWT | N/A |
| Database connection | "connected" | N/A |

---

## Custom Smoke Tests

### Add Custom Test

```markdown
## Custom Smoke Test: Payment Flow

**Purpose**: Verify payment service integration

**Endpoint**: POST /api/payment/test

**Request**:
```json
{
  "amount": 100,
  "currency": "USD",
  "test": true
}
```

**Expected Response**:
```json
{
  "transaction_id": "txn_test_123",
  "status": "test_success"
}
```

**HTTP Status**: 200

**Timeout**: 10 seconds
```

---

## Test Execution

### Manual Execution

```bash
# Run basic smoke tests
bash lib/deploy/smoke-tests-basic.sh

# Run full smoke tests
bash lib/deploy/smoke-tests-full.sh

# Run custom smoke tests
bash lib/deploy/smoke-tests-custom.sh
```

---

### CI Integration

```yaml
# GitHub Actions
name: Smoke Tests

on:
  deployment_status:

jobs:
  smoke-tests:
    if: github.event.deployment_status.state == 'success'
    runs-on: ubuntu-latest
    steps:
      - name: Run smoke tests
        run: |
          curl -s -o /dev/null -w "%{http_code}" ${{ env.APP_URL }}
          curl -s ${{ env.APP_URL }}/api/health | jq -e '.status == "ok"'
```

---

## Notes

- Smoke tests are **basic sanity checks**, not comprehensive testing
- Run after deployment, not during development
- Combine with monitoring (Datadog, CloudWatch) for ongoing health checks
- Update smoke tests when adding new critical functionality
- Test rollback scenarios with smoke tests