---
description: Manage the devloop worklog - view, sync, or reconstruct completed work history
argument-hint: Optional action (status, sync, reconstruct)
allowed-tools: ["Read", "Write", "Edit", "Grep", "Glob", "Bash", "AskUserQuestion", "Skill"]
---

# Worklog Management

View and manage the devloop worklog - the history of completed work with commit references.

**Invoke**: `Skill: worklog-management` for format details.

## Usage

```
/devloop:worklog              # Show worklog status
/devloop:worklog status       # Same as above
/devloop:worklog sync         # Sync worklog with plan
/devloop:worklog reconstruct  # Rebuild from git history
```

---

## Action: Status (Default)

**Goal**: Show current worklog state and any sync issues.

**Actions**:

1. Check if worklog exists:
   ```bash
   cat .devloop/worklog.md 2>/dev/null || echo "No worklog found"
   ```

2. If no worklog:
   ```
   Use AskUserQuestion:
   - question: "No worklog file found. Create one?"
   - header: "Worklog"
   - options:
     - Create empty (Initialize empty worklog)
     - Reconstruct (Build from git history)
     - Skip (Continue without worklog)
   ```

3. If worklog exists, display summary:
   ```markdown
   ## Worklog Status

   **Last Updated**: [timestamp]
   **Total Commits**: [count]
   **Total Tasks Completed**: [count]

   ### Recent Entries
   | Hash | Date | Message |
   |------|------|---------|
   | abc1234 | 2024-12-11 | feat: add user auth |
   | def5678 | 2024-12-12 | test: auth tests |
   ...

   ### Sync Status
   - Plan entries in worklog: [N] / [M]
   - [OK | WARNING: X entries may be missing]
   ```

---

## Action: Sync

**Goal**: Synchronize worklog with plan's Progress Log.

**Actions**:

1. Read both files:
   ```bash
   cat .devloop/plan.md
   cat .devloop/worklog.md
   ```

2. Find Progress Log entries with commit hashes not in worklog

3. For each missing entry:
   - Parse commit hash, date, task reference
   - Add to worklog commit table
   - Add task to "Tasks Completed" section

4. Update worklog's `Last Updated` timestamp

5. Report results:
   ```markdown
   ## Sync Complete

   **Added to worklog**:
   - Task 1.1 (abc1234)
   - Task 1.2 (def5678)

   **Already present**:
   - Task 2.1 (ghi9012)
   ```

---

## Action: Reconstruct

**Goal**: Rebuild worklog from git history for projects adopting devloop.

**Actions**:

1. Prompt for timeframe:
   ```
   Use AskUserQuestion:
   - question: "Reconstruct worklog from how far back?"
   - header: "History"
   - options:
     - Last 30 days (Recommended)
     - Last 90 days (Longer history)
     - All history (Complete git history)
     - Custom (Specify date)
   ```

2. Parse git history:
   ```bash
   # Get conventional commits
   git log --format="%h|%ad|%s" --date=format:"%Y-%m-%d %H:%M" \
       --since="30 days ago" | \
       grep -E '\|(feat|fix|docs|test|refactor|chore|perf|build|ci):' || true
   ```

3. Build worklog structure:
   ```markdown
   # Devloop Worklog

   **Project**: [project-name]
   **Last Updated**: [now]

   ---

   ## Historical Work (Reconstructed)

   **Note**: Reconstructed from git history on [date]
   **Period**: [start] to [end]

   ### Commits

   | Hash | Date | Message | Tasks |
   |------|------|---------|-------|
   | abc1234 | 2024-11-15 | feat: initial API setup | - |
   | def5678 | 2024-11-20 | fix: database connection | - |
   ...

   ### Notes
   - Task references were not available for historical commits
   - Future commits will include task links automatically
   ```

4. If existing worklog:
   ```
   Use AskUserQuestion:
   - question: "Worklog already exists. How to proceed?"
   - header: "Existing"
   - options:
     - Merge (Add historical section, keep existing)
     - Replace (Overwrite with reconstruction)
     - Cancel (Keep existing worklog)
   ```

5. Write worklog to `.devloop/worklog.md`

6. Report results:
   ```markdown
   ## Worklog Reconstructed

   **Period**: [date range]
   **Commits found**: [N]
   **File**: .devloop/worklog.md

   Run `/devloop:worklog status` to view.
   ```

---

## Model Usage

| Action | Model | Rationale |
|--------|-------|-----------|
| Status | haiku | Simple read/display |
| Sync | haiku | File comparison |
| Reconstruct | sonnet | Git parsing, structure creation |

---

## Integration

- Called by `/devloop:continue` when detecting worklog drift
- Can be called manually to maintain worklog
- Post-commit hook updates worklog automatically

---

## See Also

- `Skill: worklog-management` - Worklog format specification
- `Skill: file-locations` - Where worklog lives
- `/devloop:continue` - Resumes with sync checks
