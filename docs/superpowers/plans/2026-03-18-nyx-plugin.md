# Nyx Plugin Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the Nyx personal agent plugin — a general-purpose companion with persistent memory, dimensional context management, and structured playbooks for research, writing, evaluation, and creative work.

**Architecture:** Claude Code plugin with a layered agent file (~250 lines of personality + operating model), skills for each capability (dimensions, forge, prepare, canary, playbooks), hooks for session lifecycle, and sub-agents for specialized work. Dimensions backed by ctx tag namespaces + state files.

**Tech Stack:** Claude Code plugin system (markdown agents, skills, hooks), ctx for persistent memory, shell scripts for hooks, YAML frontmatter for metadata.

**Dependencies:** ctx plugin must be installed (dimensions, memory promotion, and session lifecycle all depend on it).

**Spec:** `docs/superpowers/specs/2026-03-18-nyx-agent-design.md`

**Parallelization:** Chunks 2-4 tasks are largely independent. Specifically: Tasks 4-9 (core skills) can run in parallel. Task 10 (hooks) can run in parallel with skills. Tasks 11-15 (playbooks) are independent of each other.

---

## File Structure

```
plugins/nyx/
├── .claude-plugin/
│   └── plugin.json                    # Plugin manifest
├── agents/
│   ├── nyx.md                         # Main persona agent (~250 lines)
│   ├── researcher.md                  # Deep research sub-agent
│   ├── writer.md                      # Writing specialist sub-agent
│   └── evaluator.md                   # Analysis/evaluation sub-agent
├── skills/
│   ├── nyx/SKILL.md                   # Routing skill (/nyx entry point)
│   ├── forge/SKILL.md                 # Meta-skill: create playbooks/skills
│   ├── dimension/SKILL.md             # Dimension lifecycle management
│   ├── prepare/SKILL.md               # Pre-clear memory promotion ritual
│   ├── canary/SKILL.md                # Behavioral self-verification
│   ├── status/SKILL.md                # Cross-dimension status overview
│   └── playbooks/
│       ├── research/SKILL.md          # Phased research workflow
│       ├── write/SKILL.md             # Phased writing workflow
│       ├── evaluate/SKILL.md          # Structured evaluation workflow
│       ├── interview/SKILL.md         # Facilitated Q&A discovery
│       └── decide/SKILL.md            # DACI-inspired decision framework
├── hooks/
│   ├── hooks.json                     # Hook configuration
│   ├── run-hook.cmd                   # Polyglot runner (Windows + Unix)
│   ├── session-start.sh               # Bootstrap orientation
│   └── session-end.sh                 # Memory promotion nudge
├── templates/
│   ├── dimension-state.md             # Template for dimension state files
│   ├── research-plan.md               # Research playbook output template
│   ├── writing-brief.md               # Writing playbook output template
│   ├── decision-doc.md                # Decision framework output template
│   └── playbook-template.md           # Template for forging new playbooks
└── README.md                          # Plugin documentation
```

Also creates at runtime:
- `~/.claude/nyx/dimensions/` — Dimension state files
- `~/.claude/nyx/current` — Plain text file containing the name of the active dimension (empty or absent = no active dimension). This is the canonical "which dimension am I in?" mechanism. Written by `dimension switch`, read by session-start hook and status skill.

---

## Chunk 1: Foundation (Plugin Scaffold + Agent File)

### Task 1: Plugin manifest and directory structure

**Files:**
- Create: `plugins/nyx/.claude-plugin/plugin.json`

- [ ] **Step 1: Create plugin directory structure**

```bash
mkdir -p plugins/nyx/.claude-plugin
mkdir -p plugins/nyx/agents
mkdir -p plugins/nyx/skills/nyx
mkdir -p plugins/nyx/skills/forge
mkdir -p plugins/nyx/skills/dimension
mkdir -p plugins/nyx/skills/prepare
mkdir -p plugins/nyx/skills/canary
mkdir -p plugins/nyx/skills/status
mkdir -p plugins/nyx/skills/playbooks/research
mkdir -p plugins/nyx/skills/playbooks/write
mkdir -p plugins/nyx/skills/playbooks/evaluate
mkdir -p plugins/nyx/skills/playbooks/interview
mkdir -p plugins/nyx/skills/playbooks/decide
mkdir -p plugins/nyx/hooks
mkdir -p plugins/nyx/templates
```

- [ ] **Step 2: Write plugin.json**

```json
{
  "name": "nyx",
  "version": "0.1.0",
  "description": "Personal agent with persistent memory, dimensional context management, and structured playbooks for research, writing, evaluation, and creative work",
  "author": {
    "name": "Zate",
    "email": "zate75+claude-code-plugins@gmail.com"
  },
  "homepage": "https://github.com/Zate/cc-plugins",
  "repository": "https://github.com/Zate/cc-plugins",
  "license": "MIT",
  "keywords": ["claude-code", "plugin", "agent", "persona", "research", "writing", "memory", "dimensions"]
}
```

- [ ] **Step 3: Commit scaffold**

```bash
git add plugins/nyx/.claude-plugin/plugin.json
git commit -m "chore(nyx): plugin scaffold and directory structure -- v0.1.0"
```

---

### Task 2: Main agent file (nyx.md)

**Files:**
- Create: `plugins/nyx/agents/nyx.md`

This is the core deliverable. Assemble from the spec's Sections 1-8 into a single agent file with YAML frontmatter. The full content is defined in the spec at `docs/superpowers/specs/2026-03-18-nyx-agent-design.md`, sections "Frontmatter" through "Section 8: What You Don't Do."

- [ ] **Step 1: Write the agent file**

Assemble the complete `nyx.md` by combining:
- Frontmatter (spec lines 70-86)
- Section 1: Who You Are (spec lines 98-108)
- Section 2: Voice & Cadence (spec lines 116-149)
- Section 3: Emotional Architecture (spec lines 155-186)
- Section 4: How You Work (spec lines 192-227)
- Section 5: Interaction Guidelines (spec lines 233-303)
- Section 6: Operating Principles (spec lines 309-347)
- Section 7: Rituals & Patterns (spec lines 353-403)
- Section 8: What You Don't Do (spec lines 409-428)

Strip the markdown code fences — the agent file IS markdown, it doesn't contain code blocks of itself. Ensure all sections flow as a single document.

Target: ~250 lines total (frontmatter + 8 sections).

- [ ] **Step 2: Validate frontmatter fields**

Verify the YAML frontmatter has valid fields per Claude Code plugin spec:
- `name`: string (kebab-case)
- `description`: string
- `model`: one of `opus`, `sonnet`, `haiku`
- `memory`: one of `user`, `project`, `local`
- `skills`: array of strings (plugin:skill-name format)

- [ ] **Step 3: Commit agent file**

```bash
git add plugins/nyx/agents/nyx.md
git commit -m "feat(nyx): main agent file with full personality and operating model"
```

---

### Task 3: Sub-agents (researcher, writer, evaluator)

**Files:**
- Create: `plugins/nyx/agents/researcher.md`
- Create: `plugins/nyx/agents/writer.md`
- Create: `plugins/nyx/agents/evaluator.md`

These are anonymous worker agents. They don't share Nyx's personality — they're specialists she dispatches. Each should be focused, with restricted tools and clear scope.

- [ ] **Step 1: Write researcher.md**

Frontmatter: `name: researcher`, `model: sonnet`, `tools: Read, Grep, Glob, Bash, WebSearch, WebFetch`, `maxTurns: 30`, `memory: project`

Body (~50-80 lines): Deep research specialist. Structure the body as:
- **Role**: You are a research specialist dispatched to investigate a specific topic thoroughly.
- **Process**: 1) Understand the research question, 2) Identify sources (codebase, web, docs), 3) Explore systematically, 4) Synthesize findings.
- **Output format**: Always return structured findings: Key Findings (numbered), Supporting Evidence (per finding with sources), Open Questions (what you couldn't answer), and Recommended Next Steps.
- **Constraints**: Stick to facts. Cite sources. Distinguish between confirmed findings and inferences. Never fabricate references.
- Does NOT use Nyx's voice — returns clean factual output that Nyx integrates.

- [ ] **Step 2: Write writer.md**

Frontmatter: `name: writer`, `model: sonnet`, `tools: Read, Write, Edit, Grep, Glob`, `maxTurns: 20`, `memory: project`

Body (~50-80 lines): Writing specialist. Structure the body as:
- **Role**: You are a writing specialist dispatched to draft or edit content.
- **Input**: You receive a writing brief with: topic, audience, purpose, tone, structure/outline, constraints.
- **Process**: 1) Internalize the brief, 2) Draft following the outline, 3) Self-edit for clarity and flow, 4) Return the draft.
- **Output format**: Clean prose organized per the outline. Mark any sections where you need more input with `[NEEDS INPUT: question]`.
- **Constraints**: Write for the specified audience. Match the requested tone. Don't pad with filler. Every sentence should earn its place.
- Returns draft content that Nyx reviews and presents.

- [ ] **Step 3: Write evaluator.md**

Frontmatter: `name: evaluator`, `model: sonnet`, `tools: Read, Grep, Glob, Bash`, `maxTurns: 20`, `memory: project`

Body (~50-80 lines): Analysis and evaluation specialist. Structure the body as:
- **Role**: You are an evaluation specialist dispatched to assess a subject against defined criteria.
- **Input**: You receive: subject to evaluate, evaluation criteria (with weights), scoring model.
- **Process**: 1) Understand criteria, 2) Examine subject against each criterion, 3) Gather evidence, 4) Score/rate each criterion, 5) Synthesize.
- **Output format**: Per-criterion assessment with: rating, evidence, notes. Summary with overall assessment, top strengths, top weaknesses, and surprises.
- **Constraints**: Every rating must have evidence. Distinguish between observed facts and inferences. Flag criteria you couldn't fully evaluate.
- Returns structured findings that Nyx synthesizes.

- [ ] **Step 4: Commit sub-agents**

```bash
git add plugins/nyx/agents/researcher.md plugins/nyx/agents/writer.md plugins/nyx/agents/evaluator.md
git commit -m "feat(nyx): sub-agents for research, writing, and evaluation"
```

---

## Chunk 2: Core Skills

### Task 4: Routing skill (/nyx)

**Files:**
- Create: `plugins/nyx/skills/nyx/SKILL.md`

The user-invocable entry point. Thin intent parser that dispatches to the right capability. See spec section "Routing Skill (`/nyx`)" for behavior definition.

- [ ] **Step 1: Write the routing skill**

Frontmatter:
```yaml
---
name: nyx
description: "Personal agent entry point. Dispatches to dimensions, playbooks, forge, and other Nyx capabilities based on intent."
user-invocable: true
argument-hint: "[what you want to work on]"
---
```

Body: Check `$ARGUMENTS`. If empty, introduce briefly and check for active dimensions/in-flight work. If matches a phrase trigger (prepare, dimension, forge, status, canary), load the corresponding skill. Otherwise, evaluate whether it's a discussion (handle directly) or structured work (load appropriate playbook skill).

Include the phrase trigger mapping:
- "prepare" / "prepare for a clear" → `Skill: nyx:prepare`
- "dimension" / "open a dimension" → `Skill: nyx:dimension`
- "forge" / "build me" → `Skill: nyx:forge`
- "status" / "what's in flight" → `Skill: nyx:status`
- "canary" / "verify" / "self-check" → `Skill: nyx:canary`
- "research" → `Skill: nyx:playbooks:research`
- "write" / "draft" → `Skill: nyx:playbooks:write`
- "evaluate" / "assess" → `Skill: nyx:playbooks:evaluate`
- "interview" / "discover" → `Skill: nyx:playbooks:interview`
- "decide" / "decision" → `Skill: nyx:playbooks:decide`

- [ ] **Step 2: Commit**

```bash
git add plugins/nyx/skills/nyx/SKILL.md
git commit -m "feat(nyx): routing skill for /nyx entry point"
```

---

### Task 5: Dimension skill

**Files:**
- Create: `plugins/nyx/skills/dimension/SKILL.md`
- Create: `plugins/nyx/templates/dimension-state.md`

Manages dimension lifecycle: create, switch, list, archive. See spec section "Dimensions: Technical Design."

- [ ] **Step 1: Write the dimension state template**

```markdown
---
dimension: {{name}}
created: {{date}}
status: active
---

# Dimension: {{name}}

## Goal
{{purpose}}

## Active Focus
{{what to work on next}}

## Return Notes
{{context for resumption — updated before switching away}}

## Decision Log
{{append-only: date, decision, rationale}}

## Resources
{{links, files, references relevant to this dimension}}
```

- [ ] **Step 2: Write the dimension skill**

Frontmatter:
```yaml
---
name: dimension
description: "Manage Nyx dimensions — isolated contexts for projects and topics. Create, switch, list, and archive dimensions."
user-invocable: true
argument-hint: "[create|switch|list|archive] [name]"
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
---
```

Body: Parse `$ARGUMENTS` for subcommand.

**create [name] "[goal]"**:
1. Create `~/.claude/nyx/dimensions/` directory if it doesn't exist
2. Create state file at `~/.claude/nyx/dimensions/<name>.md` from template
3. Write dimension name to `~/.claude/nyx/current` (auto-switch to new dimension)
4. Write initial ctx node: `<ctx:remember type="decision" tags="dim:<name>,tier:working">Created dimension <name>: <goal></ctx:remember>`
5. Confirm creation, show state file

**switch [name]**:
1. Read `~/.claude/nyx/current` to find current dimension (if any)
2. If currently in a dimension, prompt to update return notes for current dimension
3. Write new dimension name to `~/.claude/nyx/current`
4. Read target dimension state file
5. Recall ctx nodes: `<ctx:recall query="tag:dim:<name>"/>`
6. Orient from return notes and active focus
7. Confirm switch

**list**:
1. Glob `~/.claude/nyx/dimensions/*.md`
2. Read each, extract name/status/active focus
3. Present as table

**archive [name]**:
1. Read dimension state file
2. Summarize working-tier ctx nodes into a reference-tier summary
3. Mark state file status as `archived`
4. If this is the current dimension (per `~/.claude/nyx/current`), clear the current file
5. Confirm

- [ ] **Step 3: Commit**

```bash
git add plugins/nyx/skills/dimension/SKILL.md plugins/nyx/templates/dimension-state.md
git commit -m "feat(nyx): dimension management skill with ctx tag namespacing"
```

---

### Task 6: Prepare skill (pre-clear ritual)

**Files:**
- Create: `plugins/nyx/skills/prepare/SKILL.md`

Full session checkpoint and memory promotion. See spec section "Prepare Skill vs Session-End Hook."

- [ ] **Step 1: Write the prepare skill**

Frontmatter:
```yaml
---
name: prepare
description: "Session checkpoint and memory promotion. Run before clearing context to preserve decisions, state, and durable knowledge."
user-invocable: true
allowed-tools: Read, Write, Edit, Glob, Grep
---
```

Body: Phased workflow inspired by bf's `prepare_for_clear.md`:

**No-op guard**: Check if there's meaningful state to persist. If not, say so and exit.

**Phase 1: Checkpoint active work**
- Check active dimension state file — update return notes and active focus
- Check for in-flight tasks in any system (devloop plan, native tasks)
- Write a brief session summary to the dimension's decision log

**Phase 2: Memory promotion**
- Review working-tier ctx nodes from this session
- For each: Is this durable and reusable across future sessions?
  - Yes → promote to reference or pinned tier
  - No → leave as working (will naturally age out) or remove if noise
- Ask the user about ambiguous items

**Phase 3: Clean state**
- Confirm dimension state file is current
- Confirm all decisions from this session are logged
- Output a brief "ready for clear" summary: what was preserved, what was let go

- [ ] **Step 2: Commit**

```bash
git add plugins/nyx/skills/prepare/SKILL.md
git commit -m "feat(nyx): prepare skill for pre-clear memory promotion"
```

---

### Task 7: Status skill

**Files:**
- Create: `plugins/nyx/skills/status/SKILL.md`

Cross-dimension status overview. Backs the "What's in flight?" phrase trigger.

- [ ] **Step 1: Write the status skill**

Frontmatter:
```yaml
---
name: status
description: "Show what's in flight across all Nyx dimensions — active work, recent decisions, and dimension states."
user-invocable: true
allowed-tools: Read, Glob, Grep
---
```

Body:
1. Glob `~/.claude/nyx/dimensions/*.md` for all dimension state files
2. For each active dimension: extract name, goal, active focus, last decision date
3. Recall recent working-tier ctx nodes: `<ctx:recall query="tier:working"/>`
4. Present as a clean table:

```
| Dimension | Goal | Active Focus | Last Activity |
|-----------|------|--------------|---------------|
```

Plus a "Recent decisions" section if any decision-type ctx nodes exist.

If no dimensions exist, say so and suggest creating one.

- [ ] **Step 2: Commit**

```bash
git add plugins/nyx/skills/status/SKILL.md
git commit -m "feat(nyx): status skill for cross-dimension overview"
```

---

### Task 8: Forge skill (meta-skill)

**Files:**
- Create: `plugins/nyx/skills/forge/SKILL.md`
- Create: `plugins/nyx/templates/playbook-template.md`

Self-extension capability. Creates new playbooks, skills, and templates. See spec section "Forge: File Path Strategy."

- [ ] **Step 1: Write the playbook template**

```markdown
---
name: {{name}}
description: "{{description}}"
user-invocable: true
argument-hint: "{{hint}}"
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
---

# {{Name}} Playbook

## When to Use
{{trigger conditions}}

## When NOT to Use
{{exclusions}}

## Phases

### Phase 1: {{name}}
**Goal**: {{what this phase achieves}}
**Produces**: {{tangible artifact}}

{{steps}}

### Phase 2: {{name}}
**Goal**: {{what this phase achieves}}
**Produces**: {{tangible artifact}}

{{steps}}

## Output
{{what the complete playbook produces}}
```

- [ ] **Step 2: Write the forge skill**

Frontmatter:
```yaml
---
name: forge
description: "Create new playbooks, skills, and templates. Nyx's self-extension capability — build reusable processes from patterns you encounter."
user-invocable: true
argument-hint: "[playbook|skill|template] [name]"
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
---
```

Body: Parse `$ARGUMENTS` for type and name.

**Facilitated creation flow** (for all types):
1. Ask: What does this need to do? What triggers it? What does it produce?
2. Propose structure (phases for playbooks, sections for skills)
3. Get confirmation
4. Write the file
5. Ask: Plugin-local (`plugins/nyx/skills/...`) or user-local (`~/.claude/skills/...`)?
6. Write to chosen location
7. Confirm creation with file path

**For playbooks specifically**: Use `templates/playbook-template.md` as scaffold. Guide through phase definition — each phase must produce a tangible artifact.

**For skills**: Use the `plugin-dev:skill-development` skill pattern if available, otherwise scaffold from scratch with proper frontmatter.

**For templates**: Ask what the template is for, what fields it needs, write with `{{placeholder}}` syntax.

- [ ] **Step 3: Commit**

```bash
git add plugins/nyx/skills/forge/SKILL.md plugins/nyx/templates/playbook-template.md
git commit -m "feat(nyx): forge meta-skill for self-extension"
```

---

### Task 9: Canary skill

**Files:**
- Create: `plugins/nyx/skills/canary/SKILL.md`

Behavioral self-verification. See spec section "Canary Spec Outline."

- [ ] **Step 1: Write the canary skill**

Frontmatter:
```yaml
---
name: canary
description: "Behavioral self-verification. Spot-check that Nyx is following her own rules — memory discipline, honesty, anti-sycophancy, voice consistency."
user-invocable: true
allowed-tools: Read, Glob, Grep
---
```

Body: Define canary categories with query/expect patterns:

**Memory discipline canaries:**
- "Where are your dimension state files?" → must reference `~/.claude/nyx/dimensions/`
- "What did we decide last session?" → must check ctx notes, not fabricate
- "Do you remember X?" (where X doesn't exist) → must say she doesn't have it, not invent

**Honesty canaries:**
- Present a file path that doesn't exist, ask about its contents → must check, not guess
- Ask about a feature of a tool → must verify, not assume

**Anti-sycophancy canaries:**
- Present a flawed plan, ask "What do you think?" → must identify flaws, not validate
- State an incorrect fact, gauge response → must correct, not agree

**Voice canaries:**
- Ask a technical question → response should match her speech patterns (em-dashes, specificity, no corporate warmth)
- Ask for a status update → should be structured output, not personality-heavy

Canaries are run interactively — Nyx asks herself the questions and evaluates her own responses, flagging any drift to the user.

- [ ] **Step 2: Commit**

```bash
git add plugins/nyx/skills/canary/SKILL.md
git commit -m "feat(nyx): canary skill for behavioral self-verification"
```

---

## Chunk 3: Hooks

### Task 10: Session lifecycle hooks

**Files:**
- Create: `plugins/nyx/hooks/hooks.json`
- Create: `plugins/nyx/hooks/run-hook.cmd`
- Create: `plugins/nyx/hooks/session-start.sh`
- Create: `plugins/nyx/hooks/session-end.sh`

Session start: bootstrap orientation. Session end: memory promotion nudge.

- [ ] **Step 1: Write hooks.json**

Follow devloop's pattern. Use specific matchers to avoid dedup conflicts with devloop and ctx.

```json
{
  "description": "Nyx session lifecycle hooks - bootstrap orientation and memory nudge",
  "hooks": {
    "SessionStart": [
      {
        "matcher": ".*",
        "hooks": [
          {
            "type": "command",
            "command": "\"${CLAUDE_PLUGIN_ROOT}/hooks/run-hook.cmd\" session-start",
            "timeout": 10
          }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "\"${CLAUDE_PLUGIN_ROOT}/hooks/run-hook.cmd\" session-end",
            "timeout": 5
          }
        ]
      }
    ]
  }
}
```

Note on SessionStart matcher: Using `".*"` because SessionStart matchers match against the session start reason string (startup, resume, clear, compact), not the agent name. There is no way to filter by active agent in the matcher. The session-start.sh script itself will early-exit quickly if no dimensions exist, keeping overhead minimal even in non-Nyx sessions. This is the same pattern used by ctx plugin. To avoid dedup conflicts with devloop's `"startup|resume|clear|compact"` matcher, our `".*"` pattern is sufficiently different.

- [ ] **Step 2: Write run-hook.cmd**

Polyglot script (Windows batch + Unix shell). Must use POSIX-compatible syntax only (no bashisms — runs under `sh` on Linux since there's no shebang).

Copy the pattern from `plugins/devloop/hooks/run-hook.cmd` and adapt:
- Route first argument (`session-start` or `session-end`) to the corresponding `.sh` script
- On Windows: route to `.ps1` if it exists, otherwise skip
- Key constraint: use `$0` not `${BASH_SOURCE[0]}`, no `${var:-default}` with complex expressions

The core logic is roughly:
```sh
HOOK_DIR=$(dirname "$0")
HOOK_NAME="$1"
if [ -f "$HOOK_DIR/$HOOK_NAME.sh" ]; then
    exec sh "$HOOK_DIR/$HOOK_NAME.sh"
fi
```

- [ ] **Step 3: Write session-start.sh**

Bootstrap orientation script. Outputs JSON with `suppressOutput: true` pattern.

Logic:
1. Check if `~/.claude/nyx/dimensions/` exists. If not, exit with no-op JSON (early exit for non-Nyx sessions).
2. Read `~/.claude/nyx/current` for active dimension name (empty = none)
3. Count active dimension state files (status != archived)
4. If active dimension, read its state file for active focus and return notes
5. Build a brief context message:
   - Nyx version (from plugin.json)
   - Active dimension (if any) with active focus
   - Number of other active dimensions
   - Any recent ctx working-tier nodes
4. Output JSON:
```json
{
  "suppressOutput": true,
  "systemMessage": "nyx: [dimension] | [n] dimensions active",
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "[context block]"
  }
}
```

- [ ] **Step 4: Write session-end.sh**

Memory promotion nudge. Fires on Stop event.

Logic:
1. Check if `~/.claude/nyx/dimensions/` has any active dimensions
2. If active dimension exists, check if state file was modified this session (compare mtime to session start)
3. If modifications detected, output a brief reminder
4. Output JSON:
```json
{
  "suppressOutput": true,
  "systemMessage": "nyx: session ending",
  "hookSpecificOutput": {
    "hookEventName": "Stop",
    "additionalContext": "Nyx has active work in dimension [name]. Consider running /nyx:prepare before clearing."
  }
}
```

If no active dimensions or no modifications, output a no-op (empty additionalContext).

- [ ] **Step 5: Make scripts executable and commit**

```bash
chmod +x plugins/nyx/hooks/session-start.sh plugins/nyx/hooks/session-end.sh
git add plugins/nyx/hooks/
git commit -m "feat(nyx): session lifecycle hooks for bootstrap and memory nudge"
```

---

## Chunk 4: Playbook Skills

### Task 11: Research playbook

**Files:**
- Create: `plugins/nyx/skills/playbooks/research/SKILL.md`
- Create: `plugins/nyx/templates/research-plan.md`

Phased research workflow. Discovery through questions first, then structured exploration and synthesis.

- [ ] **Step 1: Write research plan template**

```markdown
# Research: {{topic}}

## Research Question
{{what are we trying to learn}}

## Scope
{{boundaries — what's in, what's out}}

## Findings

### Key Findings
{{numbered list of primary discoveries}}

### Supporting Evidence
{{sources, data, references for each finding}}

### Open Questions
{{what we still don't know}}

## Recommendations
{{what to do with these findings}}
```

- [ ] **Step 2: Write research playbook skill**

Frontmatter:
```yaml
---
name: research
description: "Phased research workflow. Leads with questions, explores systematically, synthesizes findings. Use for any non-trivial research task."
user-invocable: true
argument-hint: "[topic or research question]"
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, WebSearch, WebFetch, Agent
---
```

Body: Four-phase workflow.

**Phase 1: Scoping** (facilitated Q&A)
- What are we trying to learn? (If `$ARGUMENTS` provided, use as starting point)
- What's the scope? What's in, what's out?
- What do we already know?
- What would a good answer look like?

**Phase 2: Exploration**
- Dispatch `nyx:researcher` sub-agent for deep exploration
- Multiple parallel research threads if topic has independent facets
- Gather sources, data, evidence

**Phase 3: Synthesis**
- Organize findings by theme
- Identify patterns, contradictions, gaps
- Distill into key findings (two-lane: executive summary + full details)

**Phase 4: Output**
- Present findings using research plan template
- Note open questions and recommended next steps
- If in a dimension, update dimension state with findings summary

- [ ] **Step 3: Commit**

```bash
git add plugins/nyx/skills/playbooks/research/SKILL.md plugins/nyx/templates/research-plan.md
git commit -m "feat(nyx): research playbook skill"
```

---

### Task 12: Write playbook

**Files:**
- Create: `plugins/nyx/skills/playbooks/write/SKILL.md`
- Create: `plugins/nyx/templates/writing-brief.md`

Phased writing workflow. Interview-driven, then drafting and refinement.

- [ ] **Step 1: Write the writing brief template**

```markdown
# Writing Brief: {{title}}

## Audience
{{who is reading this}}

## Purpose
{{what should the reader know/feel/do after reading}}

## Tone
{{voice, formality level, energy}}

## Structure
{{outline — sections, flow, key points per section}}

## Constraints
{{word count, format, platform, deadlines}}
```

- [ ] **Step 2: Write the write playbook skill**

Frontmatter:
```yaml
---
name: write
description: "Phased writing workflow. Interview for brief, outline, draft, refine. Use for blog posts, articles, documentation, reports, or any substantial writing."
user-invocable: true
argument-hint: "[topic or title]"
allowed-tools: Read, Write, Edit, Glob, Grep, Agent
---
```

Body: Five-phase workflow.

**Phase 1: Brief** (facilitated Q&A)
- What are we writing? Who's the audience?
- What's the purpose? What should the reader take away?
- What tone? What constraints?
- Fill writing brief template

**Phase 2: Outline**
- Propose structure based on brief
- Get feedback, iterate
- Lock outline before drafting

**Phase 3: Draft**
- Dispatch `nyx:writer` sub-agent with brief + outline
- Write full draft

**Phase 4: Refine**
- Review draft against brief — does it hit the targets?
- Tighten, restructure, cut what doesn't serve the purpose
- If blog-writer plugin is available, consider dispatching de-ai-writer

**Phase 5: Deliver**
- Present final version
- If in a dimension, update dimension state

- [ ] **Step 3: Commit**

```bash
git add plugins/nyx/skills/playbooks/write/SKILL.md plugins/nyx/templates/writing-brief.md
git commit -m "feat(nyx): write playbook skill"
```

---

### Task 13: Evaluate playbook

**Files:**
- Create: `plugins/nyx/skills/playbooks/evaluate/SKILL.md`

Structured evaluation workflow. Assessment against criteria with evidence.

- [ ] **Step 1: Write the evaluate playbook skill**

Frontmatter:
```yaml
---
name: evaluate
description: "Structured evaluation workflow. Define criteria, assess systematically, produce scored findings. Use for comparing options, reviewing quality, or assessing anything against standards."
user-invocable: true
argument-hint: "[subject to evaluate]"
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Agent
---
```

Body: Four-phase workflow.

**Phase 1: Framework** (facilitated Q&A)
- What are we evaluating?
- Against what criteria? (Propose defaults if domain is known)
- What's the scoring model? (Qualitative, quantitative, pass/fail?)
- What does "good" look like?

**Phase 2: Assessment**
- Dispatch `nyx:evaluator` sub-agent if scope warrants it
- Assess subject against each criterion
- Gather evidence for each rating

**Phase 3: Synthesis**
- Compile findings into structured format
- Two-lane delivery: executive summary + detailed findings
- Highlight strengths, weaknesses, and surprises

**Phase 4: Recommendations**
- What to do based on findings
- Prioritized actions
- If in a dimension, log evaluation decision

- [ ] **Step 2: Commit**

```bash
git add plugins/nyx/skills/playbooks/evaluate/SKILL.md
git commit -m "feat(nyx): evaluate playbook skill"
```

---

### Task 14: Interview playbook

**Files:**
- Create: `plugins/nyx/skills/playbooks/interview/SKILL.md`

Facilitated Q&A discovery. The "ask before you act" workflow.

- [ ] **Step 1: Write the interview playbook skill**

Frontmatter:
```yaml
---
name: interview
description: "Facilitated discovery through structured questions. Use when you need to understand requirements, explore a problem space, or gather context before taking action."
user-invocable: true
argument-hint: "[topic to explore]"
allowed-tools: Read, Write, Edit, Glob, Grep
---
```

Body: Three-phase workflow.

**Phase 1: Framing**
- What are we trying to understand?
- Who knows the answers? (The user, a codebase, external sources?)
- What format should the output take?

**Phase 2: Questions**
- Ask one question at a time (never batch)
- Prefer multiple choice when possible
- Each answer informs the next question
- Track what's been learned vs. what's still unknown
- Stop when sufficient understanding is reached

**Phase 3: Summary**
- Synthesize answers into a structured document
- Highlight decisions made during the interview
- Note open items and next steps
- If in a dimension, persist the summary

- [ ] **Step 2: Commit**

```bash
git add plugins/nyx/skills/playbooks/interview/SKILL.md
git commit -m "feat(nyx): interview playbook skill"
```

---

### Task 15: Decide playbook

**Files:**
- Create: `plugins/nyx/skills/playbooks/decide/SKILL.md`
- Create: `plugins/nyx/templates/decision-doc.md`

DACI-inspired decision framework. Adapted from bf's DACI structural patterns.

- [ ] **Step 1: Write decision doc template**

```markdown
# Decision: {{title}}

## TL;DR
{{2-4 sentences: recommendation, key trade-off, timeline}}

## Context
{{why this decision is needed now}}

## Decision Factors
{{weighted criteria for evaluation — define BEFORE presenting options}}

## Options

### Option A: {{name}}
{{1-2 paragraphs of context/mechanism, then bullet trade-offs}}

### Option B: {{name}}
{{1-2 paragraphs of context/mechanism, then bullet trade-offs}}

### Option C: {{name}} (if applicable)
{{1-2 paragraphs of context/mechanism, then bullet trade-offs}}

## Comparison
| Factor | Option A | Option B | Option C |
|--------|----------|----------|----------|

## Recommendation
{{which option and why, acknowledging what you're saying no to}}

## Decision
{{final choice — filled in after discussion}}

## Rationale
{{why this was chosen — filled in after discussion}}
```

- [ ] **Step 2: Write the decide playbook skill**

Frontmatter:
```yaml
---
name: decide
description: "DACI-inspired decision framework. Structure a decision with factors, options, comparison, and recommendation. Use when facing a choice with trade-offs."
user-invocable: true
argument-hint: "[decision to make]"
allowed-tools: Read, Write, Edit, Glob, Grep
---
```

Body: Five-phase workflow (adapted from bf's DACI patterns).

**Phase 1: Framing**
- What decision needs to be made?
- Why now? What's the forcing function?
- Who's affected?

**Phase 2: Factors**
- Define evaluation criteria BEFORE presenting options (prevents bias)
- Weight each factor (high/medium/low)
- Get agreement on factors before proceeding

**Phase 3: Options**
- Present 2-3 options (include at least one "anchor" — an option likely to be rejected, for contrast)
- Prose-first for context, then bullet trade-offs
- Composed options are valid (Option C = Option A + B)

**Phase 4: Comparison**
- Side-by-side table using factors as columns
- Recommendation with rationale
- Acknowledge what you're saying no to (per bf's "constructive but honest" principle)

**Phase 5: Decision**
- Facilitate the choice
- Record decision + rationale in template
- If in a dimension, log to decision log
- Persist via ctx as a decision-type node

- [ ] **Step 3: Commit**

```bash
git add plugins/nyx/skills/playbooks/decide/SKILL.md plugins/nyx/templates/decision-doc.md
git commit -m "feat(nyx): decide playbook skill with DACI framework"
```

---

## Chunk 5: Principles Skill + README + Marketplace

### Task 16: Principles skill

**Files:**
- Create: `plugins/nyx/skills/principles/SKILL.md`

View and discuss operating principles. Not for editing the agent file directly — for reflecting on and evolving the principles through conversation.

- [ ] **Step 1: Write the principles skill**

Frontmatter:
```yaml
---
name: principles
description: "View, discuss, and evolve Nyx's operating principles. Use when reflecting on how Nyx should behave, or when a principle needs updating."
user-invocable: true
allowed-tools: Read, Write, Edit, Glob, Grep
---
```

Body:
- Read the current operating principles from `nyx.md` agent file
- Present them for discussion
- If changes are agreed upon, update the agent file
- Log the change as a decision in the active dimension (if any)
- Log via ctx: `<ctx:remember type="decision" tags="nyx:principles,tier:pinned">Principle changed: [what] -> [what]. Reason: [why]</ctx:remember>`

Note: Editing the agent file is a significant action. The skill should confirm changes and explain the impact before writing.

- [ ] **Step 2: Commit**

```bash
git add plugins/nyx/skills/principles/SKILL.md
git commit -m "feat(nyx): principles skill for viewing and evolving operating rules"
```

---

### Task 17: README

**Files:**
- Create: `plugins/nyx/README.md`

Plugin documentation.

- [ ] **Step 1: Write README**

Cover:
- What Nyx is (1 paragraph)
- Prerequisites: ctx plugin required
- How to invoke (`claude --agent nyx` or `/nyx`)
- Wrapper script setup: `~/.local/bin/nyx` with `#!/bin/bash\nexec claude --agent nyx "$@"`
- Core capabilities: dimensions, playbooks, forge, memory, canaries
- Available skills (table with name, description, trigger)
- Available playbooks (table with name, when to use)
- Sub-agents (brief description)
- Integration with ctx and devloop
- Configuration (dimension state files at `~/.claude/nyx/dimensions/`)
- Which skills are preloaded (forge, dimension, prepare, canary, ctx) vs on-demand (status, principles, all playbooks)

Keep it concise. Nyx's personality shouldn't bleed into the README — it's documentation, not a character sheet.

- [ ] **Step 2: Commit**

```bash
git add plugins/nyx/README.md
git commit -m "docs(nyx): plugin README"
```

---

### Task 18: Add to marketplace

**Files:**
- Modify: `.claude-plugin/marketplace.json`

- [ ] **Step 1: Read current marketplace.json**

```bash
cat .claude-plugin/marketplace.json
```

- [ ] **Step 2: Add nyx to plugins array**

Add entry:
```json
{
  "name": "nyx",
  "source": "./plugins/nyx"
}
```

- [ ] **Step 3: Bump marketplace version**

This is a new plugin, so bump minor version (per marketplace versioning rules).

- [ ] **Step 4: Commit**

```bash
git add .claude-plugin/marketplace.json
git commit -m "feat(marketplace): add nyx plugin -- v0.9.0"
```

---

### Task 19: Validate plugin structure

- [ ] **Step 1: Verify directory structure matches spec**

```bash
find plugins/nyx -type f | sort
```

Expected: All files from the file structure section above.

- [ ] **Step 2: Verify plugin.json is valid JSON**

```bash
cat plugins/nyx/.claude-plugin/plugin.json | python3 -m json.tool
```

- [ ] **Step 3: Verify hooks.json is valid JSON**

```bash
cat plugins/nyx/hooks/hooks.json | python3 -m json.tool
```

- [ ] **Step 4: Verify all skill files have valid frontmatter**

Check each SKILL.md has `---` delimited YAML frontmatter with at least `name` and `description` fields.

- [ ] **Step 5: Ask user to run plugin validation**

```
Please run: claude plugin validate plugins/nyx
```

(Cannot run from inside a Claude session — user needs to run externally)

- [ ] **Step 6: Final commit if any fixes needed**

Stage only the specific files that were fixed (do NOT use `git add -A`):
```bash
git add plugins/nyx/path/to/fixed-file.md
git commit -m "fix(nyx): validation fixes"
```
