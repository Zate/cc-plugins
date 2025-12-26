## Devloop Workflow

This project uses **devloop** for structured development.

### Commands

| Command | Purpose |
|---------|---------|
| `/devloop` | New features with full workflow |
| `/devloop:quick` | Small fixes and changes |
| `/devloop:continue` | Resume existing plan |
| `/devloop:review` | Code review |
| `/devloop:ship` | Commit and PR |

### Files

| File | Purpose | Git Tracked |
|------|---------|-------------|
| `.devloop/plan.md` | Active plan | Yes |
| `.devloop/worklog.md` | Work history | Yes |
| `.devloop/local.md` | Local settings | No |
| `.devloop/issues/` | Issue tracking | Yes |
