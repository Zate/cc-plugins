# security

> **Hybrid security scanning: deterministic tools detect, LLM triages.**

[![Version](https://img.shields.io/badge/version-3.0.0-blue)](./CHANGELOG.md)

## Philosophy

LLMs are unreliable at finding vulnerabilities directly (21-34% recall). Static analysis tools are reliable but noisy (35% precision). This plugin combines both: **tools detect, LLM triages** -- achieving ~90% precision with reproducible results.

Every finding is labeled with its source:
- **[Static]** -- Detected by deterministic tools. Reproducible.
- **[LLM]** -- Assessed by language model. Tool evidence cited.

## Quick Start

```bash
# Install the plugin
/plugin install security

# Install recommended tools (optional but recommended)
/security:setup

# Run a security scan
/security:scan

# Quick scan (30 seconds, no LLM)
/security:scan --quick

# Deep scan (5-30 minutes, full analysis)
/security:scan --deep
```

## How It Works

```
Phase 0: Recon        Detect tech stack, available tools, estimate coverage
Phase 1: Scan         Run deterministic tools (Semgrep, Gitleaks, Trivy, etc.)
Phase 2: Correlate    Dedup findings, cross-reference across tools
Phase 3: Triage       LLM classifies: true positive / false positive / needs review
Phase 4: Report       Provenance-labeled findings with remediation
```

## Tool Stack

| Tier | Tools | Coverage |
|------|-------|----------|
| **Built-in** (always) | Regex patterns | ~35% |
| **Recommended** | + Semgrep + Gitleaks | ~70% |
| **Full** | + Trivy + Bandit/gosec | ~85% |

**Works with zero tools installed** via built-in regex patterns. Install Semgrep for best results.

## Scan Modes

| Mode | Time | Token Cost | Max Findings |
|------|------|-----------|-------------|
| `--quick` | ~30s | ~10k tokens | 10 |
| Standard | ~3min | ~30k tokens | 25 |
| `--deep` | ~15min | ~100k tokens | 50 |

## What Gets Scanned

**Detection (deterministic tools):**
- Hardcoded secrets and API keys
- SQL injection, command injection, XSS patterns
- Path traversal, SSRF, unsafe deserialization
- Known vulnerable dependencies (CVEs)
- Configuration issues (debug mode, weak TLS)

**Triage (LLM assessment):**
- CWE-specialized false positive elimination
- Framework-aware suppression (Django ORM = no SQLi)
- Context-aware severity adjustment (test file vs production endpoint)
- Grouped related findings with root cause analysis

## Languages Supported

| Language | Tools | Detection Quality |
|----------|-------|-------------------|
| Python | Semgrep + Bandit + regex | Excellent |
| JavaScript/TypeScript | Semgrep + regex | Good |
| Go | Semgrep + gosec + regex | Good |
| Others | Semgrep + regex | Basic |

## Artifacts

Results are saved to `.security/`:

```
.security/
+-- recon.json              # Project analysis
+-- artifacts/              # Raw tool outputs
|   +-- semgrep.sarif.json
|   +-- gitleaks.json
|   +-- trivy.json
|   +-- regex-scan.json
+-- correlated.json         # Deduplicated findings
+-- triage.json             # LLM-assessed findings
+-- suppressions.json       # Persistent false positive overrides
+-- report.md               # Human-readable report
```

Add to `.gitignore`:
```
.security/
```

## Real-Time Protection

The plugin includes PreToolUse hooks that validate code changes in real-time:
- Blocks hardcoded secrets before they're written
- Warns about dangerous patterns (eval, shell=True with variables)
- Validates bash commands for destructive operations

## Skills (formerly Commands)

Claude uses skills to manage security assessments:

| Skill | Purpose |
|-------|---------|
| `/security:scan` | Run security assessment |
| `/security:scan --quick` | Fast scan, tools only, no LLMM |
| `/security:scan --deep` | Comprehensive analysis |
| `/security:scan --diff` | Scan only changed files vs main branch |
| `/security:scan --suppress finding-003` | Suppress a false positive permanently |
| `/security:results` | View most recent scan report |
| `/security:setup` | Install security tools |

## Author

**Zate** - [@Zate](https://github.com/Zate)

## License

MIT License
