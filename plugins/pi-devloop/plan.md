# Pi Devloop Extension Implementation Plan

This document outlines the phased approach to building the `devloop` engine as a native extension for Pi (`@mariozechner/pi-coding-agent`).

## Phase 1: Setup & Scaffolding
**Goal**: Create a valid, loading Pi Extension package.
- Initialize `plugins/pi-devloop` with a `package.json` specifying dependencies (e.g., `typebox`).
- Setup `src/index.ts` with the default export taking an `ExtensionAPI`.
- Register a simple "hello world" `/devloop:ping` command and test loading the extension locally.

## Phase 2: State Management & UI Binding
**Goal**: Track the plan and display it via Pi's Terminal UI.
- Define a TypeScript interface for `Plan`, `Phase`, and `Task`.
- Implement `PlanManager` to read/write `.devloop/plan.json` (or `.devloop/plan.md`) reliably.
- Subscribe to session start and context events to ensure `ctx.ui.setWidget("devloop", [...])` always displays the active plan.

## Phase 3: Exposing Custom Tools
**Goal**: Give the LLM deterministic, type-safe ways to alter the plan rather than relying on bash scripting.
- Use `pi.registerTool` to add:
  - `devloop_update_task`: Update a task's status (done, blocked, in_progress).
  - `devloop_add_task`: Add a subtask to the current phase.
  - `devloop_set_active`: Set the current focus task.
- Ensure that every tool invocation calls `PlanManager` and updates the TUI widget in real-time.

## Phase 4: Core Orchestration Commands
**Goal**: Build the primary interactive user commands (`/devloop:plan`, `/devloop:run`).
- `/devloop:plan <topic>`: 
  - Validates there is no active plan.
  - Sends a user message commanding the LLM to explore and draft a plan, ending with a tool call to save it.
- `/devloop:run`:
  - Starts autonomous execution.
  - Uses `ctx.sendUserMessage(..., { deliverAs: "followUp" })` to trigger the LLM to begin the first active task.

## Phase 5: Autonomous Loop & Event Interception
**Goal**: Make the LLM process tasks back-to-back without user prompting.
- Listen for `tool_result` on the `devloop_update_task` tool.
- If a task is marked `done`, automatically queue the next instruction: "Task complete. Proceed to the next pending task." using `deliverAs: "followUp"`.
- If blocked, pause execution and ask the user via `ctx.ui.notify()` and stop sending follow-ups.

## Phase 6: Context Management / Fresh Starts
**Goal**: Replicate `/devloop:fresh && /clear`.
- Implement `/devloop:fresh` using `ctx.newSession(...)`.
- Pre-populate the replacement session with the current plan state using `setup: async (sm) => sm.appendMessage(...)` so the LLM wakes up with full knowledge of the plan without history bloat.

## Phase 7: Skills & Documentation
**Goal**: Guide the LLM and the User.
- Write `skills/devloop-worker/SKILL.md` teaching the LLM how to approach tasks and when to invoke the custom `devloop_*` tools.
- Bind the skill path dynamically via the `resources_discover` hook so Pi loads the skill when the extension is active.
- Write a comprehensive `README.md` detailing installation and usage in Pi.
