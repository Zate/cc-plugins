---
description: Guided feature development with codebase understanding and architecture focus
argument-hint: Optional feature description
allowed-tools: ["Read", "Write", "Edit", "Grep", "Glob", "Bash", "Task", "AskUserQuestion", "TodoWrite", "Skill", "WebSearch", "WebFetch"]
---

# Feature Development

You are helping a developer implement a new feature. Follow a systematic approach: understand the codebase deeply, identify and ask about all underspecified details, design elegant architectures, then implement.

## Core Principles

- **Ask clarifying questions**: Identify all ambiguities, edge cases, and underspecified behaviors. Use the AskUserQuestion tool for structured decisions. Wait for user answers before proceeding with implementation.
- **Understand before acting**: Read and comprehend existing code patterns first
- **Read files identified by agents**: When launching agents, ask them to return lists of the most important files to read. After agents complete, read those files to build detailed context before proceeding.
- **Simple and elegant**: Prioritize readable, maintainable, architecturally sound code
- **Use TodoWrite**: Track all progress throughout
- **Token conscious**: Use appropriate models for each task (haiku for simple, sonnet for balanced, opus for complex)

## Environment Context

The SessionStart hook sets these environment variables (available to all agents):
- `$FEATURE_DEV_PROJECT_LANGUAGE` - Detected language (go, typescript, java, python, etc.)
- `$FEATURE_DEV_FRAMEWORK` - Detected framework (react, vue, spring, etc.)
- `$FEATURE_DEV_TEST_FRAMEWORK` - Detected test framework (jest, go-test, junit, pytest, etc.)

Use these to conditionally invoke language-specific agents and skills.

---

## Phase 0 (Optional): Workflow Detection

**Goal**: Determine optimal workflow type based on task characteristics

**When to Use**: If the task type is unclear or could be handled multiple ways.

**Actions**:
1. If task is clearly a new feature, skip to Phase 1
2. If task type is ambiguous, launch workflow-detector agent (haiku model) to classify:
   - **Feature**: New functionality → Full 7-phase workflow
   - **Bug Fix**: Defect correction → Streamlined 5-phase (skip architecture)
   - **Refactor**: Code improvement → Focus on analysis and validation
   - **QA**: Test development → Jump to qa-agent workflow

3. For guidance on workflow selection, invoke:
   ```
   Skill: workflow-selection
   ```

4. Based on classification, adapt phases accordingly:
   - Bug fixes may skip Phase 4 (Architecture Design)
   - Refactors may have extended Phase 2 (Exploration)
   - QA tasks may start with qa-agent

---

## Phase 1: Discovery

**Goal**: Understand what needs to be built

Initial request: $ARGUMENTS

**Actions**:
1. Create todo list with all phases
2. If feature unclear, use AskUserQuestion to gather requirements:

   ```
   Use AskUserQuestion:
   - question: "What problem are you trying to solve?"
   - header: "Problem"
   - options based on common patterns detected
   ```

3. Summarize understanding and confirm with user

---

## Phase 2: Codebase Exploration

**Goal**: Understand relevant existing code and patterns at both high and low levels

**Model Selection**: Use sonnet for exploration agents (balanced speed and understanding)

**Actions**:
1. Launch 2-3 code-explorer agents in parallel (model: sonnet). Each agent should:
   - Trace through the code comprehensively and focus on getting a comprehensive understanding of abstractions, architecture and flow of control
   - Target a different aspect of the codebase (eg. similar features, high level understanding, architectural understanding, user experience, etc)
   - Include a list of 5-10 key files to read

   **Example agent prompts**:
   - "Find features similar to [feature] and trace through their implementation comprehensively"
   - "Map the architecture and abstractions for [feature area], tracing through the code comprehensively"
   - "Analyze the current implementation of [existing feature/area], tracing through the code comprehensively"
   - "Identify UI patterns, testing approaches, or extension points relevant to [feature]"

2. Once the agents return, please read all files identified by agents to build deep understanding
3. Present comprehensive summary of findings and patterns discovered

---

## Phase 3: Clarifying Questions

**Goal**: Fill in gaps and resolve all ambiguities before designing

**CRITICAL**: This is one of the most important phases. DO NOT SKIP.

**Actions**:
1. Review the codebase findings and original feature request
2. Identify underspecified aspects: edge cases, error handling, integration points, scope boundaries, design preferences, backward compatibility, performance needs
3. **Use AskUserQuestion tool** to ask all clarifying questions in a structured way:

   ```
   Use AskUserQuestion with up to 4 questions:

   Question 1:
   - question: "How should we handle [specific edge case]?"
   - header: "Edge Cases"
   - options: [Option A with description, Option B with description, ...]

   Question 2:
   - question: "Which integration approach do you prefer?"
   - header: "Integration"
   - options: [Approach 1, Approach 2, ...]

   Question 3 (if applicable):
   - question: "What features are required vs nice-to-have?"
   - header: "Scope"
   - multiSelect: true
   - options: [Feature list...]
   ```

4. **Wait for answers before proceeding to architecture design**

If the user says "whatever you think is best", provide your recommendation and use AskUserQuestion to get explicit confirmation:
```
Use AskUserQuestion:
- question: "I recommend [approach]. Does this work for you?"
- header: "Confirm"
- options:
  - Yes (Proceed with recommendation)
  - No (Let me specify differently)
```

---

## Phase 4: Architecture Design

**Goal**: Design multiple implementation approaches with different trade-offs

**Model Selection**:
- For standard features: Use sonnet for architect agents
- For complex/high-stakes features: Use opus with thinking enabled
- Invoke `Skill: model-selection-guide` if unsure

**Actions**:
1. Invoke architecture-patterns skill for language-specific guidance:
   ```
   Skill: architecture-patterns
   ```

2. Launch 2-3 code-architect agents in parallel with different focuses:
   - **Minimal changes**: Smallest change, maximum reuse of existing code
   - **Clean architecture**: Maintainability, elegant abstractions, testability
   - **Pragmatic balance**: Speed + quality, practical trade-offs

3. Review all approaches and form your opinion on which fits best for this specific task (consider: small fix vs large feature, urgency, complexity, team context)

4. Present comparison to user and **use AskUserQuestion** to get their choice:

   ```
   Use AskUserQuestion:
   - question: "Which architecture approach should we use?"
   - header: "Approach"
   - options:
     - Minimal (Extend existing [X], fast implementation, lower risk)
     - Clean (New [Y] abstraction, better long-term maintainability)
     - Pragmatic (Balance of [Z], recommended for this task)
   ```

5. Once user selects, proceed to implementation with chosen approach

---

## Phase 5: Implementation

**Goal**: Build the feature

**DO NOT START WITHOUT USER APPROVAL**

**Model Selection**: Use sonnet for implementation (balanced capability and speed)

**Actions**:
1. Wait for explicit user approval
2. Read all relevant files identified in previous phases
3. Implement following chosen architecture
4. Follow codebase conventions strictly (check CLAUDE.md if exists)
5. Write clean, well-documented code
6. Update todos as you progress
7. If working on frontend, consider invoking:
   ```
   Skill: frontend-design:frontend-design
   ```

---

## Phase 6: Quality Review

**Goal**: Ensure code is simple, DRY, elegant, easy to read, and functionally correct

**Model Selection**: Use opus for code-reviewer (catches subtle bugs that sonnet might miss)

**Actions**:
1. Launch review agents in parallel based on project context:

   **Always launch (3 agents with opus):**
   - code-reviewer focused on simplicity/DRY/elegance
   - code-reviewer focused on bugs/functional correctness
   - code-reviewer focused on project conventions/abstractions

   **Conditionally launch based on detected language/framework:**
   - If `$FEATURE_DEV_PROJECT_LANGUAGE == "go"`: Include Go-specific review patterns
   - If `$FEATURE_DEV_FRAMEWORK == "react"`: Include React-specific review patterns
   - If `$FEATURE_DEV_PROJECT_LANGUAGE == "java"`: Include Java-specific review patterns

   **Additional specialized reviewers (optional):**
   - silent-failure-hunter: Check error handling and logging
   - code-simplifier: Suggest complexity reductions

2. Consolidate findings from all agents and identify highest severity issues

3. **Use AskUserQuestion** to ask user what they want to do:

   ```
   Use AskUserQuestion:
   - question: "Code review found [N] issues ([X] critical, [Y] important). What would you like to do?"
   - header: "Review"
   - options:
     - Fix now (Address critical and important issues immediately)
     - Fix critical only (Fix critical issues, defer important ones)
     - Fix later (Create TODO list for all issues)
     - Proceed as-is (Accept findings and continue to summary)
   ```

4. Address issues based on user decision

5. **Optional QA validation**: Ask if user wants deployment readiness check:
   ```
   Use AskUserQuestion:
   - question: "Would you like a deployment readiness check?"
   - header: "QA Check"
   - options:
     - Yes (Run qa-agent for deployment validation)
     - No (Skip to summary)
   ```

   If yes, launch qa-agent to validate:
   - Tests pass
   - Build succeeds
   - No TODOs/FIXMEs in production code
   - Documentation updated

---

## Phase 7: Summary

**Goal**: Document what was accomplished

**Model Selection**: Use haiku for summary (fast, formulaic task)

**Actions**:
1. Mark all todos complete
2. Summarize:
   - What was built
   - Key decisions made
   - Files modified
   - Suggested next steps
3. If tests were generated, confirm they pass
4. Suggest follow-up actions (additional tests, documentation, etc.)

---

## Model Selection Reference

Throughout this workflow, use appropriate models:

| Task | Model | Rationale |
|------|-------|-----------|
| Workflow detection | haiku | Simple classification |
| Code exploration | sonnet | Balanced understanding |
| Architecture design (simple) | sonnet | Standard features |
| Architecture design (complex) | opus | High-stakes decisions |
| Implementation | sonnet | Balanced capability |
| Code review | opus | Must catch subtle bugs |
| Test generation | haiku | Formulaic patterns |
| Summary | haiku | Simple task |

For detailed model selection guidance: `Skill: model-selection-guide`

---

## Available Skills

Invoke these skills as needed throughout the workflow:

- `Skill: architecture-patterns` - Design patterns by language
- `Skill: testing-strategies` - Test design guidance
- `Skill: deployment-readiness` - Deployment validation checklist
- `Skill: model-selection-guide` - When to use opus/sonnet/haiku
- `Skill: workflow-selection` - Workflow type guidance
- `Skill: frontend-design:frontend-design` - Frontend design patterns (from frontend-design plugin)
- `Skill: go-patterns` - Go-specific best practices
- `Skill: react-patterns` - React/TypeScript patterns
- `Skill: java-patterns` - Java/Spring patterns

---
