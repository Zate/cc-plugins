## Spike Report: Existing Codebase Onboarding for Devloop

**Spike ID**: SPIKE-001
**Timebox**: 2 hours
**Date**: 2025-12-18
**Status**: Complete

### Questions Investigated

1. **Should we enhance `/devloop:bootstrap` or create `/devloop:migrate`?** → Create NEW `/devloop:onboard` command
2. **What components are needed?** → 1 command, 1 agent, 0 new skills (reuse existing)
3. **Can we reuse existing components?** → Yes, heavily
4. **What migration patterns exist?** → bugs→issues migration is a good template

### Findings

#### Feasibility
**Yes** - The existing devloop architecture has all the building blocks needed.

#### Architecture Analysis

##### Current Commands Matrix

| Scenario | Current Command | Purpose |
|----------|-----------------|---------|
| New project from docs (PRD) | `/devloop:bootstrap` | Generate CLAUDE.md from specs |
| New project no docs | `/devloop` | Start from scratch with questions |
| Existing code, need CLAUDE.md | `/init` (built-in) | Claude Code's init command |
| Existing code, need devloop | **MISSING** | Onboard to devloop workflow |

##### Gap Identified

The missing scenario is: **"I have an existing codebase with its own plans, tasks, docs - help me work with devloop"**

This is NOT the same as:
- `/devloop:bootstrap` - which is for NEW projects with documentation artifacts
- `/init` - which generates CLAUDE.md but doesn't understand devloop

#### Recommended Approach

**Create NEW command: `/devloop:onboard`**

Rationale:
1. Clear separation of concerns:
   - `bootstrap` = new project from docs (greenfield)
   - `onboard` = existing codebase migration (brownfield)
2. Different workflows require different UX
3. Avoids overloading bootstrap with detection logic
4. User intent is clear from command name

#### Alternative Considered: Enhance `/devloop:bootstrap`

Pros:
- Single entry point
- Could auto-detect existing code

Cons:
- Clutters bootstrap with detection logic
- Different user expectations
- Bootstrap is about "start fresh", onboard is "join existing"
- Would need complex mode switching

**Verdict**: Rejected - separation is cleaner

### Component Design

#### New Command: `/devloop:onboard`

```
plugins/devloop/commands/onboard.md
```

**Purpose**: Onboard an existing codebase to devloop workflow

**Phases**:

1. **Discovery Phase**
   - Detect project type (project-context skill)
   - Find existing documentation (README, docs/, ARCHITECTURE.md)
   - Find existing plans (PROJECT.md, TODO.md, ROADMAP.md, GitHub Projects)
   - Find existing tasks (TODO comments, GitHub issues)
   - Detect existing conventions (CLAUDE.md, .claude/ directory)

2. **Analysis Phase**
   - Launch code-explorer agent for architecture understanding
   - Use complexity-estimator to gauge project size
   - Identify key directories and entry points

3. **Migration Phase**
   - Migrate discovered plans → `.claude/devloop-plan.md`
   - Migrate tasks → `.claude/issues/`
   - Preserve or enhance existing CLAUDE.md
   - Set up `.claude/` directory structure

4. **Setup Phase**
   - Generate/update project-context.json
   - Create initial plan if none migrated
   - Guide user to next steps

5. **Next Steps**
   - If plan exists: suggest `/devloop:continue`
   - If no plan: suggest `/devloop:spike` or `/devloop:new`

#### New Agent: `onboard-analyzer`

```
plugins/devloop/agents/onboard-analyzer.md
```

**Purpose**: Deep analysis of existing codebase for onboarding

**Tools**: Glob, Grep, Read, AskUserQuestion, TodoWrite

**Capabilities**:
- Detect project management artifacts (various formats)
- Parse and normalize different plan formats
- Identify documentation structure
- Find TODO/FIXME comments as potential issues
- Assess codebase health/conventions

#### Reusable Components

| Component | Use Case in Onboarding |
|-----------|------------------------|
| `code-explorer` agent | Architecture understanding |
| `project-context` skill | Tech stack detection |
| `complexity-estimator` agent | Project size assessment |
| `issue-manager` agent | Creating issues from TODOs |
| bugs→issues migration pattern | Template for file migration |

### Migration Format Mapping

#### Plans/Roadmaps

| Source Format | Detection | Migration |
|---------------|-----------|-----------|
| `PROJECT.md` | Glob for common names | Parse markdown, extract tasks |
| `TODO.md` | Glob | Convert checkboxes to plan tasks |
| `ROADMAP.md` | Glob | Extract phases and milestones |
| GitHub Project | gh CLI | Pull items via API |
| Linear/Jira | Ask user | Manual import or API |
| `.todo` files | Glob `**/*.todo` | Parse todo format |

#### Tasks/Issues

| Source | Detection | Migration |
|--------|-----------|-----------|
| `TODO:` comments | Grep | Create issues with file context |
| `FIXME:` comments | Grep | Create BUG issues |
| `HACK:` comments | Grep | Create TASK issues (tech debt) |
| GitHub Issues | gh CLI | Import as issues |
| `.claude/bugs/` | Directory check | Migrate to `.claude/issues/` |

### Complexity Estimate

- **Size**: M (Medium - 2-3 days)
- **Risk**: Low (builds on existing patterns)
- **Confidence**: High

### Key Discoveries

1. **Migration pattern exists**: The bugs→issues migration in `/devloop:issues` is a perfect template
2. **Detection is easy**: project-context skill already handles tech detection
3. **code-explorer is powerful**: Can understand architecture without new code
4. **Phase pattern works**: Discovery → Analysis → Migration → Setup aligns with devloop UX

### Risks & Concerns

1. **Over-migration**: Might create duplicate issues from TODO comments
   - Mitigation: Preview mode, user confirmation before creating issues

2. **Plan format diversity**: Many ways to write plans
   - Mitigation: Support common formats, fallback to manual entry

3. **Destructive migration**: Could overwrite existing work
   - Mitigation: Backup detection, preview of changes, dry-run mode

4. **Large codebases**: TODO scanning could find thousands of items
   - Mitigation: Limit scope, prioritization, batch processing

### Recommendation

**Proceed with implementation**

1. Create `/devloop:onboard` command (primary interface)
2. Create `onboard-analyzer` agent (discovery and analysis)
3. Add onboard skill for format mappings (optional, could be inline)
4. Update README with onboarding documentation

### Implementation Order

1. **Phase 1**: Basic onboarding (CLAUDE.md, .claude/ setup, project-context)
2. **Phase 2**: Plan migration (detect and convert common formats)
3. **Phase 3**: Issue migration (TODO comments, GitHub issues)
4. **Phase 4**: Advanced detection (Linear, Jira, etc.)

### Plan Updates Required

**Existing Plan**: Devloop Plan: Consistency & Enforcement System
**Relationship**: New work (not related to current plan)

#### Recommended Changes

- [ ] Create new plan for onboarding feature after current plan is complete
- [ ] Consider this as v1.11.0 release candidate
- [ ] Add to plugin README under "Getting Started" section

### Files to Create/Modify

#### New Files
- `plugins/devloop/commands/onboard.md` - Main command
- `plugins/devloop/agents/onboard-analyzer.md` - Discovery agent

#### Modify
- `plugins/devloop/README.md` - Add onboarding documentation
- `plugins/devloop/docs/commands.md` - Document new command
- `plugins/devloop/.claude-plugin/plugin.json` - Version bump

### Related Issues

- SPIKE-001: This spike (completing)
- TASK-001: File consolidation (.claude/devloop/) - should be done FIRST
- FEAT-001: Form-like issue creation (independent)

### Note on TASK-001 (File Consolidation)

**Recommendation**: Complete TASK-001 before implementing onboarding.

If we're moving to `.claude/devloop/` structure, the onboard command should use the new paths from the start. Implementing onboarding with old paths and then migrating would be wasteful.

**Order**:
1. TASK-001: Consolidate to .claude/devloop/
2. Onboarding feature: Build with new paths
