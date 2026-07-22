# Security Deep Dive Review Modes

Three modes. All other named reviews are Focused-mode variants.

## Triage

Fast signal. Use for quick checks, early scoping, or "anything scary here?" prompts.

Output (inline unless asked):
- Top risks
- Top unknowns
- Highest-risk trust boundaries
- Worst plausible chain
- Recommended next mode

## Focused

One domain at depth: authz, tenant isolation, abuse/ops, assume breach, external adoption, validation handoff, secrets, supply chain, AI/tool safety, etc.

Output (one scoped report):
- Scope and explicit non-scope
- Files inspected
- Domain map
- Findings using the skill schema
- Standards deviations
- Validation handoff for Critical/High/disputed
- Recommended next review

## Deep

Senior-grade engagement. Iterative deepening over three living artifacts in `.plan/security/`:

| Artifact | Purpose |
|---|---|
| `threat-model.md` | Single source of truth for system view, attack surface, data flows, trust boundaries, identity, abuse/ops surface, assume-breach narrative, standards posture, with Mermaid diagrams |
| `findings.md` | All issues grouped by surface category, with chains |
| `brief.md` | Decision-grade synthesis |

Optional artifacts (only when justified):

| Artifact | When to add |
|---|---|
| `review-plan.md` | Multi-session review needing phase tracking and resumption |
| `validation-handoff.md` | Follow-on team will validate findings dynamically |
| `uncertainties.md` | Material unknowns requiring their own register and verification paths |

Run at least three deepening passes:
1. Broad first cut covering all three artifacts and the universal attack-surface taxonomy.
2. Targeted deepening of the weakest subsystem, weakest surface category, and weakest claim.
3. Adversarial closure: end-to-end chain, assume-breach per high-trust component, abuse/ops, standards lenses, finalised brief.

Do not declare Deep complete until the Deep mode gate in the skill is fully satisfied.
