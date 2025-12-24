# devloop

**A complete, token-conscious feature development workflow for professional software engineering.**

[![Version](https://img.shields.io/badge/version-2.1.0-blue)](./CHANGELOG.md) [![Agents](https://img.shields.io/badge/agents-9-green)](#agents) [![Skills](https://img.shields.io/badge/skills-29-purple)](#skills) [![Commands](https://img.shields.io/badge/commands-16-orange)](#commands)

---

## What is devloop?

devloop is a Claude Code plugin that brings structure and efficiency to software development. It guides you through a complete workflow—from vague requirements to shipped code—while optimizing token usage through strategic model selection.

**The core insight**: Different tasks need different capabilities. Code review needs opus for catching subtle bugs. Test generation can use haiku for formulaic patterns. devloop automates this selection so you get the best results without thinking about it.

---

## Quick Start

```bash
# Install
/plugin install devloop

# Recommended workflow: spike → fresh → continue loop
/devloop:spike How should we add user authentication?
/devloop:fresh
/clear
/devloop:continue

# That's it. devloop guides you through the rest.
```

### The Recommended Workflow

devloop works best with the **spike → fresh → continue loop**:

```
Spike → Fresh → /clear → Continue → [5-10 tasks] → Fresh → /clear → Continue → ...
```

**Why this pattern?**

1. **Spike first** - Explore the problem, create a solid plan with all context
2. **Fresh regularly** - Clear context every 5-10 tasks to maintain speed
3. **Continue seamlessly** - Pick up exactly where you left off with fresh focus
4. **Better results** - Fresh context = faster responses, sharper reasoning

This iterative cycle is how professional developers work: plan, execute, reassess, continue.

### Using devloop with Other AI Agents

**Don't have Claude Code?** You can still use devloop methodology with Cursor, Aider, Gemini, or any AI coding agent.

See **[DEVLOOP_FOR_GENERIC_AGENTS.md](./docs/DEVLOOP_FOR_GENERIC_AGENTS.md)** for:
- Complete workflow documentation without plugin requirements
- Plan file format specification
- Integration with `.cursorrules`, `.aider.conf.yml`, and other agent configs
- Best practices for non-Claude agents

---

## The Workflow

devloop provides a 12-phase workflow that mirrors how senior engineers approach complex features:

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  0. Triage  │────▶│ 1. Discovery│────▶│ 2. Estimate │
└─────────────┘     └─────────────┘     └─────────────┘
                                               │
┌─────────────┐     ┌─────────────┐     ┌──────▼──────┐
│ 5. Architect│◀────│4. Clarify   │◀────│ 3. Explore  │
└──────┬──────┘     └─────────────┘     └─────────────┘
       │
┌──────▼──────┐     ┌─────────────┐     ┌─────────────┐
│  6. Plan    │────▶│ 7. Implement│────▶│  8. Test    │
└─────────────┘     └─────────────┘     └──────┬──────┘
                                               │
┌─────────────┐     ┌─────────────┐     ┌──────▼──────┐
│ 11. Git     │◀────│10. Validate │◀────│  9. Review  │
└──────┬──────┘     └─────────────┘     └─────────────┘
       │
       ▼
┌─────────────┐
│ 12. Summary │
└─────────────┘
```

**You don't have to use all phases.** Use `/devloop:quick` for small tasks, `/devloop:review` for code review, `/devloop:spike` for exploration.

---

## Commands

| Command | Purpose | When to Use |
|---------|---------|-------------|
| `/devloop` | Full feature workflow | New features, complex changes |
| `/devloop:onboard` | **Existing repo setup** | **First time using devloop, migration from .claude/** |
| `/devloop:analyze` | Codebase refactoring analysis | Technical debt, messy code, large files |
| `/devloop:bootstrap` | New project setup | Greenfield projects with docs |
| `/devloop:continue` | Resume existing plan | Continuing previous work |
| `/devloop:fresh` | Save state & clear context | Context heavy, long sessions |
| `/devloop:quick` | Fast implementation | Small, well-defined tasks |
| `/devloop:spike` | Technical exploration | Unknown feasibility |
| `/devloop:review` | Code review | Before commits, PR review |
| `/devloop:ship` | Git integration | Ready to commit/PR |
| `/devloop:new` | Smart issue creation | Track bugs, features, tasks |
| `/devloop:issues` | Manage all issues | View, filter, work on issues |
| `/devloop:bug` | Report a bug | Quick bug tracking |
| `/devloop:bugs` | View bugs | Bug-only view |
| `/devloop:worklog` | Manage work history | View, sync, reconstruct worklog |
| `/devloop:statusline` | Configure status bar | Setup status display |

### Examples

```bash
# Onboard an existing codebase to devloop
/devloop:onboard

# Bootstrap a new project from documentation
/devloop:bootstrap ./docs/PRD.md ./specs/api.yaml

# Full feature development
/devloop Add rate limiting to API endpoints

# Analyze codebase for refactoring
/devloop:analyze
/devloop:analyze Focus on the API layer

# Quick fix
/devloop:quick Fix the null pointer in UserService

# Explore feasibility
/devloop:spike Can we migrate from REST to GraphQL?

# Review changes
/devloop:review

# Ship it
/devloop:ship

# Resume where you left off
/devloop:continue

# Save state and start fresh when context heavy
/devloop:fresh

# Track issues for later
/devloop:new Add dark mode support eventually
/devloop:new The button is broken on mobile

# View and manage issues
/devloop:issues
/devloop:issues bugs
/devloop:issues backlog
```

---

## Agents

devloop v2.0 includes 9 consolidated super-agents. Each agent operates in multiple modes, reducing overhead while maintaining specialized capabilities. Agents are color-coded by category.

### Color Scheme

| Color | Category | Agents |
|-------|----------|--------|
| 🔵 blue | Engineering | engineer (4 modes) |
| 🟢 green | Quality | qa-engineer (4 modes) |
| 🟣 indigo | Planning | task-planner (4 modes) |
| 🔴 red | Review | code-reviewer, security-scanner |
| 🟡 yellow | Detection | workflow-detector, complexity-estimator |
| 🔷 teal | Documentation | doc-generator, summary-generator |

### Super-Agents (v2.0)

| Agent | Modes | Model | Purpose |
|-------|-------|-------|---------|
| `engineer` | Explorer, Architect, Refactorer, Git | sonnet | Codebase exploration, architecture design, refactoring analysis, git operations |
| `qa-engineer` | Generator, Runner, Bug Tracker, Validator | sonnet | Test generation, test execution, bug tracking, deployment validation |
| `task-planner` | Planner, Requirements, Issue Manager, DoD | sonnet | Task planning, requirements gathering, issue tracking, DoD validation |

### Specialized Agents

| Agent | Color | Model | Purpose |
|-------|-------|-------|---------|
| `code-reviewer` | red | sonnet | Quality review with confidence-based filtering |
| `security-scanner` | red | haiku | OWASP Top 10, secrets, injection vulnerabilities |
| `workflow-detector` | yellow | haiku | Classify task type (feature/bug/refactor) |
| `complexity-estimator` | yellow | haiku | T-shirt sizing and risk assessment |
| `doc-generator` | teal | sonnet | Generate and update documentation |
| `summary-generator` | teal | haiku | Session summaries and handoff docs |

### Agent Consolidation (v2.0)

The following agents were merged into super-agents:
- `code-explorer`, `code-architect`, `refactor-analyzer`, `git-manager` → **engineer**
- `test-generator`, `test-runner`, `bug-catcher`, `qa-agent` → **qa-engineer**
- `requirements-gatherer`, `issue-manager`, `dod-validator` → **task-planner**

This reduces token overhead from agent context while maintaining all capabilities.

---

## Agent Invocation Patterns

Commands orchestrate workflows by routing tasks to specialized agents using the Task tool.

### How Commands Route to Agents

Commands use the Task tool with explicit `subagent_type` to invoke agents:

```yaml
Task:
  subagent_type: devloop:engineer
  description: "Implement user authentication"
  prompt: |
    Implement JWT-based authentication for the user service.

    Requirements:
    - Token generation with RS256
    - Token validation middleware
    - Refresh token support
```

### Agent Routing Table

| Task Type | Agent | Mode/Focus |
|-----------|-------|------------|
| Implement feature/code | `devloop:engineer` | Default mode |
| Explore/understand code | `devloop:engineer` | Explore mode |
| Design architecture | `devloop:engineer` | Architect mode |
| Refactor code | `devloop:engineer` | Refactor mode |
| Git commit/branch/PR | `devloop:engineer` | Git mode |
| Plan tasks/breakdown | `devloop:task-planner` | Planner mode |
| Gather requirements | `devloop:task-planner` | Requirements mode |
| Validate completion | `devloop:task-planner` | DoD validator mode |
| Write tests | `devloop:qa-engineer` | Generator mode |
| Run tests | `devloop:qa-engineer` | Runner mode |
| Track bugs/issues | `devloop:qa-engineer` | Bug tracker mode |
| Code review | `devloop:code-reviewer` | - |
| Security scan | `devloop:security-scanner` | - |
| Generate docs | `devloop:doc-generator` | - |

### Automatic vs Explicit Invocation

**Automatic (Command-Driven)**:
- `/devloop:continue` - Analyzes next task, routes to appropriate agent
- `/devloop:review` - Automatically invokes `code-reviewer`
- `/devloop:ship` - Invokes `qa-engineer` (validator) then `engineer` (git)

**Explicit (User-Directed)**:
- `/devloop:analyze` - Directly invokes `engineer` (refactor mode)
- `/devloop:spike` - Uses `engineer` (explore mode)
- `/devloop:quick` - Routes to `engineer` (default mode)

### Mode Detection Example

The `engineer` agent detects its mode from task keywords:

```yaml
# Exploration task
Task:
  subagent_type: devloop:engineer
  description: "Explore authentication flow"
  prompt: "Understand how JWT tokens are currently generated"
# → Agent detects "explore", "understand" → Explore mode

# Architecture task
Task:
  subagent_type: devloop:engineer
  description: "Design caching strategy"
  prompt: "Design Redis caching for user sessions"
# → Agent detects "design", "strategy" → Architect mode

# Implementation task
Task:
  subagent_type: devloop:engineer
  description: "Add rate limiting"
  prompt: "Implement rate limiting middleware"
# → Agent detects "implement", "add" → Default mode
```

### Background Execution

For parallel independent tasks, use `run_in_background: true`:

```yaml
# Launch multiple agents in parallel
Task:
  subagent_type: devloop:engineer
  description: "Implement user model"
  run_in_background: true

Task:
  subagent_type: devloop:engineer
  description: "Implement product model"
  run_in_background: true

# Poll for results
TaskOutput(block=false)  # Non-blocking check
# Continue with other work while agents run

# Wait for completion when needed
TaskOutput(block=true)   # Blocking wait
```

**Best Practices**:
- Max 3-4 parallel agents (beyond this, coordination costs exceed benefits)
- Use for independent tasks (models, services, tests)
- Poll periodically with `TaskOutput(block=false)`
- Block only when no other work remains

**Example from `/devloop:continue`**:

```yaml
# Step 6: Handle Parallel Tasks
# If tasks marked [parallel:A]:

AskUserQuestion:
  question: "Tasks 2.1, 2.2, 2.3 can run in parallel. Run together?"
  options:
    - Run all in parallel (Recommended)
    - Run sequentially

# If parallel selected:
Task: devloop:engineer, description: "Task 2.1", run_in_background: true
Task: devloop:engineer, description: "Task 2.2", run_in_background: true
Task: devloop:engineer, description: "Task 2.3", run_in_background: true

# Poll and display progress
while agents_running:
  result = TaskOutput(block=false)
  if result:
    update_progress(result)
```

### Token Cost Awareness

Parallel agents increase token usage:

| Scenario | Token Cost | When to Use |
|----------|------------|-------------|
| 3x haiku agents | Low (~3k tokens) | Simple tasks (formatting, config) |
| 3x sonnet agents | Medium (~15k tokens) | Implementation, exploration |
| 3x opus agents | High (~60k tokens) | Avoid unless critical |

**Recommendation**: Use parallel execution for high-value gains (3-4 hours → 1 hour), not for marginal savings (30 min → 20 min).

---

## Skills

devloop provides 26 skills—domain knowledge that Claude automatically applies when relevant:

### Architecture & Design

| Skill | Trigger |
|-------|---------|
| `architecture-patterns` | Architecture decisions |
| `api-design` | API design work |
| `database-patterns` | Schema design, queries |

### Language-Specific Patterns

| Skill | Version | Focus |
|-------|---------|-------|
| `go-patterns` | Go 1.21+ | Interfaces, errors, goroutines, generics |
| `react-patterns` | React 18+ | Hooks, components, state, a11y |
| `java-patterns` | Java 17+ | Spring, records, streams, DI |
| `python-patterns` | Python 3.10+ | Type hints, async, pytest, match |

### Quality & Testing

| Skill | Purpose |
|-------|---------|
| `testing-strategies` | Test design and coverage |
| `security-checklist` | OWASP, auth, data protection |
| `deployment-readiness` | Pre-deploy validation |
| `refactoring-analysis` | Codebase analysis for technical debt |

### Workflow

| Skill | Purpose |
|-------|---------|
| `workflow-selection` | Choose the right workflow |
| `model-selection-guide` | When to use opus/sonnet/haiku |
| `complexity-estimation` | T-shirt sizing framework |
| `requirements-patterns` | Requirements gathering |
| `git-workflows` | Branching, commits, releases |
| `plan-management` | Plan file conventions |
| `worklog-management` | Worklog format and updates |
| `file-locations` | Where devloop files belong |
| `issue-tracking` | Unified issue management |
| `tool-usage-policy` | Tool selection and parallelization |
| `project-bootstrap` | New project setup from docs |

### Task Completion

| Skill | Purpose |
|-------|---------|
| `task-checkpoint` | Task completion checklist and verification |
| `atomic-commits` | Commit strategy and logical grouping |
| `version-management` | Semantic versioning and CHANGELOG management |

---

## Model Selection Strategy

devloop uses a **20/60/20 strategy** for token efficiency:

| Model | Usage | When |
|-------|-------|------|
| **opus** | 20% | High-stakes decisions, complex architecture |
| **sonnet** | 60% | Implementation, exploration, code review |
| **haiku** | 20% | Classification, checklists, simple tasks |

This is automatic. devloop selects the right model for each phase and agent.

---

## Plan Management

devloop saves plans to `.devloop/plan.md` so you can:

- **Resume later**: `/devloop:continue` picks up where you left off
- **Track progress**: Plans show completed/pending tasks
- **Hand off**: Share plans with teammates

```markdown
# Devloop Plan: User Authentication

**Status**: In Progress
**Current Phase**: Implementation

## Tasks
- [x] Task 1: Set up OAuth provider
- [~] Task 2: Implement login flow
- [ ] Task 3: Add session management
- [ ] Task 4: Write tests
```

---

## Consistency & Enforcement

devloop 1.10.0 introduces a consistency system that ensures plans stay in sync with actual work.

### Workflow Diagram

```
Task Complete → Plan Update (REQUIRED) → Commit Decision
                                              ↓
                        PreCommit Hook (verifies plan sync)
                                              ↓
                              Git Commit (proceeds)
                                              ↓
                        PostCommit Hook (updates worklog)
                                              ↓
                              Worklog Updated
```

### Key Components

| Component | Purpose |
|-----------|---------|
| **Plan** (`.devloop/plan.md`) | What's in progress |
| **Worklog** (`.devloop/worklog.md`) | What's done (with commits) |
| **Pre-commit hook** | Blocks if plan not updated |
| **Post-commit hook** | Auto-updates worklog |

### Enforcement Modes

Configure in `.devloop/local.md`:

```yaml
enforcement: advisory  # advisory (default) | strict
```

| Mode | Behavior |
|------|----------|
| **advisory** | Warns when plan is out of sync, allows override |
| **strict** | Blocks commits until plan is updated |

### Recovery Flows

`/devloop:continue` detects and offers recovery for:

- **Plan not updated**: Tasks marked complete without Progress Log entries
- **Uncommitted changes**: Code changes without corresponding commits
- **Worklog drift**: Plan entries not synced to worklog
- **Commits without tasks**: Work done outside the plan

### File Locations

```
.claude/
├── devloop-plan.md         # Active plan (git-tracked)
├── devloop-worklog.md      # Completed work (git-tracked)
├── devloop.local.md        # Local settings (NOT git-tracked)
├── project-context.json    # Tech cache (git-tracked)
├── issues/                 # Issue tracking (git-tracked)
└── security/               # Audit reports (NOT git-tracked)
```

See `Skill: file-locations` for complete documentation.

---

## Workflow Loop & Checkpoints

devloop v2.1 introduces a structured workflow loop that ensures reliable task completion:

### The Loop Pattern

```
┌──────────┐    ┌──────────┐    ┌───────────────┐
│  PLAN    │───▶│  WORK    │───▶│  CHECKPOINT   │
│(continue)│    │ (agent)  │    │  (mandatory)  │
└──────────┘    └──────────┘    └───────┬───────┘
     ▲                                   │
     │           ┌──────────────────────┼─────┐
     │           │                      ▼     │
     │           │  ┌────────┐    ┌─────────┐│
     │           │  │ COMMIT │◀───│ DECIDE  ││
     │           │  └────┬───┘    └────┬────┘│
     │           │       │             │     │
     │           │       ▼             ▼     │
     │           │  ┌─────────┐  ┌─────────┐│
     └───────────┼──│CONTINUE │  │  STOP   ││
                 │  │ (next)  │  │(summary)││
                 │  └─────────┘  └─────────┘│
                 └──────────────────────────┘
```

### Mandatory Checkpoints

After every task, `/devloop:continue` runs a mandatory checkpoint that:

1. **Verifies** agent output (success/failure/partial)
2. **Updates** plan markers (`[ ]` → `[x]` or `[~]`)
3. **Updates** worklog with pending entry
4. **Decides** next action with user:
   - **Commit now**: Create atomic commit for this work
   - **Continue working**: Group with related tasks before committing
   - **Fresh start**: Save state, clear context, resume in new session
   - **Stop here**: Generate summary and end session

### Checkpoint Examples

**Successful Completion**:
```yaml
# Task 2.1 complete: Implemented JWT token generation

AskUserQuestion:
  question: "Task 2.1 complete: Implemented JWT token generation. What's next?"
  header: "Checkpoint"
  options:
    - Continue to next task (Proceed to Task 2.2)
    - Commit this work (Create atomic commit)
    - Fresh start (Save state, clear context)
    - Stop here (Generate summary)

# User selects: Continue to next task
→ Task 2.1 marked [x] in plan
→ Worklog entry added: - [ ] Task 2.1: Implement JWT tokens (pending)
→ Loop continues to Task 2.2
```

**Partial Completion**:
```yaml
# Task 3.2 partially complete: Basic validation added, edge cases pending

AskUserQuestion:
  question: "Task 3.2 partially complete. Missing: edge case handling for null values. How proceed?"
  header: "Partial"
  options:
    - Mark done and continue (Accept current state)
    - Continue work on this task (Complete remaining criteria)
    - Note as tech debt (Mark blocked, track issue)
    - Fresh start (Clear context for focus)

# User selects: Continue work
→ Task 3.2 marked [~] in plan
→ Agent relaunches with context about missing edge cases
```

**Error Recovery**:
```yaml
# Task 4.1 failed: Database migration error

AskUserQuestion:
  question: "Task 4.1 failed: Migration error 'duplicate column'. How recover?"
  header: "Error"
  options:
    - Retry (Attempt again with adjusted approach)
    - Skip and mark blocked (Move to next task)
    - Investigate error (Show full error output)
    - Abort workflow (Stop and save state)

# User selects: Investigate
→ Display agent output and error details
→ User suggests fix
→ Retry with new approach
```

**Grouped Commit**:
```yaml
# Task 2.1, 2.2, 2.3 all complete (auth flow)

AskUserQuestion:
  question: "Tasks 2.1-2.3 complete (auth flow). Commit grouped?"
  header: "Commit"
  options:
    - Commit all together (Single atomic commit: "feat(auth): complete flow")
    - Commit individually (Three separate commits)
    - Review changes first (Show combined diff)

# User selects: Commit all together
→ Creates commit: feat(auth): implement authentication flow - Tasks 2.1, 2.2, 2.3
→ Worklog updated with commit hash for all three tasks
→ Loop continues to next phase
```

### Loop Completion Detection

When all tasks are complete, devloop:
- Auto-updates plan status to "Review" or "Complete"
- Offers options: Ship it, Review, Add more tasks, End session
- Handles edge cases (partial tasks, blocked tasks, archived phases)

**Completion Example**:
```yaml
# All 15 tasks complete

AskUserQuestion:
  question: "🎉 All plan tasks complete! What would you like to do?"
  header: "Complete"
  options:
    - Ship it (Run /devloop:ship for validation - Recommended)
    - Add more tasks (Extend the plan)
    - Review (Show completed work summary)
    - End session (Generate summary and finish)

# User selects: Ship it
→ Plan status updated to "Review"
→ Launches /devloop:ship workflow
→ Validates code, tests, docs
→ Creates PR or final commit
```

### Context Management

devloop tracks session metrics and suggests fresh starts when:

| Metric | Threshold | Action |
|--------|-----------|--------|
| Tasks completed | > 10 in session | Suggest fresh start |
| Agent invocations | > 15 in session | Context getting heavy |
| Session duration | > 2 hours active | Conversation likely stale |
| Estimated tokens | > 150k tokens | Context nearly full (Critical) |

**Context Warning Example**:
```markdown
⚠️ Context Health Warning

The following metrics suggest a fresh start may improve performance:
- 12 tasks completed in session
- 18 agent invocations
- Session running for 2.5 hours

Recommendations:
- Run /devloop:fresh to save state and clear context (Recommended)
- Continue anyway if close to completion
- Use /devloop:archive to compress plan if large

Would you like to continue or take action?
```

See `Skill: workflow-loop` and `Skill: task-checkpoint` for complete documentation.

---

## Fresh Start Feature

When context gets heavy, use `/devloop:fresh` to save state and resume with fresh context:

### How It Works

1. **Save**: `/devloop:fresh` saves current plan state to `.devloop/next-action.json`
2. **Clear**: Run `/clear` to reset conversation
3. **Resume**: Run `/devloop:continue` in new session - automatically detects saved state

### When to Use Fresh Start

- After completing 5-10 tasks in one session
- When conversation history is getting long
- Context feels slow or confused
- Suggested at checkpoint with "Fresh start" option

### Example

```bash
# After several tasks
/devloop:fresh

# Output shows:
# ✓ State saved to .devloop/next-action.json
# Last completed: Task 3.2
# Next up: Task 3.3
#
# To resume: /clear then /devloop:continue

# Clear context
/clear

# New session - automatically detects state
/devloop:continue

# Continues from Task 3.3 with fresh context
```

The SessionStart hook automatically detects saved state and displays a reminder.

---

## Parallel Task Execution

devloop can run independent tasks in parallel for faster feature development:

### Task Markers

Plans can include parallelism markers:

```markdown
### Phase 2: Core Implementation  [parallel:partial]
**Parallel Groups**:
- Group A: Tasks 2.1, 2.2 (independent implementations)

- [ ] Task 2.1: Create user model  [parallel:A]
- [ ] Task 2.2: Create product model  [parallel:A]
- [ ] Task 2.3: Create relationships  [depends:2.1,2.2]
```

| Marker | Meaning |
|--------|---------|
| `[parallel:X]` | Can run with other tasks in group X |
| `[depends:N.M]` | Must wait for task N.M to complete |
| `[background]` | Low priority, can run in background |
| `[sequential]` | Must run alone |

### How It Works

1. **Detection**: `/devloop:continue` detects tasks with matching `[parallel:X]` markers
2. **User Choice**: Asks if you want to run them together
3. **Parallel Execution**: Spawns agents for each task with `run_in_background: true`
4. **Progress Tracking**: Shows status as tasks complete
5. **Dependency Handling**: Only proceeds to dependent tasks when group completes

### Token Cost Awareness

Not all parallelism is free. Guidelines:
- **3x haiku agents**: Low cost, high benefit
- **3x sonnet agents**: Medium cost, evaluate need
- **3x opus agents**: High cost, usually avoid
- **Max 3-4 parallel agents**: Beyond this, coordination costs exceed benefits

---

## Issue Tracking

devloop includes a unified issue tracking system for bugs, features, tasks, chores, and spikes. Issues are stored in `.devloop/issues/` with type-prefixed IDs for quick identification.

### Issue Types

| Type | Prefix | When to Use |
|------|--------|-------------|
| Bug | BUG- | Something is broken |
| Feature | FEAT- | New functionality |
| Task | TASK- | Technical work, refactoring |
| Chore | CHORE- | Maintenance, dependencies |
| Spike | SPIKE- | Research, investigation |

### Commands

```bash
# Smart issue creation (auto-detects type)
/devloop:new Add dark mode support
/devloop:new Button doesn't work on mobile

# View all issues
/devloop:issues

# Filter by type
/devloop:issues bugs
/devloop:issues features
/devloop:issues backlog

# Filter by priority
/devloop:issues high

# Work on specific issue
/devloop:issues FEAT-001

# Legacy commands (still work)
/devloop:bug    # Quick bug creation
/devloop:bugs   # Bug-only view
```

### Smart Type Detection

`/devloop:new` analyzes your input to auto-detect issue type:

| Input Keywords | Detected Type |
|----------------|---------------|
| "broken", "error", "crash", "fix" | Bug |
| "add", "create", "implement", "new" | Feature |
| "refactor", "clean up", "optimize" | Task |
| "dependency", "upgrade", "config" | Chore |
| "investigate", "explore", "research" | Spike |

### Directory Structure

```
.devloop/issues/
├── index.md        # Master index (all issues)
├── bugs.md         # Bug-only view
├── features.md     # Feature-only view
├── backlog.md      # Open features + tasks
├── BUG-001.md      # Individual issue files
├── FEAT-001.md
└── TASK-001.md
```

### Migration from .devloop/issues/

If you have an existing `.devloop/issues/` directory, devloop will:
1. Detect it automatically
2. Offer to migrate to the unified system
3. Preserve all existing bug data with BUG- prefixes
4. Both systems can coexist during transition

See [Migration Guide](#migration-from-bugs-to-issues) below for details.

---

## Hooks

devloop includes automated hooks:

### SessionStart

Automatically detects and sets:
- `$FEATURE_DEV_PROJECT_LANGUAGE` - Primary language
- `$FEATURE_DEV_FRAMEWORK` - Framework (React, Spring, etc.)
- `$FEATURE_DEV_TEST_FRAMEWORK` - Test framework
- Shows plan progress if active plan exists
- Shows bug count if bugs tracked

### Statusline

Optional status bar showing:
- Current model
- Git branch
- Plan progress
- Bug count
- Context usage

Configure with `/devloop:statusline`.

---

## Migration from Bugs to Issues

If you have an existing `.devloop/issues/` directory and want to migrate to the unified issue system:

### Automatic Migration

1. Run `/devloop:issues` - it will detect `.devloop/issues/` and offer migration
2. Choose "Yes, migrate" when prompted
3. All bugs are copied to `.devloop/issues/` with `type: bug` added
4. Original `.devloop/issues/` is preserved (delete manually when ready)

### Manual Migration

```bash
# 1. Create issues directory
mkdir -p .devloop/issues

# 2. For each bug file, copy and add type field
# The migration adds: type: bug to frontmatter

# 3. Regenerate view files
# Run /devloop:issues to regenerate index.md, bugs.md, etc.

# 4. Verify migration worked
# Check .devloop/issues/ has all your bugs

# 5. (Optional) Remove old directory
rm -rf .devloop/issues/
```

### Coexistence Mode

During transition, both systems work:
- `/devloop:bug` creates in `.devloop/issues/` (preferred) or `.devloop/issues/` (fallback)
- `/devloop:bugs` checks both locations
- New issues always go to `.devloop/issues/`

---

## Best Practices

### Start with the Loop Pattern

For any non-trivial work, use the spike → fresh → continue loop:

```bash
# 1. Start with spike to create a plan
/devloop:spike [What you want to build]

# 2. Save and clear context
/devloop:fresh
/clear

# 3. Resume and work
/devloop:continue

# 4. After 5-10 tasks, repeat step 2-3
```

This pattern keeps context fresh and responses fast.

### Use the Right Command

| Situation | Command |
|-----------|---------|
| Starting any work | `/devloop:spike` then loop |
| Messy code, tech debt | `/devloop:analyze` |
| Small fix, clear scope | `/devloop:quick` |
| Unknown if possible | `/devloop:spike` |
| Ready to commit | `/devloop:ship` |
| Reviewing code | `/devloop:review` |
| Continuing work | `/devloop:continue` |
| Context heavy/long | `/devloop:fresh` + `/clear` |
| Track for later | `/devloop:new` |
| View/manage issues | `/devloop:issues` |

### Answer Clarifying Questions

Phase 4 asks questions to prevent confusion later. Take time to answer thoughtfully—it saves rework.

### Trust the Workflow

Each phase exists for a reason. Skipping exploration leads to wrong architecture. Skipping review leads to bugs. The workflow is designed from how senior engineers actually work.

### Use Plan Files

Save your plan. Resume later. Hand off to teammates. The plan file is your project's memory.

---

## Directory Structure

```
plugins/devloop/
├── .claude-plugin/
│   └── plugin.json           # Plugin manifest
├── agents/                   # 9 consolidated agents (v2.0)
│   ├── engineer.md           # Super-agent (4 modes)
│   ├── qa-engineer.md        # Super-agent (4 modes)
│   ├── task-planner.md       # Super-agent (4 modes)
│   ├── code-reviewer.md
│   ├── security-scanner.md
│   └── ...
├── commands/                 # 14 slash commands
│   ├── devloop.md
│   ├── quick.md
│   ├── continue.md
│   └── ...
├── hooks/                    # Event handlers
│   ├── hooks.json
│   └── session-start.sh
├── scripts/                  # Automation scripts
│   └── rotate-worklog.sh     # Worklog rotation (v2.0)
├── skills/                   # 28 domain skills
│   ├── INDEX.md              # Skill catalog (v2.0)
│   ├── go-patterns/
│   ├── react-patterns/
│   ├── architecture-patterns/
│   └── ...
├── statusline/               # Status bar script
│   └── devloop-statusline.sh
└── README.md
```

---

## Changelog

### 2.1.0 (Current)

**Workflow loop enforcement, fresh start mechanism, and engineer agent improvements.**

- **Workflow Loop**: Mandatory checkpoints after every task
  - Loop completion detection (5-state task counting)
  - Context management (6 session metrics with staleness thresholds)
  - Standardized 11 checkpoint questions across `/devloop:continue`
- **Fresh Start Mechanism**: Clear context while preserving progress
  - `/devloop:fresh` command saves state to `.devloop/next-action.json`
  - SessionStart hook detects and displays saved state
  - `/devloop:continue` auto-resumes from saved state
- **Engineer Agent Enhancements**:
  - Added 6 missing skills (complexity-estimation, project-context, api-design, database-patterns, testing-strategies)
  - Complexity-aware mode selection (simple/medium/complex)
  - Multi-mode task patterns with checkpoints
  - Token-conscious output formats (500/800/1000/200 token budgets per mode)
- **Skills & Documentation**:
  - Added `workflow-loop` skill (668 lines)
  - Created AskUserQuestion standards document (1,008 lines)
  - Enhanced `task-checkpoint` skill with mandatory worklog sync
- **Integration**:
  - Spike plan application (Phase 5b in `/devloop:spike`)
  - Removed unreliable SubagentStop hook
  - Applied AskUserQuestion standards to review.md and ship.md

See [CHANGELOG.md](./CHANGELOG.md) for complete details.

### 2.0.0

**Major architectural refactoring for reduced token usage and improved agent coordination.**

- **Agent Consolidation**: Reduced from 18 agents to 9 super-agents
  - `engineer` - Combines code-explorer, code-architect, refactor-analyzer, git-manager (4 modes)
  - `qa-engineer` - Combines test-generator, test-runner, bug-catcher, qa-agent (4 modes)
  - `task-planner` - Enhanced to absorb issue-manager, requirements-gatherer, dod-validator (4 modes)
- **XML Prompt Structure**: Core agents now use XML structure to prevent drift
  - Added `<system_role>`, `<capabilities>`, `<workflow_enforcement>` sections
  - Consistent `<thinking>` blocks for complex decisions
  - Mode detection with explicit routing rules
- **Dynamic Skill Loading**: Skills now load on-demand instead of all at startup
  - Added `skills/INDEX.md` as lightweight catalog
  - SessionStart references index, specific skills loaded when needed
  - Reduces initial context by ~50%
- **Automatic Worklog Rotation**: Prevents context bloat from large worklogs
  - Archives worklog when exceeding 500 lines
  - Runs automatically on session start
  - Archived to `.devloop/archive/worklog-YYYY-MM-DD.md`
- Updated documentation and agents.md for v2.0 architecture

### 1.10.0

- **Consistency & Enforcement System**: Plan and worklog synchronization with configurable enforcement
- Added worklog management (`devloop-worklog.md`) for completed work history with commits
- Added `file-locations` skill documenting all `.claude/` file locations and git tracking
- Added `worklog-management` skill for worklog format and update procedures
- Added `/devloop:worklog` command for viewing, syncing, and reconstructing worklog
- Added pre-commit hook to verify plan sync before commits
- Added post-commit hook to auto-update worklog after commits
- Added recovery flows in `/devloop:continue` for out-of-sync scenarios
- Added `.gitignore` template for devloop (`templates/gitignore-devloop`)
- Updated `devloop.local.md` template with enforcement settings
- Updated `task-checkpoint` skill with worklog integration
- Updated `summary-generator` to use worklog as source of truth
- Updated `plan-management` with enforcement hooks documentation
- Updated CLAUDE.md with `.claude/` directory structure guidance

### 1.9.0

- **Unified Issue Tracking**: New system supporting bugs, features, tasks, chores, and spikes
- Added `/devloop:new` command with smart type detection from keywords
- Added `/devloop:issues` command for viewing and managing all issue types
- Added `issue-manager` agent for creating any issue type
- Added `issue-tracking` skill with full schema and view generation rules
- Type-prefixed IDs: BUG-001, FEAT-001, TASK-001, CHORE-001, SPIKE-001
- Auto-generated view files: index.md, bugs.md, features.md, backlog.md
- Updated `workflow-detector` to route issue tracking requests
- Migration support from `.devloop/issues/` to unified `.devloop/issues/`
- Backwards compatibility: `/devloop:bug` and `/devloop:bugs` still work

### 1.8.0

- **Smart Parallel Task Execution**: Run independent tasks in parallel for faster development
- **Unified Plan Integration**: All commands and agents now consistently work from `.devloop/plan.md`
- Added parallelism markers: `[parallel:X]`, `[depends:N.M]`, `[background]`, `[sequential]`
- Updated `plan-management` skill with parallelism guidelines and token cost awareness
- Updated `/devloop:continue` to detect and spawn parallel task groups
- Updated `/devloop:spike` with mandatory plan integration and update recommendations
- Updated `/devloop:quick` to check for existing plans before starting
- Updated `/devloop` Phase 7 with parallel task detection
- Updated `task-planner` to generate parallelism annotations
- Updated `code-explorer`, `code-architect`, `code-reviewer` with plan update recommendations
- Updated `test-generator` with parallel execution awareness
- Updated `task-checkpoint` with parallel sibling detection
- Updated `atomic-commits` with parallel task grouping guidance

### 1.7.0

- **Task Completion Enforcement**: New checkpoint system ensures tasks are properly completed
- Added `task-checkpoint` skill for task completion verification
- Added `atomic-commits` skill for commit strategy guidance
- Added `version-management` skill for semantic versioning and CHANGELOG
- Updated `/devloop:continue` with task and phase completion checkpoints
- Updated `/devloop:ship` with version bumping and CHANGELOG generation
- Updated `/devloop:bootstrap` to include devloop workflow in generated CLAUDE.md
- Enhanced `git-manager` agent with task-linked commits
- Enhanced `summary-generator` agent with commit tracking
- Enhanced `dod-validator` agent with commit verification
- Updated `plan-management` skill with enforcement configuration
- Support for per-project enforcement modes (advisory/strict)
- Auto-detection of version bumps from conventional commits

### 1.6.0

- Added `/devloop:analyze` command for codebase refactoring analysis
- Added `refactor-analyzer` agent for identifying technical debt
- Added `refactoring-analysis` skill with analysis methodology
- Analysis findings can be converted directly to devloop plan tasks
- Merged functionality from retired `code-refactor-analyzer` plugin

### 1.5.0

- Added `/devloop:bootstrap` command for greenfield projects
- Added `project-bootstrap` skill for CLAUDE.md best practices
- Now supports starting projects from PRD/specs before any code exists
- Comprehensive documentation in `docs/` directory

### 1.4.0

- Added statusline integration (`/devloop:statusline`)
- Fixed JSON injection vulnerability in session-start hook
- Optimized language detection performance
- Updated test-generator, test-runner, doc-generator to sonnet
- Added "When NOT to Use" sections to all 17 skills
- Added version notes to language-specific skills
- Clarified qa-agent vs dod-validator responsibilities

### 1.3.0

- Added bug tracking system (`/devloop:bug`, `/devloop:bugs`)
- Added bug-catcher agent
- Added issue-tracking skill (unified bug/feature/task tracking)

### 1.2.0

- Added memory integration agents
- Added summary-generator agent
- Enhanced plan management

### 1.0.0

- Initial release
- 12-phase workflow
- Core agents and skills
- SessionStart hook

---

## Author

**Zate**
- GitHub: [@Zate](https://github.com/Zate)

Originally based on feature-dev by Sid Bidasaria (sbidasaria@anthropic.com)

---

## License

MIT License - See [LICENSE](LICENSE) for details.

---

## Support

- **Issues**: [GitHub Issues](https://github.com/Zate/cc-plugins/issues)
- **Discussions**: [GitHub Discussions](https://github.com/Zate/cc-plugins/discussions)

---

<p align="center">
  <strong>Ship features, not excuses.</strong>
</p>
