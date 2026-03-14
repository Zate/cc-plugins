---
name: security-checklist
description: This skill should be used for OWASP, security review, authentication, XSS, SQL injection prevention, CSRF, input validation, secure coding, vulnerability scanning
context: fork
---

# Security Checklist

Security review checklist based on OWASP Top 10.

## Input Validation

- [ ] Validate all user input
- [ ] Use parameterized queries (no SQL concat)
- [ ] Sanitize HTML output (prevent XSS)
- [ ] Validate file uploads (type, size)

## Authentication

- [ ] Hash passwords (bcrypt, argon2)
- [ ] Use secure session management
- [ ] Implement rate limiting
- [ ] Require strong passwords

## Authorization

- [ ] Check permissions on every request
- [ ] Use principle of least privilege
- [ ] Validate ownership of resources

## Data Protection

- [ ] Use HTTPS everywhere
- [ ] Don't log sensitive data
- [ ] Encrypt sensitive data at rest
- [ ] No secrets in source code

## Headers

```
Content-Security-Policy: default-src 'self'
X-Content-Type-Options: nosniff
X-Frame-Options: DENY
Strict-Transport-Security: max-age=31536000
```

## Common Vulnerabilities

| Vuln | Prevention |
|------|------------|
| SQL Injection | Parameterized queries |
| XSS | Output encoding |
| CSRF | CSRF tokens |
| Secrets | Environment variables |
