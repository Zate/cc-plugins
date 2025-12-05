---
description: Validate Godot environment and configure MCP server
allowed-tools:
  - Read
  - Write
  - Bash(ls:*,which:*,test:*)
---

You are helping set up the Godot development environment for this project.

Run the setup script to validate the environment and configure the MCP server:

!bash ${CLAUDE_PLUGIN_ROOT}/scripts/setup-mcp.sh

The script will:
1. Check if Godot is installed at common locations
2. Verify the Godot MCP server is built and ready at ~/projects/godot-mcp
3. Create .mcp.json from the template with detected paths
4. Report any issues and provide guidance

After running the script:
- If successful, inform the user that the environment is ready and they can now use `/gd:init-game` to start planning their game
- If there are issues, explain what needs to be fixed and how to resolve them
- Remind the user to restart Claude Code for the MCP server changes to take effect
