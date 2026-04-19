# Custom Smoke Tests

> Add your project-specific smoke tests here.

## Payment Flow Test
- URL: https://your-app.com/api/payment/test
- Expected: HTTP 200 with test transaction ID

```bash
curl -s https://your-app.com/api/payment/test
# Expected: {"transaction_id":"test-123","status":"success"}
```

## Search Function Test
- URL: https://your-app.com/api/search?q=test
- Expected: HTTP 200 with search results

```bash
curl -s "https://your-app.com/api/search?q=test"
# Expected: {"results":[...],"total":10}
```

## File Upload Test
- URL: https://your-app.com/api/upload
- Method: POST
- Expected: HTTP 200 with file ID

```bash
curl -s -X POST https://your-app.com/api/upload \
  -F "file=@test.txt"
# Expected: {"file_id":"abc123","status":"uploaded"}
```

## Email Service Test
- URL: https://your-app.com/api/email/test
- Expected: HTTP 200 with email sent confirmation

```bash
curl -s https://your-app.com/api/email/test
# Expected: {"email_sent":true,"message_id":"..."}
```

## Third-party Integration Test
- URL: https://your-app.com/api/integration/status
- Expected: HTTP 200 with all integrations connected

```bash
curl -s https://your-app.com/api/integration/status
# Expected: {"integrations":[{"name":"stripe","status":"connected"}]}
```

---

Edit this file to add custom smoke tests for your project.