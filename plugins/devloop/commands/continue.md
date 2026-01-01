---
description: Resume work from plan or fresh start
argument-hint: Optional specific task to work on
allowed-tools: ["Read", "Write", "Edit", "Grep", "Glob", "Bash", "AskUserQuestion", "TodoWrite", "Skill"]
---

# Continue - Resume Existing Work

**Use this when**: A plan exists at `.devloop/plan.md`.

**Use `/devloop` instead if**: No plan exists, or you want to start a new plan.

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
- **Large exploration**: Use Claude Code's native `Explore` agent (Task tool with `subagent_type: Explore`) for understanding large codebases

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

## When to Load Skills

Load skills when you need domain-specific guidance:

| Situation | Skill |
|-----------|-------|
| Unfamiliar language idioms | `Skill: go-patterns`, `python-patterns`, etc. |
| Complex git operations | `Skill: git-workflows` |
| Designing an API | `Skill: api-design` |
| Writing tests | `Skill: testing-strategies` |
| Security concerns | `Skill: security-checklist` |
| Database schema work | `Skill: database-patterns` |

Don't preload. Load when the task requires it.

## Parallel Agent Example

Only use agents when running truly independent tasks simultaneously:

```
Task:
  subagent_type: devloop:engineer
  description: "Implement UserService"
  run_in_background: true
  prompt: "Implement UserService with CRUD operations"

Task:
  subagent_type: devloop:engineer
  description: "Implement ProductService"
  run_in_background: true
  prompt: "Implement ProductService with CRUD operations"

# Wait for both with TaskOutput
```

For single tasks, just do the work directly.

---

**Now**: Read the plan and start working on the next task.
