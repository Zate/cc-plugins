---
description: Resume work from plan or fresh start
argument-hint: Optional specific task to work on
allowed-tools: ["Read", "Write", "Edit", "Grep", "Glob", "Bash", "AskUserQuestion", "TodoWrite", "Skill"]
---

# Continue - Resume Development Work

Resume work from an existing plan or fresh start state. **You do the work directly.**

## Step 1: Check for Fresh Start State

```bash
if [ -f ".devloop/next-action.json" ]; then
  cat .devloop/next-action.json
fi
```

If `next-action.json` exists:
1. Read and display the saved state
2. Delete the file (single-use)
3. Continue from where we left off

## Step 2: Read the Plan

```bash
cat .devloop/plan.md
```

Find the next pending task (marked with `- [ ]`).

## Step 3: Work on the Task

**You implement the task directly. Do NOT spawn agents for routine work.**

### Do It Yourself:
- Write code → Use Write/Edit tools
- Run tests → Use Bash: `npm test`, `go test`, `pytest`, etc.
- Git operations → Use Bash: `git add`, `git commit`, etc.
- Read files → Use Read/Grep/Glob tools
- Edit files → Use Edit tool

### Only Use Agents For:
- **Parallel work**: Multiple independent tasks that can run simultaneously
- **Security scan**: Full codebase security audit (`devloop:security-scanner`)
- **Large exploration**: Understanding 50+ files in unfamiliar codebase

## Step 4: Update the Plan

After completing a task, mark it done:

```markdown
- [x] Completed task description
```

For partial completion:
```markdown
- [~] Partially done task description
```

## Step 5: Checkpoint

After significant progress, ask:

```yaml
AskUserQuestion:
  question: "Completed [task]. What next?"
  header: "Checkpoint"
  options:
    - label: "Continue"
      description: "Move to next task"
    - label: "Commit"
      description: "Git commit this work"
    - label: "Break"
      description: "Save state, take a break"
```

### If "Commit":
```bash
git add -A
git commit -m "feat: [description of work]"
```

### If "Break":
Run `/devloop:fresh` to save state, then suggest `/clear`.

## Available Skills (Load On Demand)

If you need specialized knowledge:

```
Skill: plan-management      # Plan file conventions
Skill: git-workflows        # Complex git operations
Skill: testing-strategies   # Test design patterns
Skill: [language]-patterns  # Language-specific idioms
```

Read `skills/INDEX.md` for full list.

---

**Now**: Read the plan and start working on the next task.
