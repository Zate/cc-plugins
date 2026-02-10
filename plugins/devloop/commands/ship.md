---
description: Complete validation and git integration for shipping a feature
argument-hint: Optional commit message or PR title
allowed-tools:
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - Bash
  - Bash(${CLAUDE_PLUGIN_ROOT}/scripts/*.sh:*)
  - AskUserQuestion
  - TaskCreate
  - TaskUpdate
  - TaskList
---

# Ship - Commit and PR

Validate and ship changes with branch-aware workflow. **You do the work directly.**

## Phase 1: Pre-flight Check

```bash
git status && git diff --stat && git branch --show-current
```

Read `.devloop/local.md` for preferences: `git.pr-on-complete`, `commits.style`.

| Branch | Flow |
|--------|------|
| main/master | Direct commit (caution) |
| feat/*, fix/* | Feature branch → PR |
| Other | Ask user |

```yaml
AskUserQuestion:
  questions:
    - question: "How would you like to ship?"
      header: "Mode"
      multiSelect: false
      options:
        - label: "Full validation"
          description: "Run tests, review, then commit/PR"
        - label: "Quick commit"
          description: "Skip validation, just commit"
        - label: "PR only"
          description: "Changes already committed, create PR"
        - label: "Atomic commits"
          description: "One commit per completed plan task"
```

## Phase 2: Validation (if Full mode)

**Run tests:** Detect from package.json/go.mod/requirements.txt/pom.xml.
**Code review:** If `review.before-commit: always`, use `devloop:code-reviewer`.
**Safety:** No secrets, no debug code, correct branch.

## Phase 3: Smart Commit

If plan exists:
1. Find tasks marked `[x]` since last commit
2. Offer: single commit vs atomic commits

**Conventional style:**
```
<type>(<scope>): <description>

- Task 1.1: Description
- Task 1.2: Description
```

| Task Contains | Type |
|---------------|------|
| Create, Add, Implement | feat |
| Fix, Resolve | fix |
| Refactor, Clean | refactor |
| Test, Spec | test |
| Doc, README | docs |
| Other | chore |

**Issue closing:** If plan has `issue:` in frontmatter:
- `github.auto_close: always` → Auto-add `Closes #N`
- `github.auto_close: ask` → Prompt
- `github.auto_close: never` → Skip

```bash
git add -A && git commit -m "$(cat <<'EOF'
feat(scope): description

- Task 1.1: Description
- Task 1.2: Description

Closes #42
EOF
)"
```

## Phase 4: PR Creation

| Condition | Action |
|-----------|--------|
| On main/master | Skip |
| pr-on-complete: never | Skip |
| pr-on-complete: always | Auto-create |
| pr-on-complete: ask | Ask user |

Generate PR from plan:
```markdown
## Summary
[Plan title and overview]

## Changes
- [x] Task 1.1: Description
- [x] Task 1.2: Description

## Testing
- [ ] Tests pass locally
- [ ] Code reviewed
```

```bash
gh pr create --title "[Plan Title]" --body "[Description]"
```

## Phase 5: Post-Ship

1. Add PR link to plan header
2. Add Progress Log entry
3. If all tasks complete, update status to `Complete`

```bash
"${CLAUDE_PLUGIN_ROOT}/scripts/check-plan-complete.sh" .devloop/plan.md
```

**If complete:**
```yaml
AskUserQuestion:
  questions:
    - question: "All tasks done! What next?"
      header: "Next"
      multiSelect: false
      options:
        - label: "Archive plan"
          description: "Move to archive, start fresh"
        - label: "Wait for review"
          description: "PR created, wait for feedback"
        - label: "Done"
          description: "Keep plan for reference"
```

Archive: `"${CLAUDE_PLUGIN_ROOT}/scripts/archive-plan.sh" .devloop/plan.md`

**If not complete:** Offer continue/wait/break.

## Safety Checklist

Before commit: No secrets, no debug, correct branch, tests pass.
Before PR: Good messages, PR description, correct base branch.

## Quick Reference

| Mode | Flow |
|------|------|
| Full validation | Test → Review → Commit → PR |
| Quick commit | Commit only |
| PR only | Create PR from commits |
| Atomic commits | One commit per task |
