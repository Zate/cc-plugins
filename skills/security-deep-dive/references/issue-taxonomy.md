# Issue Taxonomy

Classify security observations precisely. Do not force every concern into a vulnerability.

| Type | Use for | Example |
|---|---|---|
| VULN | Exploitable vulnerability | IDOR, SSRF, auth bypass, token replay |
| DESIGN | Architectural weakness | Security-by-convention, scattered authz, unclear trust root |
| ASSURANCE | Missing evidence needed for trust | No tenant isolation tests, no runbook, no threat model |
| OPS | Detection/response/recovery gap | Privileged actions not logged, no revocation path |
| ABUSE | Misuse/fraud/automation/safety risk | Scraping, spam, cost amplification, model/tool abuse |
| STD | Standards deviation | Custom token protocol, weak OAuth redirect handling |
| HYGIENE | Defence-in-depth hardening gap | Missing container hardening, broad secrets, no egress policy |
| LATENT | Future-risk issue likely from current trajectory | Half-built endpoint will become tenant-wide delete |

## Promotion guidance

Promote an observation to an issue when one of these is true:
- It enables or materially worsens an exploit path.
- It weakens a trust boundary or makes future regressions likely.
- It prevents a decision-maker from trusting or adopting the system.
- It makes abuse, detection, containment, or recovery materially worse.
- It deviates from a mature industry pattern without explicit justification.

## Do not drop non-vulnerabilities

If something is not exploitable today, classify it as DESIGN, ASSURANCE, OPS, ABUSE, STD, HYGIENE, or LATENT. Senior security review includes future-risk amplifiers and trust/safety smells, not only present-day CVEs.
