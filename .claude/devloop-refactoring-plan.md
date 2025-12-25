# DevLoop Refactoring Plan (Agent Instructions)

This plan focuses exclusively on the `devloop` plugin. Use this checklist to guide the refactoring.

## 1. Agent Consolidation (The "Super Agent" Strategy)
**Goal:** Reduce the active agent count from ~15 to 4 core personas to improve routing accuracy and context retention.

- **Task 1.1: Build the 'Engineer' Persona**
    - Create `plugins/devloop/agents/engineer.md`.
    - Content: Merge logical instructions from:
        - `code-architect.md` (Design patterns, structure)
        - `code-explorer.md` (Navigation, understanding)
        - `refactor-analyzer.md` (Code improvement)
    - *Action:* Once created, delete the 3 source files.

- **Task 1.2: Build the 'QA' Persona**
    - Create `plugins/devloop/agents/qa-engineer.md`.
    - Content: Merge logical instructions from:
        - `test-generator.md`
        - `test-runner.md`
        - `bug-catcher.md`
    - *Action:* Once created, delete the 3 source files.

- **Task 1.3: Build the 'Manager' Persona**
    - Enhance `plugins/devloop/agents/task-planner.md`.
    - Absorb responsibilities from:
        - `issue-manager.md`
        - `requirements-gatherer.md`
        - `dod-validator.md`
    - *Action:* Delete the absorbed files.

## 2. Prompt Engineering (Guardrails)
**Goal:** Prevent agent drift using XML structure.

- **Task 2.1: Template Creation**
    - Create a standard XML wrapper in `docs/templates/agent_prompt_structure.xml`.
    
- **Task 2.2: Apply to Core Agents**
    - Rewrite `engineer.md`, `qa-engineer.md`, and `task-planner.md` using the XML structure.
    - Ensure `<thinking>` tags are mandatory before any `<command>` execution.
    - Ensure `<context>` tags explicitly reference how to read `.devloop/issues`.

## 3. Context Optimization
**Goal:** Reduce token usage during session boot.

- **Task 3.1: Skill Indexing**
    - Create `plugins/devloop/skills/INDEX.md` listing all skills with a 1-line summary.
    - Remove direct loading of all 25 distinct skill files from `bootstrap` or `session-start` scripts.
    - Update `task-planner` instructions to read `INDEX.md` first, then read specific skill files only when needed.

## 4. Maintenance Scripting
**Goal:** Automate hygiene.

- **Task 4.1: Log Rotation**
    - Create `plugins/devloop/scripts/rotate-worklog.sh`.
    - Logic: If `worklog.md` > 500 lines, move content to `.devloop/archive/worklog-YYYY-MM-DD.md` and recreate empty worklog.
