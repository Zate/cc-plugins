---
name: cleanup
description: "This skill should be used when the user asks to \"clean up memory\", \"sync ctx and memory\", \"review memory\", \"deduplicate nodes\", \"fix memory conflicts\", \"ctx cleanup\", \"memory maintenance\", \"reconcile memory systems\", or mentions stale nodes, memory bloat, or keeping ctx and MEMORY.md in sync."
when_to_use: "Removing stale, redundant, or incorrect nodes from persistent memory"
user-invocable: true
argument-hint: "[project-name] [--global]"
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - Agent
  - AskUserQuestion
---

# ctx:cleanup — Memory Reconciliation

Reconcile Claude Code's built-in MEMORY.md system with the ctx knowledge graph. Detect duplicates, stale nodes, conflicts, and bloat across both systems, then resolve them with user approval.

## Arguments

- `$1` — Project name (optional, auto-detected from git)
- `--global` — Include all projects, not just the current one

## Execution Flow

This is a **phased command** — run each phase in order, presenting findings to the user between phases.

### Phase 1: Inventory

Gather the complete state of both memory systems.

**Actions:**

1. Detect the current project name from git (`basename $(git rev-parse --show-toplevel)`)
2. Run the analysis script to dump both systems:
   ```bash
   sh "${CLAUDE_SKILL_DIR}/scripts/analyze-sync.sh" "$PROJECT"
   ```
3. Read the MEMORY.md file for this project from `~/.claude/projects/` (search for directory matching project name)
4. Read any supplemental memory files (*.md besides MEMORY.md in the same directory)
5. Query ctx for all project-scoped nodes:
   ```bash
   ctx list --tag "project:$PROJECT" --format json
   ```
6. Query ctx for global nodes (no project tag or `project:global`):
   ```bash
   ctx list --tag "project:global" --format json
   ```

If `--global` was passed, also inventory all other projects:
- List all directories in `~/.claude/projects/*/memory/`
- List all unique `project:*` tags in ctx via `ctx tags`

Save the inventory mentally — it feeds all subsequent phases.

### Phase 2: Analysis

Analyze the inventory for seven categories of issues. For each issue found, record: the issue type, affected items (node IDs / MEMORY.md line numbers), severity (high/medium/low), and recommended action.

**Issue categories** (consult `references/sync-strategies.md` for detailed detection patterns):

1. **Cross-system duplicates** — Same knowledge in both MEMORY.md and ctx
   - Compare MEMORY.md content against pinned/working ctx nodes
   - Flag when semantically identical content exists in both
   - Severity: medium

2. **Intra-ctx duplicates** — Two+ ctx nodes with near-identical content
   - Compare node contents within the same project tag
   - Flag pairs with >80% content overlap
   - Severity: medium

3. **Stale working nodes** — `tier:working` nodes from completed tasks
   - Check creation date: working nodes older than 7 days are likely stale
   - Check content: completed sprints, resolved bugs, finished implementations
   - Severity: high (these auto-load every session, wasting tokens)

4. **Pinned tier bloat** — Too many pinned nodes consuming context budget
   - Count pinned nodes and total tokens
   - Flag if >20 nodes or >1,500 tokens
   - Identify pinned nodes that could be reference instead
   - Severity: medium

5. **Conflicts** — Contradictory information across systems
   - Compare related content in MEMORY.md vs ctx
   - Flag version numbers, rules, or conventions that disagree
   - Severity: high

6. **Orphaned content** — Knowledge for projects that no longer exist or are inactive
   - Cross-reference project tags against actual project directories
   - Flag nodes for projects with no matching directory
   - Severity: low

7. **Missing structure** — Nodes without tier tags, without project tags, or with empty content
   - Query for nodes missing expected tags
   - Severity: low

### Phase 3: Report

Present findings to the user in a structured report. Group by severity (high first).

**Report format:**

```
## Memory Sync Report — [project]

### Token Budget
- MEMORY.md: ~X tokens (Y lines)
- ctx pinned: X tokens (Y nodes)
- ctx working: X tokens (Y nodes)
- Total auto-loaded: X tokens

### Issues Found

#### HIGH: Stale Working Nodes (N found)
| Node ID | Content Preview | Created | Recommendation |
|---------|----------------|---------|----------------|
| 01KK... | Sprint complete... | Mar 15 | -> tier:reference |

#### MEDIUM: Cross-System Duplicates (N found)
| MEMORY.md Line | ctx Node | Content | Recommendation |
|---------------|----------|---------|----------------|
| L5-7 | 01KH... | Release rules | Remove from MEMORY.md |

... (all categories)

### Summary
- X issues found (Y high, Z medium, W low)
- Estimated token savings: ~N tokens
```

**MANDATORY**: After presenting the report, MUST use the `AskUserQuestion` tool (not plain text) to ask how to proceed. Use this exact configuration:

- question: "How would you like to proceed with the N issues found?"
- header: "Remediation"
- options:
  1. label: "Auto-fix all (Recommended)", description: "Apply all recommendations automatically"
  2. label: "Review each", description: "Walk through issues one by one for approval"
  3. label: "Fix high-severity only", description: "Auto-fix HIGH issues, skip medium and low"
  4. label: "Skip", description: "Just show the report, don't change anything"

Do NOT proceed to Phase 4 without this user response. Do NOT present these options as text — use the AskUserQuestion tool.

### Phase 4: Remediation

Execute approved fixes. For each fix, use the appropriate mechanism:

**ctx node actions:**
- **Demote tier**: `ctx tag <id> tier:reference && ctx untag <id> tier:working`
- **Archive**: `ctx tag <id> tier:off-context && ctx untag <id> tier:working`
- **Delete**: `ctx delete <id>` (only for true duplicates or empty nodes)
- **Supersede**: Emit `<ctx:supersede old="ID1" new="ID2"/>` when one node replaces another
- **Add missing tags**: `ctx tag <id> project:name` or `ctx tag <id> tier:reference`

**MEMORY.md actions:**
- **Remove duplicate lines**: Edit the MEMORY.md file to remove lines that duplicate ctx content
- **Add missing content**: Write new entries to MEMORY.md for project conventions not in ctx
- **Update stale content**: Edit outdated information in MEMORY.md

**Cross-system actions:**
- **Migrate to ctx**: Remove from MEMORY.md, store in ctx with proper type/tags
- **Migrate to MEMORY.md**: Archive ctx node, add concise version to MEMORY.md
- **Consolidate duplicates**: Supersede in ctx, clean MEMORY.md reference

After each batch of fixes, show a summary of what changed.

### Phase 5: Verification

After remediation:

1. Run `ctx status` to show the new state
2. Read the updated MEMORY.md
3. Show before/after comparison:
   - Total auto-loaded tokens: before -> after
   - Node counts by tier: before -> after
   - MEMORY.md line count: before -> after
4. Flag any remaining issues

## Sync Maintenance Advice

After cleanup, advise the user on keeping systems in sync:

1. **The using-ctx skill already handles this** — it instructs the agent to cross-check before writing to either system. If the user feels drift is happening, the skill instructions may need strengthening.

2. **Periodic cleanup** — Run `/ctx:cleanup` quarterly or when starting major new work.

3. **Hook option** — For persistent drift, a PostToolUse hook on MEMORY.md writes can enforce cross-checking. See `references/sync-strategies.md` for the hook design. Only recommend this if the user reports ongoing issues after multiple cleanups.

## Additional Resources

### Reference Files
- **`references/sync-strategies.md`** — Detailed sync strategies, division of labor rules, issue detection patterns, token budget guidelines, and hook-based sync design

### Scripts
- **`scripts/analyze-sync.sh`** — Dumps both memory systems for comparison (run with project name argument)
