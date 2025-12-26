---
description: Archive completed phases from plan.md to compress active plan and rotate Progress Log to worklog
argument-hint: Optional phase numbers to archive (e.g., "1 2" to archive Phase 1 and 2)
allowed-tools: ["Read", "Write", "Edit", "Grep", "Glob", "Bash", "AskUserQuestion", "TodoWrite", "Skill"]
---

# Archive Plan

Archive completed phases from `.devloop/plan.md` to reduce file size and improve `/devloop:continue` performance. Moves completed phases to `.devloop/archive/` and extracts Progress Log entries to `worklog.md`.

**Benefits**:
- Reduces active plan size by ~50% for large plans (200+ lines)
- Faster `/devloop:continue` startup
- Clearer focus on active/pending tasks
- Preserves complete historical context in archive files

**Reference**:
- `Skill: plan-management` - Plan format specification
- `Skill: worklog-management` - Worklog integration
- `scripts/archive-phase.sh` - Phase extraction and archival script

---

## When to Use

- Plan exceeds 200 lines
- 2+ phases are 100% complete (all tasks `[x]`)
- `/devloop:continue` feels slow
- You want to focus active plan on "what's next"

---

## Workflow

### Step 1: Find and Read Plan

**Validation**: Before archiving, optionally validate plan format:
```bash
./plugins/devloop/scripts/validate-plan.sh .devloop/plan.md
```

**Actions**:
1. Look for plan in standard locations:
   - `.devloop/plan.md` (primary)
   - `docs/PLAN.md`, `docs/plan.md`
   - `PLAN.md`, `plan.md`

2. If no plan found:
   ```
   Error: No plan file found. Nothing to archive.
   Suggestion: Use /devloop to create a plan first.
   ```

3. Read plan file completely

---

### Step 2: Detect Completed Phases

**Goal**: Identify phases where ALL tasks are marked `[x]`

**Actions**:
1. Use Bash to detect phase boundaries and completion status:
   ```bash
   # Extract phase headers and task counts
   awk '/^### Phase/ {
     phase = $0
     complete = 0
     pending = 0
   }
   /^\s*- \[x\]/ || /^\s*- \[X\]/ {
     if (phase != "") complete++
   }
   /^\s*- \[ \]/ {
     if (phase != "") pending++
   }
   /^### Phase/ && NR > 1 {
     if (phase != "" && pending == 0 && complete > 0) {
       print phase " → COMPLETE (" complete " tasks)"
     } else if (phase != "") {
       print phase " → IN PROGRESS (" complete "/" (complete+pending) " complete)"
     }
   }
   END {
     if (phase != "" && pending == 0 && complete > 0) {
       print phase " → COMPLETE (" complete " tasks)"
     } else if (phase != "") {
       print phase " → IN PROGRESS (" complete "/" (complete+pending) " complete)"
     }
   }' .devloop/plan.md
   ```

2. Parse output to identify completed phases

3. If no completed phases:
   ```
   No completed phases found. All phases have pending tasks.
   Nothing to archive.
   ```

4. Present findings:
   ```markdown
   ## Archival Analysis

   **Plan**: {Plan name}
   **Total Phases**: {count}
   **Completed Phases**: {count}

   ### Completed Phases (Ready to Archive)
   - Phase 1: {Name} ({X} tasks)
   - Phase 2: {Name} ({Y} tasks)

   ### Active/Pending Phases (Keep in Plan)
   - Phase 3: {Name} ({A}/{B} complete)
   - Phase 4: {Name} (0/{C} complete)
   ```

---

### Step 3: Confirm Archival

**Actions**:
1. Use AskUserQuestion to confirm which phases to archive:
   ```
   AskUserQuestion:
   - question: "Archive completed phases to .devloop/archive/?"
   - header: "Confirm"
   - multiSelect: true
   - options:
     - Phase 1: {Name} ({X} tasks)
     - Phase 2: {Name} ({Y} tasks)
     - ...
   ```

2. If user provides specific phases via arguments, use those instead
3. If user cancels, exit without archiving

---

### Step 4: Create Archive Directory

**Actions**:
1. Create `.devloop/archive/` if it doesn't exist:
   ```bash
   mkdir -p .devloop/archive
   ```

2. Verify directory is created

---

### Step 5: Extract and Archive Each Phase

**For each selected phase**:

#### 5a. Extract Phase Content

Use Bash to extract the complete phase section:
```bash
# Extract Phase N (from header to next phase or section)
awk '/^### Phase N:/{flag=1} /^### Phase [0-9]+:/ && !/^### Phase N:/{flag=0} flag' .devloop/plan.md
```

#### 5b. Extract Related Progress Log Entries

Search Progress Log for entries mentioning this phase:
```bash
# Extract Progress Log entries for Phase N
awk '/^## Progress Log$/,/^## / {
  if (/Phase N/ || /Task N\./) print
}' .devloop/plan.md
```

#### 5c. Create Archive File

**Archive filename**: `.devloop/archive/{plan_name}_phase_{N}_{timestamp}.md`

**Archive file format**:
```markdown
# Archived Plan: {Plan Name} - Phase {N}

**Archived**: {YYYY-MM-DD}
**Original Plan**: {Plan name}
**Phase Status**: Complete
**Tasks**: {X}/{X} complete

---

{Complete phase section from plan}

---

## Progress Log (Phase {N})

{Progress log entries for this phase}

---

**Note**: This phase was archived to compress the active plan. The active plan focuses on current and upcoming work.
```

Write archive file using Write tool.

#### 5d. Append to Worklog

**Worklog format**: `.devloop/worklog.md`

Extract commit information from Progress Log entries and append to worklog:

```markdown
## {YYYY-MM-DD}

### {Plan Name} - Phase {N} Complete

{Brief description of what Phase N accomplished}

**Tasks Completed**:
- Task N.1: {Description}
- Task N.2: {Description}
- ...

**Commits**: {List commit hashes from Progress Log if available}

**Archived Plan**: `.devloop/archive/{plan_name}_phase_{N}_{timestamp}.md`

---
```

Use Edit tool to append to worklog (or Write if worklog doesn't exist yet).

---

### Step 6: Compress Active Plan

**Goal**: Remove archived phases, keep only active/pending work

**Actions**:

1. **Read current plan** to identify sections

2. **Sections to keep**:
   - Plan header with metadata
   - Overview section
   - Architecture section (if present)
   - Requirements section (if present)
   - All non-archived phases (pending or in-progress)
   - Last 10 Progress Log entries
   - Notes section (if present)
   - Success Criteria (if present)

3. **Sections to remove**:
   - Archived phases (already saved to archive files)
   - Older Progress Log entries (already in worklog)

4. **Implementation**:
   Use Bash to reconstruct compressed plan:
   ```bash
   # Pseudocode for plan compression
   # 1. Extract header (until ## Overview or ## Requirements or first ### Phase)
   # 2. Extract Overview/Architecture/Requirements sections
   # 3. Skip archived phases
   # 4. Keep non-archived phases
   # 5. Extract last 10 Progress Log entries
   # 6. Extract Notes/Success Criteria
   ```

5. **Write compressed plan**:
   - Use Write tool to replace `.devloop/plan.md` with compressed version
   - Add note to Progress Log:
     ```
     - {YYYY-MM-DD}: Archived Phase {N}, Phase {M} to .devloop/archive/
     ```

6. **Update plan metadata**:
   - Update "**Updated**" timestamp
   - Update "**Current Phase**" if changed
   - Increment archived phase counter if tracking

---

### Step 7: Verify and Report

**Actions**:

1. **Check compressed plan**:
   - Count lines before vs after
   - Verify phase structure intact
   - Ensure no data loss

2. **Verify archive files created**:
   ```bash
   ls -lh .devloop/archive/*.md
   ```

3. **Verify worklog updated**:
   ```bash
   tail -n 20 .devloop/worklog.md
   ```

4. **Report results**:
   ```markdown
   ## Archival Complete ✅

   **Plan Compressed**: {original_lines} → {new_lines} lines ({percentage}% reduction)

   **Archived**:
   - Phase 1: {Name} → `.devloop/archive/{filename1}.md`
   - Phase 2: {Name} → `.devloop/archive/{filename2}.md`

   **Worklog Updated**: {entry_count} new entries in `.devloop/worklog.md`

   **Active Plan Now Contains**:
   - {N} active/pending phases
   - {X} pending tasks
   - Last 10 Progress Log entries

   **Next Steps**:
   - Run `/devloop:continue` to resume work (now faster!)
   - Review archived phases in `.devloop/archive/` if needed
   - Commit changes: `git add .devloop/ && git commit -m "chore: archive completed phases"`
   ```

---

## Edge Cases

| Scenario | Detection | Action |
|----------|-----------|--------|
| No completed phases | All phases have `[ ]` tasks | Exit with message, nothing to archive |
| All phases complete | All tasks `[x]` | Archive all but keep plan structure |
| No Progress Log | `## Progress Log` not found | Skip worklog update, note in report |
| Archive conflicts | File already exists | Append timestamp with seconds |
| Plan too small | < 100 lines | Warn: "Plan is small, archival may not be needed" |

---

## Model Usage

| Step | Model | Rationale |
|------|-------|-----------|
| Detect phases | haiku | Simple bash script |
| Extract content | haiku | Text processing |
| Create archives | haiku | Formulaic writing |
| Compress plan | haiku | Mechanical restructuring |
| Verify | haiku | Validation checks |

---

## Tips

- **When to archive**: Plan > 200 lines OR 2+ completed phases
- **Archive frequently**: Don't let plan grow to 500+ lines
- **Git tracking**: Archive files ARE git-tracked (team visibility)
- **Spike reports**: NOT archived (in `.devloop/spikes/`, separate lifecycle)
- **Restoration**: If needed, copy archived phase back to plan.md manually
- **Continue workflow**: No changes needed, `/devloop:continue` works with compressed plans

---

## Safety

- **Original plan preserved**: Archives contain complete phase history
- **Worklog updated**: No commit history lost
- **Backward compatible**: All agents work with compressed plans
- **No data loss**: Everything saved somewhere (archive or worklog)
- **Reversible**: Can always restore from archive if needed
