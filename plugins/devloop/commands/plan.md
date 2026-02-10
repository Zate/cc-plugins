---
description: Create an actionable plan with autonomous exploration
argument-hint: What to plan (topic, feature, or question)
allowed-tools:
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - Bash
  - Bash(${CLAUDE_PLUGIN_ROOT}/scripts/*.sh:*)
  - Task
  - AskUserQuestion
  - WebSearch
  - WebFetch
---

# Devloop Plan - Autonomous Plan Generation

Create actionable plan from topic/feature with minimal user interaction.

**Design**: Autonomous by default. Prompt only when genuinely ambiguous.

## Step 1: Parse Input

Extract topic from `$ARGUMENTS`.

**No topic:** Display usage with examples.

**Flags:**
- `--from-issue N`: Fetch from GitHub issue
- `--thorough`: Deep exploration

If `--from-issue`:
```bash
gh issue view $ISSUE_NUMBER --json number,title,body,url
```
Use issue title as topic, body as context.

## Step 2: Check Existing Plan (Silent)

```bash
"${CLAUDE_PLUGIN_ROOT}/scripts/check-plan-complete.sh" .devloop/plan.md
```

**Incomplete plan:** Prompt to replace or cancel (only prompt in this flow).
**Complete or none:** Proceed silently (auto-archive if complete).

## Step 3: Context Detection (Silent)

```bash
"${CLAUDE_PLUGIN_ROOT}/scripts/check-devloop-state.sh"
```

Detect: tech stack, project structure, patterns from CLAUDE.md.

## Step 4: Exploration (Silent)

1. **Search**: Grep for topic keywords, Glob for patterns
2. **Read**: 3-5 most relevant files, understand patterns
3. **Assess**: Files affected, dependencies, complexity (XS/S/M/L/XL)
4. **Risks**: What could go wrong, breaking changes

**Depth:** Standard = 3-5 files. Thorough = 8-10 files.

## Step 5: Plan Generation (Silent)

| Complexity | Tasks | Phases |
|------------|-------|--------|
| XS | 2-3 | 1 |
| S | 3-4 | 1 |
| M | 4-6 | 2 |
| L | 6-8 | 2-3 |
| XL | 8-12 | 3-4 |

```markdown
# Devloop Plan: [Topic]

**Created**: YYYY-MM-DD
**Status**: Ready
**Issue**: #N (URL) (if --from-issue)

---

## Overview
[What we're building]

### Context
[Key findings from exploration]

### Approach
[Recommended approach]

### Considerations
- [Risk 1 and mitigation]

---

## Phase 1: [Name]
- [ ] Task 1.1: [Specific, actionable]
- [ ] Task 1.2: [Specific, actionable]

---

## Progress Log
- YYYY-MM-DD: Plan created
```

**Task criteria:** Specific, actionable, testable, scoped.

## Step 6: Review Checkpoint

Display summary:
```
## Plan: [Topic]

**Complexity**: [Size]
**Tasks**: [N] across [M] phases
**Key files**: [3-5 files]

### Approach
[Brief summary]

### Considerations
- [Risk 1]
```

```yaml
AskUserQuestion:
  questions:
    - question: "Plan generated. How to proceed?"
      header: "Action"
      multiSelect: false
      options:
        - label: "Save and start (Recommended)"
          description: "Write plan.md and begin with /devloop:run"
        - label: "Save only"
          description: "Write plan.md for later"
        - label: "Show full plan"
          description: "Review complete plan before saving"
```

**Save and start:** Write plan, begin `/devloop:run`.
**Save only:** Write plan, display path.
**Show full:** Display complete plan, then ask to save.

## Flags Reference

| Flag | Effect |
|------|--------|
| `--from-issue N` | Fetch from GitHub issue #N |
| `--thorough` | Deeper exploration |

## Prompt Budget

**Target: 1-2 prompts**

| Scenario | Prompts |
|----------|---------|
| No existing plan | 1 (review) |
| Complete plan | 1 (review) |
| Incomplete plan | 2 (conflict + review) |

## vs spike.md

| Aspect | spike | plan |
|--------|-------|------|
| Prompts | 4-5 | 1-2 |
| Output | Spike report | Actionable plan |
| Next step | Manual plan | Ready for /devloop:run |

Use spike for detailed exploration. Use plan to start quickly.

---

**Now**: Parse input and begin autonomous exploration.
