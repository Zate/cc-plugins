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

## Agent Routing

**CRITICAL**: This command uses devloop agents for exploration and evaluation.

| Phase | Agent | Purpose |
|-------|-------|---------|
| Research | `devloop:engineer` (explore mode) | Find similar patterns, understand codebase |
| Prototype | Direct implementation | Throwaway POC code |
| Evaluate | `devloop:complexity-estimator` | T-shirt sizing and risk assessment |
| Next Steps | Route to appropriate workflow | /devloop, /devloop:continue, etc. |

---

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

1. **Search codebase** - Use Task tool with devloop:engineer:
   ```
   Task:
     subagent_type: devloop:engineer
     description: "Explore codebase for [spike topic]"
     prompt: |
       Explore mode: Research the codebase for patterns related to:

       **Spike Topic**: [Topic from arguments]
       **Looking for**: Similar implementations, integration points, existing patterns

       Return:
       - Key files that are relevant
       - Existing patterns we could reuse
       - Potential integration points
       - Any concerns or blockers discovered

       Do NOT modify any code. This is research only.
   ```

2. **External research** if needed:
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

1. **Run complexity assessment** - Use Task tool with devloop:complexity-estimator:
   ```
   Task:
     subagent_type: devloop:complexity-estimator
     description: "Estimate complexity for [spike topic]"
     prompt: |
       Assess the complexity of implementing the approach discovered in this spike:

       **Spike Topic**: [Topic]
       **Proposed Approach**: [Summary of recommended approach]
       **Key Findings**: [What was discovered]

       Provide:
       - T-shirt size estimate (XS/S/M/L/XL)
       - Risk assessment
       - Whether full /devloop workflow is needed or /devloop:quick is sufficient
       - Any dependencies or blockers
   ```

2. **Compare approaches** if multiple:
   | Approach | Complexity | Risk | Pros | Cons |
   |----------|------------|------|------|------|
   | A | | | | |
   | B | | | | |

3. Form recommendation

### Phase 5a: Report

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

2. Display spike report summary to user

### Phase 5b: Apply Plan Updates

**Goal**: Programmatically apply spike findings to existing plan

**CRITICAL**: This phase only applies if:
- Spike report includes "Plan Updates Required" section
- The plan updates are NOT "None" or "Independent"
- User chooses to apply changes

**Actions**:

1. **Check if plan updates are needed**:
   - Read the spike report "Plan Updates Required" section
   - If `Relationship = "Independent"` → Skip to Phase 5c
   - If `Relationship = "New work"` and no existing plan → Skip to Phase 5c
   - Otherwise, continue

2. **Read current plan state**:
   ```
   Read .devloop/plan.md
   - Identify current tasks and structure
   - Locate insertion/modification points from spike recommendations
   ```

3. **Generate diff-style preview**:
   - Show what will change in clear format
   - Example:
   ```markdown
   ## Plan Update Preview

   **Spike**: [Topic]
   **Relationship**: [Replaces Task 2.3 | Adds to Phase 2 | etc.]

   ### Changes

   #### Phase 2: Implementation

   Tasks 2.1-2.2 (unchanged)

   + Task 2.3: Create authentication middleware [NEW]
   +   - Acceptance: JWT validation working
   +   - Files: middleware/auth.go

   - Task 2.3: Add basic auth [REMOVED]

   ~ Task 2.4: Wire up routes [MODIFIED]
   ~   - Acceptance: Routes use new auth middleware (was: "basic auth")
   ~   - Files: routes/routes.go, middleware/auth.go (was: "routes/routes.go")

   Tasks 2.5-2.7 (unchanged)

   #### Parallelism Changes

   + Mark Tasks 2.3 and 2.5 as [parallel:A] (can run together)
   ```

4. **Ask user to apply changes** using Format 4 (Plan Application):
   ```yaml
   Use AskUserQuestion:
     question: "Spike recommends [N] plan changes. Apply to .devloop/plan.md?"
     header: "Apply"
     options:
       - label: "Apply and start"
         description: "Update plan and immediately run /devloop:continue"
       - label: "Apply only"
         description: "Update plan, then review before starting work"
       - label: "Review changes"
         description: "Show full diff with line numbers"
       - label: "Skip updates"
         description: "Continue without applying changes"
   ```

5. **Handle user response**:

   **If "Apply and start"**:
   - Apply all recommended changes to `.devloop/plan.md`
   - Add Progress Log entry: `- [Date Time]: Applied spike findings: [Topic]`
   - Update plan timestamp
   - **Immediately invoke** `/devloop:continue` to start work
   - Exit spike command (continue takes over)

   **If "Apply only"**:
   - Apply all recommended changes to `.devloop/plan.md`
   - Add Progress Log entry: `- [Date Time]: Applied spike findings: [Topic]`
   - Update plan timestamp
   - Display confirmation: "Plan updated. Run `/devloop:continue` when ready to start."
   - Continue to Phase 5c

   **If "Review changes"**:
   - Display full diff with line numbers showing exact changes
   - Loop back to step 4 (ask again with same options)

   **If "Skip updates"**:
   - Display: "Plan unchanged. Spike findings saved to `.devloop/spikes/{topic}.md`."
   - Continue to Phase 5c

6. **Edge case handling**:

   | Scenario | Action |
   |----------|--------|
   | No plan exists | Skip Phase 5b, proceed to Phase 5c |
   | Plan file corrupted | Show error, offer to backup and create fresh |
   | Conflicting tasks | Highlight conflicts in diff, ask user to resolve |
   | Archived phases | Apply updates to active plan only, note if changes affect archived content |

### Phase 5c: Next Steps

**Goal**: Determine post-spike direction

**Actions**:
1. Ask user about next steps (only if NOT "Apply and start" in Phase 5b):
   ```yaml
   Use AskUserQuestion:
     question: "Spike complete. How would you like to proceed?"
     header: "Next"
     options:
       - label: "Start work"
         description: "Launch /devloop:continue to begin implementation"
       - label: "Full workflow"
         description: "Run /devloop for comprehensive feature development"
       - label: "More exploration"
         description: "Continue spike in specific area"
       - label: "Defer"
         description: "Save findings for later"
       - label: "Abandon"
         description: "This approach isn't viable"
   ```

2. **Handle response**:
   - **Start work** → Invoke `/devloop:continue`
   - **Full workflow** → Invoke `/devloop` (let it discover the existing plan)
   - **More exploration** → Ask what to investigate, loop back to Phase 2
   - **Defer** → Display "Findings saved. Review `.devloop/spikes/{topic}.md` when ready."
   - **Abandon** → Display "Spike complete. Consider alternative approaches."

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
