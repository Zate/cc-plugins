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

- Completing a phase in the devloop plan
- Shipping a feature with `/devloop:ship`
- Determining what version bump is needed
- Updating CHANGELOG.md
- Creating a release tag

## When NOT to Use This Skill

- During active development (version at completion)
- For commit message formatting (use `Skill: git-workflows`)
- For minor internal changes that don't warrant a release

---

## Quick Reference

### Version Bump Cheat Sheet

```
Breaking change?     → MAJOR (1.0.0 → 2.0.0)
New feature?         → MINOR (1.0.0 → 1.1.0)
Bug fix only?        → PATCH (1.0.0 → 1.0.1)
Docs/style/tests?    → No bump needed
```

### Version Format

```
v1.2.3
│ │ └── PATCH: Bug fixes (backwards compatible)
│ └──── MINOR: New features (backwards compatible)
└────── MAJOR: Breaking changes
```

### Commit Type to Version Bump

| Commit Type | Version Bump |
|-------------|--------------|
| `BREAKING CHANGE:` or `!` | MAJOR |
| `feat:` | MINOR |
| `fix:`, `perf:` | PATCH |
| `docs:`, `style:`, `test:`, `chore:` | None |

---

## References

For detailed guidance on specific topics, load these references:

| Reference | Content |
|-----------|---------|
| `references/semver-guide.md` | Semantic versioning rules, auto-detection logic, version file locations |
| `references/changelog-format.md` | Keep a Changelog format, commit-to-section mapping, templates |
| `references/release-workflow.md` | Step-by-step release process, tagging, project configuration |

### Loading References

```
Read: plugins/devloop/skills/version-management/references/semver-guide.md
Read: plugins/devloop/skills/version-management/references/changelog-format.md
Read: plugins/devloop/skills/version-management/references/release-workflow.md
```

---

## Version Bump Detection

```bash
# Get commits since last tag
git log $(git describe --tags --abbrev=0 2>/dev/null || echo "HEAD~50")..HEAD --oneline
```

**Priority (highest wins):**
1. Any `BREAKING CHANGE` or `!` → MAJOR
2. Any `feat:` → MINOR
3. Any `fix:`, `perf:` → PATCH
4. Everything else → No bump required

---

## CHANGELOG Entry Template

```markdown
## [1.2.3] - 2024-12-13

### Added
- Feature description (#issue)

### Fixed
- Bug fix description (#issue)
```

---

## Release Commit Format

```
chore(release): v1.2.3

- Bump version to 1.2.3
- Update CHANGELOG.md
```

---

## Integration Points

This skill is used by:
- `/devloop:continue` - At phase completion
- `/devloop:ship` - Before shipping
- `Skill: task-checkpoint` - Phase completion checkpoint

Related:
- `Skill: git-workflows` - Commit conventions
- `Skill: deployment-readiness` - Release checklist
- [Semantic Versioning 2.0.0](https://semver.org/)
- [Keep a Changelog](https://keepachangelog.com/)
