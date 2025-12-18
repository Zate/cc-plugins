---
id: FEAT-001
type: feature
title: Enhanced form-like issue creation in /devloop:new
status: open
priority: medium
created: 2025-12-18T12:05:00
updated: 2025-12-18T12:05:00
reporter: user
assignee: null
labels: [devloop, commands, ux]
estimate: S
related-files:
  - plugins/devloop/commands/new.md
---

# FEAT-001: Enhanced form-like issue creation in /devloop:new

## Description

Enhance the `/devloop:new` command to use AskUserQuestion with multiple questions in a single call, creating a form-like experience similar to Jira or other bug trackers. This would streamline issue creation by collecting all required information in one interactive form rather than sequential single questions.

## Current Behavior

Currently, `/devloop:new` asks questions one at a time:
1. What type of issue?
2. What priority?
3. What labels?
4. etc.

Each question requires a separate interaction.

## Proposed Behavior

Use AskUserQuestion with multiple questions in a single call to present a form-like interface:

```
AskUserQuestion with questions array:
- Type (bug/feature/task/chore/spike)
- Priority (low/medium/high)
- Title (text input via "Other")
- Labels (multiSelect)
- Estimate (for features/tasks)
```

This creates a Jira-like experience where users see all fields at once.

## Acceptance Criteria

- [ ] Single AskUserQuestion call collects type, priority, and labels
- [ ] Form adapts based on detected issue type (bugs show severity, features show estimates)
- [ ] Title can be pre-filled from command arguments or entered via "Other" option
- [ ] Maintains backward compatibility with quick mode (short descriptions)
- [ ] Works for all issue types: BUG, FEAT, TASK, CHORE, SPIKE

## Technical Notes

- AskUserQuestion supports up to 4 questions per call
- Can use multiSelect for labels
- "Other" option always available for custom text input
- May need 2 form stages: basic info, then type-specific details

## Notes

This aligns with the command orchestration pattern - keeping user interaction visible and efficient in the main conversation flow.

## Resolution

<!-- Filled in when done -->
- **Resolved in**:
- **Resolved by**:
- **Resolution summary**:
