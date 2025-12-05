---
name: model-selection-guide
description: Guidelines for choosing the optimal model (opus/sonnet/haiku) for different development tasks based on complexity, quality requirements, and token budget. Use when making model selection decisions or optimizing for token efficiency.
---

# Model Selection Guide

Strategic guidance for selecting the right model (opus, sonnet, or haiku) based on task characteristics.

## Quick Reference

| Task Type | Model | Thinking | Rationale |
|-----------|-------|----------|-----------|
| Task classification | haiku | off | Simple pattern matching |
| Code exploration | sonnet | off | Needs context understanding |
| Architecture (simple) | sonnet | off | Standard feature design |
| Architecture (complex) | opus | on (16k) | High-stakes decisions |
| Implementation | sonnet | off | Balanced capability |
| Code review | opus | on (8k) | Must catch subtle bugs |
| Test generation | haiku | off | Formulaic patterns |
| Documentation | haiku | off | Structured output |
| Refactoring analysis | sonnet | off | Pattern recognition |
| Security review | opus | on (8k) | Critical, subtle issues |
| Bug investigation | sonnet | off | Needs context |
| Summary generation | haiku | off | Simple synthesis |

## Target Distribution: 20/60/20

For optimal quality/cost balance:
- **20% Opus**: Architecture, final review, security audit, complex debugging
- **60% Sonnet**: Exploration, design, implementation, most analysis
- **20% Haiku**: Classification, test generation, documentation, simple tasks

## When to Use Each Model

### Haiku (Speed Tier)

**Use when**:
- Task is formulaic (follows clear patterns)
- Speed matters more than depth
- Context is small and focused
- Output is structured/predictable

**Examples**:
- Classifying task type (feature vs bug fix)
- Generating tests from templates
- Writing documentation
- Simple file operations
- Parsing and reformatting

**Token savings**: ~80% vs sonnet

### Sonnet (Workhorse Tier)

**Use when**:
- Task requires understanding context
- Balanced speed and quality needed
- Standard complexity work
- Most implementation tasks

**Examples**:
- Code exploration and tracing
- Standard architecture design
- Feature implementation
- Bug investigation
- Refactoring execution

**Default choice for most work**

### Opus (Quality Tier)

**Use when**:
- Subtle issues must be caught
- High-stakes decisions
- Complex multi-step reasoning
- Deep architectural analysis
- Security-critical code

**Examples**:
- Final code review before merge
- Complex architecture decisions
- Security vulnerability analysis
- Performance optimization
- Catching async/race condition bugs

**Token cost**: ~5x sonnet

## Thinking Mode Guidelines

### When to Enable Thinking

Enable extended thinking when:
- Task complexity > 7/10
- Architectural decisions with trade-offs
- Complex debugging scenarios
- Multi-step reasoning required
- Security analysis

### Thinking Budget Recommendations

| Scenario | Budget |
|----------|--------|
| Simple analysis | 4,000 tokens |
| Standard architecture | 8,000 tokens |
| Complex decisions | 16,000 tokens |
| Deep debugging | 16,000 tokens |

## Escalation Rules

### Upgrade from sonnet → opus when:
- Complexity score exceeds 8/10
- Security-sensitive code detected
- Production-critical path
- Previous review missed issues
- User explicitly requests thoroughness

### Downgrade from sonnet → haiku when:
- Task is clearly formulaic
- Following established patterns
- Speed is priority
- Low-risk operations
- Simple transformations

## Cost Optimization Strategies

### 1. Start Fast, Escalate as Needed
Begin with haiku for classification, escalate to sonnet/opus based on detected complexity.

### 2. Parallel Haiku Agents
For exploration, run multiple haiku agents in parallel instead of one sonnet agent.

### 3. Opus for Final Pass Only
Use sonnet for initial work, opus only for final review.

### 4. Cache Exploration Results
Reuse exploration findings across phases to avoid re-analysis.

## Model Selection by Phase

### Feature Development Workflow

| Phase | Primary Model | Fallback |
|-------|--------------|----------|
| Phase 0: Detection | haiku | - |
| Phase 1: Discovery | sonnet | haiku |
| Phase 2: Exploration | sonnet | - |
| Phase 3: Questions | sonnet | - |
| Phase 4: Architecture | sonnet/opus* | - |
| Phase 5: Implementation | sonnet | - |
| Phase 6: Review | opus | sonnet |
| Phase 7: Summary | haiku | - |

*Use opus for complex features, sonnet for standard

## Token Budget Management

### Session Budget Tracking
- Monitor cumulative token usage
- Warn at 80% budget
- Enforce downgrades at 90% budget

### Per-Phase Budgets (Example 100k session)
- Exploration: 20k
- Architecture: 25k
- Implementation: 30k
- Review: 20k
- Other: 5k

## See Also

- `references/complexity-scoring.md` - How to score task complexity
- `references/thinking-mode.md` - Extended thinking best practices
