---
description: Complete validation and git integration for shipping a feature
argument-hint: Optional commit message or PR title
allowed-tools: ["Read", "Write", "Edit", "Grep", "Glob", "Bash", "Task", "AskUserQuestion", "TodoWrite", "Skill"]
---

# Ship Feature

End-to-end workflow for validating a feature is complete and integrating it into version control.

**IMPORTANT**: Always invoke `Skill: plan-management` to understand plan format and update procedures.

## Agent Routing

This command routes to devloop agents at key validation points:

| Phase | Agent | Mode/Focus |
|-------|-------|------------|
| DoD Validation | `devloop:task-planner` | DoD validator mode |
| Test Analysis | `devloop:qa-engineer` | Runner mode (on failure) |
| Git Operations | `devloop:engineer` | Git mode |

## Plan Integration

Before shipping, check if a devloop plan exists at `.devloop/plan.md`:
1. Read the plan to verify all tasks are marked complete
2. If incomplete tasks exist, warn the user before proceeding
3. After successful ship, update the plan Status to "Complete"
4. Add a Progress Log entry recording the ship event

## When to Use

- After implementation is complete
- Ready to commit changes
- Ready to create a pull request
- Need pre-merge validation

## Prerequisites

This command assumes:
- Implementation is complete
- You have uncommitted or staged changes
- You want to commit/PR these changes
- All plan tasks are complete (if plan exists)

## Workflow

### Phase 1: Pre-flight Check

**Goal**: Assess readiness for shipping

**Actions**:
1. Check current git state:
   ```bash
   git status
   git diff --stat
   ```

2. Create todo list for ship process

3. Quick assessment:
   ```
   Use AskUserQuestion:
   - question: "What would you like to do?"
   - header: "Ship Mode"
   - options:
     - Full validation (DoD check, tests, then commit/PR)
     - Quick commit (Skip validation, just commit)
     - PR only (Changes already committed, create PR)
   ```

### Phase 2: Definition of Done Validation

**Goal**: Verify all completion criteria are met

**Skip if**: User chose "Quick commit" or "PR only"

**Actions**:
1. Launch `devloop:task-planner` agent in DoD validator mode (model: haiku):
   - Check code criteria (no TODOs, no debug statements)
   - Check test criteria (tests exist and pass)
   - Check quality criteria (review done, no critical issues)
   - Check documentation criteria (docs updated)
   - Check integration criteria (committable state)

2. Review validation results

3. If validation fails:
   ```
   Use AskUserQuestion:
   - question: "DoD validation found issues. How to proceed?"
   - header: "DoD Status"
   - options:
     - Fix blockers (Address failing criteria first)
     - Override (Proceed with documented exceptions)
     - Cancel (Stop shipping process)
   ```

4. If override selected, document the exceptions

### Phase 3: Test Verification

**Goal**: Ensure all tests pass

**Skip if**: User chose "Quick commit"

**Actions**:
1. Run test suite:
   ```bash
   # Detect and run appropriate test command
   npm test 2>&1 || go test ./... 2>&1 || pytest 2>&1
   ```

2. If tests fail:
   - Launch `devloop:qa-engineer` agent in runner mode to analyze failures
   - Present failure analysis
   - Ask how to proceed:
     ```
     Use AskUserQuestion:
     - question: "Tests are failing. How to proceed?"
     - header: "Tests"
     - options:
       - Fix tests (Address test failures)
       - Skip tests (Proceed anyway - not recommended)
       - Cancel (Stop shipping process)
     ```

### Phase 4: Build Verification

**Goal**: Ensure project builds successfully

**Skip if**: User chose "Quick commit"

**Actions**:
1. Run build:
   ```bash
   # Detect and run appropriate build command
   npm run build 2>&1 || go build ./... 2>&1 || mvn compile 2>&1
   ```

2. If build fails, stop and report errors

### Phase 5: Git Integration

**Goal**: Create commit and/or PR

**Actions**:
1. Determine git operation:
   ```
   Use AskUserQuestion:
   - question: "Git integration - what would you like to create?"
   - header: "Git Op"
   - options:
     - Commit only (Create commit on current branch)
     - Commit + PR (Create commit and open pull request)
     - PR only (Changes already committed)
   ```

2. Launch `devloop:engineer` agent in git mode for the operation

3. **For commits:**
   - Generate conventional commit message from changes
   - Present for approval:
     ```
     Use AskUserQuestion:
     - question: "Proposed commit message. Approve?"
     - header: "Commit"
     - options:
       - Approve (Use this message)
       - Edit (Let me modify it)
       - Cancel (Don't commit yet)
     ```
   - Create commit

4. **For PRs:**
   - Generate PR title and description
   - Present for approval
   - Create PR using `gh pr create`
   - Return PR URL

### Phase 5.5: Version & CHANGELOG

**Goal**: Update version and CHANGELOG if warranted

**Actions**:

Invoke `Skill: version-management` for detailed guidance.

1. **Determine if version bump is needed**:
   ```bash
   # Get commits since last tag
   last_tag=$(git describe --tags --abbrev=0 2>/dev/null || echo "")
   if [ -n "$last_tag" ]; then
       git log ${last_tag}..HEAD --oneline
   else
       git log --oneline -20
   fi
   ```

2. **Auto-detect bump type** from conventional commits:
   - `BREAKING CHANGE:` or `!:` → MAJOR
   - `feat:` → MINOR
   - `fix:`, `perf:` → PATCH
   - Other → No bump needed

3. **If bump warranted**, ask user:
   ```
   Use AskUserQuestion:
   - question: "Based on commits, suggest [MINOR] bump. Update version?"
   - header: "Version"
   - options:
     - Accept (Bump to suggested version)
     - Different (Let me choose the bump type)
     - Skip (No version change)
   ```

4. **Update version files** (if bumping):
   - Check for: `package.json`, `plugin.json`, `VERSION`, `pyproject.toml`, `Cargo.toml`
   - Update the version field

5. **Update CHANGELOG** (if exists):
   ```bash
   ls CHANGELOG.md 2>/dev/null && echo "CHANGELOG found"
   ```

   If CHANGELOG.md exists:
   - Generate entry from commits since last version
   - Group by type (Added, Fixed, Changed)
   - Insert under new version header
   - Follow Keep a Changelog format

6. **Commit version bump** (if changes made):
   ```
   git add -A
   git commit -m "chore(release): bump version to vX.Y.Z

   - Bump version to X.Y.Z
   - Update CHANGELOG.md"
   ```

7. **Optionally create tag**:
   ```
   Use AskUserQuestion:
   - question: "Create git tag for vX.Y.Z?"
   - header: "Tag"
   - options:
     - Yes (Create annotated tag)
     - No (Skip tagging)
   ```

   If yes:
   ```bash
   git tag -a vX.Y.Z -m "Release vX.Y.Z"
   ```

### Phase 6: Post-Ship

**Goal**: Wrap up and next steps

**Actions**:
1. **Update Plan File** (if `.devloop/plan.md` exists):
   - Set Status to "Complete"
   - Add Progress Log entry: `[YYYY-MM-DD HH:MM]: Feature shipped - [commit hash or PR URL]`
   - Update timestamps

2. Summarize what was shipped:
   ```markdown
   ## Ship Complete

   ### Commit
   - **Hash**: [hash]
   - **Message**: [message]
   - **Branch**: [branch]

   ### PR (if created)
   - **URL**: [url]
   - **Title**: [title]

   ### Version (if bumped)
   - **Previous**: [old version]
   - **New**: [new version]
   - **Tag**: [tag name if created]
   - **CHANGELOG**: [Updated/Skipped]

   ### Validation Results
   - DoD: [PASS/OVERRIDE]
   - Tests: [PASS/SKIP]
   - Build: [PASS/SKIP]

   ### Files Changed
   - [list of files]

   ### Next Steps
   - [ ] [Suggested action]
   ```

2. Ask about follow-up:
   ```
   Use AskUserQuestion:
   - question: "What's next?"
   - header: "Follow-up"
   - options:
     - Continue (Start another feature)
     - Monitor PR (I'll watch for reviews)
     - Done (End session)
   ```

---

## Conventional Commit Generation

The git-manager will analyze changes and generate:

```
<type>(<scope>): <description>

[body explaining what and why]

[footer with issue references]
```

Types based on changes:
- `feat` - New files with functionality
- `fix` - Changes to fix bugs
- `refactor` - Code restructuring
- `test` - Test additions/changes
- `docs` - Documentation changes
- `chore` - Build/config changes

---

## PR Description Template

```markdown
## Summary
[Auto-generated from commits and changes]

## Changes
- [File-by-file or feature-by-feature summary]

## Testing
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Manual testing completed

## DoD Checklist
- [ ] Code follows project conventions
- [ ] Tests added/updated
- [ ] Documentation updated
- [ ] No critical issues

## Related Issues
Closes #[issue-number]
```

---

## Safety Checks

Before any git operation:
- [ ] No secrets in staged files
- [ ] No debug code committed
- [ ] No large binary files
- [ ] Branch is correct
- [ ] No force push to protected branches

---

## Model Usage

| Phase | Model | Rationale |
|-------|-------|-----------|
| Pre-flight | haiku | Simple checks |
| DoD Validation | haiku | Checklist verification |
| Test Analysis | haiku | Pattern matching |
| Git Operations | haiku | Formulaic |
| Summary | haiku | Simple output |

All phases use haiku since shipping is mostly verification and formulaic operations.

---

## Rollback

If something goes wrong after commit:
```bash
# Undo last commit (keep changes)
git reset --soft HEAD~1

# Undo last commit (discard changes)
git reset --hard HEAD~1
```

If PR was created but needs to be closed:
```bash
gh pr close [number]
```
