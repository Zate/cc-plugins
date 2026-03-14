# CWE-352: Cross-Site Request Forgery (CSRF) — Triage Criteria

## TRUE_POSITIVE when:
- State-changing endpoint (POST/PUT/DELETE) with no CSRF token validation
- Cookie-based authentication without SameSite attribute
- Form submission without CSRF middleware enabled

## FALSE_POSITIVE when:
- API uses Bearer token authentication (not cookies) — CSRF not applicable
- Application is a pure REST API with no browser-based auth
- Framework CSRF middleware is enabled globally (Django CSRF middleware, Rails protect_from_forgery)
- Endpoint uses custom header requirement (X-Requested-With) which browsers restrict
- SameSite=Strict or SameSite=Lax cookies prevent cross-origin requests

## SEVERITY adjustment:
- HIGH: State-changing action (transfer funds, delete account) without CSRF protection
- MEDIUM: Profile update, settings change without CSRF
- LOW: Non-destructive action, or CSRF mitigated by SameSite cookies
- N/A: Pure API with Bearer auth — mark as FALSE_POSITIVE
