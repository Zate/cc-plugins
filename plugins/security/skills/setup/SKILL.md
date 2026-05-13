---
name: setup
description: Inspect and optionally install security scanning tools for the security plugin
disable-model-invocation: true
allowed-tools:
  - Bash
  - Read
  - AskUserQuestion
---

# Security Setup

Inspect scanner availability and help the user install missing tools. Do not install anything without explicit user approval.

## Step 1: Detect Current State

Run:

```bash
"${CLAUDE_PLUGIN_ROOT}/scripts/detect-tools.sh"
```

Display:

| Tool | Status | Version | Purpose |
|------|--------|---------|---------|
| semgrep | installed/missing | version | Multi-language SAST |
| gitleaks | installed/missing | version | Secret detection |
| trivy | installed/missing | version | Dependency/container/IaC scanning |
| bandit | installed/missing | version | Python SAST |
| gosec | installed/missing | version | Go SAST |

Show the coverage estimate from the script.

## Step 2: Recommend Tools

Recommendations:

- Always recommend `semgrep`.
- Recommend `gitleaks` for any repository with git history.
- Recommend `trivy` when Dockerfile, lockfiles, IaC, or container usage is detected.
- Recommend `bandit` only for Python projects.
- Recommend `gosec` only for Go projects.

## Step 3: Show Install Commands

Prefer isolated/user-scoped installers where practical:

### semgrep

```bash
# macOS
brew install semgrep

# Isolated Python tool install
pipx install semgrep

# uv
uv tool install semgrep
```

### gitleaks

```bash
brew install gitleaks
go install github.com/gitleaks/gitleaks/v8@latest
```

### trivy

```bash
brew install trivy
# Linux packages: https://aquasecurity.github.io/trivy/latest/getting-started/installation/
```

### bandit

```bash
pipx install bandit
uv tool install bandit
```

### gosec

```bash
go install github.com/securego/gosec/v2/cmd/gosec@latest
brew install gosec
```

Avoid global `pip install` unless the user explicitly chooses it.

## Step 4: Ask Before Installing

Ask which missing tools to install. Include a "show commands only" option. If the user chooses installation, run only the selected commands and explain any command that needs elevated privileges before running it.

If no supported installer is available, print manual instructions and do not attempt workarounds.

## Step 5: Verify

Run:

```bash
"${CLAUDE_PLUGIN_ROOT}/scripts/detect-tools.sh"
```

Display updated coverage and next step:

```text
Run /security:baseline to create the project profile, then /security:scan.
```

Begin by detecting current state.
