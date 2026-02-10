---
description: Create an actionable plan with autonomous exploration
argument-hint: <topic> [--deep|--quick|--from-issue N]
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
  - TaskCreate
  - TaskUpdate
  - TaskList
---

# Devloop Plan - Unified Planning Command

Create actionable plan from topic/feature. **You do the work directly.**

**Modes:**
- (default): Autonomous planning with 1-2 prompts
- `--deep`: Comprehensive exploration with spike report (4-5 prompts)
- `--quick`: Skip exploration, fast path to execution
- `--from-issue N`: Fetch from GitHub issue

## Step 1: Parse Input

Extract topic from `$ARGUMENTS`.

**No topic:** Display usage:
```
Usage: /devloop:plan <topic> [flags]

Flags:
  --deep         Comprehensive exploration with spike report (4-5 prompts)
  --quick        Skip exploration, fast path to execution
  --from-issue N Fetch from GitHub issue #N

Examples:
  /devloop:plan "add user authentication"
  /devloop:plan "fix login bug" --quick
  /devloop:plan "new caching strategy" --deep
  /devloop:plan --from-issue 42
```

**Flags:**
- `--from-issue N`: Fetch from GitHub issue
- `--deep`: Comprehensive exploration (replaces /devloop:spike)
- `--quick`: Skip exploration (replaces /devloop:quick)

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

## Step 3: Route by Mode

### If `--quick`: Fast Path

**When to use:**
- Bug fixes with known cause
- Small feature additions to existing patterns
- Configuration changes, documentation updates

**When NOT to use (escalate to default mode):**
- New features with unclear requirements
- Changes touching multiple systems
- Security-related changes

**Quick Implementation Flow:**

1. Create brief todo list (2-4 tasks max)
2. If unclear, ask ONE clarifying question
3. If too complex, suggest removing `--quick` flag

**Then implement directly:**
1. Read relevant files (limit to 3-5)
2. Make changes using Write/Edit
3. Follow existing patterns exactly
4. Run tests: `npm test --` or `go test ./...` or `pytest -x`
5. Brief summary: what changed, files modified, follow-up needed

**Escalation:**
```yaml
AskUserQuestion:
  questions:
    - question: "This is more complex than expected. Switch to full planning?"
      header: "Escalate"
      multiSelect: false
      options:
        - label: "Yes, full planning"
          description: "Remove --quick, do comprehensive planning"
        - label: "Continue quick"
          description: "Accept limitations, keep going"
```

**After quick completion:** STOP (no further steps).

---

### If `--deep`: Comprehensive Exploration

**When to use:**
- Unclear requirements that need investigation
- Technology decisions ("Should we use X?")
- Feasibility checks before committing
- Architecture redesigns

**Deep Exploration Flow:**

#### Step 3a: Define Scope

Detect spike type from topic:

| Topic Pattern | Type | Suggested Aspects |
|---------------|------|-------------------|
| "Should we use X" | Technology decision | Feasibility, Risk, Integration |
| "Add X", "Implement X" | New feature | Scope, Risk, Effort |
| "Is X possible" | Feasibility check | Feasibility, Risk |
| "X vs Y" | Comparison | Approach, Risk, Effort |
| "Redesign X", "Refactor X" | Architecture | Scope, Risk, Dependencies |
| "Fix X", "Why is X" | Investigation | Feasibility, Scope, Risk |
| General | General | Scope, Risk, Feasibility |

Display: `Detected: [Type] exploration. Mode: Deep`

```yaml
AskUserQuestion:
  questions:
    - question: "What aspects matter most?"
      header: "Aspects"
      multiSelect: true
      options:
        - label: "[Aspect 1] (Recommended)"
          description: "[From table above]"
        - label: "[Aspect 2] (Recommended)"
          description: "[From table above]"
        - label: "[Aspect 3]"
          description: "[From table above]"
```

**Available aspects:** Feasibility, Scope, Risk, Dependencies, Approach, Effort, User impact, Performance, Integration.

#### Step 3b: Research

For each selected aspect:

| Aspect | Investigation |
|--------|---------------|
| Feasibility | Search for similar code, identify blockers, check constraints |
| Scope | Map affected files/components, blast radius, secondary effects |
| Risk | Identify unknowns, worst cases, reversibility concerns |
| Dependencies | What needs to exist first, external services, teams |
| Approach | Find 2-3 viable approaches, research pros/cons |
| Effort | Break into task list, identify complexity drivers |
| User impact | Who affected, breaking changes, migration path |
| Performance | Critical paths, bottlenecks, scalability |
| Integration | Integration points, API compatibility, conflicts |

**Depth:** 8-10 files for deep exploration.

#### Step 3c: Evaluate

For each explored aspect, provide verdict:

| Aspect | Verdict Format |
|--------|---------------|
| Feasibility | Yes/No/Partial + Confidence + Blockers |
| Scope | XS/S/M/L/XL + Files affected + Secondary effects |
| Risk | Low/Medium/High + Top risks + Mitigation possible? |
| Dependencies | Blockers + External + Can start now? |
| Approach | Best + Runner-up + Confidence |
| Effort | Hours/Days/Weeks + Complexity drivers |
| User impact | Users affected + Breaking changes + Migration? |
| Performance | Acceptable/Needs work/Blocker + Concerns |
| Integration | Compatible/Needs adaptation/Incompatible |

**Overall:** Recommendation (Proceed/Caution/Don't/Need more), Confidence, Next step.

#### Step 3d: Write Spike Report

Write to `.devloop/spikes/{topic}.md`:

```markdown
## Spike: [Topic]

**Question**: [What we investigated]
**Type**: [From detection]
**Explored**: [Selected aspects]

### Findings
[Include only sections for explored aspects]

### Summary
| Aspect | Finding | Confidence |
|--------|---------|------------|
| [Explored] | [Verdict] | High/Med/Low |

### Recommendation
**[Proceed / Proceed with caution / Don't proceed / Need more info]**
[Brief explanation and next step]
```

#### Step 3e: Display Summary

**MUST display before next steps:**

```
## Deep Exploration Complete: [Topic]

### Answer
[Direct answer to question]

### Recommendation
**[Verdict]** - [1-2 sentence explanation]

### Key Findings
1. [Most important]
2. [Second most important]

### Complexity & Risk
- **Complexity**: [Size] - [reason]
- **Risk**: [Level] - [top risk if Medium/High]

*Full report: .devloop/spikes/{topic}.md*
```

**Then continue to Step 4** (Context Detection) to generate plan from findings.

---

### Default Mode: Autonomous Planning

## Step 4: Context Detection (Silent)

```bash
"${CLAUDE_PLUGIN_ROOT}/scripts/check-devloop-state.sh"
```

Detect: tech stack, project structure, patterns from CLAUDE.md.

## Step 5: Exploration (Silent)

1. **Search**: Grep for topic keywords, Glob for patterns
2. **Read**: 3-5 most relevant files, understand patterns
3. **Assess**: Files affected, dependencies, complexity (XS/S/M/L/XL)
4. **Risks**: What could go wrong, breaking changes

**Depth:** Standard = 3-5 files. Deep = 8-10 files.

## Step 6: Plan Generation (Silent)

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

## Step 7: Review Checkpoint

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

| Flag | Effect | Prompts |
|------|--------|---------|
| (none) | Autonomous exploration | 1-2 |
| `--deep` | Comprehensive with spike report | 4-5 |
| `--quick` | Skip exploration, fast execution | 0-1 |
| `--from-issue N` | Fetch from GitHub issue #N | +0 |

## Migration Notes

| Old Command | New Equivalent |
|-------------|----------------|
| `/devloop:spike` | `/devloop:plan --deep` |
| `/devloop:quick` | `/devloop:plan --quick` |
| `/devloop:from-issue N` | `/devloop:plan --from-issue N` |

---

**Now**: Parse input and begin.
