# CWE-918: Server-Side Request Forgery (SSRF) — Triage Criteria

## TRUE_POSITIVE when:
- User-controlled URL passed to HTTP client (requests.get, fetch, http.Get)
- No URL allowlist or domain validation
- Can target internal services (169.254.169.254, localhost, internal DNS)
- Redirect following enabled without destination validation

## FALSE_POSITIVE when:
- URL is hardcoded or from configuration (not user-controlled)
- URL is validated against an allowlist of domains
- URL scheme is restricted (only https://)
- Internal-only service with no external input
- DNS resolution is restricted to prevent internal network access

## SEVERITY adjustment:
- CRITICAL: Can reach cloud metadata (169.254.169.254) or internal services
- HIGH: Can make arbitrary external requests with user-controlled URL
- MEDIUM: URL partially controlled (e.g., only path component)
- LOW: Limited to specific domains via allowlist
