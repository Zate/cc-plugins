---
description: Run a comprehensive security audit aligned with OWASP ASVS 5.0
argument-hint: Optional audit type (quick, standard, comprehensive) or specific domain
allowed-tools: ["Read", "Write", "Edit", "Glob", "Grep", "Task", "AskUserQuestion", "TodoWrite", "Skill"]
---

# Security Audit Command

Run a comprehensive security audit of your codebase, aligned with OWASP Application Security Verification Standard (ASVS) 5.0.

## Quick Start

```bash
/security:audit              # Interactive - asks for scope
/security:audit quick        # Quick scan (L1 only)
/security:audit standard     # Standard audit (L1 + L2)
/security:audit comprehensive # Full audit (all levels)
```

## Overview

This command orchestrates a multi-phase security audit:

1. **Discovery** - Analyzes your project's technology stack
2. **Scoping** - Customizes the audit based on your needs
3. **Execution** - Runs domain-specific auditors in parallel
4. **Reporting** - Generates a comprehensive findings report

## Workflow

### Step 1: Parse Arguments

If `$ARGUMENTS` is provided:

| Argument | Action |
|----------|--------|
| `quick` | Set audit level to L1 only |
| `standard` | Set audit level to L1 + L2 |
| `comprehensive` or `full` | Set audit level to L1 + L2 + L3 |
| `auth` or `authentication` | Focus on V6, V7 chapters |
| `api` | Focus on V4, V1, V2 chapters |
| `frontend` or `web` | Focus on V3 chapter |
| `crypto` | Focus on V11, V12 chapters |

If no argument provided, proceed to interactive scoping.

### Step 2: Launch Audit Orchestrator

Invoke the audit-orchestrator agent to handle the full audit workflow:

```markdown
Launch Task with subagent_type: audit-orchestrator

Provide context:
- Project directory: current working directory
- Requested scope: $ARGUMENTS or "interactive"
- Output preference: summary + file

The orchestrator will:
1. Run project discovery
2. Conduct interactive scoping (if not specified)
3. Spawn domain auditors
4. Consolidate findings
5. Generate report
```

### Step 3: Handle Results

When the orchestrator completes:

1. **Display summary** in the conversation:
   ```markdown
   ## Security Audit Complete

   **Findings**: X total (Y critical, Z high)

   ### Top Issues
   1. [Critical] SQL injection in /api/users - V1.2.1
   2. [High] Missing CSRF protection - V3.5.1
   3. [High] Weak password hashing - V6.2.4

   **Full report**: .claude/security-audit-2024-12-15.md
   ```

2. **Offer next steps**:
   ```
   Use AskUserQuestion:
   - question: "How would you like to proceed?"
   - header: "Next Steps"
   - options:
     - View full report (Open the detailed findings)
     - Fix critical issues (Start remediation workflow)
     - Export findings (Generate JSON/CSV export)
     - Run another audit (Change scope and re-run)
   ```

## Audit Types

### Quick Scan (L1)
- **Duration**: Fastest
- **Coverage**: Minimum baseline requirements
- **Best for**: Initial assessment, CI/CD integration
- **Requirements checked**: ~100 (L1 only)

### Standard Audit (L1 + L2)
- **Duration**: Moderate
- **Coverage**: Recommended for most applications
- **Best for**: Regular security reviews
- **Requirements checked**: ~250 (L1 + L2)

### Comprehensive Audit (L1 + L2 + L3)
- **Duration**: Longest
- **Coverage**: Maximum rigor for critical applications
- **Best for**: Pre-release, compliance, high-value apps
- **Requirements checked**: ~369 (all levels)

## Domain-Specific Audits

Focus on specific security areas:

| Focus | Chapters | Auditors |
|-------|----------|----------|
| `auth` | V6, V7 | authentication-auditor, session-auditor |
| `api` | V4, V1, V2 | api-auditor, encoding-auditor, validation-auditor |
| `frontend` | V3 | frontend-auditor |
| `crypto` | V11, V12 | crypto-auditor, communication-auditor |
| `config` | V13, V14 | config-auditor, data-protection-auditor |
| `oauth` | V10, V9 | oauth-auditor, token-auditor |

## Output Files

The audit generates:

- **Report**: `.claude/security-audit-[date].md`
  - Executive summary
  - Detailed findings with ASVS mapping
  - Remediation recommendations
  - Coverage statistics

- **Machine-readable**: `.claude/security-audit-[date].json`
  - Structured findings for tooling integration
  - Severity scores and classifications
  - File locations and line numbers

## Integration with CI/CD

For automated security scanning:

```bash
# In CI pipeline
/security:audit quick

# Check for critical/high findings
if grep -q '"severity": "critical"' .claude/security-audit-*.json; then
  exit 1
fi
```

## Model Usage

| Phase | Model | Rationale |
|-------|-------|-----------|
| Argument parsing | haiku | Simple logic |
| Orchestrator | sonnet | Complex coordination |
| Domain auditors | sonnet | Security analysis |
| Report generation | sonnet | Comprehensive output |

## Error Handling

| Issue | Action |
|-------|--------|
| No source files | Ask user for source directory |
| Unsupported language | Run generic checks, note limitation |
| Auditor failure | Continue with others, note incomplete coverage |
| No findings | Celebrate! But verify scope wasn't too narrow |

## Examples

### Interactive Audit
```
User: /security:audit
Assistant: [Launches orchestrator which asks scoping questions]
```

### Quick CI Scan
```
User: /security:audit quick
Assistant: Running quick security scan (L1 requirements)...
[Generates summary and report]
```

### Focused Auth Audit
```
User: /security:audit auth
Assistant: Running authentication-focused audit (V6, V7)...
[Detailed auth findings]
```

## See Also

- `/security` - Plugin overview and status
- `Skill: asvs-requirements` - ASVS 5.0 reference
- `Agent: audit-orchestrator` - Full audit workflow details
