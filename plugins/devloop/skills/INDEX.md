# Devloop Skills Index v6.0

Load skills on demand with `Skill: skill-name`. Don't preload.

## Workflow Commands

These are user-invocable slash commands (`/devloop:<name>`):

| Skill | Purpose |
|-------|---------|
| `devloop` | Smart entry point - detects state, suggests actions |
| `plan` | Create actionable plan with autonomous exploration |
| `run` | Execute plan tasks autonomously |
| `run-swarm` | Execute plan tasks via fresh-context subagents |
| `epic` | Create multi-phase epic plan with TDD structure |
| `run-epic` | Execute epic phase-by-phase |
| `fresh` | Save plan state for fresh context restart |
| `ship` | Validate and commit/PR completed work |
| `review` | Comprehensive code review |
| `pr-feedback` | Fetch and integrate PR review comments |
| `new` | Create GitHub issue (or local with --local) |
| `issues` | List GitHub issues |
| `archive` | Archive completed plan |
| `help` | Interactive guide to devloop |
| `statusline` | Configure devloop statusline |

## Reference Skills

| Skill | Purpose |
|-------|---------|
| `plan-management` | Working with .devloop/plan.md |
| `local-config` | Project settings via .devloop/local.md |
| `git-hygiene` | Commit strategy, branch naming, PR workflow, merge decisions |
| `devloop-audit` | Audit devloop against Claude Code updates |

---

**Total**: 19 skills (15 workflow commands + 4 reference skills).

As of v3.25.1, low-use "knowledge" skills (language-pattern, design, security, testing) were removed — Claude's training covers that material and the auto-triggering skills were paying ~50 tokens each for ~0 invocations. `atomic-commits` and `git-workflows` were merged into `git-hygiene`. Use `/devloop:plan` for task-specific guidance instead.

## Superpowers Integration

Devloop and superpowers are complementary plugins with distinct lanes:

| Lane | Plugin | Focus |
|------|--------|-------|
| **Workflow orchestration** | devloop | Plan, run, fresh, ship cycle |
| **Quality practices** | superpowers | TDD, debugging, verification, code review |

### When to use which

| Task | Use |
|------|-----|
| "Plan and implement feature X" | `/devloop:plan` -> `/devloop:run` |
| "Large multi-phase feature with TDD" | `/devloop:epic` -> `/devloop:run-epic` |
| "Write tests first, then implement" | `superpowers:test-driven-development` |
| "Debug this failing test" | `superpowers:systematic-debugging` |
| "Review my changes" | `/devloop:review` (quick) or `superpowers:requesting-code-review` (thorough) |
| "Commit and create PR" | `/devloop:ship` |

**Note**: Superpowers is NOT required. Devloop works fully standalone.

## Quick Reference

```
# Workflow commands
/devloop             # Smart entry point
/devloop:plan        # Create plan
/devloop:run         # Execute plan
/devloop:epic        # Multi-phase TDD epic
/devloop:run-epic    # Execute epic phases
/devloop:ship        # Commit/PR

# Reference skills (load on demand)
Skill: plan-management       # Plans
Skill: local-config          # Project config
Skill: devloop-audit         # Plugin audit
```
