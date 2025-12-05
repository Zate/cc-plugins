---
description: Quickly restart the running Godot game
allowed_tools:
  - mcp__godot__stop_project
  - mcp__godot__run_project
  - mcp__godot__get_debug_output
---

Quickly restart the running Godot project for fast iteration during development.

# Process

1. **Stop the current instance**
   - Use mcp__godot__stop_project to stop the running game
   - Display: `♻️  Restarting game...`

2. **Wait briefly** (0.5 seconds) for clean shutdown

3. **Start the project again**
   - Use mcp__godot__run_project with projectPath set to current working directory

4. **Get initial output**
   - Wait 1.5 seconds
   - Use mcp__godot__get_debug_output to check for errors

5. **Display result**

## If restart successful:
```
✓ Game restarted successfully!

  Quick stats:
  • Restart time: <elapsed_time>
  • Status: Running

  Commands:
    /gd:restart     Restart again
    /gd:debug       View debug output
    /gd:stop        Stop the game

  💡 Tip: Keep this workflow for rapid iteration:
     Edit code → Save → /gd:restart → Test
```

## If errors occurred:
```
⚠ Game restarted with errors:

<formatted_errors>

  Use /gd:debug for detailed error information

  Commands:
    /gd:debug       View full debug output
    /gd:stop        Stop the game

  Would you like help fixing these errors?
```

## If no game was running:
```
ℹ No game was running. Starting fresh...

<use same output as /gd:run>
```

# Usage Tips

Display these tips the first time user runs /gd:restart:

```
💡 Restart Command Tips:

   1. Fast Iteration: Use /gd:restart after making code changes
      instead of manually stopping and starting the game.

   2. Keyboard Shortcut: Save this command for quick access
      (check if your terminal supports command aliases)

   3. Watch Your Console: Errors from the restart will be
      displayed immediately.

   4. No Need to Stop First: /gd:restart handles stopping
      automatically.

   Typical workflow:
   1. Make changes to your code
   2. Save (Cmd+S / Ctrl+S)
   3. Run /gd:restart
   4. Test your changes
   5. Repeat!
```

# Performance Optimization

Track restart metrics for user feedback:
```
📊 Restart Performance:
   • This restart: 2.1s
   • Average: 2.3s
   • Fastest: 1.8s

   Your game restarts quickly! This is great for iteration.
```

# Error Recovery

If restart fails:
```
❌ Restart failed!

   Possible causes:
   - Previous instance didn't shut down cleanly
   - Godot editor is not responding
   - MCP server connection issue

   Try these steps:
   1. Wait a few seconds and try again
   2. Check if Godot editor is running
   3. Run /gd:setup to verify MCP configuration

   Or manually:
   1. /gd:stop (ensure game stops)
   2. /gd:run (start fresh)
```

# Integration with Error Monitoring

After restart, if errors detected, activate godot-debugging skill hints:
```
🔍 Detected issues in restart:

   [ERROR] Null instance in player.gd:45

   Common cause: Node references changed or removed

   Quick fix: Verify all @onready var paths are correct
              after scene modifications.

   Want detailed help? Just ask about this error!
```
