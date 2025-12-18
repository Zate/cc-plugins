## Spike Report: Unified Issue Tracking (Bugs + Features + Backlog)

### Questions Investigated
1. Should we extend bugs to support more types? → **Yes, with a unified "issues" system**
2. Should we create a separate backlog system? → **No, unified is better**
3. How should `/devloop:new` work? → **Smart routing based on input analysis**

### Findings

#### Feasibility
**Yes** - The existing bugs infrastructure is well-designed and can be extended.

#### Recommended Approach
**Approach C: Unified Issues with Type-Based Views**

Keep a single `.claude/issues/` system with:
- `type` field in frontmatter (bug, feature, task, chore, spike)
- Type-based ID prefixes (BUG-001, FEAT-001, TASK-001)
- Auto-generated view files for filtered lists
- Smart `/devloop:new` command for intelligent routing

#### Complexity Estimate
- **Size**: M (Medium)
- **Risk**: Low
- **Confidence**: High

The implementation is straightforward:
1. Create new directory structure with views
2. Add `type` field to frontmatter schema
3. Create `/devloop:new` command with smart routing
4. Create/update agents for issue management
5. Optional: Add migration path for existing `.claude/bugs/`

#### Key Discoveries

1. **Current bugs skill explicitly excludes feature requests** - This validates the need for a broader system

2. **Tags already exist** - We can use `type` as a special first-class field, not a tag, since types affect routing and ID prefixes

3. **GitHub Issues model works well** - Single system, type-based labels, simple mental model

4. **ID prefixes are powerful** - BUG-001 vs FEAT-001 gives immediate context, can coexist in same system

5. **Views solve the "crowded index" problem** - Auto-generated `bugs.md`, `features.md` files let users focus

#### Proposed Schema

```yaml
---
id: FEAT-001                    # Type-prefixed ID
type: feature                   # bug | feature | task | chore | spike
title: User authentication flow
status: open                    # open | in-progress | done | wont-do
priority: high                  # low | medium | high | critical
created: 2024-12-18T10:00:00
updated: 2024-12-18T10:00:00
reporter: user
assignee: null                  # optional, for tracking
labels: [auth, mvp]             # renamed from tags for GitHub familiarity
related-files:
  - src/auth/
related-plan-task: Task 2.3     # optional link to devloop plan
estimate: M                     # optional T-shirt size
---
```

#### Proposed Directory Structure

```
.claude/issues/
├── index.md          # Master index (all issues)
├── bugs.md           # View: only type:bug
├── features.md       # View: only type:feature
├── backlog.md        # View: open features + tasks (the "backlog")
├── BUG-001.md
├── BUG-002.md
├── FEAT-001.md
├── FEAT-002.md
├── TASK-001.md
└── ...
```

#### Proposed Commands

| Command | Purpose |
|---------|---------|
| `/devloop:new` | Smart issue creation - analyzes input, routes to correct type |
| `/devloop:issues` | View all issues (replaces and extends `/devloop:bugs`) |
| `/devloop:backlog` | View open features/tasks (the backlog view) |

**Deprecation path**: Keep `/devloop:bug` and `/devloop:bugs` as aliases initially.

#### Smart Routing Logic for `/devloop:new`

The agent should analyze user input and route based on keywords:

| Input Pattern | Detected Type |
|--------------|---------------|
| "bug", "broken", "doesn't work", "error", "crash" | bug |
| "add", "new feature", "implement", "create", "build" | feature |
| "refactor", "clean up", "improve", "optimize" | task/chore |
| "investigate", "explore", "research", "spike" | spike |
| Multiple items (numbered list) | Multiple issues, ask for confirmation |

After detection:
1. Show detected type to user
2. Ask for confirmation or allow override
3. Create issue(s) with appropriate prefix

#### Risks & Concerns

1. **Migration complexity** - Existing `.claude/bugs/` needs migration path
   - Mitigation: Support both locations during transition, provide migration script

2. **Command proliferation** - Too many commands to remember
   - Mitigation: `/devloop:new` as single entry point, others are specialized views

3. **Index maintenance** - Views need to stay in sync
   - Mitigation: Regenerate views on any issue change (agent responsibility)

### Recommendation

**Proceed with Approach C (Unified Issues with Type-Based Views)**

This gives us:
- GitHub-like simplicity (everything is an "issue")
- Type-based prefixes for quick identification
- Smart `/devloop:new` for easy creation
- Focused views for different workflows
- Clean migration path from existing bugs

### Prototype Location

No prototype code created (30-minute timebox). Implementation is straightforward based on existing bugs infrastructure.

### Next Steps

If proceeding:
1. Create `.claude/issues/` directory structure
2. Define issue types and their ID prefix scheme
3. Implement `/devloop:new` command with smart routing
4. Implement `/devloop:issues` command (extension of `/devloop:bugs`)
5. Create `issue-tracker` skill (extension of `bug-tracking` skill)
6. Create `issue-manager` agent (extension of `bug-catcher` agent)
7. Add migration guide for existing `.claude/bugs/` directories
8. Update documentation

### Plan Updates Required
**Existing Plan**: None
**Relationship**: New work

#### Recommended Changes
- [ ] Create new plan for "Unified Issue Tracking" feature
- [ ] Parallel tasks: Commands (new, issues) and Skills (issue-tracker) can be developed together
