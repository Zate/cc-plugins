# Memory Sync Strategies

## System Architecture

Two persistent memory systems operate in parallel:

### MEMORY.md (Claude Code built-in)
- **Location**: `~/.claude/projects/<project-hash>/memory/MEMORY.md`
- **Scope**: Project-only
- **Auto-loaded**: Yes (first 200 lines, every session)
- **Queryable**: No
- **Format**: Free-form markdown
- **Best for**: Short conventions, release rules, quick reminders, project-specific gotchas

### ctx (Knowledge Graph)
- **Location**: `~/.ctx/store.db` (SQLite)
- **Scope**: Cross-project (filtered by project tags)
- **Auto-loaded**: Pinned + Working tiers only
- **Queryable**: Yes (structured queries with boolean operators)
- **Format**: Typed nodes with tags and metadata
- **Best for**: Decisions with rationale, patterns, observations, hypotheses, anything queryable

## Division of Labor

### Belongs in MEMORY.md only
- One-liner conventions ("commit style: fix(plugin): desc -- vX.Y.Z")
- Build/deploy shortcuts ("make start, make test, make bot N=3")
- Version state snapshots ("devloop v3.16.0, ctx v1.0.0")
- Quick gotchas that don't need rationale

### Belongs in ctx only
- Decisions with rationale (WHY something was chosen)
- Cross-project knowledge (applies beyond one repo)
- Observations from debugging (root causes, bug patterns)
- Hypotheses worth revisiting
- Patterns that recur across sessions
- Anything that benefits from querying or linking

### Conflict resolution rules
1. **ctx is authoritative** for structured knowledge (decisions, patterns, observations)
2. **MEMORY.md is authoritative** for brief project conventions
3. **Never duplicate** — if it's in both, remove from MEMORY.md (ctx has richer metadata)
4. **Cross-reference OK** — MEMORY.md can say "See ctx for details on X" without duplicating content

## Issue Detection Patterns

### 1. Duplicate Content (ctx <-> MEMORY.md)
- Same fact stated in both systems
- **Resolution**: Keep in whichever system is more appropriate, remove from the other
- **Default**: Keep in ctx (richer metadata), remove from MEMORY.md

### 2. Duplicate Nodes (within ctx)
- Two or more nodes with near-identical content
- Common with decision nodes during long sessions (agent stores progress twice)
- **Resolution**: Supersede older with newer, or summarize both into one

### 3. Stale Working Nodes
- `tier:working` nodes from completed tasks (sprints, debugging sessions)
- Should be demoted to `tier:reference` or `tier:off-context`
- **Heuristic**: Working nodes older than 7 days are likely stale

### 4. Pinned Tier Bloat
- Too many pinned nodes wastes context tokens every session
- **Guideline**: Keep pinned tier under 20 nodes / ~1,500 tokens
- Demote older pinned nodes to reference if they're not needed every session

### 5. Conflicting Information
- ctx says one thing, MEMORY.md says another
- **Resolution**: Determine which is current, update/remove the stale one

### 6. Orphaned Project Knowledge
- Nodes tagged with projects that no longer exist
- Memory files for projects no longer on disk
- **Resolution**: Archive to off-context or delete

### 7. Missing Project Tags
- Nodes that should have project tags but don't
- Makes project-scoped filtering unreliable
- **Resolution**: Add appropriate project tags

## Token Budget Guidelines

Auto-loaded content per session:
- MEMORY.md: ~200 lines (variable tokens)
- ctx pinned: All pinned nodes
- ctx working: All working nodes

**Target budget**: Keep total auto-loaded content under 4,000 tokens
- MEMORY.md: ~500 tokens (20-30 short lines)
- ctx pinned: ~1,500 tokens (15-20 focused nodes)
- ctx working: ~2,000 tokens (active task only)

## Keeping Systems in Sync

### Manual approach (this cleanup command)
Periodic review and reconciliation. Run `/ctx:cleanup` when:
- Starting a new major feature
- Context feels bloated or contradictory
- Switching between projects after long absence
- Quarterly maintenance

### Instruction-based approach (already implemented)
The `using-ctx` skill already instructs the agent to:
- Check ctx before writing to MEMORY.md
- Check MEMORY.md before storing in ctx
- Never duplicate across systems

### Hook-based approach (potential future enhancement)
A PostToolUse hook on Write/Edit targeting MEMORY.md files could:
1. Detect when MEMORY.md is being modified
2. Inject a reminder to check ctx for duplicates
3. Suggest ctx commands to run

**Implementation sketch:**
```json
{
  "event": "PostToolUse",
  "matcher": "Write|Edit",
  "hooks": [{
    "type": "prompt",
    "prompt": "The agent just modified a MEMORY.md file. Check if the written content duplicates any ctx knowledge. If it does, emit a <ctx:supersede> or removal."
  }]
}
```

**Tradeoffs:**
- Pro: Automatic, catches every MEMORY.md write
- Con: Adds latency to every Write/Edit (even non-memory files unless matcher is refined)
- Con: prompt hooks are expensive (LLM evaluation)
- Recommendation: Start with instructions + periodic cleanup; add hook only if drift is persistent
