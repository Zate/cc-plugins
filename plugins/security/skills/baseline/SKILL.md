---
name: baseline
description: Create or update the project security baseline, profile, suppressions file, and gitignore entries for security scans
argument-hint: "[--refresh]"
disable-model-invocation: true
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - AskUserQuestion
---

# Security Baseline

Create the local project profile that helps `/security:scan` classify severity and keep scan artifacts out of git.

## Step 1: Inspect Project

Run:

```bash
mkdir -p .security
"${CLAUDE_PLUGIN_ROOT}/scripts/recon.sh" . | tee .security/recon.json
"${CLAUDE_PLUGIN_ROOT}/scripts/detect-tools.sh" | tee .security/tools.json
```

Read `.security/recon.json`.

## Step 2: Ask for Security Profile

Ask concise questions when `.security/profile.json` does not exist or `--refresh` is passed:

- Application exposure: public internet, authenticated public, internal service, CLI/library.
- Production paths: directories or config files that represent production behavior.
- Test/example paths: directories that should usually be downgraded or treated as false positives.
- Sensitive operations: auth, payments, admin, secrets, file upload, SSRF-sensitive network access.
- Default severity posture: normal or strict.

## Step 3: Write Profile

Write `.security/profile.json`:

```json
{
  "version": 1,
  "exposure": "public-internet|authenticated-public|internal|cli-library",
  "severity_posture": "normal|strict",
  "production_paths": ["src/", "app/"],
  "test_paths": ["tests/", "fixtures/", "examples/"],
  "sensitive_operations": ["auth", "admin", "file-upload"],
  "notes": []
}
```

## Step 4: Initialize Suppressions

If `.security/suppressions.json` does not exist, write:

```json
{
  "version": 1,
  "suppressions": []
}
```

## Step 5: Update .gitignore

Ensure `.gitignore` contains:

```text
.security/artifacts/
.security/report.md
.security/triaged.json
.security/correlated.json
.security/recon.json
.security/tools.json
.security/changed-files.json
```

Keep `.security/profile.json` and `.security/suppressions.json` trackable by default because they are project policy, not scan output. If the user says suppressions should stay local, add `.security/suppressions.json` to `.gitignore`.

## Step 6: Summary

Report:

- Profile path.
- Suppression file path.
- Gitignore changes.
- Tool coverage estimate.
- Next command: `/security:scan --deep`.
