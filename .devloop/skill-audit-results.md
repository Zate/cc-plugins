# Skill Description Audit Results

**Date**: 2025-12-25
**Total Skills**: 29
**Audit Goal**: Identify skills needing trigger phrase improvements

---

## Summary

### ✅ GOOD - Already Has Trigger Phrases (11 skills)
These skills already have clear "This skill should be used when..." format:

1. **refactoring-analysis** - ✅ Multiple "when user asks..." trigger phrases (lines 8-15)
2. **atomic-commits** - ✅ Clear "Use when deciding whether to commit..." (line 3)
3. **worklog-management** - ✅ Clear "Use when..." sections (lines 10-16)
4. **task-checkpoint** - ✅ Clear "Use after completing..." (line 3)
5. **file-locations** - ✅ Clear "Use when creating devloop artifacts..." (line 3)
6. **version-management** - ✅ Clear "Use when completing phases..." (line 3)
7. **issue-tracking** - ✅ Bullet list of when to use (lines 12-16)
8. **workflow-selection** - ✅ Clear "Use when task requirements are ambiguous" (line 3)
9. **project-context** - ✅ Clear "Use when you need to understand project structure" (line 3)
10. **project-bootstrap** - ✅ Clear "Use when starting new projects..." (line 3)
11. **complexity-estimation** - ✅ Clear "Use at the start of features" (line 3)

### ⚠️ NEEDS IMPROVEMENT - Missing Strong Trigger Phrases (18 skills)

#### Priority 1: Core Skills (High Impact)
These are frequently used and need trigger phrases first:

1. **plan-management** (line 3)
   - Current: "Central reference for devloop plan file location..."
   - Needs: "This skill should be used when the user asks about 'plan format', 'update plan', '.devloop/plan.md', 'task status markers', or needs plan file conventions."
   - Has: "When to Use" section but description lacks trigger phrases

2. **workflow-loop** (line 2)
   - Current: "Standard patterns for multi-task workflows..."
   - Needs: "This skill should be used when the user asks to 'implement checkpoints', 'workflow loop', 'task completion pattern', or needs patterns for sequential task orchestration."
   - Has: whenToUse/whenNotToUse fields (good!)

3. **go-patterns** (line 3)
   - Current: "Go-specific best practices..."
   - Needs: "This skill should be used when working with Go code, implementing Go features, or when the user asks about 'Go idioms', 'goroutines', 'Go interfaces', 'Go error handling', 'Go testing'."

4. **react-patterns** (line 3)
   - Current: "React and TypeScript best practices..."
   - Needs: "This skill should be used when working with React code, implementing React features, or when the user asks about 'React hooks', 'React components', 'React state management', 'React performance'."

5. **python-patterns** (line 3)
   - Current: "Python-specific best practices..."
   - Needs: "This skill should be used when working with Python code, implementing Python features, or when the user asks about 'Python idioms', 'Python async', 'type hints', 'pytest'."

6. **java-patterns** (line 3)
   - Current: "Java and Spring best practices..."
   - Needs: "This skill should be used when working with Java code, implementing Java/Spring features, or when the user asks about 'dependency injection', 'Java streams', 'Spring Boot'."

#### Priority 2: Design/Architecture Skills (Medium Impact)

7. **architecture-patterns** (line 3)
   - Current: "Guide architecture decisions with proven patterns..."
   - Needs: "This skill should be used when the user asks to 'design architecture', 'choose design pattern', 'structure code', or needs architectural guidance for Go, TypeScript/React, or Java."

8. **api-design** (line 3)
   - Current: "Best practices for designing RESTful and GraphQL APIs..."
   - Needs: "This skill should be used when the user asks to 'design API', 'create endpoints', 'API versioning', 'REST API', 'GraphQL API', or needs API design guidance."

9. **database-patterns** (line 3)
   - Current: "Database design patterns including schema design..."
   - Needs: "This skill should be used when the user asks about 'database schema', 'database design', 'query optimization', 'indexing', 'migrations', or needs database guidance."

10. **testing-strategies** (line 3)
    - Current: "Design comprehensive test strategies..."
    - Needs: "This skill should be used when the user asks to 'design tests', 'test strategy', 'test coverage', 'unit tests', 'integration tests', 'E2E tests', or needs testing guidance."

#### Priority 3: Workflow/Process Skills (Medium Impact)

11. **git-workflows** (line 3)
    - Current: "Git workflow patterns including branching..."
    - Needs: "This skill should be used when the user asks about 'git workflow', 'branching strategy', 'commit conventions', 'code review process', or needs git workflow guidance."

12. **security-checklist** (line 3)
    - Current: "Security checklist covering OWASP Top 10..."
    - Needs: "This skill should be used when the user asks to 'security review', 'OWASP', 'security audit', 'vulnerability scan', or needs security guidance during code review."

13. **deployment-readiness** (line 3)
    - Current: "Comprehensive deployment validation checklist..."
    - Needs: "This skill should be used when the user asks about 'deployment readiness', 'production checklist', 'ship feature', 'deployment validation', or needs pre-deployment guidance."

14. **requirements-patterns** (line 3)
    - Current: "Patterns for gathering, documenting, and validating..."
    - Needs: "This skill should be used when the user asks to 'gather requirements', 'write user stories', 'acceptance criteria', 'scope management', or needs requirements guidance."

#### Priority 4: Reference/Template Skills (Lower Impact)

15. **phase-templates** (line 3)
    - Current: "Reusable phase definitions for devloop workflows..."
    - Needs: "This skill should be used by devloop commands/agents when executing standard phases (discovery, implementation, review). Not for direct user invocation."

16. **tool-usage-policy** (line 3)
    - Current: "Consolidated guidance on which tools to use..."
    - Needs: "This skill should be used when planning file operations, search workflows, or before using Bash for file tasks to ensure proper tool selection."

17. **model-selection-guide** (line 3)
    - Current: "Guidelines for choosing the optimal model..."
    - Needs: "This skill should be used when making model selection decisions (opus/sonnet/haiku) for agents or optimizing for token efficiency."

18. **language-patterns-base** (line 3)
    - Current: "Base template for language-specific pattern skills..."
    - Needs: "DO NOT invoke this skill directly. Use language-specific skills (go-patterns, python-patterns, etc.) instead. This is a template only."

---

## Skills Missing "When NOT to Use" Sections (4 skills)

Most skills already have this section. Only these are missing it:

1. **plan-management** - Has "When to Use" (line 10) but no "When NOT to Use"
2. **version-management** - Has "When to Use" (line 12) but truncated at line 20
3. **tool-usage-policy** - Has "When to Use" (line 11) but truncated at line 20
4. **language-patterns-base** - Has it but is a template (line 10)

---

## Prioritized Task List for Phase 2

### Task 2.1: ✅ COMPLETE (this audit)

### Task 2.2: Fix plan-management
- Add trigger phrases to description (line 3)
- Add "When NOT to Use" section after line 20

### Task 2.3: Fix workflow-loop
- Add trigger phrases to description (line 2)
- Already has whenToUse/whenNotToUse fields ✅

### Task 2.4: Fix go-patterns
- Add trigger phrases to description (line 3)
- Already has "When NOT to Use" section ✅

### Task 2.5: Fix language-specific patterns (parallel group)
- react-patterns (line 3)
- python-patterns (line 3)
- java-patterns (line 3)

### Task 2.6: Fix design/architecture skills (parallel group)
- architecture-patterns (line 3)
- api-design (line 3)
- database-patterns (line 3)
- testing-strategies (line 3)

### Task 2.7: Fix workflow/process skills (parallel group)
- git-workflows (line 3)
- security-checklist (line 3)
- deployment-readiness (line 3)
- requirements-patterns (line 3)

### Task 2.8: Fix reference/template skills (parallel group)
- phase-templates (line 3)
- tool-usage-policy (line 3) + add "When NOT to Use"
- model-selection-guide (line 3)
- version-management (line 3) + add "When NOT to Use"

### Task 2.9: Fix template skill
- language-patterns-base (line 3) - Make it clear this is NOT user-invocable

---

## Pattern for Trigger Phrases

**Good examples from audit:**

1. **Specific user queries**: "This skill should be used when the user asks about 'plan format', 'update plan'..."
2. **Task context**: "Use when working with Go code, implementing Go features..."
3. **Workflow stage**: "Use after completing implementation, before marking tasks complete..."
4. **Agent invocation**: "Use by devloop commands/agents when executing standard phases..."

**Bad examples to avoid:**
- Vague: "Central reference for..." (doesn't trigger Claude to invoke)
- Feature list: "Best practices for X, Y, Z" (describes content, not when to use)
- Academic: "Comprehensive guidance for..." (too formal, not actionable)

---

## Estimated Work

- **Priority 1 (6 skills)**: ~1 hour - Core skills, high impact
- **Priority 2 (4 skills)**: ~45 min - Design/architecture
- **Priority 3 (4 skills)**: ~45 min - Workflow/process
- **Priority 4 (4 skills)**: ~30 min - Reference/templates

**Total**: ~3 hours for all 18 skills

**Recommendation**: Break into parallel groups by priority for efficient completion.
