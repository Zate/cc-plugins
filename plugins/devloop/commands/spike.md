---
description: Technical spike/POC to explore feasibility before committing to implementation
argument-hint: What to explore
note: For quick plan generation, use /devloop:plan instead. Use spike for deep exploration without immediate action.
allowed-tools:
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - Bash
  - Bash(${CLAUDE_PLUGIN_ROOT}/scripts/*.sh:*)
  - AskUserQuestion
  - TaskCreate
  - TaskUpdate
  - TaskList
  - Task
  - WebSearch
  - WebFetch
---

# Spike - Technical Exploration

Time-boxed investigation before implementation. **You do the work directly.**

> **Tip**: Use `/devloop:plan` for faster planning. Use spike for detailed exploration reports.

## Step 1: Define Scope

Topic: $ARGUMENTS

### Parse Depth
- `--quick`: High-level feasibility check
- `--deep`: Comprehensive with prototypes
- (default): Standard analysis

### Detect Spike Type

| Topic Pattern | Type | Suggested Aspects |
|---------------|------|-------------------|
| "Should we use X" | Technology decision | Feasibility, Risk, Integration |
| "Add X", "Implement X" | New feature | Scope, Risk, Effort |
| "Is X possible" | Feasibility check | Feasibility, Risk |
| "X vs Y" | Comparison | Approach, Risk, Effort |
| "Redesign X", "Refactor X" | Architecture | Scope, Risk, Dependencies |
| "Fix X", "Why is X" | Investigation | Feasibility, Scope, Risk |
| "How to X" | Implementation | Approach, Dependencies |
| General | General | Scope, Risk, Feasibility |

Display: `Detected: [Type] spike. Depth: [Quick/Standard/Deep]`

### Ask Aspects

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

## Step 2: Research

**Do this directly. No agents needed** (except Explore agent for 50+ files).

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

**Depth adjustment:**
- Quick: Focus on blockers only
- Standard: Balanced investigation
- Deep: Thorough with 8-10 files

## Step 3: Prototype (Optional)

If needed, create throwaway POC in `spike/` or `experiments/`.

## Step 4: Evaluate

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

## Step 5: Report

Write to `.devloop/spikes/{topic}.md`:

```markdown
## Spike: [Topic]

**Question**: [What we investigated]
**Type**: [From detection]
**Depth**: [Quick/Standard/Deep]
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

### Display Summary

**MUST display before next steps:**

```
## Spike Complete: [Topic]

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

## Step 6: Next Steps

```bash
"${CLAUDE_PLUGIN_ROOT}/scripts/check-plan-complete.sh" .devloop/plan.md
```

```yaml
AskUserQuestion:
  questions:
    - question: "Spike complete. How to proceed?"
      header: "Next"
      multiSelect: false
      options:
        - label: "Create plan from findings (Recommended)"
          description: "Generate plan.md using spike recommendations"
        - label: "Start work directly"
          description: "Begin with /devloop:run"
        - label: "Defer"
          description: "Save findings for later"
```

### Create plan from findings

Generate plan based on complexity:
- XS/S: 2-4 tasks, 1 phase
- M: 4-6 tasks, 2 phases
- L/XL: 6-10 tasks, 3 phases

Show generated plan, then:
```yaml
AskUserQuestion:
  questions:
    - question: "Ready to proceed?"
      header: "Confirm"
      multiSelect: false
      options:
        - label: "Save and start"
          description: "Write plan and begin"
        - label: "Edit first"
          description: "Customize before saving"
        - label: "Cancel"
          description: "Don't create plan"
```

### Start work directly
Run `/devloop:run`.

### Defer
Confirm report saved to `.devloop/spikes/{topic}.md`.

---

## Best Practices

- Time-box investigation
- Document as you go
- Fail fast if not feasible
- Keep prototype code throwaway
