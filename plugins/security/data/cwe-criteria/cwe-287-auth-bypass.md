# CWE-287: Improper Authentication — Triage Criteria

## TRUE_POSITIVE when:
- Endpoint handles sensitive data but has no authentication check
- Authentication can be bypassed via parameter manipulation
- Token validation is incomplete (no signature check, no expiry check)
- Default credentials or backdoor accounts in production code
- Authentication logic uses == instead of constant-time comparison

## FALSE_POSITIVE when:
- Endpoint is intentionally public (health check, login, registration, public API)
- Authentication is handled by middleware/decorator not visible in the handler
- Framework handles authentication automatically (e.g., DRF permissions classes)
- The code is a public-facing API documented as unauthenticated

## SEVERITY adjustment:
- CRITICAL: Admin/privileged endpoint without auth
- HIGH: User data endpoint without auth
- MEDIUM: Weak authentication (no MFA, weak password policy)
- LOW: Missing auth on non-sensitive endpoint
