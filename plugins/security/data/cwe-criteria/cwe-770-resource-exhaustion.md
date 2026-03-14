# CWE-770: Allocation of Resources Without Limits — Triage Criteria

## TRUE_POSITIVE when:
- No rate limiting on public-facing endpoints
- Unbounded query results (no pagination, no LIMIT)
- File upload without size limits
- Regular expressions vulnerable to ReDoS (catastrophic backtracking)
- Unbounded loops processing user input
- No connection pool limits on database/external service connections

## FALSE_POSITIVE when:
- Rate limiting is applied at infrastructure level (API gateway, WAF, nginx)
- Internal-only service not exposed to public
- Resource limits set at container/OS level
- Pagination is implemented but detected as "no LIMIT clause" (ORM handles it)

## SEVERITY adjustment:
- HIGH: Public endpoint, no rate limiting, expensive operation (DB query, file I/O)
- MEDIUM: Public endpoint, no rate limiting, cheap operation
- LOW: Internal endpoint, or rate limiting at infrastructure level
- LOW: ReDoS in non-critical path
