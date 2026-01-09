# Rovodev - Start New Work

**Use this when**: No plan exists, or you want to start fresh.

**Use `@continue` instead if**: A plan already exists at `.devloop/plan.md`.

Start a development workflow with minimal overhead for the Rovo Dev CLI project.

## Quick Start

1. **Check for existing work**:
   - If `.devloop/plan.md` exists → Ask: continue or start new?
   - If `.devloop/next-action.json` exists → Run `@continue`

2. **Understand the task**: 
   - If clear → proceed to planning
   - If unclear → ask ONE clarifying question

3. **Check git workflow config** (if `.devloop/local.md` exists):
   - Read `git.auto-branch` setting
   - If `true` and on main/master, offer to create feature branch

4. **Create feature branch** (if configured):
   Ask user if they want to create a feature branch:
   - Yes: Create `feat/[task-slug]` branch
   - No: Stay on current branch
   
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
   - [ ] Task 1: Description
   - [ ] Task 2: Description
   - [ ] Task 3: Description

   ## Progress Log
   - YYYY-MM-DD: Plan created
   ```

6. **Implement directly** - no subagents for routine work

7. **Checkpoint** after significant progress:
   - Summarize what was done
   - Update plan.md with completed tasks
   - Ask: "Continue or take a break?"

## Key Principles

1. **You do the work** - Don't spawn subagents for tasks you can do yourself
2. **Load context on demand** - Reference devloop skills when needed
3. **Minimal questions** - One question at a time
4. **Fast iteration** - Ship working code, then improve

## When to Use Subagents

Only spawn subagents for:
- **Genuinely parallel work** - Multiple independent tasks
- **Specialized analysis** - Security scanning, complex review
- **Large codebase exploration** - Understanding many files

Do NOT spawn subagents for:
- Writing code (do it yourself)
- Running tests (use bash)
- Git operations (use bash)
- Single-file changes
- Documentation updates

## Available Prompts

| Prompt | Purpose |
|--------|---------|
| `@rovodev` | Start new work (this prompt) |
| `@continue` | Resume from plan or fresh start |
| `@spike` | Time-boxed exploration |
| `@fresh` | Save state and exit cleanly |
| `@quick` | Small, well-defined fixes |
| `@review` | Code review |
| `@ship` | Commit and/or PR |

## Available Subagents

| Subagent | Purpose |
|----------|---------|
| `@task-planner` | Planning, requirements, DoD validation |
| `@engineer` | Code exploration, architecture, git ops |
| `@reviewer` | Code review and quality checks |
| `@doc-generator` | Documentation generation |

## Project Context: Rovo Dev CLI

This is a Python monorepo for the Atlassian Rovo Dev CLI:

- **Code style**: ruff (line length 120), pylint, pytest
- **Package manager**: uv (like poetry but faster)
- **Structure**: Multiple packages in `packages/` directory
- **Testing**: pytest with fixtures in conftest.py
- **Jira**: Softwareteams project "RDA" (Rovo Dev Agents)
- **Confluence**: https://hello.atlassian.net/wiki/spaces/AIDO/pages/5200169435/

### Common Commands

```bash
# Format check
uv run ruff format --check .
uv run ruff check --select I .

# Format apply
uv run ruff format .

# Tests
uv run pytest

# Package-specific
uv build --package atlassian-cli-rovodev
uv run --package atlassian-code-nautilus pytest
```

### Import Guidelines

- Put imports at the top of files by default
- Only use local imports if there's a measured performance benefit
- Add a comment explaining why local imports are needed

## Files

- `.devloop/plan.md` - Current task plan
- `.devloop/local.md` - Project settings (git workflow, etc.)
- `.devloop/next-action.json` - Fresh start state
- `.devloop/worklog.md` - Optional work history
- `.devloop/spikes/` - Spike reports

---

**Start now**: What would you like to build?
