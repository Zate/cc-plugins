# Continue.md Refactor Mapping

**Analysis Date**: 2025-12-26
**Current Size**: 1526 lines
**Target Size**: ~400 lines (reduction of ~1100 lines)

## Executive Summary

The continue.md command contains extensive content that duplicates or overlaps with existing devloop skills. This document maps each major section to its overlapping skill(s) and provides refactoring recommendations.

**Total Estimated Line Reduction**: ~1100 lines (72% reduction)

---

## Section-by-Section Analysis

### 1. Agent Routing Table (lines 18-40)

**Current Content**: Full routing table mapping task types to agents
**Size**: 23 lines

**Overlap**:
- None directly, this is command-specific reference

**Recommendation**: **KEEP**
- This table is essential for the continue command's agent selection logic
- No skill currently provides this mapping
- Consider creating a reference file if other commands need this

**Line Savings**: 0 lines

---

### 2. Fresh Start State Detection (lines 43-100)

**Current Content**: Complete logic for reading and parsing `.devloop/next-action.json`
**Size**: 58 lines

**Overlap**:
- `Skill: workflow-loop` - Context management section (lines 947-1258)
- Specifically lines 1192-1227 cover state persistence for fresh start

**Recommendation**: **REFERENCE SKILL**
- Replace with: "See `Skill: workflow-loop` section 'State Persistence for Fresh Start' for state file format and parsing logic"
- Keep minimal pseudocode showing integration point
- Skill already documents JSON schema and parsing patterns

**Refactored Size**: 10 lines
**Line Savings**: 48 lines

---

### 3. Plan File Search (lines 104-133)

**Current Content**: Discovery order for finding plan files
**Size**: 30 lines

**Overlap**:
- `Skill: plan-management` - "Plan File Location" section (lines 24-37)
- Exact duplicate of discovery order logic

**Recommendation**: **REFERENCE SKILL**
- Replace with: "See `Skill: plan-management` for plan file discovery order and priority"
- Keep only the archive awareness note (unique to continue command)

**Refactored Size**: 8 lines
**Line Savings**: 22 lines

---

### 4. Plan Parsing and Status Presentation (lines 136-198)

**Current Content**: Task marker detection, status counting, display format
**Size**: 63 lines

**Overlap**:
- `Skill: plan-management` - "Task Status Markers" section (lines 66-73)
- `Skill: plan-management` - "Parallelism Markers" section (lines 75-108)
- Partial overlap with plan format specification

**Recommendation**: **REFERENCE SKILL + KEEP FORMAT**
- Replace marker definitions with: "See `Skill: plan-management` for task marker definitions"
- Keep display format examples (lines 164-195) - these show command-specific output
- Archive status display is unique, keep it

**Refactored Size**: 25 lines
**Line Savings**: 38 lines

---

### 5. Task Classification (lines 200-222)

**Current Content**: Keyword mapping table for task type detection
**Size**: 23 lines

**Overlap**:
- Agent routing table (lines 18-40) provides similar mapping
- No direct skill overlap

**Recommendation**: **CONSOLIDATE**
- Merge with agent routing table to avoid duplication
- Create single source of truth for task type → agent mapping

**Refactored Size**: 5 lines (merged into agent routing)
**Line Savings**: 18 lines

---

### 6. Option Presentation (lines 224-261)

**Current Content**: AskUserQuestion templates for different task types
**Size**: 38 lines

**Overlap**:
- None - command-specific UI logic

**Recommendation**: **KEEP**
- This defines the command's user interaction pattern
- No skill overlap

**Line Savings**: 0 lines

---

### 7. Agent Execution Templates (lines 263-391)

**Current Content**: Task tool invocation templates for each agent type
**Size**: 129 lines

**Overlap**:
- Agent routing table already defines which agent for which task
- Templates are repetitive (same pattern repeated)

**Recommendation**: **CONSOLIDATE TO PATTERN**
- Replace 8 individual templates with single parameterized pattern
- Show one example, reference pattern for others
- Keep agent routing table as the authoritative source

**Refactored Size**: 25 lines
**Line Savings**: 104 lines

---

### 8. Post-Agent Checkpoint (lines 393-637)

**Current Content**: Complete checkpoint sequence including verification, plan updates, commit logic
**Size**: 245 lines

**Overlap**:
- `Skill: task-checkpoint` - Complete checkpoint workflow (entire skill)
- `Skill: workflow-loop` - Checkpoint phase (lines 119-132)
- Nearly 100% duplication of task-checkpoint skill content

**Recommendation**: **REFERENCE SKILL**
- Replace entire section with: "See `Skill: task-checkpoint` for complete checkpoint workflow"
- Keep only integration-specific notes (how continue.md invokes the skill)
- The skill already covers:
  - Verification checklist
  - Plan marker updates
  - Commit decision logic
  - Worklog sync
  - Error handling

**Refactored Size**: 15 lines
**Line Savings**: 230 lines (LARGEST SAVINGS)

---

### 9. Loop Completion Detection (lines 639-944)

**Current Content**: Task counting, completion states, all completion options
**Size**: 306 lines

**Overlap**:
- `Skill: workflow-loop` - State transitions section (lines 176-189)
- `Skill: plan-management` - Plan update rules (lines 136-165)
- Partial overlap with completion detection logic

**Recommendation**: **REFERENCE SKILL + KEEP COMMAND LOGIC**
- Replace task counting logic with reference to plan-management
- Replace state detection with reference to workflow-loop
- Keep completion option presentation (command-specific UI)
- Keep integration with /devloop:ship, /devloop:archive (unique to continue)

**Refactored Size**: 80 lines
**Line Savings**: 226 lines

---

### 10. Context Management (lines 946-1258)

**Current Content**: Session metrics, staleness thresholds, warning presentation
**Size**: 313 lines

**Overlap**:
- `Skill: workflow-loop` - "Context Management" section (lines 203-212)
- Almost complete duplication of workflow-loop content

**Recommendation**: **REFERENCE SKILL**
- Replace entire section with: "See `Skill: workflow-loop` section 'Context Management' for threshold detection and fresh start patterns"
- Keep only integration notes for how continue.md uses these thresholds

**Refactored Size**: 20 lines
**Line Savings**: 293 lines (SECOND LARGEST SAVINGS)

---

### 11. Parallel Task Handling (lines 1260-1288)

**Current Content**: Parallel task detection and execution
**Size**: 29 lines

**Overlap**:
- `Skill: plan-management` - "Parallelism Markers" section (lines 75-108)
- `Skill: plan-management` - "Smart Parallelism Guidelines" section (lines 112-253)

**Recommendation**: **REFERENCE SKILL**
- Replace with: "See `Skill: plan-management` for parallel task detection and execution patterns"
- Keep only the specific AskUserQuestion format for this command

**Refactored Size**: 12 lines
**Line Savings**: 17 lines

---

### 12. Plan Mode Integration (lines 1290-1299)

**Current Content**: EnterPlanMode usage instructions
**Size**: 10 lines

**Overlap**:
- `Skill: plan-management` - Plan creation guidance

**Recommendation**: **KEEP**
- Short and command-specific
- No significant overlap

**Line Savings**: 0 lines

---

### 13. Recovery Scenarios (lines 1301-1314)

**Current Content**: Table of recovery scenarios and actions
**Size**: 14 lines

**Overlap**:
- `Skill: workflow-loop` - "Error Recovery" section (lines 191-201)
- Partial overlap

**Recommendation**: **REFERENCE SKILL**
- Replace with: "See `Skill: workflow-loop` for error recovery patterns"
- Keep only continue-specific recovery scenarios (large plan, missing phase)

**Refactored Size**: 8 lines
**Line Savings**: 6 lines

---

### 14. Fresh Start Workflow (lines 1316-1502)

**Current Content**: Complete fresh start workflow documentation
**Size**: 187 lines

**Overlap**:
- `Skill: workflow-loop` - State persistence section (lines 1192-1227)
- Extensive duplication

**Recommendation**: **REFERENCE SKILL**
- Replace with: "See `Skill: workflow-loop` section 'State Persistence for Fresh Start' for complete workflow"
- Keep only integration notes showing how continue.md reads state file

**Refactored Size**: 20 lines
**Line Savings**: 167 lines

---

### 15. Model Usage Table (lines 1504-1513)

**Current Content**: Model selection for different steps
**Size**: 10 lines

**Overlap**:
- `Skill: phase-templates` - "Model Selection Reference" section (lines 123-138)
- Similar guidance

**Recommendation**: **REFERENCE SKILL**
- Replace with: "See `Skill: model-selection-guide` for model selection guidance"

**Refactored Size**: 3 lines
**Line Savings**: 7 lines

---

### 16. Tips Section (lines 1515-1526)

**Current Content**: User tips for using /devloop:continue
**Size**: 12 lines

**Overlap**:
- None - useful command-specific tips

**Recommendation**: **KEEP**
- Good user guidance, no duplication

**Line Savings**: 0 lines

---

## Summary Table

| Section | Current Lines | Overlap Skill(s) | Recommendation | New Lines | Savings |
|---------|---------------|------------------|----------------|-----------|---------|
| Agent Routing Table | 23 | None | Keep | 23 | 0 |
| Fresh Start State | 58 | workflow-loop | Reference | 10 | 48 |
| Plan File Search | 30 | plan-management | Reference | 8 | 22 |
| Plan Parsing | 63 | plan-management | Reference + Keep Format | 25 | 38 |
| Task Classification | 23 | None | Consolidate | 5 | 18 |
| Option Presentation | 38 | None | Keep | 38 | 0 |
| Agent Execution | 129 | None | Consolidate Pattern | 25 | 104 |
| **Post-Agent Checkpoint** | **245** | **task-checkpoint** | **Reference** | **15** | **230** |
| **Loop Completion** | 306 | workflow-loop, plan-management | Reference + Keep Logic | 80 | 226 |
| **Context Management** | **313** | **workflow-loop** | **Reference** | **20** | **293** |
| Parallel Tasks | 29 | plan-management | Reference | 12 | 17 |
| Plan Mode | 10 | None | Keep | 10 | 0 |
| Recovery Scenarios | 14 | workflow-loop | Reference | 8 | 6 |
| Fresh Start Workflow | 187 | workflow-loop | Reference | 20 | 167 |
| Model Usage | 10 | phase-templates | Reference | 3 | 7 |
| Tips | 12 | None | Keep | 12 | 0 |
| **TOTAL** | **1490** | | | **314** | **1176** |

---

## Top Reduction Opportunities

1. **Context Management** (lines 946-1258): 293 lines saved
   - 100% duplicate of `Skill: workflow-loop`
   - Reference skill for all threshold detection, warning presentation, and fresh start logic

2. **Post-Agent Checkpoint** (lines 393-637): 230 lines saved
   - 100% duplicate of `Skill: task-checkpoint`
   - Reference skill for complete checkpoint workflow

3. **Loop Completion Detection** (lines 639-944): 226 lines saved
   - Major overlap with `workflow-loop` and `plan-management`
   - Keep command-specific UI, reference skills for logic

4. **Fresh Start Workflow** (lines 1316-1502): 167 lines saved
   - Duplicate of `workflow-loop` state persistence section
   - Reference skill for workflow documentation

5. **Agent Execution Templates** (lines 263-391): 104 lines saved
   - Consolidate to single parameterized pattern
   - Reduce repetition across agent types

---

## Refactoring Strategy

### Phase 1: High-Impact References (Priority 1)
Replace the largest duplicate sections first:
1. Context Management → `Skill: workflow-loop`
2. Post-Agent Checkpoint → `Skill: task-checkpoint`
3. Loop Completion Detection → `Skill: workflow-loop` + `Skill: plan-management`

**Phase 1 Savings**: 749 lines

### Phase 2: Medium-Impact Consolidation (Priority 2)
Consolidate repetitive patterns:
1. Fresh Start Workflow → `Skill: workflow-loop`
2. Agent Execution Templates → Single pattern
3. Plan Parsing → `Skill: plan-management`

**Phase 2 Savings**: 309 lines

### Phase 3: Low-Impact References (Priority 3)
Clean up smaller duplications:
1. Fresh Start State Detection → `Skill: workflow-loop`
2. Plan File Search → `Skill: plan-management`
3. Parallel Tasks → `Skill: plan-management`
4. Task Classification → Consolidate with routing table
5. Recovery Scenarios → `Skill: workflow-loop`
6. Model Usage → `Skill: model-selection-guide`

**Phase 3 Savings**: 118 lines

---

## Recommended Structure After Refactoring

```markdown
# Continue from Plan (New Structure)

## Overview
[Brief description - 10 lines]

## References
- `Skill: workflow-loop` - Standard loop patterns, context management
- `Skill: task-checkpoint` - Task completion verification
- `Skill: plan-management` - Plan file format and updates
- `Skill: phase-templates` - Phase execution templates

## Agent Routing Table
[Keep as-is - 23 lines]

## Step 1: Find and Read Plan
### 1a: Check Fresh Start State
[Minimal integration notes - 10 lines]
**Details**: See `Skill: workflow-loop` "State Persistence for Fresh Start"

### 1b: Search for Plan File
[Integration notes - 8 lines]
**Details**: See `Skill: plan-management` "Plan File Location"

## Step 2: Parse and Present Status
[Display format examples - 25 lines]
**Parsing details**: See `Skill: plan-management` "Task Status Markers"

## Step 3: Classify and Present Options
[Combined classification and options - 40 lines]

## Step 4: Execute with Agent
[Single parameterized pattern + one example - 25 lines]

## Step 5: Checkpoint and Continue Loop
### 5a: Post-Agent Checkpoint
[Integration notes - 15 lines]
**Complete workflow**: See `Skill: task-checkpoint`

### 5b: Loop Completion Detection
[Command-specific UI and integration - 80 lines]
**Detection logic**: See `Skill: workflow-loop` and `Skill: plan-management`

### 5c: Context Management
[Integration notes - 20 lines]
**Threshold detection**: See `Skill: workflow-loop` "Context Management"

## Step 6: Handle Parallel Tasks
[AskUserQuestion format - 12 lines]
**Parallel patterns**: See `Skill: plan-management` "Smart Parallelism Guidelines"

## Step 7: Plan Mode Integration
[Keep as-is - 10 lines]

## Step 8: Recovery Scenarios
[Continue-specific scenarios - 8 lines]
**Recovery patterns**: See `Skill: workflow-loop` "Error Recovery"

## Tips
[Keep as-is - 12 lines]

**Total**: ~314 lines
```

---

## Next Steps

1. **Review this mapping** with the team
2. **Prioritize phases** based on effort vs. impact
3. **Create refactored continue.md** following the recommended structure
4. **Test functionality** to ensure skill references work correctly
5. **Update CHANGELOG** to note the refactoring

---

## Notes

- This analysis assumes skills are stable and won't change frequently
- If skills evolve, continue.md references will automatically stay current
- Command-specific logic (UI, integration) is preserved
- Total reduction: **1176 lines (78.9% reduction)**
- Target achieved: **314 lines (well under 400 line target)**
