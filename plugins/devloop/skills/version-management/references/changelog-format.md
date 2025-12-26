# CHANGELOG Format (Keep a Changelog)

Following [keepachangelog.com](https://keepachangelog.com/):

## Template

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

## Mapping Commits to CHANGELOG Sections

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

## Auto-Generation Template

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

## CHANGELOG Entry Template

```markdown
## [1.2.3] - 2024-12-13

### Added
- Feature description (#issue)

### Fixed
- Bug fix description (#issue)
```
