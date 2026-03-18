# Nyx

Personal agent with persistent memory, dimensional context management, and structured playbooks for research, writing, evaluation, and creative work.

## Prerequisites

- **ctx plugin** (required) — Nyx uses ctx for persistent cross-session memory

## Invocation

**Primary** — standalone agent session:
```bash
claude --agent nyx
```

**Wrapper script** — create `~/.local/bin/nyx`:
```bash
#!/bin/bash
exec claude --agent nyx "$@"
```

**Within a Claude Code session** — via slash command:
```
/nyx [what you want to work on]
```

## Core Capabilities

| Capability | Description |
|-----------|-------------|
| **Dimensions** | Isolated contexts per project/topic with their own state, memory, and momentum |
| **Playbooks** | Structured phased workflows for research, writing, evaluation, interviews, and decisions |
| **Forge** | Self-extension — create new playbooks, skills, and templates |
| **Memory** | Persistent cross-session knowledge via ctx with promotion rituals |
| **Canaries** | Behavioral self-verification to catch drift |

## Skills

### Preloaded (always available)
| Skill | Trigger | Description |
|-------|---------|-------------|
| `nyx:forge` | "build me a..." | Create new playbooks, skills, templates |
| `nyx:dimension` | "open a dimension" | Create, switch, list, archive dimensions |
| `nyx:prepare` | "prepare for a clear" | Session checkpoint and memory promotion |
| `nyx:canary` | "self-check" | Behavioral self-verification |

### On-demand
| Skill | Trigger | Description |
|-------|---------|-------------|
| `nyx:status` | "what's in flight?" | Cross-dimension status overview |
| `nyx:principles` | "principles" | View and evolve operating principles |

### Playbooks
| Playbook | Trigger | Phases | Use For |
|----------|---------|--------|---------|
| `nyx:research` | "research..." | Scope → Explore → Synthesize → Output | Non-trivial research tasks |
| `nyx:write` | "write..." / "draft..." | Brief → Outline → Draft → Refine → Deliver | Blog posts, articles, reports, documentation |
| `nyx:evaluate` | "evaluate..." / "assess..." | Framework → Assessment → Synthesis → Recommendations | Comparisons, quality reviews, structured analysis |
| `nyx:interview` | "interview..." / "discover..." | Frame → Questions → Summary | Requirements gathering, problem exploration |
| `nyx:decide` | "decide..." / "decision..." | Frame → Factors → Options → Compare → Decide | Choices with trade-offs (DACI-inspired) |

## Sub-Agents

Nyx dispatches specialist agents for focused work:

| Agent | Role | Model |
|-------|------|-------|
| `nyx:researcher` | Deep multi-source research | sonnet |
| `nyx:writer` | Drafting and editing | sonnet |
| `nyx:evaluator` | Structured assessment | sonnet |

Sub-agents are anonymous workers — Nyx integrates their output into her workflow.

## Dimensions

Dimensions are isolated contexts backed by ctx tag namespaces and state files.

- **State files**: `~/.claude/nyx/dimensions/<name>.md`
- **Active tracking**: `~/.claude/nyx/current`
- **Memory**: ctx nodes tagged `dim:<name>` for scoped recall

```
/nyx dimension create security-audit "Evaluate auth system for OWASP compliance"
/nyx dimension switch security-audit
/nyx dimension list
/nyx dimension archive security-audit
```

## Phrase Triggers

| Phrase | Action |
|--------|--------|
| "What's in flight?" | Cross-dimension status |
| "Prepare for a clear" | Session checkpoint + memory promotion |
| "Open a new dimension" | Create isolated context |
| "What do you think?" | Honest opinion |
| "Build me a..." | Forge mode |

## Integration

- **ctx** — Persistent memory across sessions
- **devloop** — Nyx defers to devloop for code-centric development workflows
- **blog-writer** — Write playbook can dispatch de-ai-writer for blog posts
- **security** — Nyx complements, doesn't replace, dedicated security scanning
