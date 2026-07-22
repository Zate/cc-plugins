# Authentication, Authorization, OAuth/OIDC, and Token Standards Lens

Use this reference for `security-authz-review`, Deep mode trust/identity review, and standards deviation findings. This is standards-informed guidance, not a compliance checklist.

## Core review questions

- What is the root of trust for identity?
- Which component authenticates the user, workload, integration, or service?
- Which claims are authoritative, and who can mint or modify them?
- Where is authorization enforced: gateway, middleware, handler, data layer, policy engine, or convention?
- Does authorization fail closed when identity, config, policy, or parsing fails?
- Is tenant isolation enforced technically at every access path?
- Are privileged actions audited and alertable?

## Authentication expectations

Look for:
- Clear authentication boundary and protected route registration.
- No sensitive endpoint reachable without auth unless intentionally public.
- Secure credential storage using modern password hashing when passwords exist.
- Account recovery, reset, and factor lifecycle controls.
- MFA or step-up auth for sensitive operations where applicable.
- Protection against brute force, credential stuffing, and enumeration.
- Safe default behavior for missing, malformed, expired, or revoked credentials.

Common standards deviations:
- Authentication checks scattered across handlers with no central enforcement.
- Default credentials, backdoor accounts, or environment-dependent bypasses.
- Authentication logic that treats parser errors or missing config as success.
- Secrets, passwords, tokens, or reset links logged or stored unsafely.

## Session management expectations

Look for:
- Cryptographically random session identifiers with sufficient entropy.
- Session invalidation on logout, password reset, credential rotation, and account disablement.
- Idle and absolute timeouts appropriate to sensitivity.
- Cookie flags: Secure, HttpOnly, SameSite, path/domain scoping.
- CSRF protections for cookie-authenticated state-changing requests.
- Session fixation prevention during login or privilege changes.

Common standards deviations:
- Sessions that never expire or cannot be revoked.
- Cookies missing Secure/HttpOnly/SameSite where applicable.
- State-changing endpoints relying only on browser cookies without CSRF protection.
- Session IDs derived from predictable data.

## Authorization expectations

Look for:
- Object-level authorization on every object read/write/delete/export/admin action.
- Function-level authorization on privileged routes, jobs, tools, webhooks, admin APIs, and internal endpoints.
- Least-privilege roles and scopes.
- Tenant scoping at data-access boundaries, not only at UI or handler convention.
- Centralized policy helpers or policy engine with tests for allowed and denied cases.
- Fail-closed behavior when policy checks fail, policy data is missing, or identity cannot be resolved.

Common standards deviations:
- IDOR-prone resource access using caller-provided IDs without ownership/tenant checks.
- Authorization enforced by naming convention or developer discipline.
- Admin/support paths that bypass normal policy without strong audit and approval.
- Background jobs, exports, webhooks, or internal APIs that skip tenant or user authorization.

## JWT and self-contained token expectations

Look for validation of:
- Signature and allowed algorithms; never accept `alg: none`.
- Issuer (`iss`).
- Audience (`aud`).
- Expiration (`exp`) and not-before (`nbf`) where used.
- Key ID (`kid`) handling, JWKS source, cache behavior, and key rotation.
- Subject (`sub`) stability and trustworthiness.
- Tenant, role, scope, and privilege claims provenance.
- Replay and revocation strategy for high-risk tokens.

Common standards deviations:
- Decoding JWTs without verifying signatures.
- Accepting tokens without issuer/audience/expiry checks.
- Trusting role, tenant, or admin claims from an untrusted issuer.
- Confusing ID tokens, access tokens, and application session tokens.
- Using weak shared secrets or mixing HS/RS algorithm assumptions.

## OAuth/OIDC client expectations

Look for:
- Authorization Code flow with PKCE for public clients and modern flows for confidential clients.
- Exact redirect URI validation.
- `state` validation for CSRF protection.
- `nonce` validation for OIDC ID tokens where applicable.
- No access tokens or credentials in URLs.
- Correct ID token validation: issuer, audience, nonce, expiry, signature.
- Clear separation between authentication via OIDC and authorization to application resources.
- Safe handling of refresh tokens and token storage.

Common standards deviations:
- Missing PKCE for public clients.
- Weak or partial redirect URI matching.
- Missing or unenforced `state`/`nonce`.
- Treating OAuth access token possession as local app authorization without resource checks.
- Exposing tokens in query strings, logs, browser storage, or referrers.

## OAuth resource server expectations

Look for:
- Access token validation against the correct issuer and audience/resource.
- Scope and permission enforcement per endpoint/action/object.
- Token introspection or JWKS validation configured safely.
- Sender-constrained token support where required by risk profile.
- Rejection of tokens minted for another service or environment.

Common standards deviations:
- Accepting any valid token from the identity provider regardless of audience.
- Coarse scopes such as `admin` or `*` without object-level checks.
- No distinction between user tokens, service tokens, and integration tokens.

## Service-to-service and delegated authority

Look for:
- Workload identity with least privilege.
- Explicit delegation model when one service acts for a user or tenant.
- Preservation of original principal and tenant context across service calls.
- Clear distinction between service authority and user authority.
- Audit events that record both actor and effective subject.

Common standards deviations:
- Shared service credentials with broad tenant/global reach.
- Losing original user/tenant identity across queues, jobs, or internal APIs.
- Downstream services trusting caller-provided identity headers without verification.
- Support/operator tools that act as users without traceability.

## Validation handoff ideas

For auth findings, validation usually needs:
- Two users in same tenant.
- Two users in different tenants.
- One low-privilege user and one admin/support user.
- Expired, malformed, wrong-audience, wrong-issuer, and missing-token cases.
- A resource owned by another user/tenant.
- Audit log access to confirm allowed and denied events.

Expected safe behavior:
- Unauthorized requests are denied consistently.
- Denials are logged without leaking sensitive data.
- Missing/malformed/expired credentials fail closed.
- Cross-tenant object access is denied at all access paths.
