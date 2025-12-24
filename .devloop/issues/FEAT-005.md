# FEAT-005: Enforce Fresh Start Loop Workflow

**Status**: in-progress
**Priority**: high
**Type**: feature
**Estimate**: M
**Created**: 2025-12-24

## Description

Improve the devloop workflow to enforce a consistent development loop with mandatory commits and fresh start options. This will create a better user experience and prevent workflow confusion.

## Requirements

1. **Always Present Fresh Start Option**
   - At the end of `/devloop:continue`, always present "Fresh Start" as an option
   - Should be a standard choice alongside "next task" and "stop"

2. **Mandatory Git Commits**
   - Make git commits a requirement, not an optional step
   - Never ask whether to commit - always commit when a task is complete
   - Only commit after: linting passes, tests pass, and docs are updated

3. **Automatic Fresh Start on Session Begin**
   - When user types `/clear`, the new session hook should check for fresh start JSON
   - If fresh start exists, automatically begin work on that item (no asking)
   - Seamless transition into working on the next item

4. **Standardized End-of-Task Prompt**
   - After task completion (lint/test/commit/docs done), always present these options:
     - Work on next task
     - Fresh start (save current state and prepare for new session)
     - Stop (pause work)
   - Consistent options across all completion points

## Benefits

- **Enforces best practices**: Always commit, always lint/test before commit
- **Reduces friction**: No more deciding whether to commit or what to do next
- **Better flow**: Clear loop pattern that becomes muscle memory
- **Fresh context**: Encourages regular context refreshes for complex work

## Implementation Notes

- Requires session state management (JSON file for fresh start state)
- Session start hook needs to detect and auto-resume from fresh start state
- `/devloop:continue` completion prompt needs standardization
- Consider: `.devloop/local.md` or `.devloop/fresh-start.json` for state persistence

## Workflow Loop

```
1. /clear (new session starts)
   ↓
2. Hook detects fresh-start.json → auto-start work
   ↓
3. Work on task
   ↓
4. Lint passes → Tests pass → Git commit → Docs updated
   ↓
5. Prompt: [Next task] [Fresh start] [Stop]
   ↓
6. If "Fresh start" → save state to fresh-start.json
   ↓
7. User types /clear → back to step 1
```

## Acceptance Criteria

- [ ] Fresh start option always appears at end of `/devloop:continue`
- [ ] Git commits are mandatory (never ask, always commit when ready)
- [ ] Session hook detects fresh-start.json and auto-resumes work
- [ ] Standard 3-option prompt after every task completion
- [ ] Documentation updated to explain the fresh start workflow
- [ ] No user confusion about "what do I do next"

## Related Files

- `plugins/devloop/commands/continue.md` - Completion prompt
- `.claude/hooks/` - Session start hook for fresh start detection
- `.devloop/fresh-start.json` - State persistence (to be created)

---
**Labels**: workflow, ux, devloop-core
