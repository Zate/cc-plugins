---
name: phase-templates
description: This skill should be used when commands need "phase definitions", "workflow phases", "discovery phase", "implementation phase", or when referencing standardized devloop phase templates.
whenToUse: |
  - Commands referencing phase templates to reduce duplication
  - Agents needing consistent phase execution patterns
  - Plan execution referencing standard phases
  - Understanding phase structure and goals
whenNotToUse: |
  - Direct user queries - run /devloop or /devloop:continue instead
  - Non-devloop workflows - define custom phases for other plugins
  - Single-task operations without phases
---

# Phase Templates

Standardized phase definitions for devloop workflows. Commands invoke this skill to get phase details instead of duplicating content.

## When to Use This Skill

- **Commands**: Reference these templates in devloop commands to reduce duplication
- **Agents**: Use for consistent phase execution patterns
- **Plan execution**: When continuing from a plan that references standard phases

## When NOT to Use This Skill

- **Direct user queries**: Users should run `/devloop` or `/devloop:continue` instead
- **Non-devloop workflows**: For other plugin workflows, define custom phases

---

## Phase Overview

Standard devloop workflow phases in execution order:

| Phase | Goal | Model | Duration |
|-------|------|-------|----------|
| **Discovery** | Understand requirements | haiku/sonnet | 15-30min |
| **Exploration** | Map existing code | sonnet | 30-60min |
| **Architecture** | Design approach | sonnet/opus | 30-60min |
| **Planning** | Break into tasks | sonnet | 15-30min |
| **Implementation** | Build the feature | sonnet | varies |
| **Testing** | Verify correctness | haiku/sonnet | 30-60min |
| **Review** | Quality assurance | sonnet/opus | 30-45min |
| **Validation** | DoD check | haiku | 15-30min |
| **Integration** | Git commit/PR | haiku | 15-30min |
| **Summary** | Document completion | haiku | 15-30min |

---

## Phase Templates

For complete phase details with actions, outputs, and model selection, see:
- **`references/discovery-exploration.md`** - Discovery and Exploration phases
- **`references/architecture-planning.md`** - Architecture and Planning phases
- **`references/implementation-testing.md`** - Implementation and Testing phases
- **`references/review-validation.md`** - Review and Validation phases
- **`references/integration-summary.md`** - Integration and Summary phases

---

## Task Checkpoint Template

Use after completing any task. **See `Skill: task-checkpoint` for complete workflow.**

### Verification Checklist
- [ ] Code implements task requirements
- [ ] No placeholder code or TODOs incomplete
- [ ] Tests pass (if applicable)
- [ ] Error handling in place

### Plan Update (Required)
- [ ] Mark task complete: `- [ ]` → `- [x]`
- [ ] Add Progress Log entry
- [ ] Update timestamp

### Commit Decision
```
Use AskUserQuestion:
- question: "Task complete. How to handle commit?"
- header: "Commit"
- options:
  - Commit now (Task is self-contained)
  - Group with next (Tasks are related)
  - Review changes
```

---

## Phase Completion Checkpoint

Use when all tasks in a phase are complete.

### Verification
- [ ] All phase tasks marked complete
- [ ] Tests pass
- [ ] No uncommitted grouped changes

### Actions
1. Commit any pending grouped work
2. Update `**Current Phase**:` in plan
3. Add phase completion to Progress Log

---

## Recovery Templates

### Plan Out of Sync
```
Use AskUserQuestion:
- question: "Plan may be out of sync. How to proceed?"
- header: "Recovery"
- options:
  - Backfill entries
  - Continue anyway
  - Review tasks
```

### Uncommitted Changes
```
Use AskUserQuestion:
- question: "Uncommitted changes detected. How to proceed?"
- header: "Uncommitted"
- options:
  - Commit now
  - Discard changes
  - Continue
```

---

## Model Selection Reference

| Phase | Model | Rationale |
|-------|-------|-----------|
| Discovery | haiku/sonnet | Depends on complexity |
| Exploration | sonnet | Need deep understanding |
| Architecture | sonnet/opus | Depends on stakes |
| Planning | sonnet | Task breakdown needs context |
| Implementation | sonnet | Balanced capability |
| Testing | haiku | Formulaic patterns |
| Review | sonnet/opus | Must catch subtle bugs |
| Validation | haiku | Checklist verification |
| Integration | haiku | Git ops are formulaic |
| Summary | haiku | Simple documentation |

For detailed guidance: `Skill: model-selection-guide`

---

## Additional Resources

### Reference Files

**Note**: Phase templates are designed to be concise and self-contained. Detailed phase workflows are documented in individual phase-specific skills rather than separate reference files.

For phase-specific implementation details, see:
- **Discovery/Exploration phases** - `Skill: architecture-patterns` (codebase exploration patterns)
- **Architecture/Planning phases** - `Skill: architecture-patterns`, `Skill: complexity-estimation`
- **Implementation/Testing phases** - Language-specific skills (`go-patterns`, `react-patterns`, etc.)
- **Review/Validation phases** - `Skill: testing-strategies`, `Skill: deployment-readiness`

The `references/` directory exists for future expansion as phase templates evolve.

---

## See Also

- `Skill: plan-management` - Plan file format and procedures
- `Skill: task-checkpoint` - Task completion checklist
- `Skill: worklog-management` - Completed work history
- `Skill: model-selection-guide` - Model selection guidance
