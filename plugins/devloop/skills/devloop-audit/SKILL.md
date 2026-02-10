---
name: devloop-audit
description: Audit devloop against Claude Code updates to identify integration opportunities. Use after Claude Code releases, monthly maintenance, or when exploring new features.
whenToUse: Auditing devloop against Claude Code updates, maintenance checks, exploring new Claude Code features
whenNotToUse: Regular development work, implementing features, writing code
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

Audit devloop against Claude Code's evolving capabilities.

## When to Run

- After major Claude Code releases
- Monthly maintenance check
- When noticing new Claude Code features

## Audit Process

### Step 1: Gather Claude Code Information

1. **Fetch Release Notes**: https://code.claude.com/docs/en/changelog.md
2. **Review Key Docs**: Skills, Plugins, Hooks, Sub-agents at code.claude.com/docs/en/

### Step 2: Analyze Current devloop

```bash
ls plugins/devloop/commands/
ls plugins/devloop/agents/
ls plugins/devloop/skills/
```

### Step 3: Compare and Identify Gaps

| Category | Questions |
|----------|-----------|
| Overlap | Does native Claude Code now provide this? |
| Enhancement | Can new features improve this? |
| Deprecation | Are we using outdated patterns? |
| Missing | New capabilities to adopt? |

### Step 4: Generate Findings Report

**Priority Ranking:**
- **High**: Native feature replaces devloop, security issue, blocks users
- **Medium**: Partial overlap, improves UX, aligns with best practices
- **Low**: Minor improvement, nice-to-have

**Effort Estimation:**
- **Low**: <1 day, localized change
- **Medium**: 1-3 days, multiple files
- **High**: 3+ days, architectural change

Save to `.devloop/spikes/claude-code-audit-YYYY-MM-DD.md`:

```markdown
# Claude Code Audit Findings

**Date**: YYYY-MM-DD
**Claude Code Version**: X.Y.Z
**devloop Version**: X.Y.Z

## Summary
Brief overview.

## Integration Opportunities

### High Priority
| Finding | Current State | Action | Effort |
|---------|--------------|--------|--------|

### Medium Priority
...

## Deprecated Patterns
| Pattern | Native Alternative | Migration |
|---------|-------------------|-----------|

## New Features to Adopt
| Feature | Use Case | Notes |
|---------|----------|-------|
```

### Step 5: Offer Next Steps

```yaml
AskUserQuestion:
  questions:
    - question: "Audit complete. What next?"
      header: "Action"
      options:
        - label: "Create spike from findings"
        - label: "Create plan from findings"
        - label: "Review findings"
```

## Audit Checklist

- [ ] Commands: State detection, run patterns, ship workflow current?
- [ ] Skills: Standard frontmatter, discoverable by Claude?
- [ ] Agents: Standard format, aligned with Task tool?
- [ ] Hooks: Current API, best practices?
- [ ] Task Management: Plan vs session tasks clear?
- [ ] State: .devloop/ structure current?

## Key Documentation Links

- Full Index: https://code.claude.com/docs/llms.txt
- Skills: https://code.claude.com/docs/en/skills
- Plugins: https://code.claude.com/docs/en/plugins
- Hooks: https://code.claude.com/docs/en/hooks
- Sub-agents: https://code.claude.com/docs/en/sub-agents

## Output

Produces:
1. Findings report at `.devloop/spikes/claude-code-audit-YYYY-MM-DD.md`
2. Summary of integration opportunities
3. Option to create spike/plan for follow-up
