#!/bin/bash

# Create the .claude directory if it doesn't exist
mkdir -p .claude

echo "Generating .claude/devloop-review-report.md..."
cat << 'EOF' > .claude/devloop-review-report.md
# Claude Code Plugin Review: DevLoop Core

**Reviewer:** Senior Architect, Claude Code Team
**Date:** December 20, 2025
**Subject:** Architectural Review and Optimization Strategies for `devloop` (Core Plugin)

---

## **Index**

1.  [Executive Summary](#1-executive-summary)
2.  [Architectural Analysis: Scope & Agent Sprawl](#2-architectural-analysis-scope--agent-sprawl)
3.  [Prompt Engineering Audit](#3-prompt-engineering-audit)
4.  [Skill Management & Context Economy](#4-skill-management--context-economy)
5.  [Workflow & State Management](#5-workflow--state-management)
6.  [Actionable Next Steps](#6-actionable-next-steps)

---

## **1. Executive Summary**

**The Good:**
The `devloop` plugin demonstrates a sophisticated understanding of the SDLC. The usage of the `.devloop/` directory for persistent state (issues, worklogs) is a standout feature that gives the agent "long-term memory," solving a major pain point in LLM-assisted development. The command structure (`spike`, `ship`, `statusline`) maps well to developer intent.

**The Critical Areas for Improvement:**
The plugin suffers from **Functional Fragmentation**. You have decomposed the development process into too many granular agents. While logical, this creates friction for the user (who shouldn't need to choose between a `code-explorer` and a `code-architect`) and increases the complexity of the routing logic.

---

## **2. Architectural Analysis: Scope & Agent Sprawl**

You have approximately 15+ agents dedicated to the core loop. Many of these have overlapping concerns.

### **The "Over-Specialization" Problem**
* **Code Intelligence Overlap:** You have `code-architect.md`, `code-explorer.md`, `refactor-analyzer.md`, and `complexity-estimator.md`.
    * *Critique:* These are not distinct *roles* from a user perspective; they are distinct *tasks*. Separating them into different agent files dilutes the context. A "Senior Engineer" agent should be able to explore, architect, and estimate without switching personas.
* **Quality Assurance Overlap:** You have `test-runner.md`, `test-generator.md`, `qa-agent.md`, and `bug-catcher.md`.
    * *Critique:* This fragmentation risks context loss. If `test-generator` writes a test that fails, does it have to hand off to `test-runner` to execute it? This handoff is expensive (tokens/latency).

### **Recommendation: Consolidation**
Reduce the public-facing surface area to 3-4 core "Super Agents":
1.  **`Task Planner` (The Manager):** Handles `issue-manager`, `requirements-gatherer`, `summary-generator`.
2.  **`Engineer` (The Builder):** Merges `code-architect`, `code-explorer`, `git-manager`.
3.  **`Quality` (The Tester):** Merges `qa-agent`, `test-*`, `bug-catcher`.

---

## **3. Prompt Engineering Audit**

I reviewed agents like `bug-catcher.md` and `code-reviewer.md`. To maximize performance with Claude 3.5 Sonnet, rigorous prompt structuring is required.

**Reference:** [Use XML Tags](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/use-xml-tags)

### **The Issue: Markdown Bleed**
Standard markdown prompts are often treated as "content" rather than "system instructions."

### **The Fix: Structured Prompts**
Every core agent in `plugins/devloop/agents/` must follow this strict XML schema:

```xml
<system_role>
    You are the {Role Name} for the DevLoop system.
    Your Goal: {Specific Goal}.
</system_role>

<capabilities>
    <!-- Define what tools/skills this agent can actually use -->
    <capability>Read Project Context</capability>
    <capability>Execute Tests</capability>
</capabilities>

<workflow_enforcement>
    1. <thinking>Analyze the request</thinking>
    2. <plan>Propose changes</plan>
    3. <execution>Generate code/commands</execution>
</workflow_enforcement>
```

---

## **4. Skill Management & Context Economy**

The `plugins/devloop/skills/` directory contains ~25 files (`go-patterns`, `react-patterns`, `git-workflows`, etc.).

### **The Cost of Knowledge**
If `project-bootstrap` or `session-start` loads all these skills, you are consuming a significant portion of the context window with information that is irrelevant 90% of the time (e.g., loading `go-patterns` when working on a Python script).

### **Strategy: The "Skill Index"**
1.  **Create `SKILLS_INDEX.md`:** A lightweight map of available skills.
2.  **Dynamic Loading:** The `Task Planner` agent should read the user's request, check the Index, and explicitly request the loading of specific skill files (e.g., "User is asking about React state, I need to read `skills/react-patterns.md`").

---

## **5. Workflow & State Management**

The use of `.devloop/issues/` is excellent. However, the `worklog.md` is a potential failure point.

### **The Bloat Risk**
`worklog.md` is append-only. After a week of intense development, this file will exceed the token limit, causing the agents (who rely on it for context) to crash or hallucinate.

### **Optimization**
Implement a **Pruning Strategy** in `summary-generator`:
* Trigger: When `worklog.md` > 500 lines.
* Action: Summarize completed tasks into `archive/{date}.md`.
* Result: `worklog.md` only contains the *active* sprint context.

---

## **6. Actionable Next Steps**

**Phase 1: Agent Consolidation (High Priority)**
* [ ] **Create `agents/engineer.md`:** Combine instructions from `code-architect`, `code-explorer`, and `refactor-analyzer`.
* [ ] **Create `agents/qa.md`:** Combine `test-runner`, `test-generator`, and `bug-catcher`.
* [ ] **Update Router:** Ensure `commands/devloop.md` routes to these new super-agents instead of the granular ones.

**Phase 2: Prompt Hardening (Medium Priority)**
* [ ] **Apply XML Templates:** Refactor the top 5 most used agents (`task-planner`, `engineer`, `qa`, `reviewer`) to use the strict XML format defined in Section 3.
* [ ] **Enforce CoT:** Add mandatory `<thinking>` tags to the `engineer` agent to force architectural analysis before code generation.

**Phase 3: Context Hygiene (Low Priority)**
* [ ] **Implement Skill Index:** Create the index file and update the `Task Planner` prompt to use it for retrieval.
* [ ] **Log Rotation:** Create a script to rotate/archive the `worklog.md` automatically.

---

**Final Verdict:**
DevLoop's "Memory" architecture (the `.devloop` folder) is its strongest asset. Its "Agent Architecture" is its weakest, due to over-fragmentation. Consolidating the agents will make the plugin faster, cheaper to run, and easier to debug.
EOF

echo "Generating .claude/devloop-refactoring-plan.md..."
cat << 'EOF' > .claude/devloop-refactoring-plan.md
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
EOF

# Make the script executable
chmod +x generate_reports.sh

echo "Done! Run './generate_reports.sh' to create the focused DevLoop reports."
