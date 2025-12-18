# Devloop Workflow for Generic AI Agents

**Version**: 1.0.0
**Compatibility**: Claude, Cursor, Aider, Gemini, and other AI coding agents
**Purpose**: A structured, token-conscious feature development workflow

---

## Quick Start

This guide enables any AI coding agent to follow the devloop methodology without requiring Claude Code or the devloop plugin.

### What You Need
- Access to the codebase
- Ability to read/write files
- Bash command execution capability

### Entry Points by Task Type

```xml
<devloop-entry-points>
  <quick-task>See: #quick-workflow</quick-task>
  <spike>See: #spike-workflow</spike>
  <full-feature>See: #full-workflow</full-feature>
  <continue-work>See: #continue-workflow</continue-work>
  <code-review>See: #review-workflow</review-workflow>
</devloop-entry-points>
```

---

## Core Principles

All devloop workflows follow these principles:

1. **Ask clarifying questions** - Identify ambiguities before coding
2. **Understand before acting** - Read existing code patterns first
3. **Simple and elegant** - Prioritize readable, maintainable code
4. **Track progress** - Maintain a visible todo list
5. **Plan first, implement second** - Create `.claude/devloop-plan.md` before writing code

---

## Plan File Format

**CRITICAL**: All devloop work MUST create and maintain a plan file.

**Location**: `.claude/devloop-plan.md`

```xml
<lazy-load section="plan-format">
```

<details>
<summary>📄 Click to expand: Complete Plan Format</summary>

```markdown
# Devloop Plan: [Feature Name]

**Created**: [YYYY-MM-DD]
**Updated**: [YYYY-MM-DD HH:MM]
**Status**: [Planning | In Progress | Review | Complete]
**Current Phase**: [Phase name]

## Overview
[2-3 sentence description of the feature]

## Requirements
[Key requirements or link to requirements doc]

## Architecture
[Chosen approach summary]

## Tasks

### Phase 1: [Phase Name]
**Parallelizable**: full | partial | none

- [ ] Task 1.1: [Description]
  - Acceptance: [Criteria]
  - Files: [Expected files to create/modify]
  - Testing: [Test requirements]

- [ ] Task 1.2: [Description] [parallel:A]
  - Acceptance: [Criteria]
  - Files: [Expected files]

### Phase 2: [Phase Name]
- [ ] Task 2.1: [Description]
...

## Progress Log
- [YYYY-MM-DD HH:MM]: [Event description]
```

### Task Status Markers

| Marker | Meaning |
|--------|---------|
| `- [ ]` | Pending / Not started |
| `- [x]` | Completed |
| `- [~]` | In progress |
| `- [-]` | Skipped |
| `- [!]` | Blocked |

### Parallelism Markers

| Marker | Meaning | Example |
|--------|---------|---------|
| `[parallel:X]` | Can run with other tasks in group X | `[parallel:A]` |
| `[depends:N.M,...]` | Must wait for listed tasks | `[depends:1.1,1.2]` |
| `[background]` | Low priority, can defer | |
| `[sequential]` | Must run alone | |

</details>

```xml
</lazy-load>
```

---

## Full Workflow {#full-workflow}

Use this for new features or complex changes.

```xml
<lazy-load section="full-workflow-phases">
```

<details>
<summary>🔄 Click to expand: 12-Phase Workflow</summary>

### Phase 0: Triage

**Goal**: Classify the task and determine optimal workflow

**Actions**:
1. Analyze the request
2. Determine workflow path:
   - Simple/clear fix → Use Quick Workflow
   - Unknown feasibility → Use Spike Workflow
   - Code review → Use Review Workflow
   - New feature → Continue below

### Phase 1: Discovery

**Goal**: Understand what needs to be built

**Actions**:
1. Create initial todo list with all phases
2. Gather requirements:
   - User stories with acceptance criteria
   - Scope boundaries (in/out)
   - Edge cases and error scenarios
   - Non-functional requirements
3. Ask clarifying questions using structured format:
   ```
   Question: [Specific question]
   Options:
   - A: [Option description]
   - B: [Option description]
   - C: [Option description]
   ```
4. Confirm understanding before proceeding

### Phase 2: Complexity Assessment

**Goal**: Estimate effort and identify risks

**Actions**:
1. Analyze codebase impact
2. Score complexity factors (1-5 each):
   - Codebase familiarity
   - Architectural changes
   - Testing complexity
   - External dependencies
   - Risk level
3. Generate T-shirt size (XS/S/M/L/XL)
4. If L or XL, recommend spike first

### Phase 3: Exploration

**Goal**: Understand existing codebase patterns

**Actions**:
1. Search for similar features:
   ```bash
   # Find relevant files
   find . -name "*.{ext}" -type f | grep -E "pattern"
   ```
2. Read key implementation files
3. Map architecture layers
4. Document existing patterns to follow
5. Identify files to modify vs create

### Phase 4: Clarification

**Goal**: Resolve remaining unknowns

**Actions**:
1. Review findings from exploration
2. Ask targeted questions:
   - Which pattern should we follow?
   - Where should new code live?
   - What naming conventions?
3. Get explicit approval before architecture

### Phase 5: Architecture

**Goal**: Design the solution

**Actions**:
1. Design component architecture
2. Plan data flow
3. Identify integration points
4. Specify error handling approach
5. Document in plan file
6. Ask for approval on approach

### Phase 6: Task Planning

**Goal**: Break architecture into actionable tasks

**Actions**:
1. Create task breakdown in plan file
2. Mark parallelizable tasks with `[parallel:X]`
3. Add dependencies with `[depends:N.M]`
4. Include acceptance criteria for each
5. Save to `.claude/devloop-plan.md`

### Phase 7: Implementation

**Goal**: Write the code

**Actions**:
1. Work through tasks sequentially
2. Follow existing codebase patterns
3. Mark tasks `[~]` in progress, `[x]` when complete
4. Update plan file after each task
5. For parallel tasks, ask user preference

### Phase 8: Testing

**Goal**: Verify implementation works

**Actions**:
1. Generate tests following project patterns
2. Run test suite
3. Fix any failures
4. Ensure coverage meets project standards

### Phase 9: Code Review

**Goal**: Quality check before commit

**Actions**:
1. Review for:
   - Logic errors
   - Security vulnerabilities
   - Code quality issues
   - Convention adherence
2. Fix high-confidence issues
3. Document findings

### Phase 10: Definition of Done

**Goal**: Validate all criteria met

**Actions**:
1. Check DoD criteria:
   - [ ] All tests passing
   - [ ] Code reviewed
   - [ ] No security issues
   - [ ] Documentation updated
   - [ ] No TODOs or FIXMEs
2. Fix any gaps

### Phase 11: Git Integration

**Goal**: Commit changes

**Actions**:
1. Run `git status` to see changes
2. Run `git diff` to review changes
3. Stage relevant files
4. Create commit with message:
   ```bash
   git commit -m "$(cat <<'EOF'
   [type]: [concise description]

   [why this change was made]
   EOF
   )"
   ```
5. DO NOT push unless explicitly requested

### Phase 12: Summary

**Goal**: Document what was done

**Actions**:
1. Generate summary of changes
2. Update plan status to "Complete"
3. Add final progress log entry

</details>

```xml
</lazy-load>
```

---

## Quick Workflow {#quick-workflow}

Use this for small, well-defined tasks (< 3 files, < 30 minutes).

```xml
<lazy-load section="quick-workflow">
```

<details>
<summary>⚡ Click to expand: Quick Implementation Steps</summary>

### Prerequisites
- Task is clearly defined
- Scope is small (< 3 files)
- No architectural decisions needed
- Low risk

### Steps

1. **Understand the task**
   - Read the request carefully
   - Identify affected files
   - Check for existing patterns

2. **Create minimal plan**
   ```markdown
   # Quick Task: [Description]

   ## Changes
   - [ ] File1: [What to change]
   - [ ] File2: [What to change]

   ## Testing
   - [ ] Run [test command]
   ```

3. **Implement changes**
   - Make the changes
   - Follow existing patterns
   - Keep it simple

4. **Test**
   - Run relevant tests
   - Fix any issues

5. **Review**
   - Quick self-review for obvious issues
   - Check conventions

6. **Done**
   - Mark complete in todo list

### When NOT to Use Quick

- Multiple architectural approaches possible
- > 3 files affected
- Unclear requirements
- High risk or complexity
- User wants full process

In these cases, use Full Workflow instead.

</details>

```xml
</lazy-load>
```

---

## Spike Workflow {#spike-workflow}

Use this for technical exploration and proof of concepts.

```xml
<lazy-load section="spike-workflow">
```

<details>
<summary>🔬 Click to expand: Spike Investigation Process</summary>

### When to Use Spike

- New technology or pattern
- Uncertain feasibility
- Multiple approaches to evaluate
- Performance concerns
- Integration with unknown systems

### Spike Process

#### 1. Define Goals

Ask user:
```
Question: What should this spike answer?
Options:
- Feasibility: Can we do this?
- Approach: Which way is best?
- Performance: Is it fast enough?
- Integration: Does it work with X?
```

Set time box:
```
Question: Time budget for spike?
Options:
- 30 minutes: Quick exploration
- 1-2 hours: Moderate investigation
- Half day: Thorough analysis
```

#### 2. Research

- Search codebase for related patterns
- Read documentation (if needed)
- Identify existing implementations

#### 3. Prototype

- Create throwaway code in `spike/` or `experiments/`
- Don't worry about production quality
- Focus on answering spike questions
- Test the approach

#### 4. Evaluate

- Assess complexity (XS/S/M/L/XL)
- Identify risks
- Compare approaches if multiple
- Form recommendation

#### 5. Report

Create spike report at `.claude/[topic]-spike-report.md`:

```markdown
## Spike Report: [Topic]

### Questions Investigated
1. [Question] → [Answer]
2. [Question] → [Answer]

### Findings

#### Feasibility
[Can we do this? Yes/No/Partial]

#### Recommended Approach
[Which approach and why]

#### Complexity Estimate
- Size: [XS/S/M/L/XL]
- Risk: [Low/Medium/High]
- Confidence: [High/Medium/Low]

#### Key Discoveries
1. [Finding]
2. [Finding]

#### Risks & Concerns
1. [Risk with mitigation]
2. [Risk with mitigation]

### Recommendation
[Should we proceed? With what approach?]

### Plan Updates Required
**Relationship**: [New work | Informs Task X.Y | Independent]

#### Recommended Changes
- [ ] [Specific plan changes needed]

### Next Steps
1. [What to do if proceeding]
2. [What to do if not proceeding]
```

Ask user:
```
Question: Based on spike findings, how to proceed?
Options:
- Proceed: Start full implementation
- More exploration: Continue spike
- Defer: Save findings for later
- Abandon: Not viable
```

</details>

```xml
</lazy-load>
```

---

## Continue Workflow {#continue-workflow}

Use this to resume work from an existing plan.

```xml
<lazy-load section="continue-workflow">
```

<details>
<summary>▶️ Click to expand: Resume Implementation Process</summary>

### Find the Plan

Check these locations in order:
1. `.claude/devloop-plan.md` ← Primary
2. `docs/PLAN.md`, `docs/plan.md`
3. `PLAN.md`, `plan.md`

If no plan found, ask user for location or start new.

### Parse Current State

Read plan and identify:
- Overall goal and architecture
- Completed tasks (marked `[x]`)
- Current task (marked `[~]` or first `[ ]`)
- Remaining tasks (marked `[ ]`)
- Any blockers (marked `[!]`)

### Check for Parallel Tasks

Look for pending tasks with same `[parallel:X]` marker.

If found, ask user:
```
Question: Found parallel tasks [list]. How to proceed?
Options:
- Sequential: Do one at a time (safer, slower)
- Parallel: If you can spawn multiple instances
- Current only: Just do the current task
```

### Implement Next Task

1. Mark task as `[~]` in progress
2. Read files mentioned in task
3. Implement the changes
4. Test the changes
5. Mark task as `[x]` complete
6. Update progress log
7. Save plan file

### Continue or Stop

After completing task, ask:
```
Question: Task [X] complete. What next?
Options:
- Next task: Continue to next task
- Review progress: Show what's done
- Pause: Stop here for now
```

</details>

```xml
</lazy-load>
```

---

## Review Workflow {#review-workflow}

Use this for code review before commits or PRs.

```xml
<lazy-load section="review-workflow">
```

<details>
<summary>🔍 Click to expand: Code Review Process</summary>

### Review Scope

Determine what to review:
1. Uncommitted changes: `git diff`
2. Staged changes: `git diff --staged`
3. Branch changes: `git diff main...HEAD`
4. Specific files: User-specified paths

### Review Categories

Review code for:

#### 1. Logic Errors
- Incorrect algorithms
- Off-by-one errors
- Race conditions
- Edge case handling
- Error handling gaps

#### 2. Security Issues
- SQL injection
- XSS vulnerabilities
- Command injection
- Path traversal
- Hardcoded secrets
- OWASP Top 10

#### 3. Code Quality
- Naming conventions
- Code duplication
- Complex functions
- Magic numbers
- Commented code
- TODO/FIXME items

#### 4. Project Conventions
- Style guide adherence
- Pattern consistency
- Import organization
- Test coverage

### Review Output Format

```markdown
## Code Review: [Scope]

### Summary
[Overall assessment]

### Issues Found: [count]

#### 🔴 Critical (must fix)
- [File:Line] [Issue description]
  - Impact: [Why this matters]
  - Fix: [How to fix]

#### 🟡 Warning (should fix)
- [File:Line] [Issue description]
  - Suggestion: [Improvement]

#### 🔵 Info (consider)
- [File:Line] [Issue description]
  - Note: [Observation]

### Files Reviewed
- [file1] - [summary]
- [file2] - [summary]

### Recommendations
1. [Action item]
2. [Action item]
```

### After Review

Ask user:
```
Question: Review complete. What next?
Options:
- Fix issues: Let's address the findings
- Commit anyway: Issues acceptable for now
- More review: Focus on specific area
```

</details>

```xml
</lazy-load>
```

---

## Best Practices for Generic Agents

### Context Management

1. **Read before editing**: Always read files before modifying
2. **Incremental loading**: Load only needed sections
3. **Use search efficiently**: `grep`, `find`, `git grep`
4. **Cache insights**: Document findings as you go

### Task Management

1. **Create todo lists**: Track progress visibly
2. **Update frequently**: Mark completion after each task
3. **One task at a time**: Unless explicitly parallel
4. **Show progress**: Update user regularly

### Plan Updates

MUST update `.claude/devloop-plan.md`:
- After completing each task
- When blocking issues arise
- When scope changes
- When adding discovered work

Format:
```markdown
- [x] Task N.M: [Description]

## Progress Log
- [YYYY-MM-DD HH:MM]: Completed Task N.M - [brief note]
```

### Quality Standards

1. **Follow existing patterns**: Read similar code first
2. **Simple solutions**: Avoid over-engineering
3. **Test coverage**: Match project standards
4. **Security conscious**: Validate inputs, avoid injection
5. **Error handling**: At boundaries only, not internally

### Communication

1. **Ask questions early**: Don't guess on ambiguity
2. **Structured questions**: Provide clear options
3. **Confirm understanding**: Before major changes
4. **Show your work**: Explain reasoning

---

## Integration with Existing Tools

### Cursor

Add to `.cursorrules`:
```
When working on features, follow the devloop methodology:
1. Check for existing plan at .claude/devloop-plan.md
2. If no plan, create one before coding
3. Use plan format from devloop guide
4. Update plan after each task
```

### Aider

Add to `.aider.conf.yml`:
```yaml
# Follow devloop methodology
# See: /path/to/DEVLOOP_GUIDE.md
```

### Other Agents

1. Load this guide into context
2. Reference specific sections using `#section-id`
3. Follow plan format consistently
4. Use XML `<lazy-load>` sections to control context

---

## Reference Tables

### Command Quick Reference

| Task Type | Workflow | Section |
|-----------|----------|---------|
| New feature | Full | #full-workflow |
| Small fix | Quick | #quick-workflow |
| Exploration | Spike | #spike-workflow |
| Resume work | Continue | #continue-workflow |
| Code review | Review | #review-workflow |

### Model Selection Guide

| Task | Model Size | Reasoning |
|------|-----------|-----------|
| Scoping | Small | Simple classification |
| Requirements | Medium | Needs understanding |
| Exploration | Medium | Balanced capability |
| Architecture | Large | Complex decisions |
| Implementation | Medium | Most coding tasks |
| Testing | Small | Formulaic patterns |
| Review | Large | Catch subtle bugs |
| Git operations | Small | Structured output |

### File Locations

| Purpose | Primary Location | Fallbacks |
|---------|------------------|-----------|
| Plan file | `.claude/devloop-plan.md` | `docs/PLAN.md`, `PLAN.md` |
| Spike reports | `.claude/[topic]-spike-report.md` | Same dir |
| Project context | `.claude/project-context.json` | Root |
| Bug tracking | `.claude/bugs/*.md` | Same dir |

---

## Troubleshooting

### No Plan Found
1. Check `.claude/devloop-plan.md`
2. Search with: `find . -name "*plan*.md" -o -name "PLAN.md"`
3. Ask user for plan location
4. Create new plan if starting fresh

### Plan Out of Sync
1. Read current plan
2. Review git status
3. Update plan with actual state
4. Mark completed tasks `[x]`
5. Update progress log

### Unclear Requirements
1. Don't guess - ask questions
2. Use structured question format
3. Provide clear options
4. Wait for answers before proceeding

### Too Complex
1. Suggest spike first
2. Break into smaller phases
3. Mark tasks as `[parallel:X]` where possible
4. Focus on MVP first

---

## Version History

- **1.0.0** (2025-12-17): Initial release
  - Full workflow documentation
  - Quick/Spike/Continue/Review workflows
  - Plan management guidelines
  - Generic agent integration

---

## Additional Resources

For Claude Code users with the devloop plugin:
- Use `/devloop` for guided workflow
- Use `/devloop:quick` for fast tasks
- Use `/devloop:spike` for exploration
- Use `/devloop:continue` to resume

This guide provides the same methodology without plugin requirements.
