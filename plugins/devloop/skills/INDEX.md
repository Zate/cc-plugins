# Devloop Skills Index

Quick reference for all 28 devloop skills. Invoke with `Skill: <skill-name>`.

---

## Language Patterns

| Skill | Description |
|-------|-------------|
| `go-patterns` | Go-specific best practices including interfaces, error handling, goroutines, channels, testing patterns, and common idioms |
| `python-patterns` | Python-specific best practices including type hints, async patterns, testing with pytest, error handling, and common idioms |
| `java-patterns` | Java and Spring best practices including dependency injection, stream patterns, exception handling, testing, and common idioms |
| `react-patterns` | React and TypeScript best practices including hooks, component design, state management, performance optimization, and accessibility |
| `language-patterns-base` | Base template for language-specific pattern skills (defines common sections - do not invoke directly) |

---

## Workflow & Planning

| Skill | Description |
|-------|-------------|
| `workflow-selection` | Guide users in selecting the optimal development workflow based on task type |
| `plan-management` | Central reference for devloop plan file location, format, and update procedures |
| `phase-templates` | Reusable phase definitions for devloop workflows (discovery, implementation, review, handoff) |
| `task-checkpoint` | Complete checklist and verification for task completion in devloop workflows |
| `requirements-patterns` | Patterns for gathering, documenting, and validating software requirements |
| `complexity-estimation` | Framework for estimating task complexity using T-shirt sizing |

---

## Code Quality

| Skill | Description |
|-------|-------------|
| `architecture-patterns` | Guide architecture decisions with proven patterns for Go, TypeScript/React, Java, and general software design |
| `refactoring-analysis` | Comprehensive codebase analysis to identify refactoring opportunities, technical debt, and code quality issues |
| `testing-strategies` | Design comprehensive test strategies including unit tests, integration tests, E2E tests, and deployment validation |
| `security-checklist` | Security checklist covering OWASP Top 10, authentication, authorization, data protection, and secure coding practices |
| `api-design` | Best practices for designing RESTful and GraphQL APIs (endpoint naming, versioning, error handling, pagination) |
| `database-patterns` | Database design patterns including schema design, indexing strategies, query optimization, and migration best practices |

---

## Git & Version Control

| Skill | Description |
|-------|-------------|
| `git-workflows` | Git workflow patterns including branching strategies, commit conventions, code review, and release management |
| `atomic-commits` | Guidance for creating reviewable, atomic commits that capture logical units of work |
| `version-management` | Semantic versioning, CHANGELOG generation, and release management for devloop projects |
| `worklog-management` | Reference for managing the devloop worklog (completed work history with commit references) |

---

## Project Management

| Skill | Description |
|-------|-------------|
| `issue-tracking` | Unified issue tracking for bugs, features, tasks, and other work items (type-based IDs, smart routing) |
| `project-context` | Detects project tech stack, languages, frameworks, and features for development workflows |
| `project-bootstrap` | Best practices for bootstrapping new projects with CLAUDE.md and preparing them for devloop workflows |
| `deployment-readiness` | Comprehensive deployment validation checklist and test design for production readiness |

---

## Meta & Configuration

| Skill | Description |
|-------|-------------|
| `file-locations` | Authoritative reference for .devloop/ directory structure and file locations (git-tracked vs local-only) |
| `tool-usage-policy` | Consolidated guidance on which tools to use for common operations (prevents permission prompts) |
| `model-selection-guide` | Guidelines for choosing the optimal model (opus/sonnet/haiku) based on complexity and token budget |

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
