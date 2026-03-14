# Changelog

All notable changes to the security plugin are documented in this file.

## [3.1.0] - 2026-03-15

### Added — Workflow Features

- **Suppression system**: `.security/suppressions.json` persists false positive overrides across scans
  - `--suppress <finding-id>` adds a finding to suppressions
  - `--show-suppressed` includes suppressed findings in report
  - Suppressions match by rule_id, file pattern (glob), and/or CWE
  - Checked automatically during correlation phase
- **Diff-only scanning**: `--diff` flag scans only files changed vs main branch
  - `--diff-base <ref>` to compare against specific git ref
  - Scopes Semgrep, Gitleaks, Trivy, and regex scanner to changed files
  - Zero findings = "no changed files to scan" (fast exit)
- **Results viewer**: `/security:results` displays last scan report without re-running
  - Shows report age and suggests re-scan if stale (>24 hours)
- `scripts/apply-suppressions.sh` — filters correlated findings against suppressions
- `scripts/get-changed-files.sh` — lists changed files vs git ref
- `data/suppressions-schema.json` — documents suppression file format

### Fixed

- Deterministic ordering: Gitleaks and Trivy findings sorted by file+line before correlation
- Secondary sort key (file+line) within same severity for fully deterministic output
- Stricter triage: decision tree, fixed severity table, exact format templates
- `SCRIPT_DIR` variable added to correlate.sh

## [3.0.0] - 2026-03-14

### Changed — Complete Architecture Rewrite

**Philosophy shift: Tools detect, LLMs triage.** Every finding now traces to a deterministic tool output. The LLM classifies findings as true/false positives — it never scans code directly.

### Architecture

- **5-phase pipeline**: Recon -> Scan -> Correlate -> Triage -> Report
- **Deterministic detection**: Semgrep, Gitleaks, Trivy, Bandit, gosec
- **Zero-dependency fallback**: Built-in regex patterns work with no tools installed
- **Provenance labeling**: Every finding tagged [Static] or [LLM]
- **CWE-specialized triage**: Top 10 CWE criteria for precise false positive elimination
- **Findings budget**: Quick (10), Standard (25), Deep (50) — no more overwhelming reports

### Added

- `/security:scan` — Main entry point (replaces /security:audit)
  - `--quick` mode: 30 seconds, tools + regex only, max 10 findings
  - Standard mode: 2-5 minutes, tools + LLM triage, max 25 findings
  - `--deep` mode: 5-30 minutes, full analysis, max 50 findings
- `/security:setup` — Install recommended security tools
- `scripts/detect-tools.sh` — Check tool availability with coverage estimate
- `scripts/recon.sh` — Deterministic project analysis (tech stack, LOC, frameworks)
- `scripts/run-regex-scan.sh` — Zero-dependency regex-based scanner
- `scripts/run-scanners.sh` — Orchestrate SAST tool execution
- `scripts/correlate.sh` — Dedup and cross-reference findings
- `data/regex-patterns.json` — Built-in vulnerability patterns (secrets, injection, config)
- `data/cwe-criteria/` — Triage criteria for top 10 CWEs
- `agents/triage-agent.md` — Single triage agent (replaces 6 super-auditors)

### Removed

- 6 super-auditor agents (replaced by single triage-agent + deterministic tools)
- `/security:audit` command (replaced by /security:scan)
- `/security` entry command (replaced by /security:scan)
- LLM-based direct code scanning (replaced by tool-based detection)
- Legacy commands/ directory

### Kept

- PreToolUse security guard hooks (real-time validation)
- PostToolUse logging hooks
- Reference skills: asvs-requirements, vulnerability-patterns, remediation-*
- scripts/validate-security.sh (hook script)

### Migration

| Old | New |
|-----|-----|
| `/security:audit` | `/security:scan` |
| `/security:audit --quick` | `/security:scan --quick` |
| `/security:audit --comprehensive` | `/security:scan --deep` |
| 6 super-auditor agents | 1 triage-agent + SAST tools |

## [2.0.1] - Previous

See git history for v2.x changelog.
