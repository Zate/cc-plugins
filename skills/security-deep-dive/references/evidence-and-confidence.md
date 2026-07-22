# Evidence and Confidence

Use separate confidence labels instead of one global label.

## Confidence fields

- **Evidence confidence** — did you inspect code/config/artifact evidence?
- **Exploit confidence** — how proven is the attack or failure path?
- **Impact confidence** — how proven is the consequence/blast radius?
- **Control confidence** — how proven are mitigating controls?

## Labels

| Label | Meaning |
|---|---|
| ✅ VERIFIED | Directly observed in code, config, tests, or docs; cite file:line |
| ⚠️ IMPLIED | Strongly suggested by wiring/config/convention, runtime not observed |
| 🔮 PREDICTED | Not true today but likely when partially built code is wired |
| ❓ UNKNOWN | Repo cannot answer the question |
| ❌ NONE | No control found after targeted search |

## Rules

- Every concrete claim about code/config needs a citation.
- Conditional claims are allowed only with explicit condition, evidence basis, and verification path.
- Missing evidence can be an ASSURANCE issue when trust depends on that evidence.
- Do not assume platform controls. If not visible, mark UNKNOWN and explain how risk changes if present/absent.
- Critical/High issues need validation handoff.
