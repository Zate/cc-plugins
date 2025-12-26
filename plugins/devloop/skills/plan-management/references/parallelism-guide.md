# Parallelism Markers and Guidelines

Complete guide to marking and executing parallel tasks in devloop plans.

## Parallelism Markers

Tasks can include optional markers to indicate parallelization potential:

| Marker | Meaning | Example |
|--------|---------|---------|
| `[parallel:X]` | Can run with other tasks in group X | `[parallel:A]` |
| `[depends:N.M,...]` | Must wait for listed tasks | `[depends:1.1,1.2]` |
| `[background]` | Low priority, can run in background | |
| `[sequential]` | Must run alone, not parallelizable | |

## Phase-Level Parallelism

Phases can indicate overall parallelization:

```markdown
### Phase 2: Core Implementation  [parallel:partial]
**Parallelizable**: full | partial | none
**Parallel Groups**:
- Group A: Tasks 2.1, 2.2 (independent implementations)
- Group B: Tasks 2.3, 2.4 (can run after Group A completes)

- [ ] Task 2.1: Create user model  [parallel:A]
  - Acceptance: ...
- [ ] Task 2.2: Create auth service  [parallel:A]
  - Acceptance: ...
- [ ] Task 2.3: Wire up middleware  [depends:2.1,2.2] [parallel:B]
  - Acceptance: ...
- [ ] Task 2.4: Add logging  [parallel:B]
  - Acceptance: ...
```

## Detecting Parallel Tasks

When `/devloop:continue` reads a plan:
1. Find all pending tasks with `[parallel:X]` markers sharing the same group
2. Offer to spawn agents in parallel for those tasks
3. Track progress of all parallel tasks together
4. Only proceed to dependent tasks when group completes

## Smart Parallelism Guidelines

### When to Parallelize

**DO parallelize:**
- **Read-only operations**: Multiple explorers, reviewers, analyzers examining different areas
- **Independent implementations**: Tasks in same phase that touch different files
- **Test generation + implementation**: Tests can be written while implementing (when marked)
- **Multiple audits**: Security auditors analyzing different domains
- **Documentation tasks**: API docs, README updates can run parallel to code

**Parallel-safe patterns:**
```markdown
# Good: Independent file creation
- [ ] Task 2.1: Create user model  [parallel:A]
- [ ] Task 2.2: Create product model  [parallel:A]

# Good: Read-only exploration
- [ ] Explore auth patterns  [parallel:A]
- [ ] Explore API patterns  [parallel:A]
```

### When NOT to Parallelize

**DO NOT parallelize:**
- **Dependent tasks**: Task B needs output from Task A
- **Same file modifications**: Risk of merge conflicts
- **Complex context sharing**: When agents need to coordinate closely
- **High token cost scenarios**: Multiple Opus agents running in parallel
- **User interaction required**: Background agents can't ask questions

**Sequential patterns:**
```markdown
# Bad: Dependent tasks marked parallel
- [ ] Task 2.1: Create base class  [parallel:A]
- [ ] Task 2.2: Extend base class  [parallel:A]  # WRONG - depends on 2.1!

# Good: Express dependency
- [ ] Task 2.1: Create base class
- [ ] Task 2.2: Extend base class  [depends:2.1]
```

## Token Cost Awareness

| Scenario | Parallel? | Rationale |
|----------|-----------|-----------|
| 3x haiku explorers | Yes | Low cost (~$0.01), high benefit |
| 3x sonnet architects | Maybe | Medium cost, evaluate if all needed |
| 3x opus reviewers | No | High cost (~$0.15+ each), diminishing returns |
| 1 opus + 2 haiku | Yes | Balanced - heavy lifting + quick helpers |
| 5+ agents of any type | No | Context coordination costs exceed benefits |

**Rule of thumb**: Max 3-4 parallel agents. Beyond that, coordination overhead negates benefits.

## Model Selection for Parallel Work

| Agent Type | Model | Notes |
|------------|-------|-------|
| code-explorer | sonnet | Multiple explorers useful |
| code-architect | sonnet | Usually only need 2-3 variants |
| code-reviewer | sonnet | Run parallel, different focus areas |
| test-generator | haiku | Can run parallel to implementation |
| security auditors | sonnet | Designed for parallel execution |

## Marking Tasks for Parallelism

When creating plans, task-planner should:

1. **Identify independent tasks**: Tasks that don't share files or dependencies
2. **Group by execution order**: Tasks that can run at the same time get same group letter
3. **Mark dependencies explicitly**: Use `[depends:X.Y]` for clear ordering
4. **Consider token costs**: Don't mark expensive tasks for parallel without justification
