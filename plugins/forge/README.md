# Forge Plugin

Integration with [Forge](https://github.com/Zate/forge), a headless agent job runner for Claude Code.

## What it does

Submit jobs to LLM agents (Claude, Gemini, Ollama, LM Studio) running in the background, track their status, and retrieve results -- all from within Claude Code via MCP tools.

## Quick Start

```bash
# Install the plugin
/plugin install /path/to/cc-plugins/plugins/forge

# Build and install forge, start the daemon
/forge:setup

# Submit a job
# (Claude will use forge_submit MCP tool automatically)
```

## Features

- **MCP Tools**: `forge_submit`, `forge_status`, `forge_output`, `forge_list`
- **Session Check**: Automatically detects if forge daemon is running on session start
- **Setup Skill**: Builds forge from source, installs binary, starts daemon
- **Usage Skill**: Guides Claude on how to use forge MCP tools effectively

## Skills

| Skill | Description |
|-------|-------------|
| `/forge:use` | How to interact with forge via MCP tools |
| `/forge:setup` | Build, install, and start forge |

## Requirements

- Go toolchain (for building forge from source)
- Forge source at `~/projects/forge`

## Configuration

Forge config lives at `~/.forge/config.yaml`. See forge documentation for details.

## How it works

1. Plugin registers forge's MCP server (`forge mcp` over stdio)
2. SessionStart hook checks if the daemon is running
3. Claude uses MCP tools to submit jobs, check status, and get results
4. Forge daemon processes jobs asynchronously in the background
