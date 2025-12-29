---
description: Complete validation and git integration for shipping a feature
argument-hint: Optional commit message or PR title
allowed-tools: [
  "Read", "Write", "Edit", "Grep", "Glob", "Bash", "Task", "AskUserQuestion", "TodoWrite", "Skill",
  "Bash(${CLAUDE_PLUGIN_ROOT}/scripts/ship-validation.sh:*)"
]
---

# Ship Feature

End-to-end workflow for validating a feature is complete and integrating it into version control.

**IMPORTANT**: Always invoke `Skill: plan-management` to understand plan format and update procedures.

## Agent Routing

| Phase | Agent | Mode/Focus |
|-------|-------|------------|
| DoD Validation | `devloop:task-planner` | DoD validator mode |
| Test Analysis | `devloop:qa-engineer` | Runner mode (on failure) |
| Git Operations | `devloop:engineer` | Git mode |

## When to Use

- After implementation is complete
- Ready to commit changes or create a pull request
- Need pre-merge validation

## Validation Script

This command uses `scripts/ship-validation.sh` for DoD, test, and build verification:

```bash
# Run all validations
ship-validation.sh --all

# Run specific validations
ship-validation.sh --dod     # DoD checks only
ship-validation.sh --tests   # Tests only
ship-validation.sh --build   # Build only

# Get JSON output for parsing
ship-validation.sh --all --json
```

---

## Workflow

### Phase 1: Pre-flight Check

**Goal**: Assess readiness for shipping

**Actions**:
1. Check git state: `git status && git diff --stat`
2. Create todo list for ship process
3. Ask ship mode:
   - Full validation (DoD + tests + build, then commit/PR)
   - Quick commit (skip validation)
   - PR only (changes already committed)

### Phase 2: Validation

**Skip if**: User chose "Quick commit" or "PR only"

**Actions**:
1. Run validation script:
   ```bash
   "${CLAUDE_PLUGIN_ROOT}/scripts/ship-validation.sh" --all
   ```

2. Parse results and present:
   - **DoD issues**: TODO/FIXME, debug statements, secrets, large files
   - **Test failures**: Show failure summary, offer `devloop:qa-engineer` analysis
   - **Build failures**: Show error output

3. If validation fails, ask:
   - Fix blockers (address issues)
   - Override (proceed with documented exceptions)
   - Cancel (stop shipping)

### Phase 3: Git Integration

**Goal**: Create commit and/or PR

**Actions**:
1. Ask git operation type:
   - Commit + PR (create both)
   - Commit only (current branch)
   - PR only (already committed)

2. Launch `devloop:engineer` agent in git mode

3. **For commits**: Generate conventional commit, present for approval, create commit

4. **For PRs**: Generate PR description, create via `gh pr create`, return URL

### Phase 4: Version & CHANGELOG

**Goal**: Update version and CHANGELOG if warranted

Invoke `Skill: version-management` for guidance.

**Actions**:
1. Get commits since last tag, detect bump type from conventional commits
2. Ask about version bump (MAJOR/MINOR/PATCH/Skip)
3. Update version files: `package.json`, `plugin.json`, `VERSION`, etc.
4. Update CHANGELOG.md if exists (Keep a Changelog format)
5. Commit version bump, optionally create tag

### Phase 5: Post-Ship

**Goal**: Wrap up and next steps

**Actions**:
1. **Update Plan**: Set Status to "Complete", add Progress Log entry
2. Display summary (commit, PR, version, validation results)
3. Route to next work:
   - Work on existing issue (`/devloop:issues`)
   - Start new feature (`/devloop`)
   - Archive plan (`/devloop:archive`)
   - Fresh start (`/devloop:fresh`)
   - End session

---

## Conventional Commit Types

Types based on changes:
- `feat` - New functionality
- `fix` - Bug fixes
- `refactor` - Code restructuring
- `test` - Test changes
- `docs` - Documentation
- `chore` - Build/config

Format: `<type>(<scope>): <description>`

---

## PR Description Template

```markdown
## Summary
[Auto-generated from commits]

## Changes
- [File-by-file summary]

## Testing
- [ ] Unit tests pass
- [ ] Integration tests pass

## DoD Checklist
- [ ] Code follows conventions
- [ ] Tests added/updated
- [ ] Documentation updated
```

---

## Safety Checks

Before git operations:
- No secrets in staged files
- No debug code committed
- No large binary files
- Correct branch
- No force push to protected branches

---

## Model Usage

All phases use **haiku** since shipping is mostly verification and formulaic operations.

---

## Rollback

```bash
# Undo last commit (keep changes)
git reset --soft HEAD~1

# Undo last commit (discard changes)
git reset --hard HEAD~1

# Close PR
gh pr close [number]
```
