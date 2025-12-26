# Semantic Versioning Guide

## Format: MAJOR.MINOR.PATCH

```
v1.2.3
│ │ └── PATCH: Bug fixes, minor changes (backwards compatible)
│ └──── MINOR: New features (backwards compatible)
└────── MAJOR: Breaking changes (not backwards compatible)
```

## Pre-release Versions

```
v1.0.0-alpha.1   # Early development
v1.0.0-beta.1    # Feature complete, testing
v1.0.0-rc.1      # Release candidate
```

## Auto-Detection from Conventional Commits

Parse commits since last version tag to determine the appropriate bump.

### Detection Command
```bash
# Get commits since last tag
git log $(git describe --tags --abbrev=0 2>/dev/null || echo "HEAD~50")..HEAD --oneline

# Or if no tags exist
git log --oneline -50
```

### Version Bump Rules

| Commit Type | Version Bump | Example |
|-------------|--------------|---------|
| `BREAKING CHANGE:` in footer | MAJOR | Breaking API changes |
| `feat!:` or `fix!:` (with `!`) | MAJOR | Breaking changes |
| `feat:` | MINOR | New features |
| `fix:` | PATCH | Bug fixes |
| `perf:` | PATCH | Performance improvements |
| `docs:` | None (or PATCH) | Documentation only |
| `style:` | None | Code style changes |
| `refactor:` | None (or PATCH) | Refactoring |
| `test:` | None | Test additions |
| `chore:` | None | Maintenance |
| `ci:` | None | CI changes |

### Priority (highest wins)
1. Any `BREAKING CHANGE` or `!` → MAJOR
2. Any `feat:` → MINOR
3. Any `fix:`, `perf:` → PATCH
4. Everything else → No bump required

### Auto-Detection Logic
```
function determineVersionBump(commits):
    hasBreaking = false
    hasFeature = false
    hasFix = false

    for commit in commits:
        if "BREAKING CHANGE:" in commit or "!:" in commit:
            hasBreaking = true
        if commit.startsWith("feat"):
            hasFeature = true
        if commit.startsWith("fix") or commit.startsWith("perf"):
            hasFix = true

    if hasBreaking:
        return "MAJOR"
    if hasFeature:
        return "MINOR"
    if hasFix:
        return "PATCH"
    return "NONE"
```

## Quick Reference

### Version Bump Cheat Sheet
```
Breaking change?     → MAJOR (1.0.0 → 2.0.0)
New feature?         → MINOR (1.0.0 → 1.1.0)
Bug fix only?        → PATCH (1.0.0 → 1.0.1)
Docs/style/tests?    → No bump needed
```

## Version File Locations

### JavaScript/TypeScript Projects
```json
// package.json
{
  "version": "1.2.3"
}
```

### Claude Code Plugins
```json
// .claude-plugin/plugin.json
{
  "version": "1.2.3"
}
```

### Python Projects
```python
# __version__.py or __init__.py
__version__ = "1.2.3"

# pyproject.toml
[project]
version = "1.2.3"
```

### Go Projects
```go
// version.go
const Version = "1.2.3"
```

### Rust Projects
```toml
# Cargo.toml
[package]
version = "1.2.3"
```

### Generic
```
# VERSION file
1.2.3
```
