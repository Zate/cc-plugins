# pi-devloop

A native Pi Extension that brings the **devloop** workflow engine (plan, run, ship) directly into your Pi terminal. 

It provides command orchestration, state tracking natively integrated into the terminal UI, custom tools for safe execution, and autonomous task progression.

## Installation

Install using the `pi` command line. It can be installed directly from the filesystem or from git/npm.

```bash
pi install /path/to/cc-plugins/plugins/pi-devloop
# Or via git:
# pi install git:github.com/yourusername/cc-plugins/plugins/pi-devloop
```

## Usage

This extension provides the `/devloop` slash command and runs an autonomous agent loop using custom tools.

### 1. Plan

Command the agent to explore your codebase and draft a development plan:

```bash
/devloop plan "Add user authentication"
```

The LLM will explore the project, draft phases and tasks, and use the `devloop_save_plan` tool. Once saved, Pi's terminal UI will update to display the active plan above your editor.

### 2. Run

Start the autonomous execution loop:

```bash
/devloop run
```

The LLM will begin executing the first pending task. When it finishes and marks the task as `done` using the `devloop_update_task` tool, the extension automatically queues the next task without requiring manual prompts.

### 3. Fresh Context

If the context gets too large (many tasks completed) and the LLM becomes confused or slow, you can clear the conversation history while preserving the plan:

```bash
/devloop fresh
```

This creates a new Pi session and injects the current plan state as the starting prompt, allowing the LLM to resume execution seamlessly with a clean context.

## Custom Tools

The extension registers the following tools for the LLM:
- `devloop_update_task`: Mark a task as `done`, `blocked`, or `in_progress`.
- `devloop_add_task`: Dynamically add new subtasks to a phase.
- `devloop_save_plan`: Save a drafted plan to disk (`.devloop/plan.json`).

## Architecture

This follows the "commands orchestrate, agents assist" pattern:
- **State Management**: The plan is saved reliably to `.devloop/plan.json`.
- **UI Binding**: `ctx.ui.setWidget` is used to pin the checklist to your terminal.
- **Event Interception**: `tool_result` events are caught to autonomously drive the loop forward via `deliverAs: "followUp"`.
