---
name: scan
description: Run a security assessment using deterministic static analysis tools with LLM-powered triage
argument-hint: "[--quick] [--deep] [--diff] [--diff-base <ref>] [--path <dir>] [--suppress <id>] [--show-suppressed]"
disable-model-invocation: true
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - Agent
  - AskUserQuestion
  - Skill
---

# Security Scan

Run a deterministic security scan and triage only findings produced by tools. Tools detect; the model classifies and reports.

## Argument Parsing

Parse `$ARGUMENTS`:

- `--quick`: run tools and report raw findings without LLM triage. Budget: 10 findings.
- `--deep`: run tools, load CWE criteria, delegate triage. Budget: 50 findings.
- default: run tools, load CWE criteria, delegate triage. Budget: 25 findings.
- `--diff`: scan changed files only.
- `--diff-base <ref>`: base ref for `--diff`; default is auto-detected by `get-changed-files.sh`.
- `--path <dir>`: scan this directory; default `.`.
- `--suppress <id>`: add suppression for an existing finding and redisplay results; do not rescan.
- `--show-suppressed`: include suppressed findings in final report.

## Suppress Existing Finding

If `--suppress <id>` is present:

1. Read `.security/triaged.json` if it exists, otherwise `.security/correlated.json`.
2. Find the requested finding ID.
3. Append a suppression rule to `.security/suppressions.json` with the finding's `file`, first `rule_id`/`sources` value when present, `cwe`, timestamp, and reason `"User suppressed via /security:scan --suppress"`.
4. Run:

   ```bash
   "${CLAUDE_PLUGIN_ROOT}/scripts/apply-suppressions.sh" .security/correlated.json .security/suppressions.json .security/correlated.json
   ```

5. Display `.security/report.md` if present and tell the user to rerun `/security:scan` for a refreshed report.
6. Stop.

## Phase 0: Prepare

Create artifact directories:

```bash
mkdir -p .security/artifacts
```

Detect tools and save the result:

```bash
"${CLAUDE_PLUGIN_ROOT}/scripts/detect-tools.sh" | tee .security/tools.json
```

Detect project context and save the result:

```bash
"${CLAUDE_PLUGIN_ROOT}/scripts/recon.sh" "$SCAN_PATH" | tee .security/recon.json
```

If `.security/profile.json` exists, read it and use it for severity context. If it does not exist, continue and mention that `/security:baseline` can create one.

If `--diff` is present, run:

```bash
"${CLAUDE_PLUGIN_ROOT}/scripts/get-changed-files.sh" "$DIFF_BASE" | tee .security/changed-files.json
```

If the changed file count is zero, report "No changed files to scan" and stop.

## Phase 1: Scan

Run external scanners plus the built-in regex scanner through the orchestrator:

```bash
"${CLAUDE_PLUGIN_ROOT}/scripts/run-scanners.sh" .security/artifacts --path "$SCAN_PATH"
```

For diff mode:

```bash
"${CLAUDE_PLUGIN_ROOT}/scripts/run-scanners.sh" .security/artifacts --path "$SCAN_PATH" --files .security/changed-files.json
```

The orchestrator always writes `.security/artifacts/scan-summary.json` and `.security/artifacts/regex-scan.json`; external tool artifacts are written when those tools are available.

## Phase 2: Correlate and Suppress

Run correlation:

```bash
"${CLAUDE_PLUGIN_ROOT}/scripts/correlate.sh" .security/artifacts .security/correlated.json
```

`correlate.sh` automatically applies `.security/suppressions.json` when it exists.

Read `.security/correlated.json`. If there are zero unsuppressed findings, write a short `.security/report.md` with the scan date, mode, tools, and coverage gaps, display it, and stop.

## Phase 3: Load Triage Context

If not `--quick`, load:

1. `${CLAUDE_PLUGIN_ROOT}/data/triage-criteria.md`
2. `.security/recon.json`
3. `.security/profile.json` when present
4. CWE-specific files for CWEs present in `.security/correlated.json`

Use this command to list matching CWE reference files:

```bash
jq -r '.findings[]?.cwe // empty' .security/correlated.json | sort -u | while read -r cwe; do
  file="${CLAUDE_PLUGIN_ROOT}/data/cwe-criteria/$(printf "%s" "$cwe" | tr "[:upper:]" "[:lower:]")-*.md"
  ls $file 2>/dev/null || true
done
```

Read only the files that exist.

## Phase 4: Triage

If `--quick`, skip this phase and report raw correlated findings.

Otherwise, delegate to `security/triage-agent` with this task:

```text
Triage .security/correlated.json using plugins/security/data/triage-criteria.md and the loaded CWE criteria. Read only flagged files and only the allowed local context. Write .security/triaged.json exactly as specified by the agent.
```

After the agent finishes, read `.security/triaged.json`. If it is missing or invalid JSON, stop and report the failure.

## Phase 5: Report

Generate `.security/report.md` and display it.

Report structure is fixed:

````markdown
# Security Scan Report

**Date:** [timestamp]
**Mode:** [quick/standard/deep]
**Scope:** [path or diff base]

## Summary

| Severity | Count |
|----------|-------|
| CRITICAL | N |
| HIGH | N |
| MEDIUM | N |
| LOW | N |

## Tools

| Tool | Version | Findings | Status |
|------|---------|----------|--------|

## Findings

### [SEVERITY] CWE-NNN: Title -- file:line
**Provenance:** [Static: tool]
**Severity:** SEVERITY

Explanation paragraph.

**Code:**
```language
snippet
````

**Remediation:** Minimal fix.

## Suppressed False Positives

<details>
<summary>N suppressed or false-positive findings</summary>

- CWE-NNN in file:line -- reason [Static: tool]

</details>

## Coverage Gaps

- Missing scanner or unsupported stack notes.
```

Rules:

- Summary counts include `TRUE_POSITIVE` and `NEEDS_REVIEW` findings only.
- `FALSE_POSITIVE` findings go under suppressed/false positives unless `--show-suppressed` is omitted and the user only needs counts.
- Enforce budget after sorting by severity: quick 10, standard 25, deep 50.
- Use `.security/artifacts/scan-summary.json` and `.security/tools.json` for tool status.
- Always include coverage gaps from missing tools and detected languages.
- Do not read full source files while building the report. Use snippets from findings or the triage agent output.

## Post-Scan

Ask what the user wants next:

- Fix critical findings -> suggest `/security:fix <finding-id>` or proceed if they ask.
- Run deeper scan -> rerun with `--deep`.
- Create baseline/profile -> run `/security:baseline`.
- Done -> stop.

## Examples

```bash
/security:scan
/security:scan --quick
/security:scan --deep
/security:scan --diff
/security:scan --diff --diff-base HEAD~3
/security:scan --path src/api
/security:scan --suppress finding-003
/security:scan --show-suppressed
```

Begin at Phase 0.
