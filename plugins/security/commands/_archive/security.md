---
description: Security plugin entry point - shows available security commands and quick status
argument-hint: Optional subcommand (audit, guard, status)
allowed-tools: ["Read", "Glob", "Grep", "AskUserQuestion", "Skill"]
---

# Security Plugin

Main entry point for the security plugin. Provides access to security auditing and live guards.

## Available Commands

| Command | Description |
|---------|-------------|
| `/security:audit` | Run a comprehensive security audit aligned with OWASP ASVS 5.0 |
| `/security` | Show this help and current security status |

## Quick Actions

When run without arguments, show the user:

1. **Plugin Status**: Whether live guards are enabled
2. **Last Audit**: When the last security audit was run (if any)
3. **Available Commands**: List of security subcommands

## Workflow

### Step 1: Check for Arguments

If `$ARGUMENTS` is provided:
- `audit` or `run audit` → Suggest using `/security:audit`
- `status` → Show security status
- `help` → Show available commands

### Step 2: Detect Project Context

Use the Read tool to check if `.claude/project-context.json` exists.

If no context exists, offer to generate it:

```
Use AskUserQuestion:
- question: "No project context found. Generate it now?"
- header: "Context"
- options:
  - Generate (Detect project tech stack)
  - Skip (Continue without context)
  - Manual (I'll provide project details)
```

If "Generate" selected, use `Skill: project-context` to detect the project's tech stack and create the context file using Read and Glob tools to analyze the project structure.

### Step 3: Show Status

Display current security status:

```markdown
## Security Plugin Status

**Project**: [name from project-context.json or directory name]
**Type**: [type from project-context.json]

### Configuration
- **Enforcement Mode**: [strict | warning | advisory]
- **Live Guards**: [enabled | disabled]

### Project Features Detected
[List features that have security implications]

### Recommended Auditors
Based on your project, these ASVS domains are most relevant:
- V6: Authentication (auth detected)
- V8: Authorization (auth detected)
- ...

### Quick Actions
- `/security:audit` - Run full security audit
```

### Step 4: Suggest Next Steps

Based on project context, suggest appropriate actions:

```
Use AskUserQuestion:
- question: "What would you like to do?"
- header: "Action"
- options:
  - Run audit (Start /security:audit workflow)
  - Configure (Adjust security settings)
  - View docs (Learn more about security features)
```

## Feature-to-Auditor Mapping

Use project context to recommend auditors:

| Feature | Recommended Auditors |
|---------|---------------------|
| authentication | V6 (Authentication), V7 (Session) |
| oauth | V10 (OAuth/OIDC) |
| file-upload | V5 (File Handling) |
| database | V2 (Validation), V14 (Data Protection) |
| api | V4 (API Security), V1 (Encoding) |
| graphql | V4 (API Security) |
| payments | V12 (Communications), V11 (Crypto) |
| websockets | V12 (Communications), V6 (Auth) |

## Settings Reference

The plugin supports these settings in project `.claude/settings.json`:

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

### Enforcement Modes

| Mode | Behavior |
|------|----------|
| `strict` | Block operations that fail security checks |
| `warning` | Alert but allow operations to proceed |
| `advisory` | Log issues without interrupting workflow |

## Model Usage

| Task | Model | Rationale |
|------|-------|-----------|
| Show status | haiku | Simple display |
| Generate context | haiku | Script execution |
| Recommendations | haiku | Pattern matching |
