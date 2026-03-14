---
name: scan
description: Run a security assessment using deterministic static analysis tools with LLM-powered triage
argument-hint: "[--quick] [--deep] [--path <dir>]"
disable-model-invocation: true
allowed-tools:
  - Bash
  - Read
  - Write
  - Grep
  - Glob
  - Agent
  - AskUserQuestion
---

# Security Scan - Static Analysis with LLM Triage

Run a security assessment that combines deterministic tool output with LLM-powered triage. **Every finding is labeled with its provenance: [Static] or [LLM].**

## Phase 0: Recon

### 0a. Detect Available Tools

```bash
"${CLAUDE_PLUGIN_ROOT}/scripts/detect-tools.sh"
```

Display capability report:
- Which tools are installed (semgrep, gitleaks, trivy, bandit, gosec, etc.)
- Estimated coverage based on available tools
- If no tools installed: suggest `/security:setup` but continue (regex scan always works)

### 0b. Detect Tech Stack

```bash
"${CLAUDE_PLUGIN_ROOT}/scripts/recon.sh"
```

Display detected stack: languages, frameworks, package managers, infrastructure.

### 0c. Parse Scan Mode

From `$ARGUMENTS`:
- `--quick`: Fast scan, skip triage, 10-finding budget
- `--deep`: Thorough scan, 50-finding budget
- (default): Standard scan, 25-finding budget
- `--path <dir>`: Scope scan to specific directory (default: project root)

## Phase 1: Scan

Run all available scanners. Show progress as each completes.

### 1a. External Tools (if available)

```bash
"${CLAUDE_PLUGIN_ROOT}/scripts/run-scanners.sh" [--path <dir>]
```

This runs whichever tools are installed (semgrep, gitleaks, trivy, bandit, gosec) and writes normalized output to `.security/artifacts/`.

### 1b. Built-in Regex Patterns (always runs)

```bash
"${CLAUDE_PLUGIN_ROOT}/scripts/run-regex-scan.sh" [--path <dir>]
```

Pattern-based detection for common vulnerabilities. Always available regardless of installed tools. Output goes to `.security/artifacts/`.

Show after each scanner completes:
```
[+] semgrep: 12 findings (completed in 8s)
[+] gitleaks: 3 findings (completed in 2s)
[+] regex-scan: 7 findings (completed in 1s)
```

## Phase 2: Correlate

```bash
"${CLAUDE_PLUGIN_ROOT}/scripts/correlate.sh"
```

Deduplicate findings across tools. Same file + same line + same CWE = single finding with multiple sources.

Display: `"X unique findings after deduplication (from Y raw findings across Z tools)"`

**If zero findings:** Congratulate the user, show coverage estimate, suggest `/security:scan --deep` if they ran standard mode. **STOP here.**

## Phase 3: Triage

**If `--quick`:** Skip triage entirely. Report raw tool findings directly. Jump to Phase 4.

**Otherwise:** Use the triage-agent to classify each finding.

Read `.security/artifacts/correlated.json` and invoke triage-agent:

```
Agent(triage-agent): Triage the correlated findings in .security/artifacts/correlated.json.
Project context is in .security/artifacts/recon.json.
Classify each finding as TRUE_POSITIVE, FALSE_POSITIVE, or NEEDS_REVIEW.
Write results to .security/artifacts/triaged.json.
```

### Triage Criteria (passed to agent)

For each finding, the agent applies CWE-specific assessment:

| CWE | Key Question | Common False Positive |
|-----|-------------|----------------------|
| CWE-89 (SQLi) | Does user input reach query without parameterization? | ORM usage, prepared statements |
| CWE-79 (XSS) | Is output rendered without encoding? | Framework auto-escaping (React, Django) |
| CWE-78 (Cmd Injection) | Is shell invoked with user input? | Hardcoded commands, no user input |
| CWE-22 (Path Traversal) | Is file path from user input without validation? | Static paths, canonicalization |
| CWE-798 (Hardcoded Creds) | Is it a real credential? | Test fixtures, hashes, placeholders |
| CWE-502 (Deserialization) | Is untrusted data deserialized? | Safe loaders, trusted sources |

**Context adjustments:**
- Test files (`*_test.*`, `test_*`, `tests/`, `spec/`): downgrade severity unless testing production patterns
- Example/demo files: downgrade to LOW
- Public endpoints: upgrade severity
- Framework protections: mark FALSE_POSITIVE if framework provides default protection and code does not bypass it

### Findings Budget

Enforce maximum findings in the report:
- `--quick`: 10 findings max
- Standard: 25 findings max
- `--deep`: 50 findings max

If over budget, keep highest severity findings and note how many were trimmed.

## Phase 4: Report

Generate the final report and save to `.security/report.md`.

### Report Structure

```markdown
# Security Scan Report

**Date:** [timestamp]
**Mode:** [quick/standard/deep]
**Scope:** [path or "full project"]

## Summary

| Severity | Count |
|----------|-------|
| CRITICAL | N     |
| HIGH     | N     |
| MEDIUM   | N     |
| LOW      | N     |

## Tools

| Tool | Version | Findings | Status |
|------|---------|----------|--------|
| semgrep | X.Y.Z | N | ran |
| gitleaks | X.Y.Z | N | ran |
| regex-scan | built-in | N | ran |
| bandit | - | - | not installed |

## Findings

### [CRITICAL] CWE-89: SQL Injection in auth/login.py:42
**Provenance:** [Static: semgrep]
**Severity:** CRITICAL (upgraded: public endpoint)

User input from request parameter `username` reaches SQL query without parameterization.

**Code:**
\`\`\`python
cursor.execute(f"SELECT * FROM users WHERE name = '{username}'")
\`\`\`

**Remediation:** Use parameterized queries:
\`\`\`python
cursor.execute("SELECT * FROM users WHERE name = %s", (username,))
\`\`\`

---

[... more findings ...]

## Suppressed False Positives

<details>
<summary>N findings classified as false positives (click to expand)</summary>

- CWE-798 in tests/conftest.py:15 — Test fixture, not a real credential [Static: gitleaks]
- CWE-79 in templates/index.html:8 — Django auto-escaping active [Static: semgrep]

</details>

## Coverage Gaps

- **gosec not installed:** Go source files not scanned for Go-specific vulnerabilities
- **trivy not installed:** Container images and IaC not scanned

Run `/security:setup` to install missing tools.
```

### Report Rules

1. Every finding MUST have a `[Static: toolname]` or `[LLM: triage]` provenance label
2. LLM never reads full source files -- only code snippets from tool output
3. Remediation must be specific and actionable with code examples
4. False positives are listed but collapsed
5. Coverage gaps are always shown based on missing tools

Save the report:
```bash
mkdir -p .security
```
Write report to `.security/report.md`.

Display the full report in conversation.

## Post-Scan

```yaml
AskUserQuestion:
  questions:
    - question: "What would you like to do next?"
      header: "Scan Complete"
      multiSelect: false
      options:
        - label: "Fix critical findings"
          description: "Address CRITICAL and HIGH severity issues"
        - label: "Override triage decisions"
          description: "Review and change TRUE/FALSE positive classifications"
        - label: "Run deeper scan"
          description: "Re-scan with --deep for more thorough analysis"
        - label: "Export report"
          description: "Save report for sharing"
        - label: "Done"
          description: "No further action needed"
```

Route responses:
- Fix findings: Read report, address each CRITICAL/HIGH finding in priority order
- Override triage: Show each NEEDS_REVIEW finding, let user reclassify
- Deeper scan: Re-run with `--deep` flag
- Export: Report is already saved at `.security/report.md`
- Done: STOP

## Examples

```bash
/security:scan                    # Standard scan (default)
/security:scan --quick            # Fast scan, no triage
/security:scan --deep             # Thorough scan, 50-finding budget
/security:scan --path src/api     # Scan specific directory
/security:scan --deep --path .    # Deep scan of current directory
```

---

**Now**: Begin Phase 0 recon.
