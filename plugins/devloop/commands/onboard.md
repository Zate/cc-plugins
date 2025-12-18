---
description: Onboard an existing codebase to devloop - sets up .devloop/ directory and optionally migrates from .claude/
argument-hint: None required
allowed-tools: ["Read", "Write", "Edit", "Grep", "Glob", "Bash", "Task", "AskUserQuestion", "TodoWrite", "Skill", "WebFetch"]
---

# Devloop Onboard - Existing Codebase Setup

Set up devloop for an **existing codebase** that has never used devloop before, or migrate from the old `.claude/` structure to the new `.devloop/` structure.

## Purpose

Prepare an existing project for devloop by:
1. Analyzing the project's tech stack and structure
2. Creating the `.devloop/` directory structure
3. Optionally migrating existing `.claude/devloop-*` files
4. Optionally generating/enhancing CLAUDE.md
5. Optionally reconstructing worklog from git history

## When to Use

- **First time using devloop** on an existing codebase
- **Migrating from v1.10** (`.claude/` files) to v1.11+ (`.devloop/` structure)
- **Setting up a cloned repo** that was using devloop elsewhere
- **Adopting devloop** on a project that already has code and git history

## When NOT to Use

- **New project from docs**: Use `/devloop:bootstrap` instead
- **Already onboarded**: `.devloop/` directory exists and is set up
- **Quick start**: Just use `/devloop` directly - it will create minimal structure

---

## Workflow

### Phase 1: Project Analysis

**Goal**: Understand the current state of the project

**Actions**:

1. Create todo list for onboarding:
```
TodoWrite: [
  "Analyze project structure",
  "Set up .devloop/ directory",
  "Handle CLAUDE.md",
  "Reconstruct worklog (optional)",
  "Complete onboarding"
]
```

2. Gather project information from SessionStart context:
   - Language, framework, test framework
   - Project type (frontend/backend/CLI/library)
   - Git repository status

3. Check for existing devloop artifacts:
```bash
# Check for new .devloop/ structure
ls -la .devloop/ 2>/dev/null || echo "No .devloop/ directory"

# Check for legacy .claude/ devloop files
ls .claude/devloop-*.md .claude/issues/ .claude/bugs/ 2>/dev/null || echo "No legacy devloop files"

# Check for CLAUDE.md
ls CLAUDE.md 2>/dev/null || echo "No CLAUDE.md"
```

4. Present analysis:
```markdown
## Project Analysis

**Project**: [name]
**Tech Stack**: [language] / [framework]
**Test Framework**: [framework]
**Git Status**: [branch, uncommitted changes]

**Existing Devloop State**:
- `.devloop/` directory: [exists/missing]
- Legacy `.claude/devloop-*` files: [found/none]
- CLAUDE.md: [exists/missing]
- Git history: [N commits in last 30 days]
```

5. Determine onboarding path:
```
Use AskUserQuestion:
- question: "What would you like to set up?"
- header: "Setup"
- multiSelect: true
- options:
  - Create .devloop/ directory (Recommended) (Initialize devloop file structure)
  - Migrate from .claude/ (Move legacy devloop files to new location)
  - Generate/enhance CLAUDE.md (Create or improve project documentation)
  - Reconstruct worklog from git (Import commit history as work log)
```

---

### Phase 2: Directory Setup

**Goal**: Create the `.devloop/` directory structure

**Actions**:

1. If `.devloop/` doesn't exist:
```bash
mkdir -p .devloop/issues
mkdir -p .devloop/spikes
```

2. Create `plan.md` template (if not migrating):
```markdown
# Devloop Plan: [Project Name]

**Created**: [Date]
**Status**: Not Started
**Current Phase**: Setup

## Overview

[No active plan. Use `/devloop` to start a new feature or `/devloop:quick` for small tasks.]

## Tasks

(No tasks yet)

## Progress Log

- [Date]: Devloop initialized via /devloop:onboard
```

3. Create `local.md` from template:
   - Read template from plugin: `plugins/devloop/templates/devloop.local.md`
   - Write to `.devloop/local.md`
   - Ask about enforcement preference:
```
Use AskUserQuestion:
- question: "How strict should devloop enforcement be?"
- header: "Enforcement"
- options:
  - Advisory (Recommended) (Warn but don't block - good for getting started)
  - Strict (Block commits when plan is out of sync)
  - Disabled (No enforcement - rely on manual updates)
```

4. Create empty `issues/index.md`:
```markdown
# Issue Tracker

**Last Updated**: [Date]
**Open**: 0 | **In Progress**: 0 | **Done**: 0 | **Won't Do**: 0

## Open Issues by Priority

(No issues tracked yet)

---

*Commands: `/devloop:new` (create), `/devloop:issues` (manage)*
```

5. Update `.gitignore` if needed:
```bash
# Check if devloop patterns exist
grep -q ".devloop/local.md" .gitignore 2>/dev/null || echo "Need to add gitignore patterns"
```

If patterns missing, ask:
```
Use AskUserQuestion:
- question: "Add devloop patterns to .gitignore?"
- header: "Gitignore"
- options:
  - Yes (Recommended) (Add patterns for local.md and spikes/)
  - No (I'll manage gitignore manually)
```

If yes, append:
```gitignore
# Devloop local files (not tracked)
.devloop/local.md
.devloop/spikes/
```

---

### Phase 3: Migration (if selected)

**Goal**: Migrate legacy `.claude/devloop-*` files to `.devloop/`

**Condition**: Only run if user selected migration in Phase 1

**Actions**:

1. Identify files to migrate:
```bash
# List legacy devloop files
ls -la .claude/devloop-plan.md .claude/devloop-worklog.md .claude/devloop.local.md 2>/dev/null
ls -la .claude/issues/ 2>/dev/null
ls -la .claude/bugs/ 2>/dev/null
```

2. Present migration plan:
```markdown
## Files to Migrate

| Old Location | New Location |
|-------------|--------------|
| .claude/devloop-plan.md | .devloop/plan.md |
| .claude/devloop-worklog.md | .devloop/worklog.md |
| .claude/devloop.local.md | .devloop/local.md |
| .claude/issues/ | .devloop/issues/ |
| .claude/bugs/ | .devloop/issues/ (merged) |
```

3. Confirm migration:
```
Use AskUserQuestion:
- question: "Proceed with migration? (Original files will be kept as backup)"
- header: "Migrate"
- options:
  - Yes, migrate (Copy files to new locations)
  - No, skip (Keep using legacy locations)
```

4. If confirmed, execute migration:
```bash
# Copy files (don't delete originals yet)
cp .claude/devloop-plan.md .devloop/plan.md 2>/dev/null || true
cp .claude/devloop-worklog.md .devloop/worklog.md 2>/dev/null || true
cp .claude/devloop.local.md .devloop/local.md 2>/dev/null || true

# Copy issues directory
cp -r .claude/issues/* .devloop/issues/ 2>/dev/null || true

# If bugs/ exists separately, merge into issues/
if [ -d ".claude/bugs" ]; then
    cp .claude/bugs/*.md .devloop/issues/ 2>/dev/null || true
fi
```

5. Update internal links in migrated files:
   - Read each file
   - Replace `.claude/devloop-plan.md` → `.devloop/plan.md`
   - Replace `.claude/devloop-worklog.md` → `.devloop/worklog.md`
   - Replace `.claude/issues/` → `.devloop/issues/`
   - Write updated files

6. Report migration results:
```markdown
## Migration Complete

**Files migrated**: [N]
**Original files**: Preserved in `.claude/` (delete manually when ready)

To clean up old files:
\`\`\`bash
rm .claude/devloop-plan.md .claude/devloop-worklog.md .claude/devloop.local.md
rm -rf .claude/issues .claude/bugs
\`\`\`
```

---

### Phase 4: CLAUDE.md Enhancement (if selected)

**Goal**: Create or enhance CLAUDE.md with devloop-aware content

**Condition**: Only run if user selected CLAUDE.md setup in Phase 1

**Actions**:

1. If no CLAUDE.md exists:
   - Analyze codebase structure
   - Generate CLAUDE.md using project-bootstrap skill principles
   - Include devloop-specific sections

```markdown
# [Project Name]

[Auto-generated project description from analysis]

## Project Structure

[Key directories and their purposes]

## Development Workflow

This project uses **devloop** for structured development:

- `/devloop` - Start a new feature with full workflow
- `/devloop:quick` - Quick fixes and small changes
- `/devloop:review` - Code review before commits
- `/devloop:ship` - Commit and create PRs

### Devloop Files

- `.devloop/plan.md` - Active development plan
- `.devloop/worklog.md` - Completed work history
- `.devloop/issues/` - Issue tracking

## Getting Started

[Instructions for new developers]

## Testing

[Test commands and patterns]
```

2. If CLAUDE.md exists, offer to enhance:
```
Use AskUserQuestion:
- question: "CLAUDE.md exists. How should we handle it?"
- header: "CLAUDE.md"
- options:
  - Add devloop section (Recommended) (Append devloop workflow guidance)
  - Replace entirely (Generate new CLAUDE.md from analysis)
  - Skip (Leave CLAUDE.md unchanged)
```

3. If adding devloop section, append:
```markdown

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
```

---

### Phase 5: Worklog Reconstruction (if selected)

**Goal**: Build worklog from git history for context

**Condition**: Only run if user selected worklog reconstruction in Phase 1

**Actions**:

1. Delegate to worklog reconstruct logic:
```
Run the logic from /devloop:worklog reconstruct command:
- Ask for timeframe (30/90/all days)
- Parse git log for conventional commits
- Build worklog structure
- Write to .devloop/worklog.md
```

2. If worklog already exists (from migration):
```
Use AskUserQuestion:
- question: "Worklog exists from migration. How to handle?"
- header: "Worklog"
- options:
  - Keep migrated (Use worklog from .claude/)
  - Add history (Merge git history into existing)
  - Replace (Rebuild entirely from git)
```

---

### Phase 6: Completion

**Goal**: Summarize onboarding and suggest next steps

**Actions**:

1. Generate completion summary:
```markdown
## Onboarding Complete! 🎉

**Project**: [name]
**Devloop Version**: 1.11

### What Was Set Up

- [x] `.devloop/` directory structure created
- [x] Plan file initialized
- [x] Local configuration created
- [x] Issue tracker initialized
- [ ] CLAUDE.md [created/enhanced/skipped]
- [ ] Worklog [reconstructed/migrated/skipped]
- [ ] Migration from `.claude/` [completed/skipped]

### Next Steps

1. **Start a feature**: `/devloop Add [feature description]`
2. **Quick task**: `/devloop:quick Fix [issue]`
3. **Analyze codebase**: `/devloop:analyze` for refactoring opportunities
4. **Track an issue**: `/devloop:new [description]`

### Tips

- Use `/devloop:continue` to resume work after breaks
- Check `.devloop/local.md` to customize enforcement settings
- Run `/devloop:review` before committing major changes
```

2. Ask about immediate action:
```
Use AskUserQuestion:
- question: "What would you like to do now?"
- header: "Next"
- options:
  - Start a feature (Launch /devloop for a new feature)
  - Analyze codebase (Run /devloop:analyze for health check)
  - Track an issue (Create an issue with /devloop:new)
  - Done for now (Exit onboarding)
```

3. If user selects an action, suggest the appropriate command.

---

## Model Usage

| Phase | Model | Rationale |
|-------|-------|-----------|
| Analysis | haiku | Simple detection |
| Directory Setup | haiku | File operations |
| Migration | haiku | Copy operations |
| CLAUDE.md | sonnet | Content generation |
| Worklog | sonnet | Git parsing |
| Completion | haiku | Summary output |

---

## Error Handling

### Already Onboarded
If `.devloop/` exists with content:
```
Use AskUserQuestion:
- question: ".devloop/ already exists. What would you like to do?"
- header: "Exists"
- options:
  - Re-run setup (Recreate missing files only)
  - Force reset (Delete and recreate everything)
  - Cancel (Exit onboarding)
```

### Permission Issues
If can't create directories:
- Report error clearly
- Suggest checking file permissions
- Don't leave partial state

### Migration Conflicts
If files exist in both `.claude/` and `.devloop/`:
- Warn about potential overwrite
- Ask which to keep
- Never silently overwrite

---

## Skills Used

- `Skill: file-locations` - Canonical file paths
- `Skill: project-context` - Tech stack detection
- `Skill: project-bootstrap` - CLAUDE.md generation patterns
- `Skill: worklog-management` - Worklog format

---

## See Also

- `/devloop:bootstrap` - For new projects from documentation
- `/devloop:worklog reconstruct` - Standalone worklog reconstruction
- `/devloop:continue` - Resume work from existing plan
- `Skill: file-locations` - All devloop file locations
