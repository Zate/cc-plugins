# Continue - Resume Work

Resume development from an existing plan or fresh start state.

## Step 1: Check State

Look for continuation context:

```bash
# Check for fresh start state
cat .devloop/next-action.json 2>/dev/null

# Check for existing plan
cat .devloop/plan.md 2>/dev/null
```

## Step 2: Route to Appropriate Flow

### A) Fresh Start Recovery (next-action.json exists)

Load saved state:
```json
{
  "task": "Task X.Y: Description",
  "phase": "Current Phase Name", 
  "notes": "Context about work in progress",
  "saved_at": "YYYY-MM-DD HH:MM"
}
```

Show user:
```
Resuming from fresh start (saved YYYY-MM-DD HH:MM)

Task: [task description]
Phase: [phase name]
Notes: [any context]

Ready to continue?
```

Delete `.devloop/next-action.json` after loading.

### B) Plan Exists (plan.md exists)

Read `.devloop/plan.md` and find:
1. Current status
2. Next pending task (first `- [ ]`)
3. Recent progress log entries

Show user:
```
Resuming plan: [Plan Title]

Last update: [timestamp from progress log]

Next task: 
- [ ] Task X.Y: Description

Continue with this task?
```

### C) No State (neither file exists)

```
No existing plan or state found.

Start new work with @rovodev [description]
```

## Step 3: Continue Execution

Once state is loaded:

1. **Confirm current task** with user if ambiguous
2. **Review context** - read relevant files mentioned in task
3. **Execute task** - implement, test, document
4. **Update plan**:
   ```bash
   # Mark task complete
   sed -i 's/- \[ \] Task X.Y/- [x] Task X.Y/' .devloop/plan.md
   
   # Add progress log entry
   echo "- $(date +%Y-%m-%d): Task X.Y completed" >> .devloop/plan.md
   ```
5. **Move to next task** or checkpoint

## Step 4: Checkpoint

After completing task(s):

```
Progress update:
✓ Task X.Y: [description]
✓ Task X.Z: [description]

Next up:
- [ ] Task X.N: [description]

Continue? (yes/no/fresh)
- yes: Keep working
- no: Stop here
- fresh: Save state for later (@fresh)
```

## Plan Format Reference

Plans use markdown checkboxes:

```markdown
# [Feature Name]

**Status**: In Progress
**Current Phase**: Phase 2

## Tasks

### Phase 1: Foundation
- [x] Task 1.1: Completed task
- [x] Task 1.2: Another completed task

### Phase 2: Implementation  
- [ ] Task 2.1: Next pending task ← START HERE
- [ ] Task 2.2: Future task

## Progress Log
- 2026-01-09: Phase 1 complete
- 2026-01-09: Starting Phase 2
```

## Task Markers

Plans may include special markers:

- `[parallel:A]` - Can run with other Group A tasks
- `[depends:N.M]` - Must wait for Task N.M to complete
- `[blocked]` - Cannot proceed (awaiting external input)

## Useful Commands During Work

```bash
# Check plan completion status
bash plugins/rovodev/scripts/check-plan-complete.sh

# View plan
cat .devloop/plan.md

# Save state for fresh start
# (runs @fresh prompt)
```

## Integration with Other Prompts

- Need investigation? → `@spike [topic]`
- Quick detour? → `@quick [fix]` 
- Ready to ship? → `@ship`
- Code review? → `@review`

---

**Resuming work...**
