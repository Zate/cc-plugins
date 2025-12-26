# State Transitions

State transition diagram and table for the workflow loop.

## State Transition Diagram

```
PLAN ─────────────▶ WORK ────────────▶ CHECKPOINT
 ▲                                         │
 │                                         ▼
 │                                      DECIDE
 │                                         │
 │        ┌────────────────────────────────┼────────────────┐
 │        │                                │                │
 │        ▼                                ▼                ▼
 │     CONTINUE                        COMMIT            STOP
 │        │                              │                 │
 │        │                              ▼                 │
 │        │                          [Commit]              │
 │        │                              │                 │
 │        └──────────────┬────────────────┘                │
 │                       │                                  │
 │        ┌──────────────┴──────────────┐                  │
 │        │                             │                  │
 │        ▼                             ▼                  │
 │     [Next Task]               [All Complete?]          │
 │        │                             │                  │
 │        │                             ├─ Yes ─▶ SHIP    │
 │        │                             │                  │
 │        └─────────────────┬───────────┘                  │
 │                          │                              │
 │                          ▼                              │
 │                     [Back to PLAN]                      │
 │                          │                              │
 └──────────────────────────┘                              │
                                                            │
                            ┌───────────────────────────────┘
                            │
                            ▼
                         [END]
                       SUMMARY LOG
```

## State Transition Table

| From | To | Trigger | Action |
|------|-----|---------|--------|
| PLAN | WORK | Task identified | Launch agent |
| WORK | CHECKPOINT | Agent completes | Verify output |
| CHECKPOINT | COMMIT | User selects "Commit" | Create commit |
| CHECKPOINT | CONTINUE | User selects "Continue" | Next task |
| CHECKPOINT | FRESH | User selects "Fresh" | Save state |
| CHECKPOINT | STOP | User selects "Stop" | Generate summary |
| COMMIT | CONTINUE | Commit succeeds | Next task |
| CONTINUE | PLAN | Loop back | Increment counter |
| FRESH | [End] | State saved | User runs /clear |
| STOP | [End] | Summary generated | Session ends |
| [New Session] | PLAN | State file detected | Resume |

## Loop Completion Detection

After every checkpoint, check if workflow is complete:

```bash
# Count remaining work
pending=$(grep -c "^- \[ \]" .devloop/plan.md 2>/dev/null || echo "0")
in_progress=$(grep -c "^- \[~\]" .devloop/plan.md 2>/dev/null || echo "0")

if [ "$pending" -eq 0 ] && [ "$in_progress" -eq 0 ]; then
  # All tasks complete!
  # → COMPLETE state
fi
```

When all tasks are complete:

```yaml
AskUserQuestion:
  question: "🎉 All plan tasks complete! What would you like to do?"
  header: "Complete"
  options:
    - label: "Ship it"
      description: "Run /devloop:ship for final validation"
    - label: "Add more tasks"
      description: "Extend the plan with additional work"
    - label: "Review"
      description: "Review all completed work"
    - label: "End session"
      description: "Generate summary and finish"
```

**Auto-updates**:
1. Change plan Status from "In Progress" to "Review"
2. Add Progress Log: "All tasks complete"
3. Update **Updated** timestamp
