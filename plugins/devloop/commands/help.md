---
description: Learn how to use devloop - interactive guide to commands, workflow, and best practices
argument-hint: Optional topic (commands, loop, skills, troubleshooting)
allowed-tools:
  - Read
  - AskUserQuestion
---

# Devloop Help

Interactive guide to devloop.

## Step 1: Choose Topic

If `$ARGUMENTS` specifies a topic, skip to that section. Otherwise:

```yaml
AskUserQuestion:
  questions:
    - question: "What would you like to learn about?"
      header: "Topic"
      multiSelect: false
      options:
        - label: "Getting Started"
          description: "New to devloop? Start here"
        - label: "Commands"
          description: "What each command does"
        - label: "The Loop"
          description: "The spike -> fresh -> continue cycle"
        - label: "Skills & Agents"
          description: "On-demand knowledge and parallel work"
```

---

# Topic: Getting Started

## What is devloop?

Development workflow where **Claude does the work directly**. No routine agents. Just you, Claude, and the code.

## Quick Start

```bash
/devloop:spike How should we implement feature X?   # Explore and plan
/devloop:fresh && /clear                            # Save state, clear context
/devloop:run                                        # Execute tasks
```

Repeat fresh/clear/run every 5-10 tasks.

## First Session

1. Have a task? `/devloop:spike [task]`
2. Claude explores, creates plan
3. You approve
4. `/devloop:fresh` then `/clear`
5. `/devloop:run` to implement
6. Checkpoint every few tasks

---

# Topic: Commands

## Decision Tree

```
Starting new work?
├── Unclear requirements → /devloop:spike
├── Small, clear task    → /devloop:quick
└── Have a plan          → /devloop:run

Mid-workflow?
├── Context heavy        → /devloop:fresh → /clear → /devloop:run
├── Ready to commit      → /devloop:ship
└── Want review          → /devloop:review

Returning?
└── /devloop:run
```

## Command Reference

| Command | Purpose |
|---------|---------|
| `/devloop` | Start new workflow |
| `/devloop:spike` | Explore & plan |
| `/devloop:run` | Autonomous execution |
| `/devloop:run --interactive` | With checkpoints |
| `/devloop:run --next-issue` | Full issue-to-ship |
| `/devloop:run-swarm` | Swarm for 10+ tasks |
| `/devloop:fresh` | Save state for clear |
| `/devloop:quick` | Fast implementation |
| `/devloop:review` | Code review |
| `/devloop:ship` | Commit & PR |
| `/devloop:archive` | Archive completed plan |
| `/devloop:from-issue` | Start from GH issue |
| `/devloop:statusline` | Configure statusline |
| `/devloop:help` | This guide |

---

# Topic: The Loop

## Pattern

```
/devloop:spike [topic]  →  Creates plan
       ↓
/devloop:fresh          →  Saves state
       ↓
/clear                  →  Resets context
       ↓
/devloop:run            →  Implements tasks
       ↓
After 5-10 tasks?
├── Yes → Loop to fresh
└── No  → Continue
```

## Why It Works

- Fresh context = better reasoning
- Plan preserves progress
- Checkpoints keep control
- Sustainable pace

## When to Fresh

- After 5-10 tasks
- When responses slow
- After long exploration
- Before taking a break

## State Files

| File | Purpose |
|------|---------|
| `.devloop/plan.md` | Current plan (persists) |
| `.devloop/next-action.json` | Fresh state (consumed) |
| `.devloop/worklog.md` | Work history |

---

# Topic: Skills & Agents

## Skills: On-Demand Knowledge

Load when needed: `Skill: skill-name`

| Skill | Purpose |
|-------|---------|
| `plan-management` | Working with plan.md |
| `go-patterns` | Go idioms, testing |
| `python-patterns` | Python best practices |
| `react-patterns` | React/TypeScript |
| `java-patterns` | Java/Spring |
| `git-workflows` | Git operations |
| `atomic-commits` | Commit practices |
| `testing-strategies` | Test design |
| `api-design` | REST/GraphQL |
| `database-patterns` | SQL, schema |
| `architecture-patterns` | System design |
| `security-checklist` | Security review |

**Don't preload.** Claude loads automatically when needed.

## Agents: Parallel Work Only

**Use for:** parallel implementations, security scans, large exploration (50+ files)
**Don't use for:** writing code, tests, git ops, single files, docs

| Agent | Purpose |
|-------|---------|
| `devloop:engineer` | Exploration, architecture |
| `devloop:qa-engineer` | Test generation |
| `devloop:task-planner` | Planning, requirements |
| `devloop:code-reviewer` | Quality review |
| `devloop:security-scanner` | OWASP, secrets |
| `devloop:doc-generator` | READMEs, API docs |

---

# Topic: Troubleshooting

## Common Issues

**Plan corrupted:** `rm .devloop/plan.md && /devloop`
**Session ended:** `/devloop:run`
**Abandon plan:** `/devloop:archive && /devloop`
**Context heavy:** `/devloop:fresh && /clear && /devloop:run`
**Skill not loading:** Check exact name in skills/INDEX.md
**Progress not saving:** Use `[x]` not `[X]`
**Statusline missing:** `/devloop:statusline`, restart Claude Code

## Reset Everything

```bash
rm -rf .devloop/ && /devloop
```

---

# Topic: Automation

## Autonomous Execution

```bash
/devloop:run                      # Up to 50 iterations
/devloop:run --max-iterations 100 # Custom limit
/devloop:run --interactive        # With checkpoints
```

## How It Works

1. `/devloop:run` creates ralph-loop state
2. Claude works on tasks, marks `[x]`
3. When all done, outputs `<promise>ALL PLAN TASKS COMPLETE</promise>`
4. Loop terminates

## Context Guard

Auto-exits at 70% context usage. Configure in `.devloop/local.md`:
```yaml
context_threshold: 80
```

## Stopping Early

- `/cancel-ralph`
- Max iterations reached
- Context guard triggered

---

## Step 3: Offer More

```yaml
AskUserQuestion:
  questions:
    - question: "Learn about another topic?"
      header: "More"
      multiSelect: false
      options:
        - label: "Yes, show topics"
          description: "Return to topic menu"
        - label: "No, I'm good"
          description: "Exit help"
```

If yes, return to Step 1. If no:

> Ready to start? Try `/devloop:spike [task]` or `/devloop:run` if you have a plan.
