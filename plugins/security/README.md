# Security Plugin for Claude Code

A comprehensive security plugin providing OWASP ASVS 5.0-aligned audits and real-time security validation for Claude Code.

## Features

### Security Audits (`/security:audit`)

Structured security assessments aligned with OWASP Application Security Verification Standard (ASVS) 5.0:

- **17 Domain-Specific Auditors** covering all ASVS chapters
- **Parallel Execution** for fast, comprehensive analysis
- **Interactive Scoping** to customize audit focus
- **Consolidated Reports** with severity classification and ASVS mapping
- **Remediation Guidance** with prioritized fix recommendations

### Live Security Guard (Hooks)

Real-time security validation during development:

- **PreToolUse Validation** on Write/Edit/Bash operations
- **Configurable Enforcement** modes: strict, warning, advisory
- **Project Auto-Detection** for tech stack-specific rules
- **Fast Checks** (<5s) to avoid blocking workflow

## Installation

```bash
/plugin install anthropics/cc-plugins:security
```

Or add this marketplace and install:
```bash
/plugin marketplace add anthropics/cc-plugins
/plugin install security
```

## Usage

### Running a Security Audit

```bash
/security:audit
```

The audit workflow:
1. **Discovery** - Analyzes your project structure and tech stack
2. **Scoping** - Interactive questions to customize the audit
3. **Execution** - Parallel domain auditors analyze relevant areas
4. **Reporting** - Consolidated findings with severity and remediation

### Configuration

Configure in your project's `.claude/settings.json`:

```json
{
  "plugins": {
    "security": {
      "enforcement": "advisory",
      "enableLiveGuard": true,
      "auditScope": ["all"]
    }
  }
}
```

#### Enforcement Modes

| Mode | Behavior |
|------|----------|
| `strict` | Block operations with security issues |
| `warning` | Alert but allow operations to proceed |
| `advisory` | Log issues without interrupting workflow |

#### Audit Scope

Limit audits to specific ASVS chapters:

```json
{
  "auditScope": ["V1", "V6", "V8", "V11"]
}
```

Available chapters:
- V1: Encoding & Sanitization
- V2: Input Validation
- V3: Frontend Security
- V4: API Security
- V5: File Handling
- V6: Authentication
- V7: Session Management
- V8: Authorization
- V9: Token Security
- V10: OAuth/OIDC
- V11: Cryptography
- V12: Communications
- V13: Configuration
- V14: Data Protection
- V15: Architecture
- V16: Logging
- V17: WebRTC

## ASVS 5.0 Alignment

This plugin implements auditors for all 17 chapters of OWASP ASVS 5.0, covering 369 security requirements:

| Auditor | ASVS Chapter | Requirements |
|---------|--------------|--------------|
| encoding-auditor | V1 | 28 |
| validation-auditor | V2 | 15 |
| frontend-auditor | V3 | 32 |
| api-auditor | V4 | 17 |
| file-auditor | V5 | 14 |
| authentication-auditor | V6 | 44 |
| session-auditor | V7 | 18 |
| authorization-auditor | V8 | 11 |
| token-auditor | V9 | 7 |
| oauth-auditor | V10 | 50 |
| crypto-auditor | V11 | 32 |
| communication-auditor | V12 | 13 |
| config-auditor | V13 | 18 |
| data-protection-auditor | V14 | 15 |
| architecture-auditor | V15 | 20 |
| logging-auditor | V16 | 19 |
| webrtc-auditor | V17 | 15 |

## Integration with Devloop

This plugin works seamlessly with the devloop plugin:

- Shares `project-context` skill for tech stack detection
- Can be integrated into development workflows
- Supports the same enforcement configuration patterns

## Commands

| Command | Description |
|---------|-------------|
| `/security` | Main entry point, shows available subcommands |
| `/security:audit` | Run a comprehensive security audit |

## Requirements

- Claude Code >= 1.0.0

## License

MIT
