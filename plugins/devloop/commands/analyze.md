---
description: Analyze codebase for refactoring opportunities and generate actionable plan
argument-hint: Optional focus area (e.g., "API layer", "React components")
allowed-tools: ["Read", "Write", "Edit", "Grep", "Glob", "Bash", "Task", "AskUserQuestion", "TodoWrite", "Skill"]
---

# Analyze Codebase for Refactoring

Comprehensive codebase analysis to identify refactoring opportunities, technical debt, and structural issues. Generates actionable recommendations that can be converted directly into devloop plan tasks.

## Plan Integration

This command integrates with devloop's plan system:
1. Analyzes codebase for refactoring opportunities
2. Presents findings for user vetting
3. Converts approved findings to plan tasks in `.devloop/plan.md`
4. Tasks are ordered for atomic, incremental implementation

See `Skill: plan-management` for plan format.

## Agent Routing

This command uses devloop agents for analysis:

| Phase | Agent | Mode/Focus |
|-------|-------|------------|
| Analysis | `devloop:engineer` | Refactor-analyzer mode |
| Plan Generation | `devloop:task-planner` | Planning mode (when generating tasks) |

## When to Use

- **Agent-generated code issues**: When Claude or other agents have created large files, poor structure, or messy code
- **Codebase health check**: Before starting a major feature, assess existing technical debt
- **Planning refactoring work**: Generate a structured plan for cleanup efforts
- **Onboarding assessment**: Understand the quality of an unfamiliar codebase
- **Post-feature cleanup**: After rapid development, identify what needs restructuring

## What This Analyzes

### File-Level Issues
- Large files (>500 lines for most languages, >300 for React components)
- Poor organization and naming conventions
- God objects/modules with too many responsibilities
- Deeply nested directory structures

### Code-Level Issues
- Complex functions (>50 lines, high cyclomatic complexity)
- Code duplication patterns
- Missing error handling
- Inconsistent coding styles

### Language-Specific Issues
- **Go**: Large functions, package organization, error handling, interface pollution
- **Python**: Module structure, type hints, class design, circular dependencies
- **TypeScript/React**: Component complexity, hook usage, prop drilling, type safety

### Architectural Issues
- Poor separation of concerns
- Tight coupling between modules
- Missing abstractions
- Scattered business logic

## Workflow

### Phase 1: Analysis

Initial request focus: $ARGUMENTS

**Actions**:
1. Launch `devloop:engineer` agent in refactor-analyzer mode (sonnet) to perform comprehensive analysis
2. Agent uses standardized methodology:
   - File discovery with Glob
   - Pattern search with Grep
   - Detailed examination with Read
   - Language-specific checks

### Phase 2: Category Summary

Present findings organized by category:

```markdown
## Analysis Complete

**Codebase Overview:**
- Files analyzed: [count] ([languages])
- Overall health: [Good/Fair/Needs Attention/Critical]

**Findings Summary:**
- Critical issues: [count]
- High priority: [count]
- Medium priority: [count]
- Quick wins: [count]

**Categories:**
1. Test Coverage & Quality - [X items]
2. Architectural Issues - [X items]
3. Code Quality - [X items]
4. Quick Wins - [X items]
```

### Phase 3: Interactive Vetting

Use AskUserQuestion to let user select which findings to include:

```
Question: "Which categories would you like to include in the refactoring plan?"
Header: "Categories"
multiSelect: true
Options:
- Test Coverage (X items, Y days effort)
- Architecture (X items, Y days effort)
- Code Quality (X items, Y days effort)
- Quick Wins (X items, Y hours effort)
```

Then for each selected category, present individual items for approval.

### Phase 4: Output Selection

```
Use AskUserQuestion:
- question: "How would you like to use these findings?"
- header: "Output"
- options:
  - Create devloop plan (Recommended) (Generate .devloop/plan.md with refactoring tasks)
  - Add to existing plan (Append as new phase to current plan)
  - Report only (Generate REFACTORING_REPORT.md for review)
  - All formats (Both plan and detailed report)
```

### Phase 5: Plan Generation

If plan output selected:

1. Convert each approved finding to a task:
   ```markdown
   - [ ] Task X.Y: [Refactoring action]
     - Acceptance: [Specific criteria from finding]
     - Files: [Affected files from analysis]
     - Effort: [Estimate from finding]
   ```

2. Order tasks for atomic implementation:
   - Group related changes
   - Dependencies first (e.g., "create utility module" before "move functions to it")
   - Quick wins early for momentum
   - Larger structural changes later

3. Write to `.devloop/plan.md`:
   ```markdown
   # Devloop Plan: Codebase Refactoring

   **Created**: [Date]
   **Status**: Planning
   **Source**: /devloop:analyze

   ## Overview
   Refactoring plan based on automated codebase analysis.

   ## Tasks

   ### Phase 1: Quick Wins
   - [ ] Task 1.1: [Quick win 1]
   ...

   ### Phase 2: Structural Improvements
   - [ ] Task 2.1: [Structural change 1]
   ...

   ### Phase 3: Architecture
   - [ ] Task 3.1: [Architectural improvement 1]
   ...

   ## Progress Log
   - [Date]: Plan generated from /devloop:analyze
   ```

4. If "Add to existing plan" selected:
   - Read current `.devloop/plan.md`
   - Append new phase: "Refactoring (from analysis)"
   - Preserve existing tasks and progress

### Phase 6: Next Steps

After plan generation:

```
Use AskUserQuestion:
- question: "Refactoring plan created with [N] tasks. How would you like to proceed?"
- header: "Next"
- options:
  - Start implementing (Begin with first task via /devloop:continue)
  - Review plan (Show the generated plan)
  - Adjust priorities (Reorder or modify tasks)
  - Stop here (Save plan for later)
```

## Key Principles for Task Ordering

When converting findings to tasks, follow these principles for **atomic, incremental changes**:

### 1. Extract Before Modify
```
Bad:  Refactor large file (changes everything at once)
Good: 1. Create new module structure
      2. Move function A to new module
      3. Move function B to new module
      4. Update imports
      5. Remove empty original file
```

### 2. Tests Before Changes
```
Good: 1. Add tests for existing behavior
      2. Refactor implementation
      3. Verify tests still pass
```

### 3. Quick Wins First
Build momentum with easy wins:
- Rename unclear variables
- Extract obvious helper functions
- Fix simple duplication
- Add missing error handling

### 4. Dependencies Explicit
If task B depends on task A, mark it:
```markdown
- [ ] Task 2.1: Move auth logic to dedicated module
  - Depends on: Task 1.1 (Create auth module structure)
```

### 5. Reviewable Chunks
Each task should produce a reviewable, committable change:
- Single responsibility
- Tests pass after completion
- No broken intermediate states

## When to Prefer Larger Changes

Sometimes atomic isn't optimal:

| Scenario | Approach |
|----------|----------|
| Circular dependency | Break the cycle in one change |
| Rename refactoring | Single commit with all renames |
| Architecture overhaul | May need coordinated multi-file changes |
| Blocked by other work | Batch related items to minimize context switching |

The analyzer will recommend batch changes when atomic doesn't make sense.

## Model Usage

| Phase | Model | Rationale |
|-------|-------|-----------|
| Analysis | sonnet | Needs deep understanding |
| Categorization | sonnet | Judgment required |
| Vetting | haiku | UI is formulaic |
| Plan generation | sonnet | Task breakdown needs context |
| Report | haiku | Template-based |

## Integration with /devloop Workflow

This command can be used:

1. **Standalone**: `/devloop:analyze` → Get refactoring plan → `/devloop:continue`
2. **Within /devloop Phase 3**: When exploring reveals messy code, suggest analysis
3. **After /devloop Phase 7**: Post-implementation cleanup analysis

## Skills

This command uses:
- `Skill: refactoring-analysis` - Analysis methodology and patterns
- `Skill: plan-management` - Plan file format and conventions
- `Skill: [language]-patterns` - Language-specific code quality patterns

## Example Usage

```bash
# Full codebase analysis
/devloop:analyze

# Focused analysis
/devloop:analyze Focus on the API handlers
/devloop:analyze Check React component complexity
/devloop:analyze Analyze the Python backend

# After agent-generated code
/devloop:analyze Claude just created several large files, analyze for refactoring
```

## Notes

- Analysis is non-invasive (read-only during analysis phase)
- Plan generation writes to `.devloop/plan.md`
- Existing plans can be appended to, not overwritten
- Analysis typically takes 2-10 minutes depending on codebase size
- Results are deterministic - same code produces same analysis

---

Invoke the `devloop:engineer` agent in refactor-analyzer mode to perform comprehensive codebase analysis, then convert approved findings into an actionable devloop plan with atomic, ordered tasks.
