# Custom Security Rules

> Add your project-specific security rules here.

## Secrets Management
- No hardcoded API keys (enforced)
- All secrets in environment variables
- Secrets rotated quarterly

## HTTPS
- HTTPS required for all external requests
- TLS 1.2+ minimum
- HSTS header enabled

## Password Policy
- Minimum length: 12 characters
- Complexity: upper, lower, number, special
- No common passwords
- Password history: last 5 passwords

## Session Management
- Session timeout: 30 minutes
- Secure cookies: true
- HTTPOnly: true
- SameSite: strict

## API Security
- Rate limiting: 100 requests per 15 minutes
- Authentication required for all endpoints
- Input validation on all parameters
- Output encoding for all responses

## Data Protection
- PII encrypted at rest
- PII encrypted in transit
- Data retention: 90 days
- Data deletion on request

## Audit Logging
- All logins logged
- All access denied logged
- All admin actions logged
- Logs retained for 1 year

---

Edit this file to customize security rules for your project.