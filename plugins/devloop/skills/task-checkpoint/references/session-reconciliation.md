# Session End Reconciliation

Reconcile pending worklog entries at the end of a development session to ensure accurate history.

## Reconciliation Checklist

**Before ending session** (via `/devloop:continue` stop, `/devloop:fresh`, or manual exit):

1. **Check for pending entries**:
```bash
# Count pending tasks in worklog
grep "^- \[ \].*pending" .devloop/worklog.md
```

2. **Decide on pending tasks**:
   - **Commit now**: Create commit for uncommitted work
   - **Keep pending**: Leave marked as pending for next session
   - **Discard**: Remove from worklog if work was reverted

3. **Update worklog**:
   - If committing: Follow Step 6a (update with commit hash)
   - If keeping pending: Add note to Progress Log
   - If discarding: Remove entry and note in Progress Log

## Reconciliation Triggers

| Trigger | Action |
|---------|--------|
| User runs `/devloop:fresh` | Prompt to reconcile before saving state |
| User runs `/devloop:continue` with "Stop here" | Prompt to reconcile before summary |
| Session timeout detected | Auto-prompt on next session start |
| Enforcement: strict enabled | Block session end until reconciled |

## Reconciliation Workflow

```
1. Detect pending tasks in worklog
2. Show list to user with AskUserQuestion
3. For each pending task:
   - User selects: Commit / Keep / Discard
4. Update worklog based on decisions
5. Generate session summary with reconciliation notes
```

**Example Reconciliation Question**:
```yaml
AskUserQuestion:
  question: "3 tasks pending in worklog. Reconcile before ending?"
  header: "Worklog"
  options:
    - Commit all (Create grouped commit for pending tasks)
    - Review individually (Decide per task)
    - Keep pending (Leave for next session)
    - Discard (Remove from worklog)
```

## Enforcement Behavior

**Advisory Mode**:
```
⚠️ Warning: 3 pending tasks in worklog.

These tasks are marked complete in the plan but not committed:
- Task 3.2: Add validation
- Task 3.3: Write tests
- Task 3.4: Update docs

Would you like to:
- Commit now (Create grouped commit)
- Keep pending (Continue in next session)
- Review (Decide per task)
```

**Strict Mode**:
```
🛑 Blocked: Worklog reconciliation required.

Strict enforcement is enabled. Cannot end session
until all pending tasks are committed or discarded.

Pending tasks: 3
- Task 3.2: Add validation
- Task 3.3: Write tests
- Task 3.4: Update docs

Action: Create commit or discard pending work.
```

## Integration with Fresh Start

When using `/devloop:fresh`, reconciliation happens BEFORE saving state:

```
1. User runs /devloop:fresh
2. Detect pending worklog entries
3. Prompt reconciliation (if any pending)
4. After reconciliation, save state to next-action.json
5. User runs /clear
6. Next session: worklog is clean, no pending entries
```

This ensures the worklog is always in a consistent state across sessions.
