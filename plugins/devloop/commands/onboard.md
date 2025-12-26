---
description: Onboard an existing codebase to devloop - sets up .devloop/ directory and optionally migrates from .claude/
argument-hint: None required
allowed-tools: ["Read", "Write", "Edit", "Grep", "Glob", "Bash", "Task", "AskUserQuestion", "TodoWrite", "Skill", "WebFetch"]
---

# Devloop Onboard - Existing Codebase Setup

Set up devloop for an **existing codebase** that has never used devloop before, or migrate from the old `.claude/` structure to the new `.devloop/` structure.

## When to Use

- **First time using devloop** on an existing codebase
- **Migrating from v1.10** (`.claude/` files) to v1.11+ (`.devloop/` structure)
- **Setting up a cloned repo** that was using devloop elsewhere

## When NOT to Use

- **New project from docs**: Use `/devloop:bootstrap` instead
- **Already onboarded**: `.devloop/` directory exists
- **Quick start**: Just use `/devloop` directly

---

## Templates

This command uses templates from `plugins/devloop/templates/onboard/`:

| Template | Purpose |
|----------|---------|
| `claudemd-template.md` | Default CLAUDE.md structure |
| `gitignore-devloop` | Git ignore patterns for .devloop/ |
| `directory-structure.txt` | Standard .devloop/ layout |
| `plan-template.md` | Empty plan.md template |
| `issues-index-template.md` | Empty issues index |
| `devloop-section.md` | Section to append to existing CLAUDE.md |

---

## Workflow

### Phase 1: Project Analysis

**Goal**: Understand current state

**Actions**:

1. Create todo list for onboarding
2. Gather project info from SessionStart context (language, framework, git status)
3. Check for existing devloop artifacts:
```bash
ls -la .devloop/ 2>/dev/null || echo "No .devloop/ directory"
ls .claude/devloop-*.md .claude/issues/ 2>/dev/null || echo "No legacy files"
ls CLAUDE.md 2>/dev/null || echo "No CLAUDE.md"
```

4. Present analysis and determine onboarding path:
```
Use AskUserQuestion:
- question: "What would you like to set up?"
- header: "Setup"
- multiSelect: true
- options:
  - Create .devloop/ directory (Recommended)
  - Migrate from .claude/
  - Generate/enhance CLAUDE.md
  - Reconstruct worklog from git
```

---

### Phase 2: Directory Setup

**Goal**: Create `.devloop/` structure

**Actions**:

1. Create directories:
```bash
mkdir -p .devloop/issues .devloop/spikes
```

2. Create plan.md from template:
   - Read: `plugins/devloop/templates/onboard/plan-template.md`
   - Replace `${PROJECT_NAME}` and `${DATE}` placeholders
   - Write to `.devloop/plan.md`

3. Create local.md from existing template:
   - Read: `plugins/devloop/templates/devloop.local.md`
   - Write to `.devloop/local.md`
   - Ask about enforcement preference (Advisory/Strict/Disabled)

4. Create issues/index.md from template:
   - Read: `plugins/devloop/templates/onboard/issues-index-template.md`
   - Replace `${DATE}` placeholder
   - Write to `.devloop/issues/index.md`

5. Update `.gitignore` if needed:
   - Check if devloop patterns exist
   - If missing, read `templates/onboard/gitignore-devloop`
   - Ask user, then append patterns

---

### Phase 3: Migration (if selected)

**Goal**: Migrate legacy `.claude/devloop-*` files

**Condition**: Only if user selected migration

**Actions**:

1. Identify files: `devloop-plan.md`, `devloop-worklog.md`, `devloop.local.md`, `issues/`, `bugs/`

2. Present migration plan (Old → New locations table)

3. Confirm, then execute:
```bash
cp .claude/devloop-plan.md .devloop/plan.md 2>/dev/null || true
cp .claude/devloop-worklog.md .devloop/worklog.md 2>/dev/null || true
cp .claude/devloop.local.md .devloop/local.md 2>/dev/null || true
cp -r .claude/issues/* .devloop/issues/ 2>/dev/null || true
cp .claude/bugs/*.md .devloop/issues/ 2>/dev/null || true
```

4. Update internal links in migrated files
5. Report results (files remain in `.claude/` as backup)

---

### Phase 4: CLAUDE.md Enhancement (if selected)

**Goal**: Create or enhance CLAUDE.md

**Condition**: Only if user selected CLAUDE.md setup

**Actions**:

1. **If no CLAUDE.md exists**:
   - Analyze codebase structure
   - Read `templates/onboard/claudemd-template.md`
   - Replace placeholders: `${PROJECT_NAME}`, `${PROJECT_DESCRIPTION}`, etc.
   - Write to `CLAUDE.md`

2. **If CLAUDE.md exists**, offer:
   - Add devloop section (read `templates/onboard/devloop-section.md`, append)
   - Replace entirely
   - Skip

---

### Phase 5: Worklog Reconstruction (if selected)

**Goal**: Build worklog from git history

**Condition**: Only if user selected worklog reconstruction

**Actions**: Delegate to `/devloop:worklog reconstruct` logic (timeframe selection, git parsing, write to `.devloop/worklog.md`)

---

### Phase 6: Completion

**Goal**: Summarize and suggest next steps

**Actions**:

1. Display completion summary with checkmarks for completed items
2. Suggest next steps: `/devloop`, `/devloop:quick`, `/devloop:analyze`, `/devloop:new`
3. Ask about immediate action

---

## Model Usage

| Phase | Model | Rationale |
|-------|-------|-----------|
| Analysis | haiku | Simple detection |
| Directory Setup | haiku | File operations |
| Migration | haiku | Copy operations |
| CLAUDE.md | sonnet | Content generation |
| Worklog | sonnet | Git parsing |

---

## Error Handling

| Scenario | Action |
|----------|--------|
| Already onboarded | Ask: Re-run/Force reset/Cancel |
| Permission issues | Report clearly, don't leave partial state |
| Migration conflicts | Warn, ask which to keep |

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
