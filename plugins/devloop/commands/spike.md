---
description: Technical spike/POC to explore feasibility before committing to implementation
argument-hint: What to explore
allowed-tools: ["Read", "Write", "Edit", "Grep", "Glob", "Bash", "Task", "AskUserQuestion", "TodoWrite", "Skill", "WebSearch", "WebFetch"]
---

# Technical Spike

Exploratory workflow for investigating feasibility, evaluating approaches, or prototyping before committing to full implementation.

## Plan Integration

**CRITICAL**: Spikes must integrate with any existing devloop plan.

### Before Starting a Spike
1. Check if `.devloop/plan.md` exists
2. If it exists, read it to understand:
   - What feature/work is already planned
   - Current phase and progress
   - How this spike relates to existing tasks
3. Note the relationship in Phase 1 (Define Spike Goals)

### After Completing a Spike
If spike findings warrant plan changes, you MUST include a **Plan Update Section** in the report:

```markdown
### Plan Updates Required
**Existing Plan**: [Plan name from devloop-plan.md, or "None"]
**Relationship**: [New work | Replaces Task X.Y | Informs Task X.Y | Independent]

#### Recommended Changes
1. [ ] Add task: [Description] after Task X.Y
2. [ ] Modify task X.Y: [How it should change]
3. [ ] Reorder: Move Task X.Y before Task X.Z because [reason]
4. [ ] Mark parallel: Tasks X.Y and X.Z can run together [parallel:A]
```

When user proceeds with implementation, the plan MUST be updated before work begins.

See `Skill: plan-management` for plan format and parallelism markers.

## When to Use

- New technology or pattern not yet in codebase
- Uncertain feasibility or complexity
- Multiple viable approaches to evaluate
- Performance concerns to benchmark
- Integration with unknown external systems
- High-risk changes needing proof of concept

## Spike Outcomes

A spike should answer:
1. **Is this feasible?** - Can we do this at all?
2. **What's the complexity?** - How hard is it really?
3. **What's the approach?** - Which option is best?
4. **What are the risks?** - What could go wrong?

## Workflow

### Phase 1: Define Spike Goals

**Goal**: Clear scope and success criteria

Initial request: $ARGUMENTS

**Actions**:
1. **Check for existing plan**:
   ```
   Read .devloop/plan.md (if it exists)
   - Note the plan name and current phase
   - Identify if this spike relates to any planned tasks
   - Record relationship: "new work", "informs Task X.Y", or "independent"
   ```

2. Create todo list for spike activities

3. Define what we're trying to learn:
   ```
   Use AskUserQuestion:
   - question: "What's the primary question this spike should answer?"
   - header: "Goal"
   - options:
     - Feasibility (Can we do this?)
     - Approach (Which way is best?)
     - Performance (Is it fast enough?)
     - Integration (Does it work with X?)
   ```

3. Set time box:
   ```
   Use AskUserQuestion:
   - question: "How much time should we spend on this spike?"
   - header: "Timebox"
   - options:
     - 30 minutes (Quick exploration)
     - 1-2 hours (Moderate investigation)
     - Half day (Thorough analysis)
     - Custom (I'll specify)
   ```

### Phase 2: Research

**Goal**: Gather information

**Actions**:
1. Search codebase for related patterns:
   - Launch code-explorer agent to find similar implementations
   - Identify existing patterns we might reuse

2. External research if needed:
   - Use WebSearch for documentation, examples, best practices
   - Use WebFetch to read specific documentation pages
   - Look for known issues or gotchas

3. Document findings as you go

### Phase 3: Prototype

**Goal**: Build minimal proof of concept

**Actions**:
1. Create throwaway prototype code:
   - Use `spike/` or `experiments/` directory
   - Don't worry about production quality
   - Focus on answering the spike questions

2. Test the approach:
   - Does it work at all?
   - Does it integrate properly?
   - Are there performance issues?

3. If multiple approaches, prototype each briefly

### Phase 4: Evaluate

**Goal**: Assess findings

**Actions**:
1. Run complexity-estimator on the proposed approach:
   - Launch complexity-estimator agent
   - Get T-shirt size estimate
   - Identify risks

2. Compare approaches if multiple:
   | Approach | Complexity | Risk | Pros | Cons |
   |----------|------------|------|------|------|
   | A | | | | |
   | B | | | | |

3. Form recommendation

### Phase 5: Report

**Goal**: Document spike findings

**IMPORTANT**: A new spike = a new report. Always **overwrite** any existing spike report using the Write tool (not Edit). Previous spikes are no longer relevant to the current investigation.

**Actions**:
1. **Write** spike report to `.devloop/spikes/{topic}.md` (overwrites existing):

```markdown
## Spike Report: [Topic]

### Questions Investigated
1. [Question 1] → [Answer]
2. [Question 2] → [Answer]

### Findings

#### Feasibility
[Can we do this? Yes/No/Partial]

#### Recommended Approach
[Which approach and why]

#### Complexity Estimate
- **Size**: [XS/S/M/L/XL]
- **Risk**: [Low/Medium/High]
- **Confidence**: [High/Medium/Low]

#### Key Discoveries
1. [Important finding]
2. [Important finding]

#### Risks & Concerns
1. [Risk with mitigation]
2. [Risk with mitigation]

### Recommendation
[Should we proceed? With what approach?]

### Prototype Location
[Where is the POC code, if any]

### Next Steps
1. [What to do next if proceeding]
2. [What to do next if not proceeding]

### Plan Updates Required
**Existing Plan**: [Plan name from devloop-plan.md, or "None"]
**Relationship**: [New work | Replaces Task X.Y | Informs Task X.Y | Independent]

#### Recommended Changes
- [ ] [Add/Modify/Reorder/Remove task - be specific]
- [ ] [Mark parallelism opportunities if any]
```

2. Ask user about next steps:
   ```
   Use AskUserQuestion:
   - question: "Based on spike findings, how would you like to proceed?"
   - header: "Next"
   - options:
     - Proceed (Start full implementation with /devloop)
     - More exploration (Continue spike in specific area)
     - Defer (Save findings for later)
     - Abandon (This isn't viable)
   ```

3. If proceeding, offer to launch full devloop workflow

---

## Spike Best Practices

### DO
- Time-box strictly
- Write throwaway code (it's a prototype)
- Document as you go
- Test assumptions early
- Fail fast if not feasible

### DON'T
- Gold-plate the prototype
- Skip documenting findings
- Exceed the time box without checking
- Commit prototype to main branch
- Assume prototype is production-ready

## Model Usage

| Phase | Model | Rationale |
|-------|-------|-----------|
| Define | haiku | Simple scoping |
| Research | sonnet | Need understanding |
| Prototype | sonnet | Balanced capability |
| Evaluate | sonnet | Analysis needed |
| Report | haiku | Formulaic output |

## Cleanup

After spike completion:
1. Move useful prototype code to proper location OR
2. Delete spike code to avoid confusion
3. Keep spike report for reference
