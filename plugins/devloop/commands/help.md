---
description: Learn how to use devloop - interactive guide to commands, workflow, and best practices
argument-hint: Optional topic (commands, loop, skills, troubleshooting)
allowed-tools:
  - Read
  - AskUserQuestion
---

# Devloop Help

Interactive guide to using devloop effectively.

## Step 1: Choose a Topic

If `$ARGUMENTS` specifies a topic, skip to that section. Otherwise, ask:

```yaml
AskUserQuestion:
  question: "What would you like to learn about?"
  header: "Topic"
  options:
    - label: "Getting Started"
      description: "New to devloop? Start here"
    - label: "Commands"
      description: "What each command does and when to use it"
    - label: "The Loop"
      description: "The spike -> fresh -> continue cycle"
    - label: "Skills & Agents"
      description: "On-demand knowledge and parallel work"
    - label: "Troubleshooting"
      description: "Common issues and fixes"
    - label: "Automation"
      description: "Ralph loop integration for hands-free execution"
```

## Step 2: Show Topic Content

Based on selection, display the appropriate section below.

---

# Topic: Getting Started

## What is devloop?

devloop is a development workflow plugin where **Claude does the work directly**.

No routine agent spawning. No model selection. Just you, Claude, and the code.

## Philosophy

> "Ship features, not excuses."

- **You stay in control** - checkpoints, approvals, visibility
- **Claude does the work** - reads files, writes code, runs tests, commits
- **Agents only for parallel work** - not routine tasks

## Quick Start (3 Commands)

```bash
# 1. Explore and plan
/devloop:spike How should we implement feature X?

# 2. Save state, clear context
/devloop:fresh
/clear

# 3. Resume and work
/devloop:continue
```

That's the core loop. Repeat steps 2-3 every 5-10 tasks.

## Your First Session

1. **Have a task?** Run `/devloop:spike [your task]`
2. **Claude explores** the codebase, creates a plan
3. **You approve** the plan
4. **Run `/devloop:fresh`** then `/clear`
5. **Run `/devloop:continue`** to start implementing
6. **Checkpoint every few tasks** - commit, break, or continue

---

# Topic: Commands

## Which Command Should I Use?

```
Starting new work?
├── Unclear requirements → /devloop:spike (explore first)
├── Small, clear task → /devloop:quick (skip planning)
└── Have a plan already → /devloop:continue

Mid-workflow?
├── Need to clear context → /devloop:fresh → /clear → /devloop:continue
├── Ready to commit → /devloop:ship
└── Want code review → /devloop:review

Returning to work?
└── Always → /devloop:continue
```

## Command Reference

| Command | Purpose | When to Use |
|---------|---------|-------------|
| `/devloop` | Start new workflow | No plan exists, starting fresh |
| `/devloop:spike` | Explore & plan | Unclear requirements, need research |
| `/devloop:continue` | Resume work | Plan exists, returning to work |
| `/devloop:fresh` | Save state | Before clearing context |
| `/devloop:quick` | Fast implementation | Bug fixes, small changes |
| `/devloop:review` | Code review | Before shipping, PR review |
| `/devloop:ship` | Commit & PR | Ready to ship changes |
| `/devloop:archive` | Archive completed plan | Plan is done, want fresh start |
| `/devloop:from-issue` | Start from GH issue | Issue-driven development |
| `/devloop:help` | This guide | Learning devloop |

## Examples

**New feature with unclear scope:**
```bash
/devloop:spike Add user authentication
# Claude explores, creates plan
/devloop:fresh && /clear
/devloop:continue
```

**Quick bug fix:**
```bash
/devloop:quick Fix null pointer in UserService.getById()
```

**Resume yesterday's work:**
```bash
/devloop:continue
```

---

# Topic: The Loop

## The Pattern

```
┌─────────────────────────────────────────────────────────┐
│  1. /devloop:spike [topic]                              │
│     └─→ Explores codebase, creates plan                 │
└────────────────────────┬────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────────┐
│  2. /devloop:fresh                                      │
│     └─→ Saves state to .devloop/next-action.json        │
└────────────────────────┬────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────────┐
│  3. /clear                                              │
│     └─→ Resets conversation context                     │
└────────────────────────┬────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────────┐
│  4. /devloop:continue                                   │
│     └─→ Resumes from saved state                        │
│     └─→ Works through tasks with checkpoints            │
└────────────────────────┬────────────────────────────────┘
                         │
                   After 5-10 tasks?
                         │
              ┌──────────┴──────────┐
              Yes                   No
               ↓                     ↓
         Loop back to 2        Keep working
```

## Why This Works

1. **Fresh context = better reasoning** - Claude performs better with clean context
2. **Plan preserves progress** - Work never lost between sessions
3. **Checkpoints keep you in control** - Approve, adjust, or pause anytime
4. **Sustainable pace** - Avoid context overload

## When to Fresh Start

- After completing 5-10 tasks
- When responses feel slow
- After long exploration or agent work
- Before taking a break
- When Claude suggests it

## State Files

| File | Purpose |
|------|---------|
| `.devloop/plan.md` | Current task plan (persists) |
| `.devloop/next-action.json` | Fresh start state (consumed on continue) |
| `.devloop/worklog.md` | Optional work history |

---

# Topic: Skills & Agents

## Skills: On-Demand Knowledge

Skills are specialized knowledge that Claude loads when needed.

**How to use:**
```
Skill: skill-name
```

**Available skills:**

| Skill | Purpose |
|-------|---------|
| `plan-management` | Working with .devloop/plan.md |
| `go-patterns` | Go idioms, error handling, testing |
| `python-patterns` | Python best practices, pytest |
| `react-patterns` | React/TypeScript, hooks, components |
| `java-patterns` | Java/Spring patterns |
| `git-workflows` | Git operations, branching |
| `atomic-commits` | Commit best practices |
| `testing-strategies` | Test design patterns |
| `api-design` | REST/GraphQL API design |
| `database-patterns` | SQL, schema design |
| `architecture-patterns` | System design, SOLID |
| `security-checklist` | Security review, OWASP |

**Don't preload.** Claude loads skills automatically when the task requires specialized knowledge.

## Agents: Parallel Work Only

Agents are for **parallel, independent tasks** - not routine work.

**When to use agents:**
- Multiple independent implementations running simultaneously
- Full codebase security scan
- Large codebase exploration (50+ files)

**When NOT to use agents:**
- Writing code (Claude does it directly)
- Running tests (use Bash)
- Git operations (use Bash)
- Single-file changes
- Documentation

**Available agents:**

| Agent | Purpose |
|-------|---------|
| `devloop:engineer` | Code exploration, architecture, refactoring |
| `devloop:qa-engineer` | Test generation, bug tracking |
| `devloop:task-planner` | Planning, requirements |
| `devloop:code-reviewer` | Quality review |
| `devloop:security-scanner` | OWASP, secrets, injection risks |
| `devloop:doc-generator` | READMEs, API docs |

---

# Topic: Troubleshooting

## Common Issues

### Plan file corrupted or stuck
```bash
# Delete and start fresh
rm .devloop/plan.md
/devloop
```

### Session ended unexpectedly
```bash
# Just continue - picks up from plan
/devloop:continue
```

### Want to abandon current plan
```bash
# Archive old plan (if complete), start new
/devloop:archive
/devloop
```

### Issue-driven development
```bash
# Start work from GitHub issue
/devloop:from-issue 123
# On completion, plan syncs back to issue
```

### Context feels heavy/slow
```bash
# The standard fix
/devloop:fresh
/clear
/devloop:continue
```

### Skill not loading
Check `skills/INDEX.md` for exact name. Use `Skill: exact-name`.

### Plan progress not saving
Make sure tasks are marked `[x]` not `[X]`. Case matters in some parsers.

## Where to Get More Help

- **README**: Full plugin documentation
- **skills/INDEX.md**: All available skills
- **docs/living/**: Deep-dive documentation
- **GitHub Issues**: Report bugs or request features

## Reset Everything

Nuclear option - start completely fresh:

```bash
rm -rf .devloop/
/devloop
```

---

# Topic: Automation

## Ralph Loop Integration

Run devloop tasks automatically until plan completion using the ralph-loop plugin.

**Prerequisites:**
- Install ralph-loop: `/plugin install ralph-loop`
- Have a plan: `.devloop/plan.md`

## Basic Usage

```bash
# Start automated execution (up to 50 iterations)
/devloop:ralph

# With custom iteration limit
/devloop:ralph --max-iterations 100
```

## How It Works

```
┌─────────────────────────────────────────────────┐
│  /devloop:ralph                                 │
│  └─→ Creates ralph-loop state                   │
│  └─→ Sets promise: "ALL PLAN TASKS COMPLETE"    │
│  └─→ Starts working on tasks                    │
└───────────────────────┬─────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────┐
│  Claude completes a task                        │
│  └─→ Marks task [x] in plan                     │
│  └─→ Checks: all tasks done?                    │
└───────────────────────┬─────────────────────────┘
                        │
                ┌───────┴───────┐
              No tasks           All tasks
              remaining          complete
                │                    │
                ↓                    ↓
         Stop hook              Output promise:
         feeds prompt           <promise>ALL PLAN
         back to Claude         TASKS COMPLETE</promise>
                │                    │
                ↓                    ↓
         Another iteration       Loop terminates
```

## When to Use

**Good for:**
- Well-defined plans with clear tasks
- Overnight or background execution
- Automated implementation of spike-created plans

**Not good for:**
- Tasks requiring human decisions
- Creative or design work
- Unclear or evolving requirements

## The Promise Mechanism

Ralph's Stop hook looks for a `<promise>` tag in Claude's output. When all plan tasks are marked `[x]`, devloop outputs:

```
<promise>ALL PLAN TASKS COMPLETE</promise>
```

This signals Ralph to terminate the loop.

## Context Guard (Auto-Exit)

The loop automatically exits when context usage exceeds 70%, preventing degradation.

**How it works:**
1. Statusline writes context % to `.claude/context-usage.json`
2. Stop hook checks context when Claude tries to stop
3. If context >= threshold and ralph active, gracefully exits
4. You'll see: "Run `/devloop:fresh` then `/devloop:continue` to resume"

**Configure threshold** in `.devloop/local.md`:
```yaml
---
context_threshold: 80  # Default is 70
---
```

## Stopping Early

```bash
# Cancel the active ralph loop
/cancel-ralph
```

Or set `--max-iterations` for a safety limit.
The context guard also stops the loop automatically at high context.

## Monitoring Progress

```bash
# Check ralph iteration count
head -10 .claude/ralph-loop.local.md

# Check plan progress
./plugins/devloop/scripts/check-plan-complete.sh
```

## Comparison: Manual vs Automated

| Aspect | Manual (spike/fresh/continue) | Automated (ralph) |
|--------|-------------------------------|-------------------|
| Context management | You run /fresh + /clear | Context accumulates |
| Human checkpoints | Yes | No |
| Works overnight | No | Yes |
| Best for | Complex, evolving work | Clear, defined tasks |

## Tips

1. **Create good plans first** - Run `/devloop:spike` before `/devloop:ralph`
2. **Use iteration limits** - Set `--max-iterations` as a safety net
3. **Review results** - Check work after loop completes
4. **Large plans** - Consider manual loop for 20+ tasks (context builds up)

---

## Step 3: Offer Related Topics

After showing topic content, offer to explore more:

```yaml
AskUserQuestion:
  question: "Would you like to learn about another topic?"
  header: "More"
  options:
    - label: "Yes, show topics"
      description: "Return to topic menu"
    - label: "No, I'm good"
      description: "Exit help"
```

If "Yes", return to Step 1. If "No", end with:

> Ready to start? Try `/devloop:spike [your task]` or `/devloop:continue` if you have a plan.
