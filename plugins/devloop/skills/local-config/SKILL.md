---
name: local-config
description: This skill should be used for configuring devloop project settings via .devloop/local.md, git workflow preferences, commit settings, review options
when_to_use: Configuring devloop settings, .devloop/local.md, project preferences
---

# Local Configuration

Project-specific devloop settings via `.devloop/local.md` (NOT git-tracked).

## Format

YAML frontmatter followed by optional markdown notes:

```yaml
---
git:
  auto-branch: false           # Create branch when plan starts
  branch-pattern: "feat/{slug}" # {slug}, {date}, {user}
  main-branch: main
  pr-on-complete: ask          # ask | always | never
  worktree_isolation: false    # Isolate swarm workers in git worktrees (opt-in)

commits:
  style: conventional          # conventional | simple
  scope-from-plan: true
  sign: false

review:
  before-commit: ask           # ask | always | never
  use-plugin: null             # null | code-review | pr-review-toolkit

github:
  link-issues: false           # Enable GH issue linking
  auto-close: ask              # ask | always | never
  comment-on-complete: true

tokens:
  token_budget: 4000           # Max tokens for gather-task-context.sh output (default: 4000)
  cache_friendly_context: true # Order agent prompts for prompt cache hits (default: true)
---
```

## Settings Reference

| Setting | Values | Default |
|---------|--------|---------|
| `git.auto-branch` | true/false | false |
| `git.branch-pattern` | Pattern with {slug}, {date}, {user} | feat/{slug} |
| `git.pr-on-complete` | ask/always/never | ask |
| `git.worktree_isolation` | true/false | false |
| `commits.style` | conventional/simple | conventional |
| `commits.sign` | true/false | false |
| `review.before-commit` | ask/always/never | ask |
| `review.use-plugin` | null/code-review/pr-review-toolkit | null |
| `github.link-issues` | true/false | false |
| `github.auto-close` | ask/always/never | ask |
| `github.comment-on-complete` | true/false | true |
| `fresh_threshold` | 5-50 | 10 |
| `context_threshold` | 50-95 | 70 |
| `tokens.token_budget` | 1000-20000 | 4000 |
| `tokens.cache_friendly_context` | true/false | true |

## Example Configurations

### Minimal (Git-aware)

```yaml
---
git:
  auto-branch: true
---
```

### Full CI/CD Workflow

```yaml
---
git:
  auto-branch: true
  pr-on-complete: always
commits:
  style: conventional
  sign: true
review:
  before-commit: always
  use-plugin: pr-review-toolkit
---
```

### Issue-Driven Development

```yaml
---
git:
  auto-branch: true
  pr-on-complete: always
github:
  link-issues: true
  auto-close: always
  comment-on-complete: true
---
```

## Worktree Isolation

When running `/devloop:run-swarm` with many parallel tasks, you can enable git worktree
isolation so each worker operates in its own isolated branch. This prevents workers from
overwriting each other's in-progress changes.

```yaml
---
git:
  worktree_isolation: true   # Each swarm worker runs in an isolated git worktree
---
```

**Effect**: Equivalent to passing `--worktrees` to every `/devloop:run-swarm` invocation.
The orchestrator merges results back after each batch. Default is `false` — opt-in only.

**When to enable**:
- Large parallel plans (5+ concurrent workers) with overlapping file scopes
- You want maximum isolation between workers at the cost of slightly more git overhead

**When to leave off** (default):
- Most plans: workers are already assigned non-overlapping tasks
- Single-task or sequential plans
- Environments where git worktrees are not supported

## Context & Performance

```yaml
---
fresh_threshold: 10            # Tasks before suggesting /devloop:fresh (default: 10)
context_threshold: 70          # Exit ralph loop at this context % (default: 70)
---
```

| Setting | Values | Default | Description |
|---------|--------|---------|-------------|
| `fresh_threshold` | 5-50 | 10 | Tasks completed before suggesting a fresh restart. Set higher (20-30) for 1M context models. |
| `context_threshold` | 50-95 | 70 | Context usage % that triggers automatic ralph loop exit. |

## Token Efficiency

Control how devloop manages context size and prompt caching when spawning agents.

```yaml
---
tokens:
  token_budget: 4000           # Max tokens for context gathering (default: 4000)
  cache_friendly_context: true # Order agent prompts for prompt cache hits (default: true)
---
```

### token_budget

Passed as `--token-budget N` to `gather-task-context.sh`. The script estimates file sizes (~4 chars per token) and stops collecting files once the budget is reached. Files are prioritized:
1. Files directly mentioned in the task description (by name)
2. Files matching keywords in content or filename

**When to adjust**:
- **Lower (1000-2000)**: Fast swarm runs where many small tasks run in parallel; you want lean context per worker.
- **Default (4000)**: Standard single-task execution; balanced coverage.
- **Higher (8000-16000)**: Complex tasks spanning many files; you want more context per task. Increase `fresh_threshold` when raising this, as heavier context exhausts session budget faster.

### cache_friendly_context

When `true` (default), agent prompts are structured with static content first (instructions, phase name, project conventions) and dynamic content last (task description, gathered file contents). This maximizes Claude's prompt cache hit rate when multiple agents are spawned in the same session.

**Effect**: On the 2nd+ agent spawn in a parallel batch, the static prefix is already cached -- reducing latency and API cost. The first spawn always pays the full cost; subsequent spawns only pay for the dynamic suffix.

**When to disable**: If you are debugging agent prompt content and need to see the exact prompt structure without reordering, set `cache_friendly_context: false`. This has no other effect.

| Setting | Values | Default | Description |
|---------|--------|---------|-------------|
| `tokens.token_budget` | 1000-20000 | 4000 | Max tokens for `gather-task-context.sh`. Lower = faster/leaner; higher = more context. |
| `tokens.cache_friendly_context` | true/false | true | Put static prompt content first for cache hits. Disable only for debugging. |

## Plugin Integration

```yaml
---
plugins:
  superpowers-suggestions: false  # Disable seeAlso to superpowers skills
---
```

## Usage

- Edit `.devloop/local.md` directly; changes take effect on next command
- Parsed by `${CLAUDE_PLUGIN_ROOT}/scripts/parse-local-config.sh`
- Add to `.gitignore` to keep local-only
