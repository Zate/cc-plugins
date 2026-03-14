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

**Otherwise:** Triage findings yourself using the decision tree below. Do NOT delegate to the triage-agent for standard scans -- do the work directly. Only use the triage-agent for `--deep` scans with 50+ findings.

Read `.security/correlated.json`.

### Triage Decision Tree (follow IN ORDER, take FIRST match)

For each finding, read exactly 5 lines of context around the flagged line, then apply:

1. **Test fixture/data file?** (testdata/, fixtures/) -> FALSE_POSITIVE
2. **CWE-798 in test .pem/.key file?** -> FALSE_POSITIVE
3. **Test file?** (*_test.*, test_*, tests/) -> FALSE_POSITIVE unless testing production patterns
4. **CWE-798 credential check:**
   - Placeholder value (changeme, xxx, TODO) -> FALSE_POSITIVE
   - In .env.example/.env.template -> FALSE_POSITIVE
   - Looks like a hash ($2b$, hex 32+ chars) -> FALSE_POSITIVE
   - Public key (not private) -> FALSE_POSITIVE
   - Loaded from env var at runtime -> FALSE_POSITIVE
   - Otherwise -> TRUE_POSITIVE
5. **Framework default protection?** (see table below, NOT bypassed) -> FALSE_POSITIVE
6. **User input reaches sink?**
   - No evidence of user input -> FALSE_POSITIVE
   - Yes, user input reaches sink -> TRUE_POSITIVE
   - Cannot determine from 5 lines -> NEEDS_REVIEW
7. **Default:** NEEDS_REVIEW

### Framework Protection Table

| Framework | CWE | Protection | Bypass Indicators |
|-----------|-----|-----------|-------------------|
| Django | CWE-89 | ORM parameterizes | .raw(), .extra(), cursor() |
| Django | CWE-79 | Template auto-escape | \|safe, mark_safe() |
| SQLAlchemy | CWE-89 | ORM parameterizes | text() with f-string |
| React | CWE-79 | JSX auto-escapes | dangerouslySetInnerHTML |
| Rails | CWE-89 | AR parameterizes | find_by_sql(), execute() |

### Fixed Severity Table

| CWE | Base | Upgrade condition | Downgrade condition |
|-----|------|-------------------|---------------------|
| CWE-78 | CRITICAL | -- | CLI tool: HIGH |
| CWE-89 | HIGH | Public unauth endpoint: CRITICAL | Internal: MEDIUM |
| CWE-79 | HIGH | Stored XSS: CRITICAL | Self-XSS: LOW |
| CWE-798 | CRITICAL | Production keys | Dev/staging: HIGH |
| CWE-502 | CRITICAL | Network input | Local cache: MEDIUM |
| Other | MEDIUM | Public endpoint: HIGH | Test/internal: LOW |

### Explanation Format (use EXACTLY)

TRUE_POSITIVE: `[What]. [Why exploitable]. [What input reaches sink].`
FALSE_POSITIVE: `[Rule that fired]. [Why it is FP -- cite protection].`
NEEDS_REVIEW: `[What flagged]. [Why indeterminate]. [What to check].`

### Remediation Format (TRUE_POSITIVE only)

`Replace [vulnerable pattern] with [secure pattern]. Example: [one-line code].`

One fix only. Do not offer alternatives.

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

### Report Rules (MANDATORY)

1. **Use this EXACT report structure.** Do not add sections, change table columns, or rearrange.
2. **Summary table has exactly 4 rows:** CRITICAL, HIGH, MEDIUM, LOW. Count only TRUE_POSITIVE and NEEDS_REVIEW findings.
3. **Finding headings format:** `### [SEVERITY] CWE-NNN: Title -- file:line`
4. **Every finding has:** Provenance line, explanation paragraph, code block, remediation block. In that order.
5. **Provenance format:** `**Provenance:** [Static: toolname1, toolname2]`
6. **False positives go in collapsed details block.** One line per FP: `- CWE-NNN in file:line -- reason [Static: tool]`
7. **Coverage gaps always shown** based on detect-tools.sh output.
8. **Do not read full source files.** Only show the code snippet from the tool finding or the 5-line context read during triage.

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
