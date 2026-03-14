---
name: setup
description: Install and configure security scanning tools for the security plugin
disable-model-invocation: true
allowed-tools:
  - Bash
  - Read
  - AskUserQuestion
---

# Security Setup - Install Scanning Tools

Install and configure security scanning tools used by `/security:scan`.

## Step 1: Detect Current State

```bash
"${CLAUDE_PLUGIN_ROOT}/scripts/detect-tools.sh"
```

Parse the output and display a status table:

```
Security Tool Status
====================

| Tool     | Status    | Version | Purpose                        |
|----------|-----------|---------|--------------------------------|
| semgrep  | installed | 1.56.0  | Multi-language SAST scanner    |
| gitleaks | missing   | -       | Secrets detection in git repos |
| trivy    | missing   | -       | Container/IaC vulnerability    |
| bandit   | installed | 1.7.7   | Python-specific SAST           |
| gosec    | missing   | -       | Go-specific SAST               |

Coverage: 60% (2/5 tools installed + built-in regex patterns)
```

## Step 2: Show Install Commands

For each missing tool, display platform-specific install options:

### semgrep
```bash
# macOS
brew install semgrep
# Linux / pip
pip install semgrep
# Docker
docker pull semgrep/semgrep
```

### gitleaks
```bash
# macOS
brew install gitleaks
# Go install
go install github.com/gitleaks/gitleaks/v8@latest
# Linux (download binary)
# See https://github.com/gitleaks/gitleaks/releases
```

### trivy
```bash
# macOS
brew install trivy
# Ubuntu/Debian
sudo apt-get install -y trivy
# RHEL/CentOS
sudo yum install -y trivy
```

### bandit
```bash
# pip (Python projects)
pip install bandit
# pipx (isolated install)
pipx install bandit
```

### gosec
```bash
# Go install
go install github.com/securego/gosec/v2/cmd/gosec@latest
# macOS
brew install gosec
```

## Step 3: Ask What to Install

Only show tools that are missing. If all tools are installed, congratulate and STOP.

```yaml
AskUserQuestion:
  questions:
    - question: "Which tools would you like to install?"
      header: "Install Security Tools"
      multiSelect: true
      options:
        - label: "semgrep"
          description: "Multi-language static analysis (recommended)"
        - label: "gitleaks"
          description: "Secrets detection in git history"
        - label: "trivy"
          description: "Container and infrastructure scanning"
        - label: "bandit"
          description: "Python-specific security scanner"
        - label: "gosec"
          description: "Go-specific security scanner"
        - label: "All missing tools"
          description: "Install everything"
        - label: "Skip"
          description: "Don't install anything"
```

Only include options for tools that are actually missing.

## Step 4: Install Selected Tools

For each selected tool, detect the platform and run the appropriate install command:

1. Detect platform: macOS (brew), Linux (apt/yum), or fallback (pip/go)
2. Run install command
3. Show output and success/failure for each

```bash
# Example: detect platform and install
if command -v brew &>/dev/null; then
    brew install semgrep
elif command -v pip &>/dev/null; then
    pip install semgrep
else
    echo "Please install semgrep manually: https://semgrep.dev/docs/getting-started/"
fi
```

## Step 5: Verify Installation

```bash
"${CLAUDE_PLUGIN_ROOT}/scripts/detect-tools.sh"
```

Show updated status table with new coverage estimate.

If any installations failed, show manual install instructions and links.

Display:
```
Setup complete! Coverage: 100% (5/5 tools + built-in regex patterns)
Run /security:scan to start your first security assessment.
```

---

**Now**: Detect currently installed tools.
