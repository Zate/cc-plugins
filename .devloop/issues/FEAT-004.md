---
id: FEAT-004
type: feature
title: Add golangci-lint hook integration to devloop
status: done
priority: medium
created: 2025-12-19T12:35:00
updated: 2025-12-19T13:00:00
reporter: user
assignee: null
labels: [golang, hooks, linting, devloop]
related-files:
  - templates/golangci.yml.template
  - plugins/devloop/hooks/hooks.json
estimate: S
---

# FEAT-004: Add golangci-lint hook integration to devloop

## Description

Integrate golangci-lint into devloop plugin with a PostToolUse hook that automatically lints Go files after editing, providing immediate feedback in Claude's context.

**Spike Reference**: `.devloop/spikes/golangci-lint-hook.md` (SPIKE-003)

## Requirements

Based on user requirements and spike findings:

1. **Only activate for Go files** - Check file extension in hook script
2. **Only run if golangci-lint is installed** - Silent skip if not available
3. **Setup yml on demand** - `/devloop:golangci-setup` command to create config
4. **Return errors to context** - Use `hookSpecificOutput.additionalContext`
5. **Nice user messaging** - Brief `systemMessage` with issue count

## Acceptance Criteria

- [ ] PostToolUse hook triggers on Write/Edit of `.go` files
- [ ] Lint errors are added to Claude's context for fixing
- [ ] Hook silently skips if golangci-lint not installed
- [ ] Hook silently skips for non-Go files (no overhead)
- [ ] `/devloop:golangci-setup` creates `.golangci.yml` from template
- [ ] Setup command respects existing project config (don't overwrite)
- [ ] Template uses strict linter set from `templates/golangci.yml.template`

## Implementation

### Files to Create

1. `plugins/devloop/hooks/go-lint.sh` - PostToolUse hook script
2. `plugins/devloop/commands/golangci-setup.md` - Setup command
3. `plugins/devloop/templates/golangci.yml` - Strict linter template

### Files to Modify

1. `plugins/devloop/hooks/hooks.json` - Add PostToolUse entry for go-lint.sh

### Hook Script Design

```bash
#!/bin/bash
# go-lint.sh - PostToolUse hook for Go linting

INPUT=$(cat)
FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# Only lint Go files
[[ ! "$FILE" =~ \.go$ ]] && exit 0

# Check if golangci-lint is installed
command -v golangci-lint &> /dev/null || exit 0

# Check if file exists
[[ ! -f "$FILE" ]] && exit 0

# Run golangci-lint
LINT_OUTPUT=$(golangci-lint run --fast "$FILE" 2>&1 || true)
[[ -z "$LINT_OUTPUT" ]] && exit 0

# Return to context
ISSUE_COUNT=$(echo "$LINT_OUTPUT" | grep -c "^$FILE:" || echo "0")
# ... JSON output with hookSpecificOutput
```

## Context

- Part of devloop plugin, not separate plugin
- Follows existing hook patterns in `plugins/devloop/hooks/`
- Based on completed spike SPIKE-003

## Resolution

- **Resolved**: 2025-12-19
- **Files Created**:
  - `plugins/devloop/hooks/go-lint.sh` - PostToolUse hook script
  - `plugins/devloop/commands/golangci-setup.md` - Setup command
  - `plugins/devloop/templates/golangci.yml` - Strict linter template
- **Files Modified**:
  - `plugins/devloop/hooks/hooks.json` - Added PostToolUse entry for go-lint.sh

## Notes

Implementation complete. The hook:
- Only triggers for `.go` files
- Silently skips if golangci-lint not installed
- Returns lint errors to Claude's context via `hookSpecificOutput.additionalContext`
- Uses `--fast` mode for quick feedback
