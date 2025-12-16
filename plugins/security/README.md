# Security Plugin for Claude Code

A comprehensive security plugin providing OWASP ASVS 5.0-aligned audits and real-time security validation for Claude Code.

## Features

### Security Audits (`/security:audit`)

Structured security assessments aligned with OWASP Application Security Verification Standard (ASVS) 5.0:

- **17 Domain-Specific Auditors** covering all ASVS chapters (369 requirements)
- **Parallel Execution** for fast, comprehensive analysis
- **Interactive Scoping** to customize audit focus
- **Consolidated Reports** with severity classification and ASVS mapping
- **Remediation Guidance** with prioritized fix recommendations and code examples

### Live Security Guard (Hooks)

Real-time security validation during development:

- **PreToolUse Validation** on Write/Edit/Bash operations
- **Configurable Enforcement** modes: strict, warning, advisory
- **Per-Category Rule Overrides** for fine-grained control
- **Project Auto-Detection** for tech stack-specific rules
- **Fast Checks** (<5s) to avoid blocking workflow

### Skills

| Skill | Description |
|-------|-------------|
| `vulnerability-patterns` | Index to detection pattern skills |
| `vuln-patterns-core` | Universal patterns: secrets, SQL/command injection, path traversal |
| `vuln-patterns-languages` | Language-specific patterns: JS/TS, Python, Go, Java, Ruby, PHP |
| `remediation-library` | Index to remediation skills |
| `remediation-injection` | Fixes for SQL, command injection, XSS |
| `remediation-crypto` | Fixes for weak cryptography, randomness, TLS |
| `remediation-auth` | Fixes for credentials, JWT, deserialization, access control |
| `remediation-config` | Fixes for path traversal, debug mode, security headers |
| `asvs-requirements` | Full OWASP ASVS 5.0 requirements database |
| `project-context` | Auto-detect project tech stack and applicable rules |
| `audit-report` | Standardized security report format |

## Installation

```bash
/plugin install Zate/cc-plugins:security
```

Or add the marketplace and install:
```bash
/plugin marketplace add Zate/cc-plugins
/plugin install security
```

## Quick Start

### Run a Security Audit

```bash
/security:audit
```

The audit workflow:
1. **Discovery** - Analyzes your project structure and tech stack
2. **Scoping** - Interactive questions to customize the audit
3. **Execution** - Parallel domain auditors analyze relevant areas
4. **Reporting** - Consolidated findings with severity and remediation

### Check Plugin Status

```bash
/security
```

Shows current configuration, enabled features, and available commands.

## Configuration

Configure in your project's `.claude/settings.json`:

```json
{
  "plugins": {
    "security": {
      "enforcement": "warning",
      "enableLiveGuard": true,
      "auditLevel": "L2",
      "auditScope": ["all"],
      "blockOnCritical": true
    }
  }
}
```

### Enforcement Modes

| Mode | Behavior |
|------|----------|
| `strict` | Block operations with security issues |
| `warning` | Alert but allow operations to proceed |
| `advisory` | Log issues without interrupting workflow |

### ASVS Verification Levels

| Level | Name | Applicability |
|-------|------|---------------|
| `L1` | Opportunistic | Minimum baseline for all applications |
| `L2` | Standard | Recommended for most applications |
| `L3` | Advanced | High-value or critical applications |

### Rule Overrides

Override enforcement for specific vulnerability categories:

```json
{
  "plugins": {
    "security": {
      "enforcement": "warning",
      "ruleOverrides": {
        "injection": "strict",
        "secrets": "strict",
        "crypto": "warning",
        "xss": "warning",
        "deserialization": "strict",
        "tls": "advisory",
        "auth": "warning"
      }
    }
  }
}
```

Available categories:
- `injection` - SQL/Command injection
- `secrets` - Hardcoded credentials
- `crypto` - Weak cryptography
- `xss` - Cross-site scripting
- `deserialization` - Unsafe deserialization
- `tls` - TLS/certificate validation
- `auth` - Authentication security

### Path Exclusions

Exclude specific paths from security checks:

```json
{
  "plugins": {
    "security": {
      "excludePaths": [
        "**/test/**",
        "**/__tests__/**",
        "**/fixtures/**",
        "**/mocks/**",
        "**/examples/**"
      ]
    }
  }
}
```

### Full Configuration Reference

```json
{
  "plugins": {
    "security": {
      "enforcement": "warning",
      "enableLiveGuard": true,
      "auditScope": ["all"],
      "auditLevel": "L2",
      "ruleOverrides": {},
      "excludePaths": ["**/test/**", "**/__tests__/**"],
      "includeLanguages": ["python", "javascript", "typescript", "java", "go", "ruby", "php"],
      "blockOnCritical": true,
      "logFindings": true
    }
  }
}
```

| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `enforcement` | string | `"warning"` | Default enforcement level |
| `enableLiveGuard` | boolean | `true` | Enable real-time hook validation |
| `auditScope` | array | `["all"]` | ASVS chapters to include |
| `auditLevel` | string | `"L2"` | ASVS verification level |
| `ruleOverrides` | object | `{}` | Per-category enforcement |
| `excludePaths` | array | `[...]` | Paths to exclude |
| `includeLanguages` | array | `[...]` | Languages to scan |
| `blockOnCritical` | boolean | `true` | Always block critical issues |
| `logFindings` | boolean | `true` | Log findings to file |

## ASVS 5.0 Coverage

This plugin implements auditors for all 17 chapters of OWASP ASVS 5.0:

| Auditor | ASVS | Focus Area | Requirements |
|---------|------|------------|--------------|
| encoding-auditor | V1 | Injection prevention | 28 |
| validation-auditor | V2 | Input validation | 15 |
| frontend-auditor | V3 | XSS, CSP, browser security | 32 |
| api-auditor | V4 | REST/GraphQL security | 17 |
| file-auditor | V5 | File upload/download | 14 |
| authentication-auditor | V6 | Auth, MFA, credentials | 44 |
| session-auditor | V7 | Session management | 18 |
| authorization-auditor | V8 | Access control, RBAC | 11 |
| token-auditor | V9 | JWT security | 7 |
| oauth-auditor | V10 | OAuth/OIDC | 50 |
| crypto-auditor | V11 | Cryptography | 32 |
| communication-auditor | V12 | TLS, certificates | 13 |
| config-auditor | V13 | Secrets, configuration | 18 |
| data-protection-auditor | V14 | Data classification | 15 |
| architecture-auditor | V15 | Secure coding patterns | 20 |
| logging-auditor | V16 | Security logging | 19 |
| webrtc-auditor | V17 | WebRTC security | 15 |

**Total: 369 requirements covered**

## Live Security Guard

The live security guard uses PreToolUse hooks to validate code changes in real-time.

### What Gets Checked

**On Write/Edit operations:**
- Hardcoded secrets (API keys, passwords, private keys)
- SQL injection patterns
- Command injection patterns
- XSS vulnerabilities
- Unsafe deserialization
- Weak cryptography
- TLS verification disabled
- Debug mode in production

**On Bash commands:**
- Destructive commands (`rm -rf /`, etc.)
- Credential exposure
- Reverse shells
- Data exfiltration attempts
- Force flags on dangerous commands

### How It Works

1. **PreToolUse Hook** - Claude validates each Write/Edit/Bash operation
2. **Pattern Matching** - Uses `vulnerability-patterns` skill for detection
3. **Decision** - Returns approve/warn/block based on severity and enforcement mode
4. **PostToolUse Hook** - Logs findings for audit trail

### Severity Levels

| Severity | Action (strict) | Action (warning) | Action (advisory) |
|----------|-----------------|------------------|-------------------|
| Critical | Block | Warn | Log |
| High | Block | Warn | Log |
| Medium | Warn | Warn | Log |
| Low | Log | Log | Log |

## Scripts

The plugin includes command-line scripts for manual scanning:

### validate-security.sh

Full security scan with JSON output:

```bash
./plugins/security/scripts/validate-security.sh [files...] [--quick|--full]
```

Options:
- `--quick` - Skip test files, use fast patterns (default)
- `--full` - Scan all files with all patterns

Exit codes:
- `0` - No issues found
- `1` - Critical security issues
- `2` - High severity issues
- `3` - Medium severity issues

### post-write-scan.sh

Lightweight post-write logging:

```bash
./plugins/security/scripts/post-write-scan.sh
```

## Integration with Devloop

This plugin works seamlessly with the devloop plugin:

- **Shared project-context** - Both plugins use the same tech stack detection
- **Workflow integration** - Run security audits as part of development flow
- **Compatible configuration** - Same enforcement patterns and settings style

To enable security in your devloop workflow:

```json
{
  "plugins": {
    "devloop": { "..." },
    "security": {
      "enforcement": "warning",
      "enableLiveGuard": true
    }
  }
}
```

## Commands Reference

| Command | Description |
|---------|-------------|
| `/security` | Main entry point, shows status and commands |
| `/security:audit` | Run comprehensive security audit |

### /security:audit Arguments

```bash
/security:audit [scope] [--level L1|L2|L3] [--quick]
```

Examples:
```bash
/security:audit                    # Full audit with interactive scoping
/security:audit V1,V6,V11          # Audit specific chapters
/security:audit --level L1         # Quick L1 baseline check
/security:audit --quick            # Fast scan without interactive scoping
```

## Extending the Plugin

### Adding Custom Patterns

For universal patterns (secrets, injection), edit `skills/vuln-patterns-core/SKILL.md`.
For language-specific patterns, edit `skills/vuln-patterns-languages/SKILL.md`.

### Adding Custom Remediation

Choose the appropriate skill based on vulnerability type:
- `skills/remediation-injection/SKILL.md` - SQL, command injection, XSS fixes
- `skills/remediation-crypto/SKILL.md` - Cryptography, randomness, TLS fixes
- `skills/remediation-auth/SKILL.md` - Credentials, JWT, deserialization fixes
- `skills/remediation-config/SKILL.md` - Path traversal, debug, headers fixes

### Custom Hooks

Modify `hooks/hooks.json` to customize validation behavior:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "prompt",
            "prompt": "Your custom validation prompt...",
            "timeout": 20
          }
        ]
      }
    ]
  }
}
```

## Troubleshooting

### Hooks Not Running

1. Verify plugin is installed: `/plugin list`
2. Check `enableLiveGuard` is `true` in settings
3. Run Claude Code with `--debug` to see hook loading

### Too Many False Positives

1. Add paths to `excludePaths`
2. Change enforcement to `advisory` for specific categories
3. Check if files are test/example code

### Audit Taking Too Long

1. Limit scope: `/security:audit V1,V6`
2. Use `--quick` flag
3. Lower audit level to L1

## Requirements

- Claude Code >= 1.0.0

## License

MIT

## References

- [OWASP ASVS 5.0](https://owasp.org/www-project-application-security-verification-standard/)
- [OWASP Top 10:2025](https://owasp.org/Top10/)
- [CWE/SANS Top 25](https://cwe.mitre.org/top25/)
