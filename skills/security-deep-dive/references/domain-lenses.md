# Domain Lenses

Use lenses as investigation prompts, not as rigid checklists that replace judgment.

## Trust model
- Principals, roots of trust, authoritative claims, delegated authority.
- Technical enforcement vs convention.
- Catastrophic assumptions if false.

## AuthN/AuthZ
- Issuer, audience, expiry, nonce/state, redirect URI, token binding, session lifecycle, revocation.
- Object-level and function-level authorization.
- Admin/support/break-glass flows.
- Fail-open/fail-closed on missing identity, missing config, parser failure, and policy lookup failure.

## Multi-tenancy
- Storage/query-level tenant enforcement.
- Missing/empty/default/stale/attacker-controlled tenant IDs.
- Cross-tenant effects through cache, logs, search, queues, jobs, exports, billing, and availability.

## Data protection and privacy
- Data classification, minimization, logging, retention, deletion, export, backup, encryption, key ownership, support/operator access, regionality.

## Abuse and misuse
- Enumeration, scraping, signup/login abuse, spam/fraud, automation, cost amplification, expensive operations, quotas, rate limits, per-tenant containment.

## Detection, response, and recovery
- Security event taxonomy, audit logs, privileged action logs, policy denials, exports, admin changes, suspicious tool calls.
- Alerting, retention, correlation IDs, tamper resistance, revocation, quarantine, kill switches, forensics, restore.

## Assume breach
- Runtime identity, secrets, network reachability, data/control-plane reach, persistence, log tampering, lateral movement, containment, recovery.

## Supply chain and SDLC
- Lockfiles, dependency freshness, SBOM, provenance, signing, CI isolation, branch protection, CODEOWNERS, secret scanning, SAST/SCA, deployment approvals, rollback, patch ownership.

## Infrastructure/cloud/runtime isolation
- IAM, service accounts, RBAC, NetworkPolicy, egress, IMDS access, container security context, filesystem permissions, KMS, secret mounts, environment separation.

## AI/agent/tool safety
- Prompt injection, model-output-as-input, MCP trust boundaries, tool approvals, memory poisoning, credentials exposed to tools, sandboxing, human approval bypass.

## Resilience and availability
- DoS, algorithmic complexity, retry storms, queue exhaustion, fanout amplification, storage growth, external API quota exhaustion, per-tenant blast radius, graceful degradation.

## Standards and maturity
- Homegrown crypto, custom token protocols, scattered security checks, implicit admin trust, security-by-convention, undocumented exceptions, missing tests/guardrails.
