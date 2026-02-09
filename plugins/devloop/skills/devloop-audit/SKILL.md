---
name: devloop-audit
description: Audit devloop against Claude Code updates to identify integration opportunities. Use after Claude Code releases, monthly maintenance, or when exploring new features.
disable-model-invocation: true
context: fork
agent: Explore
allowed-tools:
  - Read
  - Grep
  - Glob
  - WebFetch
  - WebSearch
  - Write
  - AskUserQuestion
---

# Devloop Audit

Audit devloop against Claude Code's evolving capabilities to identify integration opportunities, deprecated patterns, and areas for improvement.

## When to Run

- After major Claude Code releases
- Monthly maintenance check
- When noticing new Claude Code features
- Before major devloop changes

## Audit Process

### Step 1: Gather Claude Code Information

Fetch the latest documentation and release notes:

1. **Check Release Notes**
   - Fetch changelog: https://code.claude.com/docs/en/changelog.md
   - Use WebFetch to get the latest entries
   - Focus on: new tools, hooks, skills, plugin features, breaking changes

2. **Review Key Documentation**
   - Skills: https://code.claude.com/docs/en/skills
   - Plugins: https://code.claude.com/docs/en/plugins
   - Hooks: https://code.claude.com/docs/en/hooks
   - Sub-agents: https://code.claude.com/docs/en/sub-agents

3. **Check Built-in Tools**
   - TaskCreate/TaskUpdate/TaskList (session-scoped tasks)
   - Skill tool (skill invocation)
   - Task tool (subagent spawning)

### Step 2: Analyze Current devloop Features

Review devloop's current implementation:

```bash
# List all devloop commands
ls plugins/devloop/commands/

# List all devloop agents
ls plugins/devloop/agents/

# List all devloop skills
ls plugins/devloop/skills/
```

### Step 3: Compare and Identify Gaps

For each devloop feature, check:

| Category | Questions |
|----------|-----------|
| **Overlap** | Does native Claude Code now provide this? |
| **Enhancement** | Can we leverage new features to improve this? |
| **Deprecation** | Are we using patterns that are now outdated? |
| **Missing** | Are there new capabilities we should adopt? |

### Step 4: Generate Findings Report

**Priority Ranking Logic:**

| Priority | Criteria |
|----------|----------|
| **High** | Native feature fully replaces devloop feature, OR security/correctness issue, OR blocking user workflows |
| **Medium** | Native feature partially overlaps, OR improves UX/performance, OR aligns with best practices |
| **Low** | Minor improvement, OR "nice to have", OR requires significant refactoring for small benefit |

**Effort Estimation:**

| Effort | Description |
|--------|-------------|
| **Low** | < 1 day, localized change, no breaking changes |
| **Medium** | 1-3 days, touches multiple files, may require migration |
| **High** | 3+ days, architectural change, breaking changes likely |

Create a findings report at `.devloop/spikes/claude-code-audit-YYYY-MM-DD.md`:

```markdown
# Claude Code Audit Findings

**Date**: YYYY-MM-DD
**Claude Code Version**: X.Y.Z
**devloop Version**: X.Y.Z

## Summary

Brief overview of findings.

## Integration Opportunities

### High Priority

| Finding | Current State | Recommended Action |
|---------|--------------|-------------------|
| [Description] | [How devloop works now] | [What to change] |

### Medium Priority

...

### Low Priority

...

## Deprecated Patterns

| Pattern | Native Alternative | Migration Path |
|---------|-------------------|----------------|
| [Current approach] | [New approach] | [How to migrate] |

## New Features to Adopt

| Feature | Use Case | Implementation Notes |
|---------|----------|---------------------|
| [Feature name] | [How it helps devloop] | [How to implement] |

## No Action Needed

Features that are already aligned with Claude Code best practices.

## Next Steps

1. Create spike plans for high-priority items
2. Schedule medium-priority items for future sprints
3. Document low-priority items for consideration
```

### Step 5: Generate Spike Plan (if needed)

If high-priority items are found, generate a spike plan:

```markdown
# Spike: Claude Code Integration Opportunities

**Date**: YYYY-MM-DD
**Source**: Audit findings from [date]
**Focus**: High-priority integration opportunities

## Questions to Answer

1. [Question derived from top finding]
2. [Question derived from second finding]

## Investigation Tasks

- [ ] Task 1: [Specific investigation from findings]
- [ ] Task 2: [Specific investigation from findings]

## Success Criteria

- Clear recommendation for each integration opportunity
- Migration path documented for any deprecations
- Risk assessment for breaking changes
```

Save to `.devloop/spikes/claude-code-integration-YYYY-MM-DD.md`

### Step 6: Offer Next Steps

After generating the report, ask the user:

```yaml
AskUserQuestion:
  questions:
    - question: "Audit complete. What would you like to do?"
      header: "Action"
      multiSelect: false
      options:
        - label: "Create spike from findings"
          description: "Start /devloop:spike with top priority items"
        - label: "Create plan from findings"
          description: "Create implementation plan for all items"
        - label: "Review findings"
          description: "Just review the report for now"
```

## Audit Checklist

### Commands

- [ ] `/devloop` - State detection still relevant?
- [ ] `/devloop:run` - Autonomous execution aligned with native patterns?
- [ ] `/devloop:spike` - Exploration workflow current?
- [ ] `/devloop:fresh` - Context management vs native summarization?
- [ ] `/devloop:ship` - Git integration patterns current?

### Skills

- [ ] Skill format using standard frontmatter?
- [ ] Skills discoverable by Claude when relevant?
- [ ] Skill content appropriate for invocation type?

### Agents

- [ ] Agent definitions using standard format?
- [ ] Subagent patterns aligned with Task tool?
- [ ] Agent capabilities appropriate for tasks?

### Hooks

- [ ] Hook events using current API?
- [ ] Hook patterns following best practices?

### Task Management

- [ ] Plan persistence (markdown) vs session tasks (TaskCreate)?
- [ ] Appropriate use of each system?
- [ ] Clear documentation on when to use which?

### State Management

- [ ] `.devloop/` directory structure current?
- [ ] State files using appropriate formats?
- [ ] Session state vs persistent state clear?

## Key Documentation Links

**Start here for complete doc index:**
- Full Index: https://code.claude.com/docs/llms.txt

**Core documentation pages:**
- Skills: https://code.claude.com/docs/en/skills
- Plugins: https://code.claude.com/docs/en/plugins
- Plugins Reference: https://code.claude.com/docs/en/plugins-reference
- Hooks: https://code.claude.com/docs/en/hooks
- Sub-agents: https://code.claude.com/docs/en/sub-agents
- Interactive Mode: https://code.claude.com/docs/en/interactive-mode
- Memory: https://code.claude.com/docs/en/memory
- Permissions/IAM: https://code.claude.com/docs/en/iam

## Example Output

```markdown
# Claude Code Audit Findings

**Date**: 2026-01-27
**Claude Code Version**: 2.1.x
**devloop Version**: 3.14.0

## Summary

Found 3 integration opportunities: 1 high, 1 medium, 1 low priority.
No deprecated patterns detected.

## Integration Opportunities

### High Priority

| Finding | Current State | Recommended Action | Effort |
|---------|--------------|-------------------|--------|
| TaskCreate/Update native integration | devloop uses plan.md only | Hybrid: plan.md for persistence + native Tasks for UI | Medium |

### Medium Priority

| Finding | Current State | Recommended Action | Effort |
|---------|--------------|-------------------|--------|
| Skill frontmatter alignment | Some skills missing new fields | Update frontmatter to include `context`, `agent` where applicable | Low |

### Low Priority

| Finding | Current State | Recommended Action | Effort |
|---------|--------------|-------------------|--------|
| Document /compact vs /fresh | Users confused about when to use which | Add guidance to CLAUDE.md | Low |

## Deprecated Patterns

None found.

## New Features to Adopt

| Feature | Use Case | Implementation Notes |
|---------|----------|---------------------|
| `context: fork` for skills | Run expensive operations in subagent | Consider for devloop-audit skill |

## Next Steps

1. Create Issue #20 for TaskCreate integration (high priority)
2. Update skill frontmatter in next maintenance pass
3. Add /compact vs /fresh guidance to docs
```

## Output

This skill produces:
1. A findings report at `.devloop/spikes/claude-code-audit-YYYY-MM-DD.md`
2. Summary of integration opportunities
3. Option to create spike/plan for follow-up work
