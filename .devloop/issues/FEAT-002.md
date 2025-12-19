---
id: FEAT-002
type: feature
title: Smart context-aware /devloop command with state detection
status: open
priority: medium
created: 2025-12-19T10:05:00
updated: 2025-12-19T10:05:00
reporter: user
assignee: null
labels: [ux, devloop, workflow]
related-files:
  - plugins/devloop/commands/devloop.md
estimate: M
---

# FEAT-002: Smart context-aware /devloop command with state detection

## Description

Create a unified `/devloop` command (currently `/devloop:devloop`) that intelligently detects the current state of devloop in the project and presents the most relevant options to the user.

Instead of requiring users to know which specific command to run, `/devloop` should analyze the project state and suggest 4 contextual options plus a free-form input option.

## Acceptance Criteria

- [ ] `/devloop` becomes the main entry point (rename from `/devloop:devloop`)
- [ ] Command detects current devloop state on invocation
- [ ] Presents up to 4 smart suggestions based on state
- [ ] Always includes "Tell me what you want to do" option for custom input
- [ ] Suggestions are relevant and actionable

## State Detection Logic

The command should detect and prioritize these states:

### 1. Not Set Up
- `.devloop/` directory doesn't exist
- Suggest: "Set up devloop for this project"

### 2. Needs Migration
- Old `.claude/` structure exists but not `.devloop/`
- Suggest: "Migrate from .claude/ to .devloop/"

### 3. Has Active Plan
- `.devloop/plan.md` exists with incomplete tasks
- Suggest: "Continue working on [current task]"

### 4. Outstanding Git Changes
- Uncommitted changes exist
- Suggest: "Commit/ship your changes"

### 5. Open Bugs
- `.devloop/issues/BUG-*.md` with status: open exists
- Suggest: "Fix open bugs (N bugs)"

### 6. Open Features in Backlog
- Open features exist in `.devloop/issues/`
- Suggest: "Work on backlog items"

### 7. Clean State
- Everything is set up and no active work
- Suggest: "Start a new feature", "Run a spike", etc.

## Example UX

```
/devloop

Detected: Active plan with 3 remaining tasks

What would you like to do?
1. Continue plan (Task 2.3: Add authentication)
2. Fix bugs (2 open)
3. Ship changes (uncommitted work detected)
4. View issues
5. Something else...
```

## Notes

- Options should be dynamically generated based on actual state
- The 4 options should be the most relevant actions, not static
- "Something else" routes to free-form input where user describes task
- This replaces the current static `/devloop:devloop` command
