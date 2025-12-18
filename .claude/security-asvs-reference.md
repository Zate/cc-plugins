# ASVS 5.0 Reference for Security Plugin

This document provides the ASVS 5.0 chapter structure and control objectives for building domain auditor agents.

## Related Documents
- **Implementation Plan**: [devloop-plan.md](devloop-plan.md) - Task breakdown and phases
- **Spike Report**: [security-spike-report.md](security-spike-report.md) - Architecture decisions and rationale
- **Secure Coding Rules**: `~/projects/claude-secure-coding-rules/` - Vulnerability patterns and remediation examples

## ASVS Levels

| Level | Name | Use Case |
|-------|------|----------|
| L1 | Opportunistic | All applications (minimum) |
| L2 | Standard | Most applications |
| L3 | Advanced | Critical applications, high-value transactions |

**Audit Depth Mapping:**
- Quick Scan → Level 1
- Standard Audit → Level 2
- Comprehensive Audit → Level 3

---

## V1: Encoding and Sanitization (28 requirements)

### Control Objective
Ensure the application correctly encodes and decodes data to prevent injection attacks.

### Sections
- V1.1 Encoding and Sanitization Architecture
- V1.2 Injection Prevention (SQL, OS, LDAP, XPath, NoSQL, template)
- V1.3 Sanitization (HTML, SVG, markup)
- V1.4 Memory, String, and Unmanaged Code
- V1.5 Safe Deserialization

### Key Checks
- Input decoded into canonical form only once
- Output encoding as final step before interpreter use
- Parameterized queries for all database access
- No string concatenation for command building
- Safe deserialization (use JSON, avoid unsafe serialization formats)

---

## V2: Validation and Business Logic (15 requirements)

### Control Objective
Ensure input validation enforces business expectations and prevents logic bypass.

### Sections
- V2.1 Validation and Business Logic Documentation
- V2.2 Input Validation
- V2.3 Business Logic Security
- V2.4 Anti-automation

### Key Checks
- Server-side validation (never trust client)
- Allowlist validation over denylist
- Sequential step enforcement (no skipping)
- Rate limiting on sensitive operations
- Anti-automation for data exfiltration prevention

---

## V3: Web Frontend Security (32 requirements)

### Control Objective
Ensure browsers are protected against common web attacks through proper headers and configurations.

### Sections
- V3.1 Web Frontend Security Documentation
- V3.2 Unintended Content Interpretation
- V3.3 Cookie Setup
- V3.4 Browser Security Mechanism Headers
- V3.5 Browser Origin Separation
- V3.6 External Resource Integrity
- V3.7 Other Browser Security Considerations

### Key Checks
- Content-Security-Policy with restrictive defaults
- Strict-Transport-Security (HSTS) with 1+ year max-age
- X-Content-Type-Options: nosniff
- X-Frame-Options or CSP frame-ancestors
- Cookie attributes: Secure, HttpOnly, SameSite, __Host- prefix
- Subresource integrity for external scripts

---

## V4: API and Web Service (17 requirements)

### Control Objective
Ensure API endpoints are secure against common attack patterns.

### Sections
- V4.1 Generic Web Service Security
- V4.2 HTTP Message Structure Validation
- V4.3 GraphQL
- V4.4 WebSocket

### Key Checks
- Content-Type validation
- HTTP smuggling prevention
- GraphQL query cost analysis / depth limiting
- WebSocket authentication and authorization
- Rate limiting per endpoint

---

## V5: File Handling (14 requirements)

### Control Objective
Ensure files are handled securely throughout upload, storage, and download.

### Sections
- V5.1 File Handling Documentation
- V5.2 File Upload and Content
- V5.3 File Storage
- V5.4 File Download

### Key Checks
- File extension and content type validation
- Upload size limits
- Uploaded files cannot execute as code
- Path traversal prevention
- Safe filename encoding in responses

---

## V6: Authentication (44 requirements)

### Control Objective
Ensure robust authentication mechanisms protect user accounts.

### Sections
- V6.1 Authentication Documentation
- V6.2 Password Security
- V6.3 General Authentication Security
- V6.4 Authentication Factor Lifecycle and Recovery
- V6.5 General Multi-factor Authentication Requirements
- V6.6 Out-of-Band Authentication Mechanisms
- V6.7 Cryptographic Authentication Mechanism
- V6.8 Authentication with an Identity Provider

### Key Checks
- Minimum 8 character passwords
- Password breach checking (3000+ known passwords)
- Secure password hashing (bcrypt, argon2)
- Account lockout after failed attempts
- MFA for sensitive operations
- Secure credential recovery flow
- Session regeneration on login

---

## V7: Session Management (18 requirements)

### Control Objective
Ensure sessions are created, managed, and terminated securely.

### Sections
- V7.1 Session Management Documentation
- V7.2 Fundamental Session Management Security
- V7.3 Session Timeout
- V7.4 Session Termination
- V7.5 Defenses Against Session Abuse
- V7.6 Federated Re-authentication

### Key Checks
- 128+ bits of entropy in session tokens
- Server-side session validation
- Session regeneration on authentication
- Idle and absolute timeouts
- Logout invalidates session server-side
- Session binding to prevent hijacking

---

## V8: Authorization (11 requirements)

### Control Objective
Ensure access control decisions are made correctly and consistently.

### Sections
- V8.1 Authorization Documentation
- V8.2 General Authorization Design
- V8.3 Operation Level Authorization
- V8.4 Other Authorization Considerations

### Key Checks
- Deny by default
- Consistent enforcement at trusted service layer
- Resource ownership verification
- Function-level access control
- Adaptive/contextual authorization

---

## V9: Self-contained Tokens (7 requirements)

### Control Objective
Ensure JWT and similar tokens are validated correctly.

### Sections
- V9.1 Token Source and Integrity
- V9.2 Token Content

### Key Checks
- Signature/MAC validation before trust
- Algorithm allowlist enforcement
- nbf/exp claim validation
- Audience (aud) validation
- Token not used beyond intended scope

---

## V10: OAuth and OIDC (50 requirements)

### Control Objective
Ensure OAuth 2.0 and OpenID Connect flows are implemented securely.

### Sections
- V10.1 Generic OAuth and OIDC Security
- V10.2 OAuth Client
- V10.3 OAuth Resource Server
- V10.4 OAuth Authorization Server
- V10.5 OIDC Client
- V10.6 OpenID Provider
- V10.7 Consent Management

### Key Checks
- PKCE for public clients
- State parameter validation
- Authorization code single-use
- Short-lived tokens
- Secure token storage
- Proper redirect URI validation
- Consent management and revocation

---

## V11: Cryptography (32 requirements)

### Control Objective
Ensure cryptographic operations use approved algorithms and proper key management.

### Sections
- V11.1 Cryptographic Inventory and Documentation
- V11.2 Secure Cryptography Implementation
- V11.3 Encryption Algorithms
- V11.4 Hashing and Hash-based Functions
- V11.5 Random Values
- V11.6 Public Key Cryptography
- V11.7 In-Use Data Cryptography

### Key Checks
- Minimum 128-bit security level
- Industry-validated implementations
- No deprecated algorithms (MD5, SHA1, DES)
- Cryptographically secure random numbers
- Proper key management lifecycle
- No hardcoded keys

---

## V12: Secure Communication (13 requirements)

### Control Objective
Ensure all communications use TLS and certificates are validated.

### Sections
- V12.1 General TLS Security Guidance
- V12.2 HTTPS Communication with External Facing Services
- V12.3 General Service to Service Communication Security

### Key Checks
- TLS 1.2+ required, 1.3 preferred
- No fallback to insecure protocols
- Certificate validation enabled
- Certificate pinning for mobile/high-security
- Strong cipher suites only

---

## V13: Configuration (18 requirements)

### Control Objective
Ensure secure configuration and secrets management.

### Sections
- V13.1 Configuration Documentation
- V13.2 Backend Communication Configuration
- V13.3 Secret Management
- V13.4 Unintended Information Leakage

### Key Checks
- Secrets in vault/key management system
- No secrets in source code or environment variables
- No debug info in production
- No .git/.svn in deployments
- Service-to-service authentication

---

## V14: Data Protection (15 requirements)

### Control Objective
Ensure sensitive data is identified, classified, and protected appropriately.

### Sections
- V14.1 Data Protection Documentation
- V14.2 General Data Protection
- V14.3 Client-side Data Protection

### Key Checks
- Data classification scheme
- Sensitive data encryption at rest
- No sensitive data in URLs
- Minimal data retention
- Secure data deletion

---

## V15: Secure Coding and Architecture (20 requirements)

### Control Objective
Ensure secure coding patterns and architectural decisions.

### Sections
- V15.1 Secure Coding and Architecture Documentation
- V15.2 Security Architecture and Dependencies
- V15.3 Defensive Coding
- V15.4 Safe Concurrency

### Key Checks
- SBOM maintained for dependencies
- Dependency vulnerability scanning
- Mass assignment protection
- Safe concurrency patterns
- Defense in depth architecture

---

## V16: Security Logging and Error Handling (19 requirements)

### Control Objective
Ensure security events are logged and errors handled securely.

### Sections
- V16.1 Security Logging Documentation
- V16.2 General Logging
- V16.3 Security Events
- V16.4 Log Protection
- V16.5 Error Handling

### Key Checks
- Authentication events logged
- Authorization failures logged
- Logs include who/what/when/where
- No sensitive data in logs
- Logs protected from modification
- Generic error messages to users
- Detailed errors logged internally

---

## V17: WebRTC (15 requirements)

### Control Objective
Ensure WebRTC implementations are secure.

### Sections
- V17.1 TURN Server
- V17.2 Media
- V17.3 Signaling

### Key Checks
- TURN server access restrictions
- DTLS certificate management
- Signaling server rate limiting
- Media encryption (SRTP)

---

## Using This Reference

When building domain auditor agents:

1. **Copy the Control Objective** as the agent's mission statement
2. **Use the Sections** to structure the audit checklist
3. **Use the Key Checks** as specific items to verify
4. **Reference the requirement count** to gauge thoroughness

Example agent context:
```markdown
## Control Objective
[Paste from this document]

## Audit Areas
[Use sections as headers]

## Key Checks
[Use as specific verification items]
```

## Source

ASVS 5.0: https://owasp.org/www-project-application-security-verification-standard/
CSV Data: https://raw.githubusercontent.com/OWASP/ASVS/v5.0.0/5.0/docs_en/OWASP_Application_Security_Verification_Standard_5.0.0_en.csv
