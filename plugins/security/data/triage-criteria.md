# Security Triage Criteria

Shared triage rules for `/security:scan` and `security/triage-agent`.

## Core Rule

Tools detect. The model triages. Do not invent findings and do not scan files that static tools did not flag.

## Inputs

- `.security/correlated.json` - correlated static findings.
- `.security/recon.json` - project stack and framework signals.
- `.security/profile.json` - optional project security profile.
- `data/cwe-criteria/cwe-*.md` - load only files matching CWEs present in correlated findings.

## Context Budget

For each finding, read only `line - 2` through `line + 2` unless the loaded CWE criteria explicitly requires one additional local check. Do not read whole source files.

## Decision Tree

Apply these checks in order and take the first matching branch.

1. Test fixture or test data path (`testdata/`, `fixtures/`, `test_fixtures/`, `__fixtures__/`) -> `FALSE_POSITIVE`.
2. CWE-798 in a `.pem`, `.key`, or `.crt` under a test path -> `FALSE_POSITIVE`.
3. Test file (`*_test.*`, `test_*`, `*_spec.*`, `tests/`, `spec/`, `__tests__/`) -> `FALSE_POSITIVE` when fake data is obvious; otherwise `NEEDS_REVIEW` with severity `LOW`.
4. CWE-798 credential checks:
   - Placeholder (`changeme`, `xxx`, `your-*-here`, `TODO`, `REPLACE`) -> `FALSE_POSITIVE`.
   - `.env.example` or `.env.template` -> `FALSE_POSITIVE`.
   - Hash-like value (`$2b$`, `$argon2`, hex string 32+ chars) -> `FALSE_POSITIVE`.
   - Public key, not private key -> `FALSE_POSITIVE`.
   - Runtime environment lookup, not literal credential -> `FALSE_POSITIVE`.
   - Otherwise -> `TRUE_POSITIVE`.
5. Framework default protection applies and no bypass indicator exists -> `FALSE_POSITIVE`.
6. User-controlled input reaches dangerous sink:
   - Clear source-to-sink path -> `TRUE_POSITIVE`.
   - No source evidence in allowed context -> `FALSE_POSITIVE`.
   - Indeterminate -> `NEEDS_REVIEW`.
7. Default -> `NEEDS_REVIEW`.

## Framework Protections

| Framework | CWE | Default Protection | Bypass Indicators |
|-----------|-----|--------------------|-------------------|
| Django | CWE-89 | ORM parameterizes queries | `.raw()`, `.extra()`, `connection.cursor()` |
| Django | CWE-79 | Template auto-escaping | `|safe`, `mark_safe()`, `{% autoescape off %}` |
| Django | CWE-352 | CSRF middleware | `@csrf_exempt` |
| SQLAlchemy | CWE-89 | ORM parameterizes | `text()` with f-string, `.execute()` with string concat |
| React | CWE-79 | JSX auto-escapes | `dangerouslySetInnerHTML` |
| Rails | CWE-89 | ActiveRecord parameterizes | `.find_by_sql()`, `.execute()` |
| Rails | CWE-79 | ERB auto-escapes | `.html_safe`, `raw()` |
| Express | CWE-89 | None | Always check ORM or driver usage |
| FastAPI | CWE-89 | None | Check ORM or driver usage |
| Gin/Echo | CWE-89 | None | Check ORM or driver usage |

## Severity Table

| CWE | Base Severity | Upgrade If | Downgrade If |
|-----|---------------|------------|--------------|
| CWE-78 | CRITICAL | - | CLI tool where operator is the only input source: HIGH |
| CWE-89 | HIGH | Public unauthenticated endpoint: CRITICAL | Internal-only endpoint: MEDIUM |
| CWE-79 | HIGH | Stored XSS: CRITICAL | Self-XSS only: LOW |
| CWE-22 | HIGH | Reads arbitrary files: CRITICAL | Write-only and restricted: MEDIUM |
| CWE-798 | CRITICAL | Production API keys/passwords | Dev/staging credentials: HIGH |
| CWE-502 | CRITICAL | Network input: CRITICAL | Local cache: MEDIUM |
| CWE-918 | HIGH | Can reach metadata or internal network: CRITICAL | External-only fetch: MEDIUM |
| CWE-352 | MEDIUM | State-changing operation: HIGH | Read-only: LOW |
| CWE-287 | HIGH | Admin or privileged endpoint: CRITICAL | Non-sensitive endpoint: MEDIUM |
| CWE-770 | MEDIUM | Public expensive operation: HIGH | Internal-only: LOW |
| Other | MEDIUM | Public endpoint: HIGH | Test/internal: LOW |

## Explanation Format

For `TRUE_POSITIVE`:

```text
[What the vulnerability is]. [Why this instance is exploitable]. [What input reaches the sink].
```

For `FALSE_POSITIVE`:

```text
[Tool rule that fired]. [Why it is a false positive, citing the protection or reason].
```

For `NEEDS_REVIEW`:

```text
[What the tool flagged]. [Why it cannot be determined from static context]. [What a reviewer should check].
```

## Remediation Format

For `TRUE_POSITIVE` and `NEEDS_REVIEW`, provide one minimal fix:

```text
Replace [vulnerable pattern] with [secure pattern]. Example: `[one-line code fix]`.
```

Use the matching remediation skill for deeper fixes:

- Injection and XSS: `remediation-injection`
- Secrets, auth, access control, deserialization: `remediation-auth`
- Crypto and TLS: `remediation-crypto`
- Path traversal, debug mode, headers, deployment: `remediation-config`
