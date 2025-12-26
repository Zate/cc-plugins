# Engineer Agent Mode Extraction Plan

**Created**: 2025-12-26
**Purpose**: Document extraction boundaries for engineer.md optimization

## Current State

- **Total Lines**: 1,034 lines
- **Mode Instructions**: ~345 lines (33% of file)
- **Target**: ~500 lines after extraction

## Section Analysis

### KEEP in engineer.md (Core Sections)

| Section | Lines | Rationale |
|---------|-------|-----------|
| Frontmatter | 37 | Required metadata, tools, skills |
| system_role | 10 | Core identity |
| capabilities | 18 | Core capability definitions |
| mode_detection | 143 | Orchestration logic - triggers, complexity detection |
| workflow_enforcement | 44 | Core workflow phases |
| output_requirements | 53 | Token budgets, file reference format |
| model_escalation | 13 | Small, important guidance |
| constraints | 8 | Critical safety rules |
| limitations | 11 | Delegation triggers |
| plan_context | 16 | Plan awareness |
| workflow_awareness | 126 | Plan sync, checkpoints (critical integration) |
| skill_integration | 117 | Skill routing (keep for now) |
| delegation | 72 | Agent delegation table |

**Subtotal KEEP**: ~668 lines

### EXTRACT to references/ (Mode Instructions)

| Mode | Lines | Target File |
|------|-------|-------------|
| Explorer Mode | 80 | `references/explorer-mode.md` |
| Architect Mode | 109 | `references/architect-mode.md` |
| Refactorer Mode | 76 | `references/refactorer-mode.md` |
| Git Mode | 80 | `references/git-mode.md` |

**Subtotal EXTRACT**: ~345 lines

## Extraction Approach

### What Goes in Reference Files

Each mode reference file contains:
1. Mode title and purpose
2. Detailed workflow/process steps
3. Output format templates with examples
4. Token budget guidance
5. Mode-specific patterns and examples

### What Stays in engineer.md

For each mode, keep in mode_instructions:
1. Brief summary (2-3 lines)
2. Reference link: `"For detailed instructions, see references/{mode}-mode.md"`
3. Key output format notes (condensed)

### Updated mode_instructions Structure (After Extraction)

```markdown
<mode_instructions>

<mode name="explorer">
## Explorer Mode

**Purpose**: Trace execution paths, map architecture, understand patterns

**Reference**: See `references/explorer-mode.md` for detailed workflow

**Quick Reference**:
- Analysis: Feature discovery → Code flow tracing → Architecture analysis
- Output: Entry points table, execution flow, key components, insights
- Token budget: Max 500 tokens for exploration summaries
</mode>

<mode name="architect">
## Architect Mode

**Purpose**: Design features, make structural decisions, plan implementations

**Reference**: See `references/architect-mode.md` for detailed workflow

**Quick Reference**:
- Process: Pattern analysis → Architecture design → Implementation blueprint
- Output: Patterns found, decision rationale, component design, build sequence
- Token budget: Max 800 tokens per architecture proposal
</mode>

<mode name="refactorer">
## Refactorer Mode

**Purpose**: Identify code quality issues, technical debt, improvements

**Reference**: See `references/refactorer-mode.md` for detailed workflow

**Quick Reference**:
- Workflow: Survey → Analysis → Categorize → Quick wins
- Output: Codebase health, findings by priority, quick wins, roadmap
- Token budget: Max 1000 tokens for refactoring reports
</mode>

<mode name="git">
## Git Mode

**Purpose**: Commits, branches, PRs, history management

**Reference**: See `references/git-mode.md` for detailed workflow

**Quick Reference**:
- Operations: Conventional commits, branch naming, PR descriptions
- Safety: Never force push main, confirm before history modification
- Token budget: Max 200 tokens for git summaries
</mode>

</mode_instructions>
```

**Estimated reduction**: 345 lines → ~60 lines = 285 lines saved

## Reference File Templates

### references/explorer-mode.md

```markdown
# Explorer Mode Reference

This document contains detailed workflow and output format for Explorer mode.

**Loaded when**: Engineer agent operates in Explorer mode
**Token impact**: ~80 lines loaded on-demand

## Analysis Approach
[Full content from current explorer mode section]

## Scope Clarification
[Full AskUserQuestion examples]

## Output Format
[Full structured output template with examples]

## Token Budget
[Guidance on staying within 500 tokens]
```

### references/architect-mode.md

```markdown
# Architect Mode Reference

This document contains detailed workflow and output format for Architect mode.

**Loaded when**: Engineer agent operates in Architect mode
**Token impact**: ~109 lines loaded on-demand

## Design Process
[Full content from current architect mode section]

## Decision Points
[AskUserQuestion patterns]

## Output Format
[Full structured output template with examples]

## Parallelization Analysis
[Parallel vs sequential decision logic]

## Token Budget
[Guidance on staying within 800 tokens]
```

### references/refactorer-mode.md

```markdown
# Refactorer Mode Reference

This document contains detailed workflow and output format for Refactorer mode.

**Loaded when**: Engineer agent operates in Refactorer mode
**Token impact**: ~76 lines loaded on-demand

## Analysis Workflow
[Full content from current refactorer mode section]

## Interactive Vetting
[AskUserQuestion patterns for vetting]

## Output Format
[Full structured output template with examples]

## Token Budget
[Guidance on staying within 1000 tokens]
```

### references/git-mode.md

```markdown
# Git Mode Reference

This document contains detailed workflow and output format for Git mode.

**Loaded when**: Engineer agent operates in Git mode
**Token impact**: ~80 lines loaded on-demand

## Operations
[Commit, branch, PR, history operations]

## Conventional Commits
[Format and type definitions]

## Task-Linked Commits
[Format for devloop task references]

## Git Safety
[Safety constraints]

## Output Format
[Structured output template]

## Token Budget
[Guidance on staying within 200 tokens]
```

## Implementation Steps

1. **Task 4.2**: Create `plugins/devloop/agents/engineer/references/` directory with README.md
2. **Task 4.3**: Extract Explorer mode → `references/explorer-mode.md`
3. **Task 4.4**: Extract Architect mode → `references/architect-mode.md`
4. **Task 4.5**: Extract Refactorer mode → `references/refactorer-mode.md`
5. **Task 4.6**: Extract Git mode → `references/git-mode.md`
6. **Task 4.7**: Update engineer.md with condensed mode_instructions and references
7. **Task 4.8**: Test all 4 modes work correctly with references

## Expected Results

| Metric | Before | After | Reduction |
|--------|--------|-------|-----------|
| engineer.md lines | 1,034 | ~500 | 51% |
| Mode instructions loaded | 345 lines always | ~60 lines + on-demand | 83% per-invocation |
| Reference files | 0 | 4 files (~345 lines total) | N/A |

## Future Optimization Opportunities

If further reduction needed (Phase 6+):
- Extract `skill_integration` to `references/skill-routing.md` (~117 lines)
- Extract `delegation` to `references/delegation-table.md` (~72 lines)
- Extract `workflow_awareness` to `references/workflow-patterns.md` (~126 lines)

Potential additional savings: ~315 lines (engineer.md → ~350 lines)
