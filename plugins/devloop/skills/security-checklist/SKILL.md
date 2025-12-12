---
name: security-checklist
description: Security checklist covering OWASP Top 10, authentication, authorization, data protection, and secure coding practices. Use during code review or security assessment.
---

# Security Checklist

Comprehensive security checklist for application development.

## When NOT to Use This Skill

- **Internal tools**: Lower security bar for internal-only applications
- **Prototypes/spikes**: Don't security-audit throwaway code
- **Static content**: Read-only sites with no user input
- **Already audited**: Don't re-audit recently reviewed code
- **Third-party code**: Report upstream, don't try to fix dependencies

## OWASP Top 10 (2021)

### A01: Broken Access Control
- [ ] Deny by default - explicitly grant access
- [ ] Verify user owns requested resources
- [ ] Disable directory listing
- [ ] Log access control failures
- [ ] Rate limit API access
- [ ] Invalidate sessions on logout
- [ ] Use short-lived JWT tokens

### A02: Cryptographic Failures
- [ ] Encrypt sensitive data at rest
- [ ] Use TLS for data in transit
- [ ] Use strong algorithms (AES-256, RSA-2048+)
- [ ] Don't use deprecated crypto (MD5, SHA1, DES)
- [ ] Properly manage encryption keys
- [ ] Don't store passwords in plain text
- [ ] Use proper password hashing (bcrypt, argon2)

### A03: Injection
- [ ] Use parameterized queries (never concatenate)
- [ ] Validate and sanitize all input
- [ ] Use ORM/query builders
- [ ] Escape output based on context
- [ ] Use allowlists over denylists
- [ ] Limit query results

### A04: Insecure Design
- [ ] Threat model during design
- [ ] Use secure design patterns
- [ ] Implement defense in depth
- [ ] Separate business logic from security logic
- [ ] Design for failure scenarios
- [ ] Limit resource consumption

### A05: Security Misconfiguration
- [ ] Remove default credentials
- [ ] Disable unnecessary features
- [ ] Configure security headers
- [ ] Keep software updated
- [ ] Disable detailed error messages in production
- [ ] Review cloud permissions

### A06: Vulnerable Components
- [ ] Inventory all dependencies
- [ ] Monitor for CVEs
- [ ] Update dependencies regularly
- [ ] Remove unused dependencies
- [ ] Use trusted sources only
- [ ] Verify package integrity

### A07: Authentication Failures
- [ ] Implement MFA where possible
- [ ] Don't ship default credentials
- [ ] Implement account lockout
- [ ] Use secure session management
- [ ] Hash passwords properly
- [ ] Protect against brute force

### A08: Data Integrity Failures
- [ ] Verify software/data integrity
- [ ] Use signed updates
- [ ] Validate serialized data
- [ ] Review CI/CD pipeline security
- [ ] Use integrity checks for critical data

### A09: Logging & Monitoring Failures
- [ ] Log authentication events
- [ ] Log access control failures
- [ ] Log input validation failures
- [ ] Include context in logs
- [ ] Don't log sensitive data
- [ ] Set up alerting for suspicious activity

### A10: Server-Side Request Forgery
- [ ] Validate and sanitize URLs
- [ ] Use allowlists for external requests
- [ ] Block requests to internal networks
- [ ] Disable unnecessary URL schemas
- [ ] Don't return raw responses to users

## Authentication Checklist

### Password Security
- [ ] Minimum 12 characters
- [ ] Check against breached passwords
- [ ] Hash with bcrypt/argon2 (cost factor ≥ 12)
- [ ] Salt passwords (automatic with bcrypt)
- [ ] Never log passwords
- [ ] Secure password reset flow

### Session Management
- [ ] Generate secure random session IDs
- [ ] Regenerate ID after login
- [ ] Set appropriate expiration
- [ ] Use HttpOnly cookies
- [ ] Use Secure flag for HTTPS
- [ ] Use SameSite attribute
- [ ] Implement idle timeout

### Token Security (JWT)
- [ ] Use strong signing algorithm (RS256, ES256)
- [ ] Set short expiration (15 min for access)
- [ ] Validate all claims
- [ ] Store refresh tokens securely
- [ ] Implement token revocation
- [ ] Don't store sensitive data in payload

## Authorization Checklist

### Access Control
- [ ] Implement role-based access (RBAC)
- [ ] Check permissions on every request
- [ ] Verify resource ownership
- [ ] Use principle of least privilege
- [ ] Separate admin functionality
- [ ] Log authorization failures

### API Security
- [ ] Authenticate all endpoints
- [ ] Implement rate limiting
- [ ] Validate Content-Type
- [ ] Use CORS appropriately
- [ ] Don't expose internal errors
- [ ] Validate query parameters

## Input Validation

### General Rules
- [ ] Validate on server side (never trust client)
- [ ] Whitelist over blacklist
- [ ] Validate type, length, format, range
- [ ] Reject invalid input (don't sanitize silently)
- [ ] Use built-in validators

### Specific Inputs
| Input Type | Validation |
|------------|------------|
| Email | Format, length, domain |
| URL | Protocol, domain allowlist |
| File upload | Type, size, name, content |
| Numbers | Range, precision |
| Dates | Format, range |
| HTML | Sanitize, allowlist tags |

## Output Encoding

### Context-Specific Encoding
| Context | Encoding |
|---------|----------|
| HTML body | HTML entity encode |
| HTML attribute | Attribute encode |
| JavaScript | JS encode |
| URL | URL encode |
| CSS | CSS encode |
| JSON | JSON encode |

## Security Headers

### Essential Headers
```http
# Prevent XSS
Content-Security-Policy: default-src 'self'

# Prevent clickjacking
X-Frame-Options: DENY

# Prevent MIME sniffing
X-Content-Type-Options: nosniff

# Force HTTPS
Strict-Transport-Security: max-age=31536000; includeSubDomains

# Control referrer
Referrer-Policy: strict-origin-when-cross-origin

# Permissions policy
Permissions-Policy: geolocation=(), camera=()
```

## Error Handling

### Safe Error Messages
```
❌ "SQL error: column 'password' not found"
✅ "An error occurred. Please try again."

❌ "User admin@company.com not found"
✅ "Invalid username or password"

❌ Stack trace with file paths
✅ "Error reference: ABC123"
```

### Error Handling Rules
- [ ] Log detailed errors server-side
- [ ] Show generic messages to users
- [ ] Use error codes for support
- [ ] Never expose stack traces
- [ ] Don't reveal system information
- [ ] Handle all exceptions

## Sensitive Data

### Data Classification
| Type | Examples | Protection |
|------|----------|------------|
| Critical | Passwords, keys | Never store plain, encrypt |
| PII | Email, phone, SSN | Encrypt at rest, mask in logs |
| Financial | Card numbers, bank | PCI compliance, tokenize |
| Health | Medical records | HIPAA compliance, encrypt |

### Data Protection
- [ ] Encrypt sensitive data at rest
- [ ] Use TLS for transmission
- [ ] Mask in logs and displays
- [ ] Implement data retention policies
- [ ] Secure backup encryption
- [ ] Proper key management

## Code Review Security Focus

### Red Flags to Look For
- String concatenation in queries
- User input in system commands
- Hardcoded credentials
- Disabled security features
- TODO comments about security
- Custom crypto implementations
- Broad exception catches

### Questions to Ask
- Where does this data come from?
- Is this input validated?
- Who can access this?
- What if this fails?
- Is this logged appropriately?
- Could this be exploited?

## See Also

- `Skill: api-design` - Secure API design
- `Skill: database-patterns` - Database security
- `Skill: testing-strategies` - Security testing
