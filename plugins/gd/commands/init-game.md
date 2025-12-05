---
description: Initialize a new Godot game project with interactive planning
allowed-tools:
  - Task
  - Write
  - Read
  - mcp__godot__*
---

You are helping initialize a new Godot game project.

First, launch the game-planner agent to gather requirements and create a game plan:

Use the Task tool with subagent_type "game-planner" to launch the planning agent.

After the planning agent completes, use the returned game plan to:
1. Update or create the project.godot file with appropriate settings (2D/3D, display settings, etc.)
2. Create the main scene based on the game type (Node2D for 2D games, Node3D for 3D games)
3. Set up the basic folder structure:
   - scenes/ (for game scenes)
   - scripts/ (for GDScript files)
   - assets/ (for images, sounds, etc.)
   - resources/ (for Godot resource files)
4. Create a README.md documenting the project plan, core mechanics, and initial architecture

Use the Godot MCP tools to create scenes and add nodes as appropriate based on the game plan.

Inform the user when initialization is complete and suggest next steps for development.
