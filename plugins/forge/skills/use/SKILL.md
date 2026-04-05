---
name: use
description: "How to use Forge to submit headless agent jobs, check status, and retrieve output via MCP tools. Use when the user wants to delegate work to a background agent, run a task on another LLM, or interact with forge."
user-invocable: true
---

# Forge: Headless Agent Job Runner

Forge runs tasks on LLM agents in the background via a daemon. Interact through MCP tools.

## MCP Tools

### forge_submit
Submit a job. Returns a job ID.

**Required:** `task` (string) - the prompt/task description.

**Optional:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `agent` | string | `claude` (default), `gemini`, `local`, `lmstudio` |
| `model` | string | Agent-specific: `sonnet`, `haiku`, `opus`, `gemini-2.5-pro`, etc. |
| `timeout` | string | Duration: `30s`, `10m` (default), `1h` |
| `input_files` | string[] | File paths to include as context |
| `output_format` | string | `markdown` (default), `json`, `yaml`, `code`, `raw` |
| `constraints` | string[] | Output validation constraints |
| `tags` | string[] | Tags for filtering/organization |

### forge_status
Check job status. **Required:** `job_id` (string).

### forge_output
Get completed job result. **Required:** `job_id` (string).
Returns: output content, metadata (agent, model, duration, tokens, cost).

### forge_list
List jobs. **Optional:** `status` filter (`pending`, `running`, `completed`, `failed`), `limit` (default 20).

## Workflow

```
1. forge_submit  →  returns job_id
2. forge_status  →  poll until "completed" or "failed"
3. forge_output  →  retrieve the result
```

## Job States

`pending` → `claimed` → `dispatched` → `running` → `validating` → `delivering` → `completed`

Any state can transition to `failed`.

## Tips

- **Daemon must be running** for jobs to process. If jobs stay `pending`, check with `forge_status` or run `/forge:setup`.
- **Jobs are async** - submit returns immediately. Poll status or use `forge_list` to monitor.
- **Claude agent** uses Claude CLI with full tool use (file editing, bash). Other agents are completion-only.
- **Input files** let you pass context files to the job agent.
- **Constraints** validate output (e.g., `["non-empty", "min-length:100"]`).

## When NOT to Use

- For tasks that should happen in the current session (just do them directly).
- When you need interactive back-and-forth with the user during the task.
- Forge is for fire-and-forget background work.
