# Standards and Norms Map

Use standards and mature industry norms to guide judgment. Do not turn the review into checklist compliance; map standards when they clarify risk.

## Application security
- OWASP ASVS for web/application control expectations.
- OWASP Top 10 categories for common risk framing, but do not limit review to them.

## AuthN/AuthZ
- OAuth 2.0 Security Best Current Practice for OAuth client/server behavior, redirect URI handling, token leakage, sender-constrained tokens, and deprecated flows.
- OpenID Connect Core for ID token, nonce, issuer, audience, and discovery/JWKS behavior.
- JWT best practices for algorithm confusion, issuer/audience validation, expiry, key rotation, and claim trust.

## Secure SDLC and supply chain
- NIST Secure Software Development Framework for secure development, vulnerability response, and supply-chain risk management.
- SLSA/in-toto concepts for build provenance and artifact integrity.
- OWASP secure pipeline and component analysis guidance for CI/CD and dependency risk.

## Cloud/runtime
- Least privilege, separation of duties, defense in depth, network segmentation, immutable infrastructure, workload identity, and secrets rotation.

## Privacy and data protection
- Data minimization, purpose limitation, retention/deletion, access control, auditability, encryption, and regionality expectations.

## AI/agent systems
- Treat model output and retrieved content as untrusted input.
- Tool invocation should default closed for dangerous actions.
- Separate user instructions, system instructions, tool outputs, and untrusted content.
- Minimize credential exposure to tools and model context.

## Standards deviation register

Use this for non-standard but not necessarily vulnerable patterns:

```markdown
### STD-N — <title>

**Domain:** AuthN / AuthZ / OAuth / OIDC / JWT / Crypto / Logging / Supply Chain / Privacy / AI Safety / Other
**Severity:** High / Medium / Low
**Confidence:** ✅ VERIFIED / ⚠️ IMPLIED / ❓ UNKNOWN
**Observed design:**
**Expected standard pattern:**
**Deviation:**
**Why a senior reviewer would care:**
**Risk today:**
**Risk if system scales:**
**Evidence required to accept this deviation:**
**Recommendation:**
```
