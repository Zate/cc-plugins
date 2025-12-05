---
description: Run the Godot game project with optional watch mode and enhanced error display
allowed_tools:
  - mcp__godot__run_project
  - mcp__godot__get_debug_output
  - AskUserQuestion
  - Skill
---

Run the current Godot project using the MCP server with enhanced debugging features.

# Process

## 1. Parse Command Arguments

Check if user provided any flags:
- `--watch` or `-w`: Enable watch mode (auto-restart on file changes)
- `--debug` or `-d`: Show detailed debug output immediately
- `--no-output`: Run without showing initial output

Examples:
- `/gd:run` - Normal run
- `/gd:run --watch` - Run with watch mode
- `/gd:run --debug` - Run with immediate debug output

## 2. Start the Project

Use mcp__godot__run_project with projectPath set to the current working directory.

Display:
```
🎮 Starting Godot project...
   Project: <current_directory>
```

## 3. Get Initial Output

Wait 2 seconds, then use mcp__godot__get_debug_output to fetch initial output.

## 4. Parse and Display Output

Parse the output for:
- **Errors** (lines containing "ERROR", "Error:", or stack traces)
- **Warnings** (lines containing "WARNING", "WARN")
- **Info** (other output)

Display with enhanced formatting:

### If No Errors:
```
✓ Game started successfully!

Output:
<formatted_output>

Commands:
  /gd:stop      Stop the running game
  /gd:debug     View enhanced debug output
  /gd:restart   Quick restart

Tip: The game is now running. Make changes to your code and use /gd:restart to quickly reload!
```

### If Errors Found:
```
⚠ Game started with errors:

<formatted_errors>

Commands:
  /gd:debug     View detailed error information
  /gd:stop      Stop the game

Would you like me to help fix these errors? I can explain what's wrong and suggest solutions.
```

## 5. Error Highlighting

When displaying errors, highlight key information:

```
[ERROR] <error_type>
  File: <file_path>:<line_number>
  Message: <error_message>

  💡 Quick Tip: <brief_suggestion>
```

Examples:

```
[ERROR] Null Instance
  File: res://scripts/player.gd:45
  Message: Attempt to call function 'take_damage' in base 'null instance' on a null instance

  💡 Quick Tip: Add null check before calling methods: if node != null: node.method()
```

```
[WARNING] Resource Not Found
  File: res://scenes/level.tscn
  Message: Cannot load resource at path: 'res://sprites/missing.png'

  💡 Quick Tip: Check that the file exists and the path is correct (case-sensitive)
```

## 6. Watch Mode (if --watch flag provided)

If watch mode is enabled:

1. Display:
```
📁 Watch mode enabled
   Monitoring for file changes in:
   - *.gd (GDScript files)
   - *.tscn (Scene files)
   - *.tres (Resource files)

   The game will auto-restart when you save changes.
   Press Ctrl+C or type 'stop' to exit watch mode.
```

2. Set up file watching (conceptual - explain to user):
```
Note: Watch mode requires manual restart for now.

To enable auto-restart:
1. Make your code changes
2. Use /gd:restart to quickly reload
3. Repeat as needed

Future enhancement: Automatic file watching with instant reload.
```

3. Provide workflow tips:
```
💡 Rapid Iteration Workflow:
   1. Edit your code
   2. Save the file (Ctrl+S / Cmd+S)
   3. Run /gd:restart
   4. See changes immediately!

   This is much faster than closing and reopening the game.
```

## 7. Error Count Summary

After initial run, provide summary:
```
═══════════════════════════════════════
  Status Summary
═══════════════════════════════════════
  🔴 Errors: <count>
  🟡 Warnings: <count>
  🔵 Info messages: <count>

  ⏱ Startup time: <elapsed_time>
═══════════════════════════════════════
```

## 8. Offer Help

Based on what was found:

### If errors present:
```
I noticed some errors. Would you like me to:
  1. Explain what these errors mean
  2. Show you how to fix them
  3. Run the debugger for more details

Just ask! For example: "Help me fix the null instance error"
```

### If warnings only:
```
There are some warnings you might want to address.
Use /gd:debug to see detailed information.
```

### If clean run:
```
Everything looks good! Your game is running smoothly.
```

## 9. Continuous Monitoring (Enhanced)

Offer to monitor for new errors:

Ask user:
Question: "Would you like me to monitor for runtime errors?"
Header: "Monitoring"
Multi-select: false
Options:
- Yes, watch for errors: I'll alert you if new errors occur
- No, just run: Just start the game without monitoring
- Debug mode: Show all output in real-time

If "Yes, watch for errors" selected:
```
👀 Monitoring enabled
   I'll alert you if new errors occur while the game is running.

   You can check anytime with /gd:debug
```

Then periodically (conceptually - every 30 seconds or when user asks):
- Check for new errors with get_debug_output
- If new errors found, alert user:
  ```
  ⚠ New error detected!

  [ERROR] <brief_description>

  Use /gd:debug to see full details
  ```

## 10. Integration with Debugging Skill

If errors are found, automatically suggest using the debugging skill:

```
💬 Need help understanding these errors?

   Try asking:
   - "What does this error mean?"
   - "How do I fix the null instance error?"
   - "Debug the player.gd script"

   I can explain and fix these issues for you!
```

## 11. Performance Notes

Display performance indicators if available:
```
⚡ Performance:
   FPS: <if_available>
   Memory: <if_available>

   Use /gd:profile for detailed performance analysis
```

## 12. Quick Actions

At the end, always show quick actions:
```
Quick Commands:
  /gd:stop          Stop the game
  /gd:restart       Restart quickly
  /gd:debug         Detailed debug view
  /gd:profile       Performance analysis

  💡 Press Tab to see all /gd: commands
```

# Example Full Output

## Success Case:
```
🎮 Starting Godot project...
   Project: /Users/user/games/platformer

✓ Game started successfully!

Output:
  Godot Engine v4.2.1 - https://godotengine.org
  Vulkan API 1.3.0 - Device: Apple M1

  Loading scene: res://scenes/main.tscn
  Player initialized
  Level loaded: Level_1

═══════════════════════════════════════
  Status Summary
═══════════════════════════════════════
  🔴 Errors: 0
  🟡 Warnings: 0
  🔵 Info messages: 4

  ⏱ Startup time: 1.2s
═══════════════════════════════════════

Everything looks good! Your game is running smoothly.

Commands:
  /gd:stop      Stop the running game
  /gd:debug     View debug output
  /gd:restart   Quick restart

Tip: Make changes to your code and use /gd:restart to quickly reload!
```

## Error Case:
```
🎮 Starting Godot project...
   Project: /Users/user/games/platformer

⚠ Game started with errors:

[ERROR] Null Instance
  File: res://scripts/player.gd:45
  Message: Attempt to call function 'take_damage' in base 'null instance'

  💡 Quick Tip: Add null check: if player != null: player.take_damage(10)

[WARNING] Resource Not Found
  File: res://scenes/level.tscn
  Message: Cannot load resource: 'res://sprites/enemy.png'

  💡 Quick Tip: Verify the file path is correct and the file exists

═══════════════════════════════════════
  Status Summary
═══════════════════════════════════════
  🔴 Errors: 1
  🟡 Warnings: 1
  🔵 Info messages: 3

  ⏱ Startup time: 1.5s
═══════════════════════════════════════

💬 Need help fixing these errors?

   I can explain what went wrong and show you how to fix it.
   Just ask: "Help me fix the null instance error"

Commands:
  /gd:debug     View detailed error information
  /gd:stop      Stop the game
```

# Important Notes

- Always format output in a user-friendly way
- Highlight errors in a visually distinct manner
- Provide actionable suggestions, not just error messages
- Make it easy to transition to fixing errors (mention debugging skill)
- Track context for follow-up questions about specific errors
