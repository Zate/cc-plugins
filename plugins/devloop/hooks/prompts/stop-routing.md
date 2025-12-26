Before stopping, evaluate the current state and provide routing options:

## Step 1: Check for Devloop Plan

1. Check if `.devloop/plan.md` exists
2. If exists, parse for:
   - Pending tasks (lines with `- [ ]`)
   - In-progress tasks (lines with `- [~]`)
   - Completed tasks (lines with `- [x]`)
3. Determine completion state:
   - **All complete**: All tasks marked `[x]`, no pending/in-progress
   - **Pending work**: Has `[ ]` or `[~]` markers
   - **No plan**: File doesn't exist or no task markers found

## Step 2: Check for Uncommitted Changes

1. Check if there are staged or unstaged changes (git status)
2. If changes exist and plan has tasks:
   - Suggest auto-commit sequence: lint → test → commit
   - If lint/test fails, warn but don't block

## Step 3: Provide Routing Based on State

### If All Tasks Complete:
Respond with:
```json
{"decision": "complete", "message": "All tasks complete! Consider running /devloop:ship to validate and deploy.", "show_ship": true}
```

### If Pending Tasks Exist:
Respond with routing options:
```json
{
  "decision": "route",
  "pending_tasks": 5,
  "next_task": "Task 2.1: Implement feature X",
  "options": [
    {"label": "Continue next task", "action": "continue", "description": "Resume work immediately with /devloop:continue"},
    {"label": "Fresh start", "action": "fresh", "description": "Save state and prepare for /clear (hook-based resume)"},
    {"label": "Stop", "action": "stop", "description": "End session, resume manually later"}
  ],
  "uncommitted_changes": true|false
}
```

### If No Plan Exists:
Respond with:
```json
{"decision": "approve", "message": "No active plan detected. Session ending normally."}
```

## Edge Cases to Handle:

- **Plan file missing**: Skip routing, approve stop
- **Plan corrupted**: Log error in message, approve stop
- **Empty plan**: Treat as no plan
- **Only completed tasks**: Treat as all complete
- **next-action.json exists**: Note stale state file in message

## Output Format:

Always respond with valid JSON matching one of the three formats above. Be concise - this runs on every Stop event.
