# Decision Rationale

## Why use .devloop/ instead of .claude/?

- **Clean separation**: Devloop files are separate from Claude Code's `.claude/` directory
- **Simple gitignore**: Just ignore `local.md` and `spikes/` - no complex patterns
- **Clear ownership**: `.devloop/` = devloop plugin, `.claude/` = Claude Code core
- **Easier maintenance**: No confusion with other Claude tools' files

## Why track the plan?

- **Team visibility**: Everyone sees what's being worked on
- **Context preservation**: New sessions can pick up where you left off
- **Audit trail**: History of what was planned (worklog shows what was done)

## Why NOT track local settings?

- **Personal preference**: Enforcement levels vary by person
- **Environment-specific**: May differ between machines
- **Avoid conflicts**: Prevents merge conflicts on preferences

## Why NOT track spike reports?

- **Working notes**: Not polished deliverables
- **Exploration**: May contain rejected ideas
- **Flow to plan**: Conclusions become plan tasks; report is transient
