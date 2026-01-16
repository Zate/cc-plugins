---
description: Start development workflow - lightweight entry point
argument-hint: Optional task description
allowed-tools:
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - Bash
  - Task
  - AskUserQuestion
  - TodoWrite
  - Skill
---

# Devloop - Start New Work

**Use this when**: No plan exists, or you want to start fresh.

**Use `/devloop:continue` instead if**: A plan already exists at `.devloop/plan.md`.

Start a development workflow with minimal overhead. **You do the work directly.**

## Quick Start

1. **Check for existing work**:
   - If `.devloop/plan.md` exists → Ask: continue or start new?
   - If `.devloop/next-action.json` exists → Run `/devloop:continue`

2. **Understand the task**: $ARGUMENTS
   - If clear → proceed to planning
   - If unclear → ask ONE clarifying question

3. **Check git workflow config** (if `.devloop/local.md` exists):
   - Read `git.auto-branch` setting
   - If `true` and on main/master, offer to create feature branch

4. **Create feature branch** (if configured):
   ```yaml
   AskUserQuestion:
     questions:
       - question: "Create feature branch for this work?"
         header: "Branch"
         multiSelect: false
         options:
           - label: "Yes"
             description: "Create feat/[task-slug] branch"
           - label: "No"
             description: "Stay on current branch"
   ```
   If yes:
   ```bash
   git checkout -b feat/[task-slug]
   ```

5. **Create plan** (if task is non-trivial):
   ```bash
   mkdir -p .devloop
   ```
   Write plan to `.devloop/plan.md`:
   ```markdown
   # [Task Name]

   **Created**: YYYY-MM-DD
   **Status**: In Progress
   **Branch**: feat/[task-slug] (if created)

   ## Tasks
   - [ ] Task 1
   - [ ] Task 2
   - [ ] Task 3

   ## Progress Log
   - YYYY-MM-DD: Plan created
   ```

6. **Implement directly** - no subagents for routine work

7. **Checkpoint** after significant progress:
   - Summarize what was done
   - Ask: "Continue or take a break?"

## Key Principles

1. **You (Claude) do the work** - Don't spawn subagents for tasks you can do yourself
2. **Skills on demand** - Load with `Skill: skill-name` only when needed
3. **Minimal questions** - One question at a time, not multi-part interrogations
4. **Fast iteration** - Ship working code, then improve

## When to Use Subagents (Task tool)

Only spawn subagents for:
- **Genuinely parallel work** - Multiple independent tasks that can run simultaneously
- **Specialized analysis** - Security scanning (`devloop:security-scanner`), complex code review
- **Large codebases** - Use Claude Code's native `Explore` agent for understanding 50+ files

Do NOT spawn subagents for:
- Writing code (do it yourself)
- Running tests (use Bash)
- Git operations (use Bash)
- Single-file changes
- Documentation

## Available Skills (Load on Demand)

```
Skill: plan-management      # Working with .devloop/plan.md
Skill: go-patterns          # Go idioms and patterns
Skill: python-patterns      # Python best practices
Skill: react-patterns       # React/TypeScript patterns
Skill: java-patterns        # Java/Spring patterns
Skill: testing-strategies   # Test design
Skill: git-workflows        # Git operations
Skill: atomic-commits       # Commit best practices
```

Full index: `skills/INDEX.md`

## Workflow Commands

| Command | Purpose |
|---------|---------|
| `/devloop` | Start new work (this command) |
| `/devloop:continue` | Resume from plan or fresh start |
| `/devloop:spike` | Time-boxed exploration |
| `/devloop:fresh` | Save state and exit cleanly |
| `/devloop:quick` | Small, well-defined fixes |
| `/devloop:review` | Code review |
| `/devloop:ship` | Commit and/or PR |
| `/devloop:pr-feedback` | Integrate PR review comments |

## Example Flow

```
User: Add user authentication to the API

Claude:
1. Check: No existing plan
2. Ask: "OAuth, JWT, or session-based auth?"
3. User: "JWT"
4. Create plan in .devloop/plan.md
5. Implement JWT auth directly (no subagents)
6. Run tests with Bash
7. Checkpoint: "Auth complete. Continue to tests or break?"
```

## Files

- `.devloop/plan.md` - Current task plan
- `.devloop/local.md` - Project settings (git workflow, etc.)
- `.devloop/next-action.json` - Fresh start state (auto-created by /devloop:fresh)
- `.devloop/worklog.md` - Optional work history
- `.devloop/spikes/` - Spike reports

---

**Start now**: What would you like to build?
