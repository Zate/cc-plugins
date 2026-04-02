---
name: local-config
description: This skill should be used for configuring devloop project settings via .devloop/local.md, git workflow preferences, commit settings, review options
when_to_use: Configuring devloop settings, .devloop/local.md, project preferences
when_not_to_use: Regular development work, implementing features, exploring code
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
---
```

## Settings Reference

| Setting | Values | Default |
|---------|--------|---------|
| `git.auto-branch` | true/false | false |
| `git.branch-pattern` | Pattern with {slug}, {date}, {user} | feat/{slug} |
| `git.pr-on-complete` | ask/always/never | ask |
| `commits.style` | conventional/simple | conventional |
| `commits.sign` | true/false | false |
| `review.before-commit` | ask/always/never | ask |
| `review.use-plugin` | null/code-review/pr-review-toolkit | null |
| `github.link-issues` | true/false | false |
| `github.auto-close` | ask/always/never | ask |
| `github.comment-on-complete` | true/false | true |
| `fresh_threshold` | 5-50 | 10 |
| `context_threshold` | 50-95 | 70 |

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
