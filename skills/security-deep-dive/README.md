# Security Deep Dive

> Senior-grade security review skill that produces a living threat model, finding list, and decision brief through iterative deepening passes — not a 14-document checklist.

## Why this exists

Most agent-driven security reviews fail in two ways. They either produce one giant generic checklist, or they produce many shallow documents that add up to less than the sum of their parts. This skill is shaped around how a real senior reviewer actually works:

- discovery and analysis happen together,
- a small number of artifacts are revisited until they earn the synthesis,
- coverage breadth is enforced before any synthesis is written,
- modes scale depth without changing the artifact contract.

## Modes

Three modes. Everything else is a Focused-mode variant.

| Mode | Use for | Output |
|---|---|---|
| **Triage** | Fast signal, "anything scary?", scoping | Inline only unless asked |
| **Focused** | One domain at depth (authz, abuse/ops, assume breach, external adoption, validation handoff, secrets, supply chain, AI/tool, etc.) | One scoped report |
| **Deep** | Senior-grade engagement | Three living artifacts in `.plan/security/` (plus up to three optional ones) |

## Prompt suite

| Prompt | Use for |
|---|---|
| `!security-triage` | Fast security signal: top risks, unknowns, worst chain, recommended next mode |
| `!security-deep-dive` | Senior-grade engagement using iterative deepening |
| `!security-authz-review` | Focused authn/authz, identity propagation, tenant isolation, and auth standards |
| `!security-abuse-ops-review` | Focused abuse, detection, audit, incident response, containment, recovery |
| `!security-assume-breach` | Focused blast-radius analysis assuming compromise |
| `!security-external-adoption` | Focused external/untrusted codebase adoption review |
| `!security-validation-handoff` | Convert findings into safe validation plans |

All focused prompts run Focused mode underneath; they only differ in scope and required sections.

## Deep mode artifacts

Deep mode writes three living artifacts in `.plan/security/` (or a directory you specify):

| Artifact | Purpose |
|---|---|
| `threat-model.md` | Single source of truth for system view, attack surface, data flows, trust boundaries, identity, abuse/ops surface, assume-breach narrative, standards posture, and Mermaid diagrams |
| `findings.md` | All issues grouped by surface category, with chain section |
| `brief.md` | Decision-grade synthesis: verdict, top risks, structural diagnosis, remediation order, coverage statement, open questions |

Optional artifacts, only when justified:

| Artifact | When |
|---|---|
| `review-plan.md` | Multi-session review needing phase tracking and resumption |
| `validation-handoff.md` | Follow-on team will validate findings dynamically |
| `uncertainties.md` | Material unknowns requiring their own register and verification paths |

## Iterative deepening

Deep mode runs at least three deepening passes over the same three artifacts.

1. **Broad first cut** — orient on the system, inventory the universal attack surface, sketch trust boundaries and key data flows in `threat-model.md` with diagrams, capture obvious findings, write a draft brief with explicit Pass-1 caveat.
2. **Targeted deepening** — fix the weakest subsystem, weakest surface category, and weakest claim. Update the threat model in place. Promote, demote, merge, split, and add findings. Run a breadth check across all surface categories.
3. **Adversarial closure** — walk the worst plausible end-to-end chain, run assume-breach for each high-trust component, run abuse/ops, apply standards lenses, finalise the brief, run the gate.

Pass 1 cannot declare the review complete. The synthesis depends on revisit, not on first impressions.

## What it produces beyond findings

- VULN, DESIGN, ASSURANCE, OPS, ABUSE, STD, HYGIENE, LATENT issue typing
- Multi-dimensional confidence: evidence, exploit, impact, control
- Universal attack-surface inventory (network, IPC/RPC, input, authority, persistence, execution, trust, supply chain, observability)
- Mermaid diagrams for system context, trust boundaries, highest-risk data flow
- Assume-breach narratives for high-trust components
- Abuse and operations posture
- Standards deviations (auth/OAuth/OIDC/JWT, ASVS-inspired, supply chain, AI/tool safety)
- Validation handoff for Critical/High/disputed findings

## Limitations

- Repository-only review cannot fully verify platform controls, runtime state, deployed IAM, log pipelines, or alerting behavior unless those artifacts are present.
- Absence of evidence is not proof of absence, but it can be an adoption or assurance risk.
- Very large monorepos require phased execution, persisted in `review-plan.md`, rather than silent scope reduction.
- The skill produces analysis and validation guidance; it does not automatically exploit systems or apply remediations.

## Reference files

- `references/attack-surface-taxonomy.md` — discovery checklist used during every Deep pass
- `references/authn-authz-standards.md` — authn/authz, OAuth/OIDC, JWT, session, service-to-service
- `references/asvs-lens.md` — ASVS-inspired control quality lens
- `references/domain-lenses.md` — twelve investigation lenses
- `references/issue-taxonomy.md` — issue type promotion guidance
- `references/evidence-and-confidence.md` — confidence model
- `references/validation-handoff.md` — validation handoff schema
- `references/standards-map.md` — standards/norms quick map
- `references/review-modes.md` — mode reference

## Changelog

### v3.0.0
- Refactored to three living artifacts: `threat-model.md`, `findings.md`, `brief.md` (plus three optional).
- Replaced phase-by-phase artifact pipeline with iterative deepening passes.
- Reduced Deep mode artifact count from fourteen to three.
- Collapsed six modes into three (triage, focused, deep) with focused prompt variants.
- Made discovery and analysis happen together; threat model is now a living document.

### v2.1.0
- Added breadth-first Deep mode execution with universal attack-surface inventory.
- Added phased continuation via `security-review-plan.md` for large reviews.
- Added required Mermaid threat-model diagrams.
- Added anti-fixation and breadth-check requirements.

### v2.0.0
- Reworked as a layered security engagement framework.
- Added review modes, issue taxonomy, multi-dimensional confidence model.
- Added assume-breach, abuse/ops, standards deviation, and validation handoff.
- Expanded deep mode from six documents to twelve engagement artifacts.

### v1.0.0
- Initial release with phased data-flow, findings, attack chains, uncertainty register, synthesis, and rejected findings.
