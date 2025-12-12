---
name: workflow-selection
description: Guide users in selecting the optimal development workflow based on task type. Use when task requirements are ambiguous or when user needs guidance on approach.
---

# Workflow Selection

Guidance for choosing the right development workflow based on task characteristics.

## When NOT to Use This Skill

- **Explicit user choice**: User already specified `/devloop:quick`, `/devloop:spike`, etc.
- **Obvious task type**: Clear feature request or bug fix - just start
- **Continuation**: Using `/devloop:continue` to resume existing work
- **Review/ship phases**: These are post-implementation, not workflow selection
- **Documentation only**: Doc updates don't need full workflow analysis

## Quick Reference

| Task Type | Workflow | Phases | When to Use |
|-----------|----------|--------|-------------|
| **Feature** | Full 7-phase | All | New functionality |
| **Bug Fix** | Streamlined 5-phase | Skip architecture | Defect correction |
| **Refactor** | Focused 6-phase | Extended analysis | Code improvement |
| **QA** | Test-focused 5-phase | Test design | Test development |

## Workflow Decision Tree

```
Start
  │
  ├─ Is this new functionality?
  │   └─ Yes → Feature Workflow
  │
  ├─ Is something broken/not working?
  │   └─ Yes → Bug Fix Workflow
  │
  ├─ Is this improving existing code without changing behavior?
  │   └─ Yes → Refactor Workflow
  │
  └─ Is this about testing/QA?
      └─ Yes → QA Workflow
```

## Feature Development Workflow

**Use when**: Adding new functionality, implementing requirements

**Phases**:
1. **Discovery**: Understand requirements
2. **Exploration**: Analyze codebase
3. **Clarifying Questions**: Resolve ambiguities
4. **Architecture Design**: Design approaches
5. **Implementation**: Build feature
6. **Quality Review**: Code review
7. **Summary**: Document completion

**Indicators**:
- "add", "create", "implement", "build"
- "new feature", "new functionality"
- Requirements for something that doesn't exist

**Model Strategy**:
- Phase 0-1: haiku (classification, discovery)
- Phase 2-3: sonnet (exploration, questions)
- Phase 4: sonnet/opus (architecture based on complexity)
- Phase 5: sonnet (implementation)
- Phase 6: opus (quality review)
- Phase 7: haiku (summary)

## Bug Fix Workflow

**Use when**: Correcting defective behavior, fixing errors

**Phases** (adapted):
1. **Discovery**: Understand the bug
2. **Investigation**: Reproduce and trace
3. **Fix**: Implement correction
4. **Test**: Verify fix, prevent regression
5. **Summary**: Document fix

**Skipped**: Architecture Design (usually not needed)

**Indicators**:
- "fix", "broken", "not working", "bug"
- "error", "fails", "crash", "issue"
- Something that used to work doesn't anymore

**Model Strategy**:
- Investigation: sonnet (needs context)
- Fix: sonnet
- Test: haiku (test generation)
- Review: opus (catch regressions)

**Key Focus**:
- Reproduce the bug first
- Understand root cause, not just symptoms
- Add regression test
- Verify no side effects

## Refactor Workflow

**Use when**: Improving code without changing behavior

**Phases** (adapted):
1. **Discovery**: Understand refactoring scope
2. **Analysis**: Deep dive into current state
3. **Planning**: Design refactoring approach
4. **Execution**: Apply changes incrementally
5. **Validation**: Ensure behavior unchanged
6. **Summary**: Document changes

**Extended**: Analysis phase (more exploration needed)

**Indicators**:
- "refactor", "clean up", "improve", "simplify"
- "technical debt", "code quality"
- "reorganize", "restructure"

**Model Strategy**:
- Analysis: sonnet (extended exploration)
- Planning: sonnet
- Execution: sonnet
- Validation: opus (critical - must verify no behavior change)

**Key Focus**:
- Tests must pass before AND after
- Make changes incrementally
- Preserve all existing behavior
- Document any intentional changes

## QA Workflow

**Use when**: Building test suites, improving coverage

**Phases** (adapted):
1. **Discovery**: Understand what needs testing
2. **Analysis**: Map testable components
3. **Design**: Plan test strategy
4. **Generation**: Create tests
5. **Validation**: Verify tests work

**Indicators**:
- "test", "coverage", "QA", "quality"
- "write tests", "add tests"
- "validate", "verify"

**Model Strategy**:
- Analysis: sonnet (understand code)
- Design: sonnet (test strategy)
- Generation: haiku (formulaic)
- Validation: sonnet (verify correctness)

**Key Focus**:
- Prioritize critical paths
- Balance unit/integration/E2E
- Test behavior, not implementation
- Consider edge cases

## Mixed Tasks

Sometimes tasks combine elements:

**"Fix the bug and add a feature"**:
→ Start with Bug Fix, then Feature workflow
→ Fix first, then build on stable foundation

**"Refactor and add tests"**:
→ Refactor workflow with QA emphasis
→ Add tests before/during refactoring

**"Add feature with full test coverage"**:
→ Feature workflow with test-generator in Phase 5
→ Use qa-agent in Phase 6

## Task Classification Indicators

### Feature Keywords
- add, create, implement, build
- new, feature, functionality
- capability, enhance, extend

### Bug Fix Keywords
- fix, repair, correct, resolve
- broken, not working, fails
- error, bug, issue, crash
- regression, unexpected

### Refactor Keywords
- refactor, clean, improve
- simplify, reorganize, restructure
- technical debt, code quality
- optimize, consolidate

### QA Keywords
- test, coverage, QA
- validate, verify, check
- quality, reliability

## When to Ask for Clarification

If classification is unclear:
1. Ask what outcome user expects
2. Ask if behavior should change
3. Ask about urgency/priority
4. Default to Feature if truly ambiguous

## See Also

- `Skill: model-selection-guide` - Choose right model per phase
- `Skill: testing-strategies` - Test design guidance
- `Skill: architecture-patterns` - For feature workflows
