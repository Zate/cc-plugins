# Spike Report: Plan Integration & Smart Parallelism

## Questions Investigated
1. **How well integrated is plan management across devloop components?** → Partial - good patterns exist but inconsistent application
2. **Where can parallel execution be safely introduced?** → Several opportunities in exploration, architecture, and review phases
3. **How should tasks be marked for parallel execution?** → New markers and metadata in plan format
4. **What's the token cost tradeoff for parallelism?** → Significant savings when used correctly, wasteful when overused

## Findings

### Feasibility
**Yes** - This is feasible and will improve the devloop workflow. The foundation exists:
- `Skill: plan-management` already defines the canonical format and update procedures
- Several agents already reference plans (code-explorer, code-reviewer with `permissionMode: plan`)
- The security plugin's audit.md shows a good pattern for parallel agent execution with visibility

### Current State Analysis

#### Plan Management - What Works Well
1. **plan-management skill** is comprehensive - defines format, update rules, and agent responsibilities
2. **task-planner agent** saves to `.claude/devloop-plan.md`
3. **continue.md command** reads plan and updates progress
4. **task-checkpoint skill** enforces plan updates between tasks

#### Plan Management - Gaps Found
1. **spike.md** only mentions plans passively: "The parent command/agent is responsible for applying plan updates based on spike recommendations" - needs direct integration
2. **No automatic plan discovery** when executing ad-hoc requests that relate to existing plans
3. **Agents lack explicit instructions** to check for and incorporate findings into existing plans
4. **No ordering/prioritization guidance** when new tasks are discovered mid-implementation

#### Parallelism - Current Patterns
1. **devloop.md Phase 3 (Exploration)**: "Launch 2-3 code-explorer agents in parallel"
2. **devloop.md Phase 5 (Architecture)**: "Launch 2-3 code-architect agents in parallel"
3. **devloop.md Phase 9 (Review)**: "Launch code-reviewer agents in parallel"
4. **security audit.md Phase 3**: "Launch 3-4 auditors in parallel (use `run_in_background: true`)"

#### Parallelism - Gaps Found
1. **No task markers** in plan format to indicate parallelizable tasks
2. **No guidance** on when NOT to parallelize (token costs, dependencies)
3. **Individual agents** don't know if they can run in parallel with others
4. **test-runner, test-generator** could often run in parallel but don't have guidance

### Recommended Approach

#### Part 1: Enhanced Plan Format with Parallelism Markers

Extend the plan-management skill with parallelism metadata:

```markdown
### Phase 2: Core Implementation
**Parallelizable**: partial
**Parallel Groups**:
- Group A: Tasks 2.1, 2.2 (can run together, no dependencies)
- Sequential: Task 2.3 depends on Group A

- [ ] Task 2.1: Create user model  [parallel:A]
  - Acceptance: ...
- [ ] Task 2.2: Create auth service  [parallel:A]
  - Acceptance: ...
- [ ] Task 2.3: Wire up auth middleware  [depends:2.1,2.2]
  - Acceptance: ...
```

**New task markers:**
| Marker | Meaning |
|--------|---------|
| `[parallel:X]` | Can run in parallel with other tasks in group X |
| `[depends:N.M]` | Depends on task N.M completing first |
| `[background]` | Low-priority, can run in background |
| `[sequential]` | Must run alone, not parallelizable |

#### Part 2: Plan Integration Points to Update

**Commands to update:**

| File | Change Needed |
|------|---------------|
| `spike.md` | Add Phase 6: Plan Integration - explicitly update devloop-plan.md with findings |
| `devloop.md` | Add reminder at Phase 7 start to check for parallel task groups |
| `continue.md` | Add logic to detect and spawn parallel tasks |
| `quick.md` | Check for existing plan before skipping plan creation |

**Agents to update:**

| Agent | Change Needed |
|-------|---------------|
| `task-planner.md` | Generate parallel group annotations when creating plans |
| `code-explorer.md` | Output "Plan Integration" section with task dependencies discovered |
| `code-architect.md` | Output "Parallelization Opportunities" in blueprint |
| `test-generator.md` | Can run in parallel with implementation (add guidance) |
| `code-reviewer.md` | Note when findings require plan updates |

**Skills to update:**

| Skill | Change Needed |
|-------|---------------|
| `plan-management/SKILL.md` | Add parallel markers section, update format |
| `task-checkpoint/SKILL.md` | Check for parallel siblings, suggest spawning |

#### Part 3: Smart Parallelism Guidelines

Add to plan-management skill:

```markdown
## Parallelism Guidelines

### When to Parallelize
- **Read-only operations**: Multiple explorers, reviewers, analyzers
- **Independent implementations**: Tasks in same phase with no shared files
- **Test generation + implementation**: Tests can be written while implementing
- **Multiple audits**: Security auditors analyzing different domains

### When NOT to Parallelize
- **Dependent tasks**: Task B needs output from Task A
- **Same file modifications**: Risk of merge conflicts
- **Complex context sharing**: When agents need to coordinate
- **High token cost scenarios**: Opus agents running in parallel
- **User interaction required**: Can't ask questions from background agents

### Token Cost Awareness
| Scenario | Parallel? | Rationale |
|----------|-----------|-----------|
| 3x haiku explorers | Yes | Low cost, high benefit |
| 3x sonnet architects | Maybe | Medium cost, consider if needed |
| 3x opus reviewers | No | High cost, diminishing returns |
| 1 opus + 2 haiku | Yes | Balanced approach |
```

### Complexity Estimate
- **Size**: M (Medium)
- **Risk**: Low - additive changes, backwards compatible
- **Confidence**: High - patterns already proven in security plugin

### Key Discoveries
1. The plan-management skill is the right place to centralize this - it's already the authority
2. Security plugin's phased audit command is the gold standard for parallel agent orchestration
3. Most agents already have `permissionMode: plan` which means they can READ but not WRITE - good for parallel safety
4. The `[depends:X]` marker solves ordering without complex dependency graphs

### Risks & Concerns
1. **Risk**: Over-parallelization wastes tokens
   - **Mitigation**: Clear guidelines on when NOT to parallelize, token cost awareness section
2. **Risk**: Plan format changes break existing plans
   - **Mitigation**: New markers are optional, old format still works
3. **Risk**: Agents spawn too many parallel tasks
   - **Mitigation**: Explicit limits (e.g., "max 3 parallel agents") in guidelines

## Recommendation
**Proceed** - This is a valuable improvement that will:
1. Make devloop more consistent about plan updates
2. Enable smart parallel execution where appropriate
3. Reduce wasted effort when tasks can be done simultaneously
4. Keep token costs under control with clear guidelines

## Prototype Location
N/A - This is a documentation/process change, not code

## Next Steps

### If Proceeding to Implementation

1. **Update plan-management skill** (primary)
   - Add parallelism markers section
   - Add smart parallelism guidelines
   - Update task status markers table

2. **Update spike.md** (high priority)
   - Add Phase 6: Plan Integration
   - Require reading existing plan at start
   - Output plan update recommendations

3. **Update task-planner agent** (high priority)
   - Generate parallel annotations
   - Identify dependency chains
   - Document parallelization opportunities

4. **Update continue.md** (medium priority)
   - Detect parallel task groups
   - Offer to spawn parallel agents
   - Track parallel task progress

5. **Update individual agents** (lower priority)
   - Add plan context sections
   - Output plan integration recommendations

### Estimated Task Breakdown
- plan-management skill update: S
- spike.md update: S
- task-planner agent update: M
- continue.md update: M
- Individual agent updates (5-6 agents): S each, M total
- Testing and validation: S

**Total estimate**: M (could be done in phases)
