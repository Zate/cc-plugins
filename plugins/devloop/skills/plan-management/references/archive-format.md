# Plan Archival Format and Procedures

Complete guide to archiving completed phases in devloop plans.

## When to Archive

**DO archive when:**
- Plan file exceeds 200 lines
- 2+ phases are 100% complete (all tasks `[x]`)
- `/devloop:continue` feels slow due to plan size
- Team wants active plan focused on "what's next"

**DON'T archive when:**
- Plan < 100 lines (too small, no benefit)
- Active phases still in progress
- All phases complete (use `/devloop:ship` instead)

## Archive Format

Archived phases are saved to `.devloop/archive/{plan-name}_phase_{N}_{timestamp}.md`:

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

**Note**: This phase was archived to compress the active plan.
```

## Compressed Plan Structure

After archival, the active `.devloop/plan.md` is compressed to:

1. **Keep**:
   - Plan header with metadata
   - Overview, Architecture, Requirements sections
   - All non-archived phases (pending or in-progress)
   - Last 10 Progress Log entries
   - Notes and Success Criteria

2. **Remove**:
   - Archived phases (saved to archive files)
   - Older Progress Log entries (rotated to worklog)

3. **Update**:
   - Progress Log with archival note:
     ```markdown
     - {YYYY-MM-DD}: Archived Phase 1, Phase 2 to .devloop/archive/
     ```

## Archive-Worklog Integration

When archiving, Progress Log entries for completed phases are extracted and appended to `.devloop/worklog.md`:

```markdown
## {YYYY-MM-DD}

### {Plan Name} - Phase {N} Complete

**Tasks Completed**:
- Task N.1: {Description}
- Task N.2: {Description}

**Commits**: {List commit hashes from Progress Log}

**Archived Plan**: `.devloop/archive/{filename}.md`

---
```

## Archive Awareness

**Commands that handle archives:**
- `/devloop:continue` - Detects archived phases, displays "Archive Status" note
- `/devloop:archive` - Creates and manages archives

**Hooks that handle archives:**
- Pre-commit hook - Skips task count validation for archived plans

**Git tracking:**
- Archive files ARE git-tracked (team visibility)
- Compressed plan IS git-tracked
- Both committed together

## Restoration from Archive

To restore an archived phase:
1. Read archive file from `.devloop/archive/`
2. Copy phase section back into plan.md
3. Update Progress Log
4. Update Current Phase metadata

Archives are complete backups - no information is lost during archival.
