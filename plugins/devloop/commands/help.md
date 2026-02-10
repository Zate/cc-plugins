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
          description: "The plan -> run -> fresh cycle"
        - label: "Skills & Agents"
          description: "On-demand knowledge and parallel work"
```

---

# Topic: Getting Started

## What is devloop?

Development workflow where **Claude does the work directly**. No routine agents. Just you, Claude, and the code.

## Quick Start

```bash
/devloop:plan "How should we implement feature X?"  # Plan (or --deep for exploration)
/devloop:run                                        # Execute tasks
/devloop:fresh && /clear                           # Save state, clear context (every 5-10 tasks)
/devloop:run                                        # Continue execution
```

## First Session

1. Have a task? `/devloop:plan [task]` (or `--deep` for detailed exploration)
2. Claude explores, creates plan
3. You approve
4. `/devloop:run` to implement
5. Every 5-10 tasks: `/devloop:fresh` then `/clear` then `/devloop:run`
6. Done? `/devloop:ship`

---

# Topic: Commands

## Decision Tree

```
Starting new work?
|-- Unclear requirements  -> /devloop:plan --deep
|-- Small, clear task     -> /devloop:plan --quick
|-- Normal feature        -> /devloop:plan
|-- Have a plan           -> /devloop:run

Mid-workflow?
|-- Context heavy         -> /devloop:fresh -> /clear -> /devloop:run
|-- Ready to commit       -> /devloop:ship
|-- Want review           -> /devloop:review

Returning?
|-- /devloop:run
```

## Command Reference

| Command | Purpose |
|---------|---------|
| `/devloop` | Start new workflow (smart entry point) |
| `/devloop:plan` | Autonomous planning (default mode) |
| `/devloop:plan --deep` | Comprehensive exploration with spike report |
| `/devloop:plan --quick` | Fast path for small, clear tasks |
| `/devloop:plan --from-issue N` | Start from GitHub issue #N |
| `/devloop:run` | Autonomous execution |
| `/devloop:run --interactive` | With checkpoints |
| `/devloop:run --next-issue` | Full issue-to-ship pipeline |
| `/devloop:run-swarm` | Swarm for 10+ tasks |
| `/devloop:fresh` | Save state for clear |
| `/devloop:review` | Code review |
| `/devloop:ship` | Commit & PR |
| `/devloop:archive` | Archive completed plan |
| `/devloop:new` | Create GitHub issue |
| `/devloop:issues` | List GitHub issues |
| `/devloop:statusline` | Configure statusline |
| `/devloop:help` | This guide |

### Migration from Old Commands

| Old Command | New Command |
|-------------|-------------|
| `/devloop:spike` | `/devloop:plan --deep` |
| `/devloop:quick` | `/devloop:plan --quick` |
| `/devloop:from-issue N` | `/devloop:plan --from-issue N` |
| `/devloop:continue` | `/devloop:run --interactive` |
| `/devloop:ralph` | `/devloop:run` |

---

# Topic: The Loop

## Pattern

```
/devloop:plan [topic]    ->  Creates plan
       |
/devloop:run             ->  Implements tasks
       |
After 5-10 tasks?
|-- Yes -> /devloop:fresh -> /clear -> /devloop:run
|-- No  -> Continue
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
| `devloop:engineer` | Exploration, architecture, code review |
| `devloop:qa-engineer` | Test generation |
| `devloop:task-planner` | Planning, requirements |
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

> Ready to start? Try `/devloop:plan [task]` or `/devloop:run` if you have a plan.
