---
id: FEAT-003
type: feature
title: Add option to create plan.md from spike findings
status: open
priority: medium
created: 2025-12-19T10:10:00
updated: 2025-12-19T10:10:00
reporter: user
assignee: null
labels: [spike, plan, devloop, workflow]
related-files:
  - plugins/devloop/commands/spike.md
estimate: S
---

# FEAT-003: Add option to create plan.md from spike findings

## Description

When a spike has fully investigated a topic and produced a recommended approach, the user should have the option to directly create a `plan.md` from the spike findings. This streamlines the workflow from research to implementation.

## Acceptance Criteria

- [ ] Spike command offers "Create plan from findings" as a next step option
- [ ] This option only appears when spike has a clear recommendation
- [ ] Selecting this option generates a `.devloop/plan.md` with:
  - Tasks derived from the recommended approach
  - Complexity estimates from the spike
  - Risks noted in the plan
- [ ] User can review/edit the generated plan before it becomes active

## Current Behavior

The spike command's Phase 5 offers these options:
- Proceed (Start full implementation with /devloop)
- More exploration (Continue spike in specific area)
- Defer (Save findings for later)
- Abandon (This isn't viable)

## Proposed Behavior

Add a new option when the spike has clear findings:
- **Create plan** (Generate plan.md from these findings)

This option should:
1. Parse the spike report's recommended approach
2. Break it into logical implementation tasks
3. Apply complexity estimates from the spike
4. Include risks as notes/considerations
5. Write to `.devloop/plan.md`
6. Show the generated plan to the user
7. Ask for confirmation before finalizing

## Example Flow

```
Based on spike findings, how would you like to proceed?
1. Create plan (Generate plan.md from these findings) (Recommended)
2. Proceed with /devloop (Manual feature flow)
3. More exploration (Continue spike)
4. Defer (Save for later)
```

If "Create plan" selected:
```markdown
## Generated Plan from Spike: [Topic]

### Task 1: [Derived from recommendation]
- Complexity: [From spike]
- Notes: [From spike risks]

### Task 2: ...

Would you like to use this plan? (Yes/Edit/Cancel)
```

## Notes

This connects spikes directly to the implementation workflow, making spikes more actionable and reducing friction between research and development.
