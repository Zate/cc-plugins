# Devloop v3.1.0 - Final Polish

**Goal**: Address remaining suggestions from final evaluation

**Status**: In Progress

---

## Phase 1: Enhance continue.md

Add practical guidance that's currently missing.

### 1.1 Add "When to Load Skills" section

Add after the "Available Skills" section:

```markdown
## When to Load Skills

Load skills when you need domain-specific guidance:

| Situation | Skill |
|-----------|-------|
| Unfamiliar language idioms | `Skill: go-patterns`, `python-patterns`, etc. |
| Complex git operations | `Skill: git-workflows` |
| Designing an API | `Skill: api-design` |
| Writing tests | `Skill: testing-strategies` |
| Security concerns | `Skill: security-checklist` |
| Database schema work | `Skill: database-patterns` |

Don't preload. Load when the task requires it.
```

- [x] Add "When to Load Skills" section to continue.md

### 1.2 Add parallel agent example

Add a concrete example showing how to use agents for parallel work:

```markdown
## Parallel Agent Example

Only use agents when running truly independent tasks simultaneously:

\`\`\`
Task:
  subagent_type: devloop:engineer
  description: "Implement UserService"
  run_in_background: true
  prompt: "Implement UserService with CRUD operations"

Task:
  subagent_type: devloop:engineer  
  description: "Implement ProductService"
  run_in_background: true
  prompt: "Implement ProductService with CRUD operations"

# Wait for both with TaskOutput
\`\`\`

For single tasks, just do the work directly.
```

- [x] Add parallel agent example to continue.md

## Phase 2: Clarify devloop.md vs continue.md

Make the distinction crystal clear.

### 2.1 Update devloop.md intro

Change intro to explicitly state when to use it:

```markdown
# Devloop - Start New Work

**Use this when**: No plan exists, or you want to start fresh.

**Use `/devloop:continue` instead if**: A plan already exists at `.devloop/plan.md`.
```

- [x] Clarify devloop.md intro - when to use vs continue

### 2.2 Update continue.md intro

```markdown
# Continue - Resume Existing Work

**Use this when**: A plan exists at `.devloop/plan.md`.

**Use `/devloop` instead if**: No plan exists, or you want to start a new plan.
```

- [x] Clarify continue.md intro - when to use vs devloop

## Phase 3: Document Spike Outputs

Standardize where spike findings go.

- [x] Add to spike.md: Save findings to `.devloop/spikes/[topic].md` (already present)
- [x] Add example showing spike output file structure (already present)

## Phase 4: Add Troubleshooting to README

Add a troubleshooting section for common issues:

```markdown
## Troubleshooting

### Plan file corrupted
Delete `.devloop/plan.md` and run `/devloop` to start fresh.

### Session ended unexpectedly
Run `/devloop:continue` - it will pick up from the last checkpoint in your plan.

### Want to abandon current plan
Delete `.devloop/plan.md` or rename it, then run `/devloop`.

### Context feels heavy/slow
Run `/devloop:fresh`, then `/clear`, then `/devloop:continue`.

### Skill not loading
Check `skills/INDEX.md` for the exact skill name. Use `Skill: exact-name`.
```

- [x] Add Troubleshooting section to README.md

## Phase 5: Trim Living Docs

Reduce 00-overview.md and 01-architecture.md to <100 lines each.

### 5.1 Trim 00-overview.md
Currently 169 lines. Target: <100 lines.
- Remove redundant content
- Keep core message: what devloop is, how to use it

- [x] Trim 00-overview.md to <100 lines (170→95)

### 5.2 Trim 01-architecture.md
Currently 289 lines. Target: <100 lines.
- Remove verbose explanations
- Keep: component list, file structure, key concepts

- [x] Trim 01-architecture.md to <100 lines (290→104)

## Phase 6: Git Commit and Tag

- [ ] Stage all changes: `git add -A`
- [ ] Commit: `git commit -m "docs(devloop): final polish - skill guidance, troubleshooting, trimmed docs"`
- [ ] Tag release: `git tag v3.1.0`

---

## Summary of Changes

| File | Change |
|------|--------|
| `commands/continue.md` | Add skill guidance, parallel agent example |
| `commands/devloop.md` | Clarify when to use vs continue |
| `commands/spike.md` | Document spike output location |
| `README.md` | Add troubleshooting section |
| `docs/living/00-overview.md` | Trim to <100 lines |
| `docs/living/01-architecture.md` | Trim to <100 lines |
