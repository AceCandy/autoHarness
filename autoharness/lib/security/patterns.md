# Security Vulnerability Patterns

> Common vulnerability patterns with detection methods and fixes.

---

## Pattern 1: SQL Injection

### Detection Pattern

```javascript
// Regex pattern to detect potential SQL injection
const sqlInjectionPattern = /(?:SELECT|INSERT|UPDATE|DELETE|DROP).*\$\{.*\}|(?:SELECT|INSERT|UPDATE|DELETE|DROP).*\+.*\+/gi;

// Example vulnerable code
const query = `SELECT * FROM users WHERE id = ${userId}`;
const query = 'SELECT * FROM users WHERE name = "' + userName + '"';
```

### Vulnerability Types

1. **String Interpolation**: `SELECT * FROM ${table}`
2. **String Concatenation**: `'SELECT * FROM ' + table`
3. **Template Literals**: `` `SELECT * FROM ${table}` ``

### Fix Pattern

```javascript
// Parameterized query (Node.js)
const query = 'SELECT * FROM users WHERE id = ?';
db.query(query, [userId]);

// ORM (Sequelize)
User.findOne({ where: { id: userId } });

// ORM (TypeORM)
userRepository.findOne({ id: userId });

// NoSQL (MongoDB)
db.users.findOne({ _id: ObjectId(userId) });
```

---

## Pattern 2: NoSQL Injection

### Detection Pattern

```javascript
// MongoDB injection pattern
const nosqlInjectionPattern = /\$where|\$gt|\$lt|\$ne|\$regex/i;

// Example vulnerable code
db.users.find({ name: userInput }); // If userInput = { $ne: null }
db.users.find({ age: { $gt: userAge } }); // If userAge = { $gt: 0 }
```

### Vulnerability Types

1. **Operator Injection**: `{ $ne: null }`, `{ $gt: 0 }`
2. **JavaScript Injection**: `{ $where: 'this.name == "admin"' }`
3. **Regex Injection**: `{ $regex: '.*' }`

### Fix Pattern

```javascript
// Validate input type
if (typeof userInput !== 'string') {
  throw new Error('Invalid input type');
}

// Use strict equality
db.users.find({ name: { $eq: userInput } });

// Whitelist allowed operators
const allowedFields = ['name', 'email', 'age'];
const query = {};
for (const field of allowedFields) {
  if (input[field]) {
    query[field] = input[field];
  }
}
db.users.find(query);
```

---

## Pattern 3: XSS (Cross-Site Scripting)

### Detection Pattern

```javascript
// DOM XSS pattern
const xssPattern = /\.innerHTML|\.outerHTML|document\.write|eval\(|new Function\(/gi;

// Example vulnerable code
element.innerHTML = `<div>${userInput}</div>`;
document.write(userInput);
eval(userInput);
```

### Vulnerability Types

1. **HTML Injection**: `innerHTML`, `outerHTML`
2. **JavaScript Injection**: `eval()`, `Function()`
3. **Event Handler Injection**: `onclick`, `onerror`

### Fix Pattern

```javascript
// Text content (safe)
element.textContent = userInput;

// HTML escaping
function escapeHtml(str) {
  return str
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#x27;');
}
element.innerHTML = escapeHtml(userInput);

// Sanitize HTML (use library)
import sanitizeHtml from 'sanitize-html';
element.innerHTML = sanitizeHtml(userInput, {
  allowedTags: ['b', 'i', 'em', 'strong'],
  allowedAttributes: {}
});

// React (auto-escaped)
<div>{userInput}</div>

// React with HTML (dangerous, must sanitize)
<div dangerouslySetInnerHTML={{ __html: sanitizeHtml(userInput) }} />
```

---

## Pattern 4: Path Traversal

### Detection Pattern

```javascript
// Path traversal pattern
const pathTraversalPattern = /\.(?:\/|\\)|\.\.\%2f|\.\.\%5c/i;

// Example vulnerable code
const filePath = `/uploads/${filename}`;
fs.readFile(filePath);
```

### Vulnerability Types

1. **Relative Path**: `../../../etc/passwd`
2. **URL Encoded**: `..%2f..%2f..%2fetc%2fpasswd`
3. **Null Byte**: `../../../etc/passwd%00.jpg`

### Fix Pattern

```javascript
// Whitelist allowed characters
const allowedChars = /^[a-zA-Z0-9-_\.]+$/;
if (!allowedChars.test(filename)) {
  throw new Error('Invalid filename');
}

// Use path.basename
const safeFilename = path.basename(filename);
const filePath = path.join('/uploads', safeFilename);

// Validate resolved path
const resolvedPath = path.resolve('/uploads', filename);
if (!resolvedPath.startsWith('/uploads/')) {
  throw new Error('Path traversal detected');
}
```

---

## Pattern 5: Hardcoded Secrets

### Detection Pattern

```javascript
// Secret pattern detection
const secretPatterns = [
  /(?:password|pwd|pass)\s*[=:]\s*['"][^'"]{8,}['"]/gi,
  /(?:api[_-]?key|apikey)\s*[=:]\s*['"][^'"]{16,}['"]/gi,
  /(?:secret|token)\s*[=:]\s*['"][^'"]{16,}['"]/gi,
  /(?:aws[_-]?access[_-]?key[_-]?id)\s*[=:]\s*['"][A-Z0-9]{20}['"]/gi,
  /(?:aws[_-]?secret[_-]?access[_-]?key)\s*[=:]\s*['"][A-Za-z0-9\/+=]{40}['"]/gi
];

// Example vulnerable code
const password = 'SuperSecret123!';
const apiKey = 'sk-1234567890abcdef';
const awsKey = 'AKIAIOSFODNN7EXAMPLE';
```

### Fix Pattern

```javascript
// Environment variables
const password = process.env.DB_PASSWORD;
const apiKey = process.env.API_KEY;
const awsKey = process.env.AWS_ACCESS_KEY_ID;

// Secret management (HashiCorp Vault, AWS Secrets Manager)
import { getSecret } from './secrets-manager';
const apiKey = await getSecret('api-key');

// Config file (outside repo)
import config from './config.json';
const apiKey = config.apiKey;

// Git-ignored env file (.env)
# .env (DO NOT COMMIT)
DB_PASSWORD=SuperSecret123!
API_KEY=sk-1234567890
```

---

## Pattern 6: Command Injection

### Detection Pattern

```javascript
// Command injection pattern
const commandInjectionPattern = /exec\(|spawn\(|execSync\(|\`.*\`|;|&&|\|\|/gi;

// Example vulnerable code
exec(`ls ${userInput}`);
spawn('find', [userInput]);
system(`convert ${filename} output.png`);
```

### Vulnerability Types

1. **Command Chaining**: `; rm -rf /`, `&& cat /etc/passwd`
2. **Backtick Injection**: `` `cat /etc/passwd` ``
3. **Argument Injection**: `file.txt; rm -rf /`

### Fix Pattern

```javascript
// Avoid shell=True
import { execFile } from 'child_process';
execFile('ls', [userInput], (err, stdout) => { ... });

// Validate input
const allowedChars = /^[a-zA-Z0-9-_\.\/]+$/;
if (!allowedChars.test(userInput)) {
  throw new Error('Invalid input');
}

// Whitelist commands
const allowedCommands = ['ls', 'find', 'grep'];
const command = userInput.split(' ')[0];
if (!allowedCommands.includes(command)) {
  throw new Error('Command not allowed');
}
```

---

## Pattern 7: SSRF (Server-Side Request Forgery)

### Detection Pattern

```javascript
// SSRF pattern
const ssrfPattern = /fetch\(|request\(|axios\.|http\.get|https\.get/gi;

// Example vulnerable code
fetch(userProvidedUrl);
request(userProvidedUrl);
axios.get(userInput);
```

### Vulnerability Types

1. **Internal Network**: `http://localhost/admin`, `http://192.168.1.1/`
2. **Cloud Metadata**: `http://169.254.169.254/latest/meta-data/`
3. **File Protocol**: `file:///etc/passwd`

### Fix Pattern

```javascript
// Validate URL protocol
const url = new URL(userProvidedUrl);
if (url.protocol !== 'http:' && url.protocol !== 'https:') {
  throw new Error('Invalid protocol');
}

// Block internal IPs
const privateIpRanges = [
  /^10\./,
  /^172\.16\./,
  /^192\.168\./,
  /^127\./,
  /^169\.254\./,
  /^localhost$/i
];

const hostname = url.hostname;
if (privateIpRanges.some(range => range.test(hostname))) {
  throw new Error('Internal network access blocked');
}

// Whitelist allowed domains
const allowedDomains = ['api.example.com', 'cdn.example.com'];
if (!allowedDomains.some(domain => hostname.endsWith(domain))) {
  throw new Error('Domain not allowed');
}

// Resolve DNS and check IP
const dns = require('dns');
dns.lookup(hostname, (err, address) => {
  if (privateIpRanges.some(range => range.test(address))) {
    throw new Error('Resolved to internal IP');
  }
  fetch(url.toString());
});
```

---

## Pattern 8: XML/XXE Injection

### Detection Pattern

```javascript
// XXE pattern
const xxePattern = /DOCTYPE|ENTITY|SYSTEM|PUBLIC/gi;

// Example vulnerable code
const xml = `<?xml version="1.0"?>
<!DOCTYPE foo [<!ENTITY xxe SYSTEM "file:///etc/passwd">]>
<foo>&xxe;</foo>`;
xmlParser.parse(xml);
```

### Fix Pattern

```javascript
// Disable external entities (Node.js xml2js)
import xml2js from 'xml2js';
const parser = new xml2js.Parser({
  xmlns: true,
  doctype: false,
  externalEntities: false
});

// Disable DTD (Python lxml)
from lxml import etree
parser = etree.XMLParser(resolve_entities=False, load_dtd=False)

// Use JSON instead of XML
const json = JSON.parse(userInput);
```

---

## Pattern 9: Insecure Deserialization

### Detection Pattern

```javascript
// Deserialization pattern
const deserializePattern = /JSON\.parse|eval\(|new Function\(|pickle\.loads|yaml\.load/gi;

// Example vulnerable code
const obj = eval('(' + jsonString + ')');
const obj = yaml.load(yamlString); // PyYAML default
```

### Fix Pattern

```javascript
// Safe JSON parsing
const obj = JSON.parse(jsonString);

// Safe YAML parsing (Python)
import yaml
obj = yaml.safe_load(yamlString)  # Only safe types

// Safe YAML parsing (Node.js js-yaml)
import yaml from 'js-yaml';
const obj = yaml.load(yamlString, { schema: yaml.JSON_SCHEMA });

// Validate schema
import ajv from 'ajv';
const validate = new ajv().compile(schema);
if (!validate(JSON.parse(jsonString))) {
  throw new Error('Invalid JSON schema');
}
```

---

## Pattern 10: Missing Authentication

### Detection Pattern

```javascript
// Missing auth pattern
const missingAuthPattern = /app\.get\(|app\.post\(|app\.put\(|app\.delete\(/gi;

// Example vulnerable code
app.get('/admin/users', (req, res) => { ... });
app.post('/api/delete', (req, res) => { ... });
```

### Fix Pattern

```javascript
// Authentication middleware
app.get('/admin/users', authenticate, (req, res) => { ... });

// Authentication + Authorization
app.get('/admin/users', authenticate, authorize('admin'), (req, res) => { ... });

// Role-based middleware
function authorize(role) {
  return (req, res, next) => {
    if (req.user.role !== role) {
      return res.status(403).json({ error: 'Forbidden' });
    }
    next();
  };
}

// Resource-level authorization
app.delete('/users/:id', authenticate, (req, res) => {
  if (req.user.id !== req.params.id && req.user.role !== 'admin') {
    return res.status(403).json({ error: 'Forbidden' });
  }
  deleteUser(req.params.id);
});
```

---

## Pattern Detection Tools

### ESLint Security Plugins

```bash
# Install
npm install eslint-plugin-security eslint-plugin-no-unsanitized

# Configure .eslintrc
{
  "plugins": ["security", "no-unsanitized"],
  "extends": ["plugin:security/recommended"]
}
```

---

### Git Hooks (pre-commit)

```bash
# Install
npm install husky lint-staged

# Configure package.json
{
  "husky": {
    "hooks": {
      "pre-commit": "lint-staged"
    }
  },
  "lint-staged": {
    "*.js": ["eslint", "npm audit"]
  }
}
```

---

### Automated Scanners

```bash
# OWASP Dependency Check
dependency-check --scan ./node_modules

# Snyk
snyk test

# SonarQube
sonar-scanner
```

---

## Pattern Severity Matrix

| Pattern | CVE Count | Severity | Detection |
|---------|-----------|----------|-----------|
| SQL Injection | 1000+ | Critical | Regex + ESLint |
| XSS | 500+ | High | Regex + ESLint |
| Hardcoded Secrets | 200+ | High | Regex + GitLeaks |
| Path Traversal | 300+ | High | Regex + ESLint |
| Command Injection | 200+ | Critical | Regex + ESLint |
| SSRF | 100+ | Medium | Regex + Manual |
| XXE | 50+ | High | Regex + Scanner |
| Deserialization | 100+ | Critical | Regex + Scanner |
| NoSQL Injection | 50+ | Medium | Regex + Manual |
| Missing Auth | 500+ | High | Manual + Test |

---

## Pattern Summary

| Pattern | Prevention | Detection | Fix Complexity |
|---------|------------|-----------|----------------|
| SQL Injection | Parameterized queries | Regex + lint | Easy |
| NoSQL Injection | Type validation | Regex + manual | Medium |
| XSS | Text content + sanitize | Regex + lint | Easy |
| Path Traversal | Whitelist + basename | Regex + lint | Easy |
| Hardcoded Secrets | Env vars + secrets manager | Regex + GitLeaks | Easy |
| Command Injection | Avoid shell=True | Regex + lint | Medium |
| SSRF | URL validation + whitelist | Manual + test | Hard |
| XXE | Disable external entities | Regex + scanner | Medium |
| Deserialization | Safe parsers + schema | Regex + scanner | Medium |
| Missing Auth | Middleware | Manual + test | Easy |

---

## Quick Detection Script

```bash
#!/bin/bash
# Quick security pattern detection

echo "Checking for security patterns..."

# SQL Injection
grep -r "SELECT.*\$\{" . --include="*.js" && echo "⚠️  Potential SQL injection"

# XSS
grep -r "innerHTML" . --include="*.js" && echo "⚠️  Potential XSS"

# Hardcoded Secrets
grep -r "password.*=.*'" . --include="*.js" && echo "⚠️  Potential hardcoded password"

# Path Traversal
grep -r "\.\.\/" . --include="*.js" && echo "⚠️  Potential path traversal"

# Command Injection
grep -r "exec.*\$\{" . --include="*.js" && echo "⚠️  Potential command injection"

echo "Security check complete."
```

---

## Notes

- Pattern detection is **not perfect** — false positives/negatives possible
- Combine automated detection with manual review
- Regular audits (npm audit, OWASP ZAP) provide comprehensive coverage
- Security patterns evolve — update detection patterns regularly