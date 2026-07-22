# ASVS-Inspired Review Lens

Use OWASP ASVS as a control-quality lens, not as the whole engagement. ASVS helps identify mature application security expectations, but it does not replace architecture review, abuse analysis, assume-breach analysis, operational readiness, or external adoption judgment.

## Verification depth mapping

| Review depth | ASVS-style depth | Use |
|---|---|---|
| Triage | L1 themes only | Fast baseline and obvious control gaps |
| Focused | Relevant L1/L2 themes | Domain-specific control review |
| Deep | Relevant L1/L2 plus selected L3 themes | Engagement-grade review for high-value systems |
| External adoption | Scenario-dependent | Required evidence and compensating controls |

## Chapter map

| Chapter | Domain | Primary focus |
|---|---|---|
| V1 | Encoding & Sanitization | Injection prevention, output encoding, unsafe deserialization |
| V2 | Validation & Business Logic | Server-side validation, business workflow integrity, anti-automation |
| V3 | Web Frontend Security | Browser security, cookies, CSP, HSTS, origin separation |
| V4 | API & Web Service | API security, content-type validation, GraphQL, WebSocket security |
| V5 | File Handling | Upload/download validation, storage safety, path traversal prevention |
| V6 | Authentication | Passwords, MFA, account lifecycle, identity provider auth |
| V7 | Session Management | Session ID entropy, logout, timeout, cookie security |
| V8 | Authorization | Request-level access control, IDOR prevention, least privilege |
| V9 | Self-contained Tokens | JWT/signature/expiry/issuer/audience claim validation |
| V10 | OAuth & OIDC | OAuth clients/servers, resource servers, OIDC clients/providers |
| V11 | Cryptography | Key management, CSPRNG, modern algorithms, secure hashing |
| V12 | Secure Communications | TLS, certificate validation, secure transport |
| V13 | Configuration | Secure defaults, secrets, dependency scanning, deployment config |
| V14 | Data Protection | Classification, encryption, minimization, sensitive-data handling |
| V15 | Secure Coding | Secure coding practices, static analysis, dependency hygiene |
| V16 | Security Logging | Security event logging, log protection, safe error handling |
| V17 | WebRTC | WebRTC media/signaling security when applicable |

## Feature-to-chapter routing

| Feature | Primary chapters | Secondary chapters |
|---|---|---|
| Authentication | V6 | V7, V11, V16 |
| OAuth/OIDC | V10 | V6, V7, V9, V12, V16 |
| Authorization / tenant isolation | V8 | V4, V14, V16 |
| File upload/download | V5 | V1, V14, V16 |
| API | V4 | V1, V2, V8, V16 |
| GraphQL | V4 | V8, V2, V16 |
| Database-backed app | V1, V2 | V8, V14 |
| WebSocket | V4, V12 | V6, V8, V16 |
| Frontend/browser app | V3 | V1, V7, V10 |
| Logging/audit | V16 | V14, V13 |
| Secrets/config/deployment | V13 | V11, V12, V15 |

## How to use this lens

For each applicable chapter:
1. Identify whether the repository contains relevant evidence.
2. Map observed controls to expected mature patterns.
3. Report gaps as VULN, DESIGN, ASSURANCE, OPS, STD, HYGIENE, or LATENT as appropriate.
4. Avoid claiming ASVS compliance unless the user explicitly asks for compliance-style mapping and evidence is sufficient.

## Reporting standards deviations

Use `STD` findings when the implementation deviates from mature ASVS-style expectations even if exploitability is not proven. Examples:
- Custom token validation without issuer/audience/expiry checks.
- Access control enforced by handler convention rather than central policy.
- Sensitive operations without audit events.
- Upload handling without explicit content, extension, size, storage, and execution controls.
- GraphQL APIs without depth/complexity limits.
