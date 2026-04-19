# Security Checklist

> Quick reference for common security vulnerabilities.

---

## OWASP Top 10 (2021) Quick Check

### A01: Broken Access Control

- Authorization checks on sensitive operations
- No path traversal vulnerabilities
- Validated user permissions
- Tested privilege escalation scenarios
- Reviewed API endpoint access controls

---

### A02: Cryptographic Failures

- Encrypted sensitive data at rest
- HTTPS only (TLS 1.2+)
- Strong algorithms (AES-256, RSA-2048)
- No hardcoded secrets
- Secure key management

---

### A03: Injection

- Parameterized queries (SQL)
- Input validation (type, length, format)
- Escaped special characters
- Reviewed ORM usage
- Tested XSS vulnerabilities

---

### A04: Insecure Design

- Threat modeling documented
- No business logic flaws
- Rate limiting on sensitive endpoints
- Secure password reset flow
- No insecure direct object references

---

### A05: Security Misconfiguration

- Removed default credentials
- Disabled unnecessary features
- Generic error messages (no stack traces)
- Reviewed CORS configuration
- Security headers present

---

### A06: Vulnerable Components

- Updated dependencies (npm audit)
- No known CVEs
- Automatic dependency updates
- No deprecated packages
- License compatibility checked

---

### A07: Authentication Failures

- Strong password policy (12+ chars, mixed)
- Brute force protection (rate limiting)
- Secure session management (timeout, cookies)
- MFA enabled (if applicable)
- No credential stuffing vulnerabilities

---

### A08: Integrity Failures

- Secure CI/CD pipeline
- Reviewed auto-update mechanisms
- Signed code/packages
- CI pipeline access controls
- Code review required

---

### A09: Logging Failures

- Security events logged (login, access denied)
- No log injection
- Log retention policy
- Monitoring and alerting
- Audit trail (who, what, when)

---

### A10: SSRF

- Validated URLs from user input
- No internal network access
- Reviewed webhook URLs
- Blocked cloud metadata endpoints
- Restricted file upload URLs

---

## STRIDE Quick Check

### Spoofing

- User identity authenticated
- Session token validated
- API key authentication secure
- Tested impersonation scenarios

---

### Tampering

- Data integrity checks (checksums)
- Input validation
- No unauthorized modifications
- Database transaction integrity

---

### Repudiation

- Audit logging enabled
- Immutable logs
- Digital signatures (if applicable)
- Accurate timestamps

---

### Information Disclosure

- Sensitive fields encrypted
- Error handling secure (no leaks)
- API responses filtered
- Access control on sensitive endpoints

---

### Denial of Service

- Rate limiting enabled
- Resource exhaustion tested
- Timeout configurations
- Input size limits

---

### Elevation of Privilege

- Authorization checks
- RBAC implemented
- No privilege escalation paths
- Admin-only operations validated

---

## Quick Commands

```bash
# Node.js dependency audit
npm audit

# Python dependency audit
pip-audit

# Check security headers
curl -I https://your-app.com

# OWASP ZAP baseline scan
zap-baseline.py -t https://your-app.com
```

---

## Security Headers Checklist

- X-Frame-Options: DENY or SAMEORIGIN
- X-Content-Type-Options: nosniff
- Strict-Transport-Security: max-age=31536000
- Content-Security-Policy: [configured]
- X-XSS-Protection: 1; mode=block
- Referrer-Policy: strict-origin-when-cross-origin

---

## Common Fixes

### SQL Injection

```javascript
// Before
const query = `SELECT * FROM users WHERE id = ${id}`;

// After
const query = 'SELECT * FROM users WHERE id = ?';
db.query(query, [id]);
```

---

### Hardcoded Secrets

```javascript
// Before
const apiKey = 'sk-1234567890';

// After
const apiKey = process.env.API_KEY;
```

---

### Missing Authorization

```javascript
// Before
app.get('/admin/users', (req, res) => { ... });

// After
app.get('/admin/users', authenticate, authorize('admin'), (req, res) => { ... });
```

---

### XSS Vulnerability

```javascript
// Before
res.send(`<div>${userInput}</div>`);

// After
res.send(`<div>${escapeHtml(userInput)}</div>`);
```

---

### Path Traversal

```javascript
// Before
const filePath = `/uploads/${filename}`;

// After
const filePath = path.join('/uploads', path.basename(filename));
```

---

## Severity Matrix

| Type | Example | Severity |
|------|---------|----------|
| SQL Injection | String interpolation in queries | Critical |
| Hardcoded Secrets | API keys in code | High |
| Missing Authorization | Public admin endpoints | High |
| XSS | Unescaped user input | Medium |
| Weak Passwords | 4+ character minimum | Medium |
| Missing Rate Limiting | No brute force protection | Medium |
| Information Disclosure | Stack traces in errors | Low |
| Missing Security Headers | No X-Frame-Options | Low |

---

## Red Flags

If you see these, **stop and fix immediately**:

- `eval()`, `Function()` with user input
- String interpolation in SQL/NoSQL queries
- Hardcoded passwords, API keys, tokens
- `innerHTML` with user input (XSS)
- File operations with unsanitized paths
- No authorization checks on admin endpoints
- HTTP (not HTTPS) for sensitive data

---

## Checklist Usage

1. **Before coding**: Review checklist to avoid common mistakes
2. **During coding**: Check for red flags
3. **Before commit**: Run quick check
4. **Before ship**: Run the unified verification gate (`/ah-verify`)
