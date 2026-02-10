# CC-Plugins Architecture

High-level overview of the plugin ecosystem. For implementation details, see individual plugin READMEs.

---

## The Big Picture

```
                              CC-Plugins Marketplace
                                       |
          +----------------------------+----------------------------+
          |                            |                            |
       devloop                        ctx                       security
   (workflow engine)          (persistent memory)          (OWASP auditing)
          |                            |
          +------------+---------------+
                       |
               Your Development Session
```

**devloop** orchestrates your development workflow. **ctx** gives Claude memory across sessions. **security** audits for vulnerabilities. They work together but can be used independently.

---

## Core Philosophy

**"Plan, Build, Validate, Ship, Repeat"**

```
/devloop:plan "feature"     # Plan - explore and design
        |
/devloop:run                # Build - implement autonomously
        |
/devloop:ship               # Ship - commit and PR
        |
     Repeat                 # Start next feature
```

This loop replaces complex multi-phase workflows with a simple, repeatable pattern.

---

## Component Flow

```
User Input
    |
    v
+--------+     +---------+     +--------+     +-------+
| Slash  | --> | Command | --> | Skills | --> | Tools |
|Commands|     |   .md   |     |  .md   |     | (API) |
+--------+     +---------+     +--------+     +-------+
                   |               ^
                   |               |
                   v               |
              +--------+       +------+
              | Agents | ----> | Hooks|
              |  .md   |       | .sh  |
              +--------+       +------+
                                  |
                                  v
                            ctx (memory)
```

| Component | Purpose | Location |
|-----------|---------|----------|
| Commands | User-invoked workflows | `commands/*.md` |
| Agents | Parallel work, specialized tasks | `agents/*.md` |
| Skills | Domain knowledge, patterns | `skills/*/SKILL.md` |
| Hooks | Event-driven automation | `hooks/*.sh` |

---

## How ctx Provides Memory

Claude is stateless. Every session starts fresh. ctx fixes this:

```
Session 1                          ctx Database                    Session 2
    |                                   |                               |
Claude learns                     +------------+                   Claude knows
"use gRPC for                     | Decisions  |                   about gRPC
 internal APIs"  -----store----> | Patterns   | -----load----->   decision
    |                             | Facts      |                       |
<ctx:remember>                    +------------+                   (auto-injected)
```

**Storage tiers:**
- `tier:pinned` - Always loaded (critical facts, conventions)
- `tier:working` - Current task context (debugging, hypotheses)
- `tier:reference` - Query on demand via `<ctx:recall>`

---

## Hook Lifecycle

Hooks fire at key moments in a Claude Code session:

```
Session Start
    |
    v
[SessionStart hook]     # ctx: inject stored knowledge
    |                   # devloop: detect project state
    v
User Prompt
    |
    v
[UserPromptSubmit]      # ctx: parse commands from last response
    |
    v
Claude Response
    |
    v
[Stop hook]             # ctx: final command sweep
                        # ralph-loop: check completion promise
```

---

## Plugin Interaction

devloop and ctx complement each other:

| devloop | ctx |
|---------|-----|
| Plans what to build | Remembers why you built it |
| Tracks tasks | Stores patterns discovered |
| Manages workflow | Preserves debugging insights |
| Session-scoped | Cross-session |

**Example flow:**

1. `/devloop:plan "add auth"` - creates plan
2. During work, Claude discovers OAuth quirk
3. `<ctx:remember type="observation">` stores it
4. Next session: ctx injects the observation
5. Claude knows about the quirk immediately

---

## File Structure

```
cc-plugins/
+-- .claude-plugin/
|   +-- marketplace.json      # Plugin registry
+-- plugins/
    +-- devloop/
    |   +-- .claude-plugin/
    |   |   +-- plugin.json   # Plugin manifest
    |   +-- commands/         # 13 slash commands
    |   +-- agents/           # 7 specialized agents
    |   +-- skills/           # 15 domain skills
    |   +-- hooks/            # Event handlers
    |   +-- scripts/          # Helper scripts
    +-- ctx/
    |   +-- commands/         # 3 commands
    |   +-- skills/           # 1 skill
    |   +-- hooks/            # Memory lifecycle
    +-- security/
        +-- commands/         # Audit commands
```

---

## Design Principles

1. **Claude does the work directly** - No routine agent spawning
2. **Fresh context = better reasoning** - Clear after 5-10 tasks
3. **Plans survive sessions** - Pick up where you left off
4. **Skills load on demand** - No preloading bloat
5. **Hooks are minimal** - Fast, focused, fail gracefully

---

## Learn More

| Resource | What you'll learn |
|----------|-------------------|
| [devloop README](plugins/devloop/README.md) | Full workflow documentation |
| [ctx README](plugins/ctx/README.md) | Persistent memory system |
| [CLAUDE.md](CLAUDE.md) | Plugin development guide |
| [skills/INDEX.md](plugins/devloop/skills/INDEX.md) | Available skills |
