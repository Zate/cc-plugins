---
description: Technical spike/POC to explore feasibility before committing to implementation
argument-hint: What to explore
allowed-tools:
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - Bash
  - Bash(${CLAUDE_PLUGIN_ROOT}/scripts/*.sh:*)
  - AskUserQuestion
  - TodoWrite
  - WebSearch
  - WebFetch
---

# Spike - Technical Exploration

Time-boxed investigation to explore feasibility before committing to implementation. **You do the work directly.**

## Step 1: Define Scope

Initial request: $ARGUMENTS

Ask user what aspects to explore and their time budget:

```yaml
AskUserQuestion:
  questions:
    - question: "What aspects should this spike explore? (Select all that apply)"
      header: "Explore"
      multiSelect: true
      options:
        - label: "Feasibility"
          description: "Can we do this at all?"
        - label: "Approach comparison"
          description: "Compare different implementation strategies"
        - label: "Performance"
          description: "Is it fast/efficient enough?"
        - label: "Integration"
          description: "Compatibility with existing code"
    - question: "What's your time budget?"
      header: "Depth"
      multiSelect: false
      options:
        - label: "Quick (30 min)"
          description: "High-level feasibility check"
        - label: "Standard (1-2 hr)"
          description: "Solid analysis with recommendations"
        - label: "Deep dive"
          description: "Comprehensive exploration with prototypes"
```

Create a brief todo list for the investigation based on selected aspects.

## Step 2: Research

**Do this directly. No agents needed.**

For each selected exploration aspect, investigate accordingly:

### If "Feasibility" selected:
1. Search for similar implementations in codebase
2. Identify technical blockers or requirements
3. Check for dependencies or constraints

### If "Approach comparison" selected:
1. Identify 2-3 viable approaches
2. Research pros/cons of each
3. Look for existing patterns in codebase

### If "Performance" selected:
1. Identify performance-critical areas
2. Research benchmarks or profiling approaches
3. Look for bottlenecks or optimization opportunities

### If "Integration" selected:
1. Find integration points in existing code
2. Check API compatibility
3. Identify potential conflicts

**General research steps:**
1. **Search codebase**: Use Grep/Glob to find similar patterns
2. **Read relevant files**: Understand existing implementation
3. **External research**: Use WebSearch/WebFetch for docs if needed

Adjust depth based on time budget:
- **Quick**: Focus on blockers, skip detailed analysis
- **Standard**: Balanced investigation of each aspect
- **Deep dive**: Thorough research with code exploration

Document key findings as you go.

## Step 3: Prototype (Optional)

If needed, create throwaway POC code:

1. Use `spike/` or `experiments/` directory
2. Don't worry about production quality
3. Focus on answering the spike question

## Step 4: Evaluate

After investigation, assess each selected exploration aspect:

### For each selected aspect, provide a verdict:

**If "Feasibility" was explored:**
- Verdict: Yes / No / Partial
- Confidence: High / Medium / Low
- Key blockers (if any)

**If "Approach comparison" was explored:**
- Best approach: [Name]
- Runner-up: [Name]
- Confidence: High / Medium / Low

**If "Performance" was explored:**
- Verdict: Acceptable / Needs work / Blocker
- Confidence: High / Medium / Low
- Key concerns (if any)

**If "Integration" was explored:**
- Verdict: Compatible / Needs adaptation / Incompatible
- Confidence: High / Medium / Low
- Integration points identified

### Overall Assessment:
- **Complexity**: XS / S / M / L / XL
- **Risk**: Low / Medium / High
- **Recommended approach**: What's the best path forward?

## Step 5: Report

Write spike report to `.devloop/spikes/{topic}.md`:

```markdown
## Spike: [Topic]

**Question**: [What we investigated]
**Explored**: [Feasibility, Approach, Performance, Integration] (list selected)
**Depth**: [Quick/Standard/Deep dive]

### Findings by Aspect

#### Feasibility (if selected)
- [Key finding]
- Verdict: [Yes/No/Partial]

#### Approach Comparison (if selected)
| Approach | Pros | Cons |
|----------|------|------|
| Option A | ... | ... |
| Option B | ... | ... |

- Best approach: [Name]

#### Performance (if selected)
- [Key finding]
- Verdict: [Acceptable/Needs work/Blocker]

#### Integration (if selected)
- [Key finding]
- Verdict: [Compatible/Needs adaptation/Incompatible]

### Summary Matrix

| Aspect | Verdict | Confidence |
|--------|---------|------------|
| Feasibility | Yes/No/Partial | High/Med/Low |
| Approach | [Best option] | High/Med/Low |
| Performance | Acceptable/Needs work | High/Med/Low |
| Integration | Compatible/Needs adapt | High/Med/Low |

### Recommendation
[Proceed/Don't proceed] with [approach]

### Complexity: [Size] | Risk: [Level]
```

## Step 6: Next Steps

First, check if there's an existing completed plan that should be archived:

```bash
"${CLAUDE_PLUGIN_ROOT}/scripts/check-plan-complete.sh" .devloop/plan.md
```

If an existing plan is complete (`complete: true`), offer to archive before proceeding:

```yaml
AskUserQuestion:
  question: "Existing plan is complete. Archive it before starting new work?"
  header: "Archive"
  options:
    - label: "Archive and continue"
      description: "Move old plan to archive, then proceed"
    - label: "Replace without archiving"
      description: "Overwrite the old plan"
    - label: "Cancel"
      description: "Keep existing plan"
```

If "Archive and continue":
```bash
"${CLAUDE_PLUGIN_ROOT}/scripts/archive-plan.sh" .devloop/plan.md
```

Then ask about next steps:

```yaml
AskUserQuestion:
  question: "Spike complete. How would you like to proceed?"
  header: "Next"
  options:
    - label: "Start work"
      description: "Begin implementation with /devloop:continue"
    - label: "Create plan"
      description: "Design full implementation plan"
    - label: "Defer"
      description: "Save findings for later"
```

---

## Best Practices

- Time-box: Don't exceed planned investigation time
- Document as you go
- Fail fast if not feasible
- Keep prototype code throwaway (don't commit to main)
