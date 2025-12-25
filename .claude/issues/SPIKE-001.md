---
id: SPIKE-001
type: spike
title: Investigate existing codebase onboarding for devloop
status: done
priority: medium
created: 2025-12-18T12:00:00
updated: 2025-12-18T12:00:00
reporter: user
assignee: null
labels: [bootstrap, migration]
timebox: 2 hours
related-files:
  - plugins/devloop/commands/bootstrap.md
---

# SPIKE-001: Investigate existing codebase onboarding for devloop

## Description

Explore how to enable devloop to onboard an existing repository with code, plans, tasks, and documentation into the devloop workflow system.

## Goals

1. **Analyze** existing codebase structure and conventions
2. **Discover** existing plans, tasks, and documentation
3. **Migrate** found artifacts to devloop format (devloop-plan.md)
4. **Understand** project architecture through spike/analysis
5. **Suggest** next steps if no plans/tasks exist

## Key Questions to Answer

### Architecture Decision
- Should we enhance `/devloop:bootstrap` with existing codebase detection?
- Or create a new `/devloop:migrate` command specifically for this?
- Pros/cons of each approach?

### Integration Points
- What new commands, hooks, agents, or skills are needed?
- Can we reuse existing components (code-explorer, spike, etc.)?
- How does this integrate with existing devloop workflow?

### Discovery Phase
- How to detect existing plans (project.md, TODO.md, ROADMAP.md)?
- How to find existing task tracking (GitHub issues, TODO comments)?
- How to discover documentation structure?
- How to understand project architecture?

### Migration Phase
- What formats should we support migrating from?
- How to convert discovered plans to devloop-plan.md format?
- How to handle partial migrations?

### Fallback Behavior
- What if no plans/tasks exist?
- When to suggest `/devloop:spike` vs `/devloop:new`?
- How to guide users through initial setup?

## Acceptance Criteria

- [x] Document decision: enhance bootstrap vs new migrate command
- [x] List of components needed (commands, agents, skills, hooks)
- [x] Integration strategy with existing codebase
- [x] Migration format mapping (source formats → devloop format)
- [x] Fallback flow documented

## Notes

- Current `/devloop:bootstrap` is for PRDs/specs, creating new projects
- This spike is about onboarding EXISTING codebases
- Should leverage existing exploration/analysis capabilities
- Must be non-destructive - don't overwrite existing work

## Related

- `/devloop:bootstrap` - Current command for new projects from docs
- `/devloop:spike` - Technical investigation workflow
- `code-explorer` agent - Analyzes existing codebases
- `project-context` skill - Detects tech stack

## Resolution

- **Resolved in**: `.claude/onboarding-spike-report.md`
- **Resolved by**: agent:claude
- **Resolution summary**: Recommend creating NEW `/devloop:onboard` command (not enhancing bootstrap). Needs 1 command + 1 agent. Can heavily reuse existing components (code-explorer, project-context, issue-manager). Migration pattern from bugs→issues provides good template. Should complete TASK-001 (file consolidation) first before implementing.
