# Validation Handoff

Every Critical/High issue and every likely disputed claim needs a safe validation handoff.

## Required fields

```markdown
#### Validation handoff

**Hypothesis:** <claim to prove or disprove>
**Required access:** <role, tenant, environment, credentials, platform access>
**Safe environment:** local / staging / dedicated tenant / production forbidden
**Test outline:** <non-destructive steps>
**Expected vulnerable result:** <observable unsafe behavior>
**Expected safe result:** <control blocks or logs the attempt>
**Telemetry to check:** <logs, audit events, alerts, dashboards>
**Cleanup:** <data, accounts, resources, feature flags, secrets>
**Risk notes:** <data exposure, destructive side effects, approvals, legal/customer constraints>
```

## Safety rules

- Prefer non-destructive validation.
- Do not include weaponized exploit code unless explicitly requested and safe.
- Mark production testing as forbidden when customer data, availability, or integrity could be affected.
- Include expected logs/alerts so validation also tests detection.
- If validation requires platform access unavailable to the agent, state the exact command, console, owner, or artifact needed.
