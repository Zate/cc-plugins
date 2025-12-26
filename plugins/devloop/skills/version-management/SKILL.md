---
name: version-management
description: This skill should be used when the user asks about "version bump", "CHANGELOG", "semantic versioning", "release tag", or needs guidance on versioning and release management.
whenToUse: |
  - Completing a phase in the devloop plan
  - Shipping a feature with /devloop:ship
  - Determining what version bump is needed (major/minor/patch)
  - Updating CHANGELOG.md with release notes
  - Creating and pushing release tags
whenNotToUse: |
  - During active development - version at completion
  - Commit message formatting - use git-workflows
  - Minor internal changes that don't warrant a release
  - Projects that don't use semantic versioning
---

# Version Management Skill

Semantic versioning, CHANGELOG generation, and release management for devloop projects.

## When to Use This Skill

Use this skill when:
- Completing a phase in the devloop plan
- Shipping a feature with `/devloop:ship`
- Determining what version bump is needed
- Updating CHANGELOG.md
- Creating a release tag

## When NOT to Use This Skill

- During active development (version at completion)
- For commit message formatting (use `Skill: git-workflows`)
- For minor internal changes that don't warrant a release
- When project doesn't use semantic versioning

---

## Semantic Versioning

### Format: MAJOR.MINOR.PATCH

```
v1.2.3
│ │ └── PATCH: Bug fixes, minor changes (backwards compatible)
│ └──── MINOR: New features (backwards compatible)
└────── MAJOR: Breaking changes (not backwards compatible)
```

### Pre-release Versions
```
v1.0.0-alpha.1   # Early development
v1.0.0-beta.1    # Feature complete, testing
v1.0.0-rc.1      # Release candidate
```

---

## Auto-Detection from Conventional Commits

Parse commits since last version tag to determine the appropriate bump:

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

---

## Version File Locations

Check for and update these files (in order of preference):

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

# setup.py
setup(
    version="1.2.3",
)
```

### Go Projects
```go
// version.go
const Version = "1.2.3"

// Or in main.go
var version = "1.2.3"
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

---

## CHANGELOG Management

### Format: Keep a Changelog

Following [keepachangelog.com](https://keepachangelog.com/):

```markdown
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- New features that have been added

### Changed
- Changes in existing functionality

### Deprecated
- Features that will be removed in future versions

### Removed
- Features that have been removed

### Fixed
- Bug fixes

### Security
- Security vulnerability fixes

## [1.2.3] - 2024-12-13

### Added
- User authentication with JWT tokens (#42)
- Profile page with avatar upload (#45)

### Fixed
- Login redirect loop on expired sessions (#48)

## [1.2.2] - 2024-12-01

### Fixed
- Password reset email not sending (#40)
```

### Mapping Commits to CHANGELOG Sections

| Commit Type | CHANGELOG Section |
|-------------|-------------------|
| `feat:` | Added |
| `fix:` | Fixed |
| `perf:` | Changed |
| `refactor:` | Changed |
| `docs:` | (Usually not in CHANGELOG) |
| `BREAKING CHANGE:` | Changed (with migration note) |
| `deprecated:` | Deprecated |
| `security:` | Security |

### Auto-Generation Template
```markdown
## [X.Y.Z] - YYYY-MM-DD

### Added
{{#each feat_commits}}
- {{description}} {{#if issue}}(#{{issue}}){{/if}}
{{/each}}

### Changed
{{#each change_commits}}
- {{description}} {{#if issue}}(#{{issue}}){{/if}}
{{/each}}

### Fixed
{{#each fix_commits}}
- {{description}} {{#if issue}}(#{{issue}}){{/if}}
{{/each}}
```

---

## Version Bump Workflow

### At Phase Completion

```
When all tasks in a phase are [x] complete:

1. Collect commits for this phase:
   git log <phase-start-commit>..HEAD --oneline

2. Determine version bump from commits

3. Present to user:
   Use AskUserQuestion:
   - question: "Phase complete. Based on commits, suggest [MINOR] bump. Proceed?"
   - header: "Version"
   - options:
     - Accept suggested (Bump to v1.3.0)
     - Different bump (Let me choose)
     - Skip versioning (No version change now)
     - Custom version (Enter specific version)
```

### At Feature Ship

```
When running /devloop:ship:

1. Check if version bump is warranted
2. If yes, update version file(s)
3. Generate/update CHANGELOG entry
4. Commit version bump: "chore(release): bump version to v1.3.0"
5. Optionally create git tag
```

---

## Tagging

### Tag Creation
```bash
# Annotated tag (recommended)
git tag -a v1.2.3 -m "Release v1.2.3"

# Push tag
git push origin v1.2.3
```

### Tag Naming Convention
```
v1.2.3        # Standard release
v1.2.3-rc.1   # Release candidate
v1.2.3-beta.1 # Beta release
```

### When to Tag
- After version bump commit
- Before pushing to remote
- After CHANGELOG is updated

---

## Complete Release Workflow

### Step 1: Determine Version
```
1. Parse commits since last tag
2. Apply version bump rules
3. Calculate new version number
```

### Step 2: Update Version Files
```
1. Find version file(s) in project
2. Update version string
3. Stage changes
```

### Step 3: Update CHANGELOG
```
1. Check if CHANGELOG.md exists
2. If yes:
   - Parse commits into sections
   - Generate new version entry
   - Prepend to CHANGELOG.md
3. If no:
   - Ask user if they want to create one
```

### Step 4: Create Release Commit
```bash
git add -A
git commit -m "chore(release): v1.2.3

- Bump version to 1.2.3
- Update CHANGELOG.md"
```

### Step 5: Create Tag
```bash
git tag -a v1.2.3 -m "Release v1.2.3"
```

### Step 6: Update Plan
```
Add Progress Log entry:
- YYYY-MM-DD HH:MM: Released v1.2.3 - [summary of release]
```

---

## Project Configuration

In `.devloop/local.md`:

```yaml
---
auto_version: true      # Suggest version bumps automatically
version_file: package.json  # Primary version file location
changelog: true         # Maintain CHANGELOG.md
auto_tag: false         # Create git tags automatically (or prompt)
---
```

---

## Integration Points

This skill is used by:
- `/devloop:continue` - At phase completion
- `/devloop:ship` - Before shipping
- `Skill: task-checkpoint` - Phase completion checkpoint

References:
- `Skill: git-workflows` - Commit conventions
- `Skill: deployment-readiness` - Release checklist
- [Semantic Versioning 2.0.0](https://semver.org/)
- [Keep a Changelog](https://keepachangelog.com/)

---

## Quick Reference

### Version Bump Cheat Sheet
```
Breaking change?     → MAJOR (1.0.0 → 2.0.0)
New feature?         → MINOR (1.0.0 → 1.1.0)
Bug fix only?        → PATCH (1.0.0 → 1.0.1)
Docs/style/tests?    → No bump needed
```

### CHANGELOG Entry Template
```markdown
## [1.2.3] - 2024-12-13

### Added
- Feature description (#issue)

### Fixed
- Bug fix description (#issue)
```

### Release Commit Format
```
chore(release): v1.2.3

- Bump version to 1.2.3
- Update CHANGELOG.md
```
