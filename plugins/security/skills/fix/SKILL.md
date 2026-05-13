---
name: fix
description: Fix or guide remediation for a specific security finding from the latest scan report
argument-hint: "<finding-id|CWE/file:line> [--dry-run]"
disable-model-invocation: true
allowed-tools:
  - Read
  - Edit
  - Grep
  - Glob
  - Bash
  - AskUserQuestion
  - Skill
---

# Security Fix

Remediate one finding from `.security/triaged.json` or `.security/report.md`.

## Step 1: Load Finding

Read `.security/triaged.json`. If it does not exist, tell the user to run `/security:scan` first.

Resolve `$ARGUMENTS` as:

- exact finding ID, e.g. `finding-003`
- CWE plus file/line, e.g. `CWE-89 src/db.py:42`
- if omitted, ask the user to select from CRITICAL/HIGH `TRUE_POSITIVE` findings.

If the finding verdict is `FALSE_POSITIVE`, stop and suggest suppressing it with `/security:scan --suppress <id>`.

## Step 2: Load Remediation Skill

Route by CWE/category:

| CWE/category | Skill |
|--------------|-------|
| CWE-78, CWE-79, CWE-89, injection, XSS | `remediation-injection` |
| CWE-798, CWE-287, CWE-502, auth, authorization, deserialization | `remediation-auth` |
| CWE-327, CWE-330, TLS, crypto, randomness | `remediation-crypto` |
| CWE-22, CWE-489, headers, deployment, config | `remediation-config` |
| Other | `remediation-library` |

Use the selected remediation skill for the fix pattern.

## Step 3: Inspect Minimal Context

Read the affected file around the finding and only nearby helper code needed to make a safe edit. Do not broaden into unrelated security work.

## Step 4: Fix or Dry Run

If `--dry-run` is present, report the proposed change without editing.

Otherwise:

1. Apply the minimal secure change.
2. Preserve existing behavior.
3. Add or adjust focused tests only when the project already has a clear test pattern.
4. Run the narrowest relevant verification command available.

## Step 5: Update User

Report:

- Finding fixed.
- File changed.
- Verification run.
- Recommended follow-up: `/security:scan --diff`.
