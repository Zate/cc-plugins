# Devloop Configuration Reference

Complete documentation for hooks, environment variables, statusline, and plugin settings.

---

## Quick Reference

| Component | Purpose | Location |
|-----------|---------|----------|
| SessionStart Hook | Project detection, context loading | `hooks/session-start.sh` |
| Validation Hooks | Tool use validation | `hooks/hooks.json` |
| Statusline | Status bar display | `statusline/devloop-statusline.sh` |
| Environment Variables | Project context | Set by SessionStart hook |
| Local Settings | Project-specific config | `.claude/devloop.local.md` |
| Plan File | Workflow state | `.claude/devloop-plan.md` |
| Bug Tracking | Issue management | `.claude/bugs/` |

---

## Hooks

Devloop uses hooks to automate validation, context loading, and progress tracking.

### SessionStart Hook

**File**: `hooks/session-start.sh`

**Triggers**: Every new Claude Code session

**Purpose**: Detect project context and provide rich initial context for agents

**What It Does**:
1. **Language Detection** - Analyzes project files to determine primary language
   - Checks for `go.mod`, `package.json`, `pom.xml`, `requirements.txt`, etc.
   - Falls back to file extension counting if no manifest found

2. **Framework Detection** - Identifies frameworks in use
   - React, Vue, Angular, Next.js (JavaScript/TypeScript)
   - Spring, Spring Boot (Java)
   - Django, Flask, FastAPI (Python)
   - Gin, Echo, Fiber, Chi (Go)

3. **Test Framework Detection** - Finds test tooling
   - Jest, Vitest, Mocha, Playwright, Cypress
   - Go test, JUnit, pytest, unittest, RSpec

4. **Project Type Classification** - Categorizes project
   - frontend, backend, fullstack, cli, library

5. **Context Generation** - Creates rich context message including:
   - Tech stack summary
   - Key directories
   - Git status
   - CLAUDE.md summary (if exists)
   - Active plan progress
   - Open bug count

**Output Format**:
```json
{
  "systemMessage": "## Devloop Project Context\n\n**Project**: my-app\n**Tech Stack**:\n- Language: typescript\n- Framework: react\n..."
}
```

### Validation Hooks

**File**: `hooks/hooks.json`

Devloop includes prompt-based validation hooks:

#### PreToolUse: Write/Edit Validation
**Triggers**: Before any `Write`, `Edit`, or `MultiEdit` tool use

**Checks**:
1. Follows project conventions (if CLAUDE.md exists)
2. No obvious security issues (secrets, SQL injection)
3. Change is reasonable for current task

**Responses**:
- `{"decision": "approve"}` - Continue with operation
- `{"decision": "warn", "message": "..."}` - Show warning but continue
- `{"decision": "deny", "message": "..."}` - Block operation

#### PreToolUse: Bash Validation
**Triggers**: Before any `Bash` tool use

**Checks**:
1. Not a destructive command (`rm -rf`, `drop database`)
2. No obvious security risks
3. Appropriate for development workflow

#### PostToolUse: Bash Analysis
**Triggers**: After any `Bash` command completes

**Analyzes**:
1. Success or failure status
2. Expected vs unexpected failures
3. Warning signs in output

**Response**:
```json
{
  "status": "success|warning|error",
  "summary": "One line summary",
  "action": "none|retry|investigate"
}
```

#### PostToolUse: Task Analysis
**Triggers**: After any `Task` (agent) completes

**Assesses**:
1. Did agent accomplish its goal
2. Any issues or warnings
3. Follow-up actions needed

#### Stop: Completion Verification
**Triggers**: Before session ends

**Verifies**:
1. All user-requested tasks addressed
2. No obvious unfinished items
3. Tests appear to pass
4. Todo list up to date

**Responses**:
- `{"decision": "approve"}` - Allow stop
- `{"decision": "block", "message": "..."}` - Prevent stop with reason

#### Notification: Issue Detection
**Triggers**: On messages matching `.*test.*fail.*|.*error.*|.*exception.*`

**Provides**:
- Severity assessment (critical/warning/info)
- Summary of issue
- Alert recommendation

---

## Environment Variables

The SessionStart hook sets these environment variables for use by agents:

| Variable | Description | Example Values |
|----------|-------------|----------------|
| `FEATURE_DEV_PROJECT_LANGUAGE` | Primary language | go, typescript, java, python |
| `FEATURE_DEV_FRAMEWORK` | Detected framework | react, spring-boot, fastapi, gin |
| `FEATURE_DEV_TEST_FRAMEWORK` | Test framework | jest, go-test, pytest, junit |
| `FEATURE_DEV_PROJECT_TYPE` | Project classification | frontend, backend, fullstack, cli, library |
| `FEATURE_DEV_PROJECT_NAME` | Project name | my-app |

**Usage in Agents**:
```markdown
Based on project type, adjust validation focus:
- `$FEATURE_DEV_PROJECT_TYPE` = frontend → check bundle, assets
- `$FEATURE_DEV_PROJECT_TYPE` = backend → check API, database
```

---

## Statusline

### Setup

Configure with the `/devloop:statusline` command or manually:

1. Add to `~/.claude/settings.json`:
```json
{
  "statusline": {
    "command": "bash /path/to/devloop/statusline/devloop-statusline.sh"
  }
}
```

2. Or use the command:
```bash
/devloop:statusline
```

### What It Shows

The statusline displays:

| Component | Description | Example |
|-----------|-------------|---------|
| **Model** | Current Claude model | `Claude 4 Sonnet` |
| **Path** | Working directory (last 2 dirs) | `cc-plugins/plugins` |
| **Git Branch** | Current branch (cyan) | `main` |
| **Plan Progress** | Tasks complete/total (magenta) | `Plan:3/7` |
| **Bug Count** | Open bugs (red) | `Bugs:2` |

**Example Output**:
```
Claude 4 Sonnet | cc-plugins/plugins | main | Plan:3/7 | Bugs:2
```

### Requirements

- **jq** - JSON parser (install with `sudo apt install jq` on Linux)
- Without jq, shows install message

### Input

The statusline receives JSON input from Claude Code:
```json
{
  "model": {
    "display_name": "Claude 4 Sonnet"
  },
  "workspace": {
    "current_dir": "/home/user/project",
    "project_dir": "/home/user/project"
  }
}
```

---

## Plan Management

### Plan File Location

**Path**: `.claude/devloop-plan.md`

### Plan File Format

```markdown
# Devloop Plan: [Feature Name]

**Created**: [Date]
**Status**: In Progress | Complete | Paused
**Current Phase**: [Phase name]

## Overview
[Feature description]

## Architecture
[Chosen approach summary]

## Tasks

### Phase 1: [Name]
- [x] Task 1.1: [Description]
  - Acceptance: [Criteria]
  - Files: [file1.ts, file2.ts]
- [~] Task 1.2: [In progress task]
- [ ] Task 1.3: [Pending task]

### Phase 2: [Name]
- [ ] Task 2.1: [Description]

## Progress Log
- [Date]: Plan created
- [Date]: Phase 1 complete
- [Date]: [Update]
```

### Task States

| Marker | State | Meaning |
|--------|-------|---------|
| `- [ ]` | Pending | Not started |
| `- [~]` | In Progress | Currently working |
| `- [x]` | Complete | Finished |

### Resuming Work

Use `/devloop:continue` to:
1. Find the plan file
2. Identify next pending task
3. Mark it in-progress
4. Continue implementation

---

## Local Settings

### Project-Specific Configuration

**Path**: `.claude/devloop.local.md`

Override default behavior with project-specific settings:

```markdown
---
dod:
  require_tests: true
  require_docs: false
  min_coverage: 80
workflow:
  skip_phases: [complexity, clarification]
  default_model: sonnet
---

## Project-Specific Notes

- Use kebab-case for file names
- All API endpoints must be documented
- Run `make lint` before committing
```

### Supported Settings

| Setting | Type | Description |
|---------|------|-------------|
| `dod.require_tests` | boolean | Require tests for DoD validation |
| `dod.require_docs` | boolean | Require docs for DoD validation |
| `dod.min_coverage` | number | Minimum test coverage percentage |
| `workflow.skip_phases` | array | Phases to skip by default |
| `workflow.default_model` | string | Default model preference |

---

## Bug Tracking

### Directory Structure

```
.claude/bugs/
├── INDEX.md           # Bug index with status summary
├── BUG-001.md         # Individual bug report
├── BUG-002.md
└── ...
```

### Bug Report Format

```markdown
---
id: BUG-001
title: Login button misaligned on mobile
status: open
priority: medium
created: 2025-01-15
updated: 2025-01-15
tags: [ui, mobile]
---

## Description
The login button overlaps with the navigation bar on mobile viewports.

## Steps to Reproduce
1. Open app on mobile device
2. Navigate to login page
3. Observe button position

## Expected Behavior
Button should be below navigation bar.

## Related Files
- src/components/LoginButton.tsx
- src/styles/mobile.css

## Notes
Likely a CSS specificity issue.
```

### Bug States

| Status | Description |
|--------|-------------|
| `open` | Active bug, needs fixing |
| `in-progress` | Currently being fixed |
| `fixed` | Fix implemented |
| `wont-fix` | Decided not to fix |

### Git Integration

**Option 1**: Keep bugs local
```gitignore
# .gitignore
.claude/bugs/
```

**Option 2**: Share with team
- Commit `.claude/bugs/` to share bug tracking

---

## Directory Structure

Complete devloop plugin structure:

```
plugins/devloop/
├── .claude-plugin/
│   └── plugin.json           # Plugin manifest
├── agents/                   # 16 specialized agents
│   ├── code-explorer.md
│   ├── code-architect.md
│   ├── code-reviewer.md
│   ├── task-planner.md
│   ├── test-generator.md
│   ├── test-runner.md
│   ├── qa-agent.md
│   ├── dod-validator.md
│   ├── security-scanner.md
│   ├── requirements-gatherer.md
│   ├── complexity-estimator.md
│   ├── workflow-detector.md
│   ├── summary-generator.md
│   ├── doc-generator.md
│   ├── git-manager.md
│   └── bug-catcher.md
├── commands/                 # 9 slash commands
│   ├── devloop.md
│   ├── continue.md
│   ├── quick.md
│   ├── spike.md
│   ├── review.md
│   ├── ship.md
│   ├── bug.md
│   ├── bugs.md
│   └── statusline.md
├── hooks/                    # Event handlers
│   ├── hooks.json
│   └── session-start.sh
├── skills/                   # 17 domain skills
│   ├── architecture-patterns/
│   ├── api-design/
│   ├── database-patterns/
│   ├── go-patterns/
│   ├── react-patterns/
│   ├── java-patterns/
│   ├── python-patterns/
│   ├── testing-strategies/
│   ├── security-checklist/
│   ├── deployment-readiness/
│   ├── workflow-selection/
│   ├── model-selection-guide/
│   ├── complexity-estimation/
│   ├── requirements-patterns/
│   ├── git-workflows/
│   ├── plan-management/
│   └── bug-tracking/
├── statusline/               # Status bar script
│   └── devloop-statusline.sh
├── docs/                     # Documentation
│   ├── agents.md
│   ├── skills.md
│   ├── commands.md
│   ├── workflow.md
│   └── configuration.md
└── README.md
```

---

## Troubleshooting

### SessionStart Hook Not Running

1. Check hook is registered in `hooks/hooks.json`
2. Verify script has execute permission: `chmod +x hooks/session-start.sh`
3. Run with debug: `claude --debug`

### Environment Variables Not Set

1. Check `CLAUDE_ENV_FILE` is available to the hook
2. Verify script completes without errors
3. Check script output is valid JSON

### Statusline Not Showing

1. Verify `jq` is installed: `which jq`
2. Check settings.json path is correct
3. Test script manually: `echo '{"model":{"display_name":"Test"}}' | bash statusline/devloop-statusline.sh`

### Plan File Not Found

1. Ensure `.claude/` directory exists
2. Check working directory is project root
3. Verify plan was created by `/devloop` command

### Hooks Blocking Operations

1. Check hook decision responses in console
2. Verify hook prompt is not too restrictive
3. Adjust timeout if hooks are timing out

---

## See Also

- [Agents Documentation](agents.md) - All 16 agents
- [Skills Documentation](skills.md) - All 17 skills
- [Commands Documentation](commands.md) - All 9 commands
- [Workflow Documentation](workflow.md) - 12-phase workflow
