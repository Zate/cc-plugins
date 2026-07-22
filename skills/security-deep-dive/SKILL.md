---
name: security-deep-dive
description: "Senior-grade security review skill that produces a living threat model, finding list, and decision brief through iterative deepening passes."
version: "3.0.0"
author: "Zate Berg"
allowed-tools:
  - open_files
  - expand_code_chunks
  - grep
  - bash
  - create_file
  - find_and_replace_code
  - expand_folder
tags:
  - security
  - architecture
  - threat-modelling
---

# Security Deep Dive Skill

Produce a senior-grade, evidence-backed security review of a repository or system. The skill emulates how a seasoned reviewer actually works: discovery, analysis, and reporting happen together, in a small number of deepening passes, against a small number of living artifacts.

This skill explicitly avoids document bloat. It produces three living artifacts and revisits them until they earn the synthesis.

**When to use:** the user asks for a security review, threat model, security audit, deep dive, abuse review, assume-breach analysis, external adoption review, validation handoff, or any framing that requires security judgment.

**When not to use:** style review, single-line code feedback, or remediation implementation without a security-analysis request.

---

## Prime directive

Decision-useful truth, earned through repeated passes over a small artifact set.

In order:

1. Accuracy and breadth before completeness theatre.
2. Few deep artifacts revisited > many shallow artifacts written once.
3. Discovery and analysis happen together, not in separate phases.
4. Explicit uncertainty with verification path > confident guesses.
5. Standards-aware critique > only finding directly exploitable bugs.
6. Operationally actionable framing > abstract vulnerability labels.

If a review cannot complete in one session, the agent stops at a deepening-pass boundary and continues later. It must not silently narrow scope, declare premature completion, or compress the review to fit.

---

## Modes

Three modes. Everything else is a focused variant of these.

| Mode | Purpose | Output |
|---|---|---|
| **Triage** | Fast signal, top risks, recommended next mode | Inline only unless user asks |
| **Focused** | One domain at depth (authz, abuse/ops, assume breach, external adoption, validation handoff, etc.) | One scoped report |
| **Deep** | Senior-grade engagement | Three living artifacts (and three optional ones) |

Choose the smallest mode that answers the user's decision need. Expand scope when adjacent trust boundaries materially affect the answer. Never narrow auth, tenant isolation, adoption, or assume-breach so far that identity propagation, downstream authorization, auditability, or blast radius are excluded.

---

## Living artifacts

Deep mode produces three core artifacts in `.plan/security/` (or a directory the user specifies):

| Artifact | Purpose |
|---|---|
| `threat-model.md` | Single source of truth for system view: context, trust boundaries, attack surface, data flows, identity, abuse/ops surface, assume-breach narrative, standards posture |
| `findings.md` | All issues, grouped by surface category, with full evidence and recommendation |
| `brief.md` | Decision-grade synthesis: verdict, top risks, structural diagnosis, remediation order, coverage statement, open questions |

Optional artifacts, only when justified:

| Artifact | When to add |
|---|---|
| `review-plan.md` | Multi-session review where phase tracking and resumption are needed |
| `validation-handoff.md` | Follow-on team will validate findings dynamically |
| `uncertainties.md` | Material unknowns that need their own register and verification paths |

Do not add other artifacts. If something does not belong in one of these, it is probably noise.

---

## Iterative deepening — Deep mode workflow

Deep mode runs as **three deepening passes** over the same three artifacts. The goal is repeated revisit, not sequential phases that freeze each output.

### Pass 1 — Broad first cut

Goal: a usable but admittedly shallow draft of all three artifacts.

Do, in one continuous pass:

1. Orient on repo shape, runtime, frameworks, deployment, and major subsystems.
2. Inventory the universal attack surface (see Attack-surface lens below).
3. Sketch trust boundaries, identity propagation, and the highest-risk data flows in `threat-model.md`, with at least one Mermaid diagram.
4. Capture any obviously concerning issues in `findings.md`, grouped by surface category.
5. Write a draft `brief.md` with verdict, top risks, and explicit acknowledgment that this is a Pass 1 cut.

Pass 1 is not allowed to declare the review complete.

### Pass 2 — Targeted deepening

Goal: fix the weakest parts of the draft and broaden coverage.

Do:

1. Identify the weakest surface category, the weakest subsystem, and the weakest claim in the brief.
2. Re-read code in those areas with intent: discovery and analysis simultaneously.
3. Update `threat-model.md` directly — do not append, edit. The threat model is a living document.
4. Promote, demote, merge, split, and add findings in `findings.md`. Group by surface category.
5. Run a breadth check: every universal surface category must either contain inventoried surfaces or be explicitly marked not applicable with evidence.
6. Update `brief.md` to reflect new understanding.

If one subsystem still dominates findings without explanation, do another targeted deepening before continuing.

### Pass 3 — Adversarial closure

Goal: pressure-test the artifact set the way a reviewer would before signing it.

Do:

1. Walk the worst plausible attack chain end to end. Add a chain section to `findings.md` with evidence, attacker class, blast radius, and minimum/full defence.
2. Run an assume-breach pass for each externally reachable or high-trust component. Update `threat-model.md` with blast radius, persistence, detection, containment, and recovery for each.
3. Run an abuse and operations pass: telemetry, alerting, evidence tampering, revocation, quarantine, kill switches, recovery. Findings go into `findings.md`; structural observations go into `threat-model.md`.
4. Apply standards lenses (authn/authz, ASVS-inspired control quality, supply chain, AI/tool safety) and record meaningful deviations as `STD` findings.
5. Finalise `brief.md`: verdict, top 3–5 risks, structural diagnosis, prioritised remediation order, coverage statement, and open questions.
6. Run the Deep mode gate. If it fails, run another deepening pass; do not declare complete.

If the artifact set cannot survive Pass 3 in this session, write `review-plan.md` and stop at a pass boundary with exact next actions.

---

## Multi-session continuation

If Deep mode cannot complete in one session, create or update:

```text
.plan/security/review-plan.md
```

It must include:

- the current pass (1, 2, or 3),
- which artifacts have been touched,
- which surface categories have been inventoried,
- which subsystems have been read,
- the next concrete action.

Each session resumes by reading `review-plan.md`, then continues the next deepening pass. The agent never declares Deep complete with an active `review-plan.md` that lists pending work.

---

## Anti-patterns the skill exists to prevent

1. Writing 14 thin documents and calling it a deep dive.
2. Letting the first 3–5 interesting findings define the whole review.
3. Treating the surface inventory as a separate phase whose output is frozen.
4. Producing a `synthesis.md` after only a single broad pass.
5. Declaring Deep complete when major source directories were not read.
6. Hiding incomplete coverage by adding more documents.
7. Reasoning about findings before any surface inventory exists.
8. Reasoning about chains, blast radius, or operations before identity and trust boundaries are mapped.

---

## Issue taxonomy

Every issue is classified:

| Type | Meaning |
|---|---|
| VULN | Confirmed/strongly supported exploitable vulnerability |
| DESIGN | Security architecture weakness or brittle trust model |
| ASSURANCE | Missing evidence required to trust, adopt, or operate safely |
| OPS | Detection/response/recovery/operability risk |
| ABUSE | Misuse, fraud, automation, adversarial-use, or safety risk |
| STD | Standards deviation or non-standard pattern |
| HYGIENE | Defence-in-depth or hardening gap |
| LATENT | Not exploitable today but likely to become so as code is wired or scaled |

Group findings in `findings.md` by **surface category** first, then sort by severity within each group.

---

## Confidence model

Each finding carries four labels (single-line allowed):

```text
Evidence: ✅ VERIFIED | ⚠️ IMPLIED | ❓ UNKNOWN
Exploit:  ✅ VERIFIED | ⚠️ IMPLIED | 🔮 PREDICTED | ❓ UNKNOWN
Impact:   ✅ VERIFIED | ⚠️ IMPLIED | ❓ UNKNOWN
Control:  ✅ VERIFIED | ⚠️ IMPLIED | ❓ UNKNOWN | ❌ NONE
```

Cite `file:line` for every concrete claim. Repo-level absence claims may cite search evidence. ASSURANCE issues may have `Evidence: ❓ UNKNOWN` when the issue is the absence of expected evidence.

---

## Severity calibration

Judge by impact, exploitability, exposure, blast radius, control posture, and detectability.

| Severity | Definition |
|---|---|
| Critical | Severe harm at global/multi-tenant/control-plane scale, or persistent compromise, with practical exploit path and weak/no verified controls |
| High | Severe harm with higher prerequisite or limited blast radius, or design/OPS weakness materially weakening a critical trust boundary |
| Medium | Moderate harm, meaningful hardening gap, or exploit requiring high privilege and limited impact |
| Low | Minor harm, hygiene, or future-risk precursor without present exploit path |

Design or OPS issues are High only when they materially weaken a critical trust boundary, make Critical regressions likely, or prevent safe operation/adoption.

---

## Attack-surface lens

Use the universal attack surface taxonomy as a discovery checklist during every Deep pass. For each category, look for surfaces and reason about them in the same pass.

Categories:

1. Network surfaces — HTTP routes, listeners, localhost, WebSockets, gRPC, GraphQL, webhooks, update feeds, cloud/local clients.
2. IPC / RPC / message surfaces — IPC, postMessage, workers, queues, pub/sub, named pipes, stdio protocols, MCP, JSON-RPC, jobs, event buses.
3. User-controlled input and parser surfaces — forms, JSON, files, URLs, markdown, HTML/XML/YAML, archives, CLI args, env vars, clipboard, drag/drop, model output.
4. Privilege / authority surfaces — tokens, secrets, admin operations, settings changes, file writes, shell/tool execution, cloud calls, impersonation, OS permissions, updates.
5. Persistence surfaces — databases, files, caches, cookies, browser storage, logs, queues, settings, exports, vector stores, memory.
6. Code execution and extension surfaces — child processes, plugins/extensions, MCP/tools, eval, template engines, deserialization, native modules, package scripts, auto-update installers.
7. Trust-boundary surfaces — renderer→main, browser→native, model→tool, user→service, tenant→shared backend, local→cloud, plugin→host, service→service identity propagation.
8. Supply-chain / update surfaces — package manifests, lockfiles, native deps, lifecycle hooks, container images, CI/CD, signing/checksums/provenance, update manifests.
9. Observability / response surfaces — audit/app logs, security events, telemetry, redaction, retention, alerting, revocation, quarantine, kill switches, debug modes.

For each inventoried surface, note in `threat-model.md`:

```text
surface, location, entry condition, caller/attacker, authority reached,
data touched, trust boundary, validation/auth, evidence, open questions
```

---

## Domain lenses (used during deepening passes)

Apply lenses based on the system, not as a fixed checklist:

- Trust model
- AuthN / AuthZ
- Multi-tenancy
- Data protection and privacy
- Abuse and misuse
- Detection, response, and recovery
- Assume breach
- Supply chain and SDLC
- Infrastructure / cloud / runtime isolation
- AI / agent / tool safety
- Resilience and availability
- Standards and architecture maturity

Reference details:

- `references/authn-authz-standards.md` — for any auth-touching review
- `references/asvs-lens.md` — ASVS-inspired control quality lens
- `references/attack-surface-taxonomy.md` — discovery checklist for every Deep pass

---

## Required diagrams

`threat-model.md` must contain at least:

- a system context diagram,
- a trust-boundary diagram,
- a highest-risk data-flow diagram.

Mermaid is sufficient. Diagrams are part of the threat model, not a separate artifact.

The worst attack chain in `findings.md` must include a Mermaid or step-by-step chain map.

---

## Finding schema

Use this schema in `findings.md` for each finding. Compact form is allowed for Low/Medium without dispute; full form is required for Critical/High, disputed, or dynamically-verifiable findings.

```markdown
### F-N — <title>

**Type:** VULN | DESIGN | ASSURANCE | OPS | ABUSE | STD | HYGIENE | LATENT
**Severity:** Critical | High | Medium | Low
**Surface category:** <one of the nine universal categories>
**Attacker class:** <lowest-privilege actor>
**Confidence:** Evidence ✅/⚠️/❓ · Exploit ✅/⚠️/🔮/❓ · Impact ✅/⚠️/❓ · Control ✅/⚠️/❓/❌
**Evidence:** `<file>:<line-range>`

**What the system does:** <concrete behavior>
**Why this matters:** <security property weakened or violated>
**Exploit / failure scenario:** <numbered steps with conditions>
**Blast radius:** <asset and scope>
**Default behavior:** <fail-open / fail-closed / unclear>
**Detection / response:** <telemetry, alerting, containment, evidence tampering>
**Compensating controls:** ✅ verified | ⚠️ implied | ❓ unknown | ❌ none
**Recommendation:** <specific fix or architectural change>
**Validation handoff:** <required for Critical/High/disputed/dynamically-verifiable; otherwise: "Not required; static evidence sufficient.">
```

Group findings by surface category. Within each category, sort by severity.

For attack chains, add a `## Chains` section in `findings.md` with named chains, member findings, and step-by-step exploitation.

---

## Deep mode gate

Deep mode is complete only when **all** of the following are true:

- [ ] `threat-model.md`, `findings.md`, and `brief.md` exist and have been revisited at least twice.
- [ ] At least three deepening passes were performed, with explicit evidence of revisit (edits, not appends).
- [ ] Every universal surface category has inventoried surfaces in `threat-model.md` or is explicitly marked not applicable with evidence.
- [ ] Every major source directory was inspected or listed as not inspected with reason.
- [ ] `threat-model.md` includes Mermaid diagrams for system context, trust boundaries, and highest-risk data flow.
- [ ] At least one assume-breach narrative is present for each externally reachable or high-trust component.
- [ ] At least one end-to-end chain is documented with evidence and minimum/full defence.
- [ ] Findings are grouped by surface category, not by discovery order.
- [ ] No subsystem dominates findings without explicit explanation in the brief.
- [ ] `brief.md` has verdict, top risks, structural diagnosis, remediation order, coverage statement, and open questions.
- [ ] If `review-plan.md` exists, all phases are marked complete.

If any item fails, run another deepening pass. Do not declare complete.

---

## Triage and Focused outputs

### Triage
Inline unless asked. Sections: scope/caveats, top 5 risks, top 5 unknowns, highest-risk trust boundaries, worst plausible chain, default-open/default-closed concerns, recommended next mode.

### Focused
One scoped report. Sections: scope and explicit non-scope, files inspected, domain map, findings (using the same schema), standards deviations, validation handoff for Critical/High/disputed, recommended next review.

The focused prompts (authz, abuse-ops, assume-breach, external adoption, validation handoff) all run Focused mode underneath; they only differ in scope and required sections.

---

## Reference files

- `references/attack-surface-taxonomy.md` — discovery checklist
- `references/authn-authz-standards.md` — auth/OAuth/OIDC/JWT standards
- `references/asvs-lens.md` — ASVS-inspired control-quality lens
- `references/domain-lenses.md` — twelve investigation lenses
- `references/issue-taxonomy.md` — issue type promotion guidance
- `references/evidence-and-confidence.md` — confidence model
- `references/validation-handoff.md` — validation handoff schema
- `references/standards-map.md` — standards/norms quick map
- `references/review-modes.md` — mode reference
- Prompt entrypoints: `../../prompts/security/security-*.md`
