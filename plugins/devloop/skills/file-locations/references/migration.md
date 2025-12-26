# Migration Guide

## From .claude/ to .devloop/ (v1.10.x → v1.11.x)

If you have existing devloop files in `.claude/`:

| Old Location | New Location |
|--------------|--------------|
| `.claude/devloop-plan.md` | `.devloop/plan.md` |
| `.claude/devloop-worklog.md` | `.devloop/worklog.md` |
| `.claude/devloop.local.md` | `.devloop/local.md` |
| `.claude/project-context.json` | `.devloop/context.json` |
| `.claude/issues/` | `.devloop/issues/` |
| `.claude/bugs/` | `.devloop/issues/` |
| `.claude/*-spike-report.md` | `.devloop/spikes/*.md` |

### Migration Process

1. Session-start hook detects old files and prompts for migration
2. User confirms via AskUserQuestion
3. Files are moved to new locations (content preserved)
4. Old files can be deleted after verification

### Backwards Compatibility

- v1.11.x reads from `.devloop/` first, falls back to `.claude/` paths
- v1.12.0+ will remove fallback (migrate before upgrading)

---

## From bugs/ to issues/

If you have existing `.claude/bugs/` files:

1. Files move to `.devloop/issues/` with prefix: `BUG-001.md`
2. `type: bug` added to frontmatter
3. View files (`index.md`, `bugs.md`) generated automatically

---

## New Project Setup

1. Run `/devloop` to create initial plan
2. `.devloop/` directory created automatically
3. Add `.devloop/local.md` and `.devloop/spikes/` to `.gitignore`
4. Context will be detected and cached automatically

---

## .gitignore Template

Add these patterns to your project's `.gitignore`:

```gitignore
# Devloop local files (do not commit)
.devloop/local.md
.devloop/spikes/
```

See also: `plugins/devloop/templates/gitignore-devloop` for a copy-paste template.
