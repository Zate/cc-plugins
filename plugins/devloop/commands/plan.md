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

Create an actionable plan from a topic, feature request, or question. Performs exploration and plan generation with minimal user interaction.

**Design principle**: Autonomous by default. Only prompt when genuinely ambiguous.

## Step 1: Parse Input

Extract topic from `$ARGUMENTS`.

**If no topic provided:**
```
Usage: /devloop:plan "your feature or question"

Examples:
  /devloop:plan "add user authentication"
  /devloop:plan "refactor payment service"
  /devloop:plan --from-issue 123
```

**Parse flags:**
- `--from-issue N`: Fetch topic from GitHub issue N
- `--thorough`: Deep exploration (more time, more detail)
- (default): Standard exploration

### If --from-issue specified:

```bash
gh issue view $ISSUE_NUMBER --json number,title,body,url
```

Use issue title as topic, body as context.

## Step 2: Check Existing Plan (Silent)

```bash
"${CLAUDE_PLUGIN_ROOT}/scripts/check-plan-complete.sh" .devloop/plan.md
```

**If plan exists and is INCOMPLETE:**

This is the ONE place we prompt - overwriting incomplete work:

```yaml
AskUserQuestion:
  questions:
    - question: "Existing plan has [N] pending tasks. Replace it?"
      header: "Conflict"
      multiSelect: false
      options:
        - label: "Replace"
          description: "Overwrite with new plan"
        - label: "Cancel"
          description: "Keep existing plan"
```

**If plan is complete or doesn't exist:** Proceed silently (auto-archive if complete).

## Step 3: Context Detection (Silent)

Gather context WITHOUT prompting:

```bash
"${CLAUDE_PLUGIN_ROOT}/scripts/check-devloop-state.sh"
```

Also detect:
- Tech stack from package.json, go.mod, requirements.txt, etc.
- Project structure from directory layout
- Existing patterns from CLAUDE.md if present

Store context for plan generation.

## Step 4: Exploration (Silent)

Explore the codebase to understand the topic:

1. **Search for related code**
   ```bash
   # Find relevant files
   Grep for keywords from topic
   Glob for likely file patterns
   ```

2. **Read key files**
   - Identify 3-5 most relevant files
   - Understand existing patterns
   - Note integration points

3. **Assess scope**
   - How many files/components affected?
   - Dependencies involved?
   - Complexity estimate (XS/S/M/L/XL)

4. **Identify risks**
   - What could go wrong?
   - Breaking changes?
   - External dependencies?

**Depth adjustment:**
- Standard: Focus on most relevant 3-5 files
- Thorough (`--thorough`): Explore 8-10 files, deeper analysis

Document findings internally (don't display yet).

## Step 5: Plan Generation (Silent)

Generate plan based on findings:

### Complexity-based task count:

| Complexity | Tasks | Phases |
|------------|-------|--------|
| XS | 2-3 | 1 |
| S | 3-4 | 1 |
| M | 4-6 | 2 |
| L | 6-8 | 2-3 |
| XL | 8-12 | 3-4 |

### Plan structure:

```markdown
# Devloop Plan: [Topic]

**Created**: YYYY-MM-DD
**Updated**: YYYY-MM-DD
**Status**: Ready
**Issue**: #N (URL) (if from --from-issue)

---

## Overview

[Brief description of what we're building/changing]

### Context

[Key findings from exploration - what we learned about the codebase]

### Approach

[Recommended approach based on exploration]

### Considerations

- [Risk 1 and mitigation]
- [Risk 2 and mitigation]

---

## Phase 1: [Phase Name]

- [ ] Task 1.1: [Specific, actionable task]
- [ ] Task 1.2: [Specific, actionable task]

---

## Phase 2: [Phase Name] (if M/L/XL)

- [ ] Task 2.1: [Specific, actionable task]
...

---

## Progress Log

- YYYY-MM-DD: Plan created from exploration
```

### Task quality criteria:

Each task should be:
- **Specific**: Clear what to do
- **Actionable**: Can start immediately
- **Testable**: Know when it's done
- **Scoped**: Not too big, not too small

## Step 6: Review Checkpoint

Display the generated plan summary:

```
## Plan: [Topic]

**Complexity**: [XS/S/M/L/XL]
**Tasks**: [N] across [M] phases
**Key files**: [list 3-5 most relevant]

### Approach
[Brief approach summary]

### Phase Overview
1. [Phase 1 name] - [N] tasks
2. [Phase 2 name] - [N] tasks (if applicable)

### Top Considerations
- [Risk/consideration 1]
- [Risk/consideration 2]
```

Then prompt (only prompt in typical flow):

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

### If "Save and start":
1. Write plan to `.devloop/plan.md`
2. Display: "Plan saved. Starting autonomous execution..."
3. Begin `/devloop:run` workflow

### If "Save only":
1. Write plan to `.devloop/plan.md`
2. Display: "Plan saved to .devloop/plan.md. Run `/devloop:run` when ready."

### If "Show full plan":
1. Display the complete plan markdown
2. Ask: "Save this plan?"

## Flags Reference

| Flag | Effect |
|------|--------|
| `--from-issue N` | Fetch topic from GitHub issue #N |
| `--thorough` | Deeper exploration, more detail |

## Examples

```bash
# Basic usage
/devloop:plan "add dark mode support"

# From GitHub issue
/devloop:plan --from-issue 42

# Thorough exploration for complex features
/devloop:plan "redesign authentication system" --thorough
```

## Prompt Budget

**Target: ≤ 2 prompts in typical flow**

| Scenario | Prompts |
|----------|---------|
| No existing plan | 1 (review checkpoint) |
| Complete plan exists | 1 (review checkpoint) |
| Incomplete plan exists | 2 (conflict + review) |

## Comparison with spike.md

| Aspect | spike.md | plan.md |
|--------|----------|---------|
| User prompts | 4-5 | 1-2 |
| Output | Spike report | Actionable plan |
| Next step | Manual plan creation | Ready for /devloop:run |
| Use case | Deep exploration | Quick to actionable |

Use `spike.md` when you need detailed analysis without immediate action.
Use `plan.md` when you want to start implementing quickly.

---

**Now**: Parse input and begin autonomous exploration.
