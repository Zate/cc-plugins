---
description: Complete validation and git integration for shipping a feature
argument-hint: Optional commit message or PR title
allowed-tools: ["Read", "Write", "Edit", "Grep", "Glob", "Bash", "Bash(${CLAUDE_PLUGIN_ROOT}/scripts/check-plan-complete.sh:*)", "Bash(${CLAUDE_PLUGIN_ROOT}/scripts/archive-plan.sh:*)", "AskUserQuestion", "TodoWrite"]
---

# Ship - Commit and PR

Validate and ship your changes with branch-aware workflow. **You do the work directly.**

## Phase 1: Pre-flight Check

**Gather context:**

```bash
git status
git diff --stat
git branch --show-current
```

**Check for local config:**

If `.devloop/local.md` exists, read git workflow preferences:
- `git.pr-on-complete`: ask | always | never
- `commits.style`: conventional | simple

**Determine branch context:**

| Branch | Likely Flow |
|--------|-------------|
| `main`/`master` | Direct commit (caution) |
| `feat/*`, `fix/*` | Feature branch → PR |
| Other | Ask user |

**Ask ship mode:**

```yaml
AskUserQuestion:
  question: "How would you like to ship?"
  header: "Mode"
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

---

## Phase 2: Validation (if Full mode)

**Run tests:**

Detect test runner from project:
```bash
npm test          # package.json
go test ./...     # go.mod
pytest            # requirements.txt/pyproject.toml
mvn test          # pom.xml
```

**Code review check:**

If `review.before-commit` is `always` or user chooses:
- Use `devloop:code-reviewer` agent
- Or specified `review.use-plugin`

**Safety checks:**
- No secrets in staged files (API keys, passwords)
- No debug code (console.log, print statements)
- Verify correct branch

---

## Phase 3: Smart Commit Strategy

**If plan exists at `.devloop/plan.md`:**

1. Find tasks marked `[x]` since last commit
2. Offer commit strategy:

```yaml
AskUserQuestion:
  question: "Found N completed tasks. How to commit?"
  header: "Strategy"
  options:
    - label: "Single commit"
      description: "Squash all into one commit"
    - label: "Atomic commits"
      description: "One commit per task"
```

**Generate commit messages:**

For conventional style (`commits.style: conventional`):
```
<type>(<scope>): <task description>

- Task 1.1: Created local-config skill
- Task 1.2: Added config parsing
```

Type mapping from task names:
| Task Contains | Type |
|---------------|------|
| Create, Add, Implement | `feat` |
| Fix, Resolve, Repair | `fix` |
| Refactor, Clean, Improve | `refactor` |
| Test, Spec | `test` |
| Doc, README | `docs` |
| Other | `chore` |

Scope: Use plan name slugified, or detect from files changed.

**Execute commits:**

```bash
git add -A
git commit -m "$(cat <<'EOF'
feat(git-workflow): add local config system

- Task 1.1: Created skills/local-config/SKILL.md
- Task 1.2: Added scripts/parse-local-config.sh
- Task 1.3: Updated session-start hook
EOF
)"
```

---

## Phase 4: PR Creation

**When to create PR:**

| Condition | Action |
|-----------|--------|
| On main/master | Skip PR (already on main) |
| `pr-on-complete: never` | Skip PR |
| `pr-on-complete: always` | Auto-create |
| `pr-on-complete: ask` | Ask user |

**Generate PR description from plan:**

```markdown
## Summary

[Plan title and overview from .devloop/plan.md]

## Changes

- [x] Task 1.1: Description
- [x] Task 1.2: Description
- [x] Task 1.3: Description

## Testing

- [ ] Tests pass locally
- [ ] Code reviewed

## Related

- Spike: `.devloop/spikes/[topic].md`
```

**Create PR:**

```bash
gh pr create --title "[Plan Title]" --body "$(cat <<'EOF'
[Generated description]
EOF
)"
```

If PR created successfully, capture URL for plan update.

---

## Phase 5: Post-Ship Actions

**Update plan:**

If `.devloop/plan.md` exists:

1. Add PR link to plan header (if PR created):
   ```markdown
   **PR**: https://github.com/owner/repo/pull/123
   ```

2. Add Progress Log entry:
   ```markdown
   - YYYY-MM-DD: Shipped Phase N - [brief description]
   ```

3. If all tasks complete, update status to `Complete`

**Check if plan is complete and offer archival:**

```bash
"${CLAUDE_PLUGIN_ROOT}/scripts/check-plan-complete.sh" .devloop/plan.md
```

If `complete: true`, suggest next action with archive option:

```yaml
AskUserQuestion:
  question: "Ship complete. All tasks done! What next?"
  header: "Next"
  options:
    - label: "Archive plan"
      description: "Move completed plan to archive, start fresh"
    - label: "Wait for review"
      description: "PR created, wait for feedback before archiving"
    - label: "Done"
      description: "Keep plan for reference"
```

### If "Archive plan":
```bash
"${CLAUDE_PLUGIN_ROOT}/scripts/archive-plan.sh" .devloop/plan.md
```

Display:
```
Plan archived to: .devloop/archive/YYYY-MM-DD-{slug}.md

Great work! Ready for the next project.
```

If plan is NOT complete, offer:

```yaml
AskUserQuestion:
  question: "Ship complete. What next?"
  header: "Next"
  options:
    - label: "Continue work"
      description: "Move to next phase"
    - label: "Wait for review"
      description: "PR created, wait for feedback"
    - label: "Done for now"
      description: "Take a break"
```

---

## Safety Checklist

Before any commit:
- [ ] No secrets in staged files
- [ ] No debug statements
- [ ] Correct branch
- [ ] Tests pass (if validation mode)

Before PR:
- [ ] Meaningful commit messages
- [ ] PR description complete
- [ ] Base branch correct (usually main)

---

## Quick Reference

| Mode | What It Does |
|------|--------------|
| Full validation | Test → Review → Commit → PR |
| Quick commit | Commit only |
| PR only | Create PR from existing commits |
| Atomic commits | One commit per plan task |
