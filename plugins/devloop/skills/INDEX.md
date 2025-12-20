# Devloop Skills Index

Quick reference for all 28 devloop skills. Invoke with `Skill: <skill-name>`.

---

## Language Patterns

| Skill | Description |
|-------|-------------|
| `go-patterns` | Go interfaces, error handling, goroutines, channels, testing patterns (Go 1.21+) |
| `python-patterns` | Type hints, async patterns, pytest testing, error handling (Python 3.10+) |
| `java-patterns` | Spring DI, streams, exception handling, JUnit testing (Java 17+) |
| `react-patterns` | Hooks, component design, state management, performance, accessibility (React 18+) |
| `language-patterns-base` | Base template for language skills - do not invoke directly |

---

## Workflow & Planning

| Skill | Description |
|-------|-------------|
| `workflow-selection` | Choose optimal workflow (devloop/quick/spike) based on task type |
| `plan-management` | Plan file format, location, and update procedures |
| `phase-templates` | Reusable phase definitions for discovery, implementation, review |
| `task-checkpoint` | Verification checklist before marking tasks complete |
| `requirements-patterns` | User stories, acceptance criteria, scope management |
| `complexity-estimation` | T-shirt sizing, risk factors, spike/POC decision criteria |

---

## Code Quality

| Skill | Description |
|-------|-------------|
| `architecture-patterns` | Design patterns for Go, TypeScript/React, Java, general software |
| `refactoring-analysis` | Identify tech debt, code smells, refactoring opportunities |
| `testing-strategies` | Unit/integration/E2E test design and coverage planning |
| `security-checklist` | OWASP Top 10, auth, data protection, secure coding |
| `api-design` | REST/GraphQL endpoint naming, versioning, error handling |
| `database-patterns` | Schema design, indexing, query optimization, migrations |

---

## Git & Version Control

| Skill | Description |
|-------|-------------|
| `git-workflows` | Branching strategies, commit conventions, code review |
| `atomic-commits` | Logical commit grouping and reviewable commit structure |
| `version-management` | Semantic versioning, CHANGELOG generation, releases |
| `worklog-management` | Completed work history format and commit integration |

---

## Project Management

| Skill | Description |
|-------|-------------|
| `issue-tracking` | Unified issue tracking (BUG/FEAT/TASK/CHORE/SPIKE IDs) |
| `project-context` | Detect tech stack, languages, frameworks, project type |
| `project-bootstrap` | CLAUDE.md setup, new project initialization |
| `deployment-readiness` | Production validation checklist and deployment tests |

---

## Meta & Configuration

| Skill | Description |
|-------|-------------|
| `file-locations` | .devloop/ directory structure, git tracking guidelines |
| `tool-usage-policy` | Standard tool usage for file ops, search, permissions |
| `model-selection-guide` | Opus/sonnet/haiku selection based on task complexity |

---

## Quick Selection Guide

**Starting a feature?**
- `workflow-selection` → Choose approach
- `project-context` → Understand tech stack
- `complexity-estimation` → Set expectations

**Writing code?**
- `{lang}-patterns` → Language-specific guidance
- `architecture-patterns` → Design decisions
- `testing-strategies` → Test coverage

**Finishing work?**
- `task-checkpoint` → Verify completeness
- `atomic-commits` → Structure commits
- `deployment-readiness` → Ship safely
