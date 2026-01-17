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

### Parse Depth Flag

Check arguments for depth modifiers:
- `--quick` → Quick depth (high-level feasibility check)
- `--deep` → Deep depth (comprehensive exploration with prototypes)
- (no flag) → Standard depth (default - solid analysis with recommendations)

Strip the flag from the topic string for analysis.

### Detect Spike Type

Analyze the topic to determine the type of spike and suggest the most relevant aspects.

**Available Aspects:**

| Aspect | Description | When to suggest |
|--------|-------------|-----------------|
| **Feasibility** | Can we do this at all? | Most spikes |
| **Scope** | How big is this? What's the blast radius? | Most spikes |
| **Risk** | What could go wrong? Unknowns? | Most spikes |
| **Dependencies** | What does this touch? What's needed first? | Changes touching multiple areas |
| **Approach** | Compare different ways to do it | When multiple valid paths exist |
| **Effort** | Is this a day or a month? | Planning/estimation needs |
| **User impact** | How does this affect users? | User-facing changes |
| **Performance** | Is it fast enough? Scalable? | Performance-sensitive features |
| **Integration** | How does it fit with existing code? | Touching existing systems |

**Spike Type Detection:**

| Topic Pattern | Spike Type | Suggested Aspects (pick 2-3) |
|---------------|------------|------------------------------|
| "Should we use X", "Is X right for" | Technology decision | Feasibility, Risk, Integration |
| "Add X", "Implement X", "Build X" | New feature | Scope, Risk, Effort |
| "Is X possible", "Can we do X" | Feasibility check | Feasibility, Risk |
| "X vs Y", "Compare X and Y" | Comparison | Approach, Risk, Effort |
| "Redesign X", "Refactor X" | Architecture | Scope, Risk, Dependencies |
| "Fix X", "Why is X broken" | Investigation | Feasibility, Scope, Risk |
| "How to X", "Best way to X" | Implementation | Approach, Dependencies |
| (general/unclear) | General | Scope, Risk, Feasibility |

Display the detected type and depth:
```
Detected: [Spike Type] spike
Depth: [Quick/Standard/Deep] (use --deep or --quick to change)
```

### Ask for Aspects

Based on detected type, present a context-aware question with 3-4 relevant options.

**Build the question dynamically** using the suggested aspects from type detection:

```yaml
AskUserQuestion:
  questions:
    - question: "What aspects matter most for this spike?"
      header: "Aspects"
      multiSelect: true
      options:
        - label: "[Suggested aspect 1] (Recommended)"
          description: "[From aspects table]"
        - label: "[Suggested aspect 2] (Recommended)"
          description: "[From aspects table]"
        - label: "[Suggested aspect 3]"
          description: "[From aspects table]"
```

**Example for "Add dark mode" (New feature spike):**
```yaml
options:
  - label: "Scope (Recommended)"
    description: "How big is this? What's the blast radius?"
  - label: "Risk (Recommended)"
    description: "What could go wrong? Unknowns?"
  - label: "Effort"
    description: "Is this a day or a month?"
  - label: "User impact"
    description: "How does this affect users?"
```

**Example for "Should we use Redis" (Technology decision):**
```yaml
options:
  - label: "Feasibility (Recommended)"
    description: "Can we do this at all?"
  - label: "Risk (Recommended)"
    description: "What could go wrong? Unknowns?"
  - label: "Integration"
    description: "How does it fit with existing code?"
```

Only show aspects relevant to the spike type. Don't always show Performance or Integration unless the topic warrants it.

Create a brief todo list for the investigation based on selected aspects.

## Step 2: Research

**Do this directly. No agents needed.**

For each selected aspect, investigate accordingly:

### If "Feasibility" selected:
1. Search for similar implementations in codebase
2. Identify technical blockers or requirements
3. Check for hard constraints (API limits, platform restrictions, etc.)

### If "Scope" selected:
1. Identify all files/components that would be touched
2. Map out the blast radius (what else changes if this changes?)
3. List any secondary effects or follow-on work

### If "Risk" selected:
1. Identify unknowns and assumptions being made
2. What could go wrong? What's the worst case?
3. Are there reversibility concerns? Can we undo this?

### If "Dependencies" selected:
1. What needs to exist/happen before this can work?
2. What other systems/teams are involved?
3. Are there external dependencies (APIs, libraries, services)?

### If "Approach" selected:
1. Identify 2-3 viable approaches
2. Research pros/cons of each
3. Look for existing patterns in codebase

### If "Effort" selected:
1. Break down into rough task list
2. Identify complexity drivers (what makes this hard?)
3. Compare to similar past work if available

### If "User impact" selected:
1. Who is affected by this change?
2. Is there a migration path? Breaking changes?
3. What's the user-facing behavior change?

### If "Performance" selected:
1. Identify performance-critical paths
2. Research benchmarks or profiling approaches
3. Look for bottlenecks or scalability concerns

### If "Integration" selected:
1. Find integration points in existing code
2. Check API compatibility
3. Identify potential conflicts with existing behavior

**General research steps:**
1. **Search codebase**: Use Grep/Glob to find related code
2. **Read relevant files**: Understand existing implementation
3. **External research**: Use WebSearch/WebFetch for docs if needed

Adjust depth based on depth level:
- **Quick**: Focus on blockers and showstoppers only
- **Standard**: Balanced investigation of each aspect
- **Deep**: Thorough research with code exploration

Document key findings as you go.

## Step 3: Prototype (Optional)

If needed, create throwaway POC code:

1. Use `spike/` or `experiments/` directory
2. Don't worry about production quality
3. Focus on answering the spike question

## Step 4: Evaluate

After investigation, assess each selected aspect:

### For each selected aspect, provide a verdict:

**If "Feasibility" was explored:**
- Verdict: Yes / No / Partial
- Confidence: High / Medium / Low
- Key blockers (if any)

**If "Scope" was explored:**
- Size: XS / S / M / L / XL
- Files/components affected: [count]
- Secondary effects: [list]

**If "Risk" was explored:**
- Risk level: Low / Medium / High
- Top risks: [list 2-3]
- Mitigation possible? Yes / Partial / No

**If "Dependencies" was explored:**
- Blocking dependencies: [list]
- External dependencies: [list]
- Can start now? Yes / After X / No

**If "Approach" was explored:**
- Best approach: [Name]
- Runner-up: [Name]
- Confidence: High / Medium / Low

**If "Effort" was explored:**
- Estimate: Hours / Days / Weeks
- Complexity drivers: [list]
- Confidence: High / Medium / Low

**If "User impact" was explored:**
- Users affected: [scope]
- Breaking changes: Yes / No
- Migration needed: Yes / No

**If "Performance" was explored:**
- Verdict: Acceptable / Needs work / Blocker
- Key concerns (if any)

**If "Integration" was explored:**
- Verdict: Compatible / Needs adaptation / Incompatible
- Integration points: [list]

### Overall Assessment:
- **Recommendation**: Proceed / Proceed with caution / Don't proceed / Need more info
- **Confidence**: High / Medium / Low
- **Next step**: What should happen next?

## Step 5: Report

Write spike report to `.devloop/spikes/{topic}.md`:

```markdown
## Spike: [Topic]

**Question**: [What we investigated]
**Type**: [Technology decision / New feature / Feasibility check / Comparison / Architecture / Investigation / Implementation / General]
**Depth**: [Quick/Standard/Deep]
**Explored**: [List only the aspects that were selected]

### Findings

<!-- Include only sections for aspects that were explored -->

#### Feasibility
- [Key findings]
- **Verdict**: Yes / No / Partial

#### Scope
- **Size**: XS / S / M / L / XL
- **Blast radius**: [What's affected]
- **Secondary effects**: [Follow-on work needed]

#### Risk
- **Level**: Low / Medium / High
- **Top risks**:
  1. [Risk 1]
  2. [Risk 2]
- **Mitigation**: [Possible / Partial / Difficult]

#### Dependencies
- **Blockers**: [What needs to happen first]
- **External**: [APIs, services, teams]

#### Approach
| Option | Pros | Cons |
|--------|------|------|
| A | ... | ... |
| B | ... | ... |
- **Recommendation**: [Best option]

#### Effort
- **Estimate**: [Hours / Days / Weeks]
- **Complexity drivers**: [What makes this hard]

#### User Impact
- **Affected users**: [Scope]
- **Breaking changes**: Yes / No
- **Migration**: [Required / Not needed]

#### Performance
- **Verdict**: Acceptable / Needs work / Blocker
- **Concerns**: [If any]

#### Integration
- **Verdict**: Compatible / Needs adaptation / Incompatible
- **Integration points**: [List]

### Summary

| Aspect | Finding | Confidence |
|--------|---------|------------|
| [Only list explored aspects] | [Verdict] | High/Med/Low |

### Recommendation

**[Proceed / Proceed with caution / Don't proceed / Need more info]**

[Brief explanation of recommendation and suggested next step]
```

### Display Summary Before Proceeding

**IMPORTANT**: After writing the report, you MUST display a summary to the user BEFORE asking next steps.

Display this summary in the conversation:

```
## Spike Complete: [Topic]

### Answer
[Direct answer to the primary question being investigated]

### Recommendation
**[Proceed / Proceed with caution / Don't proceed / Need more info]**

[1-2 sentence explanation]

### Key Findings
1. [Most important finding]
2. [Second most important finding]
3. [Third most important finding - if applicable]

### Complexity & Risk
- **Complexity**: [XS/S/M/L/XL] - [brief reason]
- **Risk Level**: [Low/Medium/High] - [top risk if Medium/High]

*Full report saved to: `.devloop/spikes/{topic}.md`*
```

This summary MUST be displayed before any `AskUserQuestion` call.

## Step 6: Next Steps

First, check if there's an existing completed plan that should be archived:

```bash
"${CLAUDE_PLUGIN_ROOT}/scripts/check-plan-complete.sh" .devloop/plan.md
```

If an existing plan is complete (`complete: true`), offer to archive before proceeding:

```yaml
AskUserQuestion:
  questions:
    - question: "Existing plan is complete. Archive it before starting new work?"
      header: "Archive"
      multiSelect: false
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
  questions:
    - question: "Spike complete. How would you like to proceed?"
      header: "Next"
      multiSelect: false
      options:
        - label: "Create plan from findings (Recommended)"
          description: "Generate plan.md using spike recommendations"
        - label: "Start work directly"
          description: "Begin implementation with /devloop:continue"
        - label: "Defer"
          description: "Save findings for later"
```

### If "Create plan from findings":

Generate a plan from the spike findings:

1. **Parse spike data** from the summary displayed above:
   - Topic becomes plan title
   - Recommendation becomes overview
   - Complexity estimate informs task breakdown
   - Risks become considerations section

2. **Generate tasks** based on complexity:
   - **XS/S**: 2-4 tasks in single phase
   - **M**: 4-6 tasks across 2 phases
   - **L/XL**: 6-10 tasks across 3 phases

3. **Create plan structure**:

```markdown
# Devloop Plan: [Spike Topic]

**Created**: YYYY-MM-DD
**Updated**: YYYY-MM-DD
**Status**: Planning
**Source**: Spike findings

---

## Overview

[Spike recommendation and approach summary]

### From Spike

- **Recommendation**: [Proceed/Proceed with caution/etc]
- **Complexity**: [XS/S/M/L/XL]
- **Risk Level**: [Low/Medium/High]

### Considerations

[List key risks and mitigations from spike findings]

---

## Phase 1: [Phase Name]

- [ ] Task 1.1: [Task derived from spike findings]
- [ ] Task 1.2: [Task derived from spike findings]

[Additional phases as needed based on complexity]

---

## Progress Log

- YYYY-MM-DD: Plan created from spike findings
```

4. **Display the generated plan** to the user for review.

5. **Ask for confirmation**:

```yaml
AskUserQuestion:
  questions:
    - question: "Review the generated plan. Ready to proceed?"
      header: "Confirm"
      multiSelect: false
      options:
        - label: "Looks good, save it"
          description: "Write plan to .devloop/plan.md"
        - label: "Edit first"
          description: "I'll make changes before saving"
        - label: "Cancel"
          description: "Don't create plan"
```

**If "Looks good, save it":**
- Write plan to `.devloop/plan.md`
- Display: "Plan created at .devloop/plan.md"
- Ask: "Start working on the plan now?"

**If "Edit first":**
- Display the plan content
- Tell user: "Make your edits to the plan above, then run `/devloop:continue` when ready"

**If "Cancel":**
- Don't write anything
- Return to next steps options

### If "Start work directly":
Run `/devloop:continue` to begin implementation immediately

### If "Defer":
- Ensure spike report is saved to `.devloop/spikes/{topic}.md`
- Display: "Findings saved to `.devloop/spikes/{topic}.md` - revisit anytime"

---

## Best Practices

- Time-box: Don't exceed planned investigation time
- Document as you go
- Fail fast if not feasible
- Keep prototype code throwaway (don't commit to main)
