---
allowed_tools:
  - mcp__godot__get_debug_output
  - Skill
---

View enhanced debug output from the running Godot project with error highlighting and filtering.

# Process

1. **Check if project is running**
   - Use mcp__godot__get_debug_output to fetch current debug output

2. **Parse and enhance the output:**
   - Identify error types (ERROR, WARNING, INFO)
   - Parse stack traces
   - Extract file paths and line numbers
   - Highlight important information

3. **Display formatted output:**

## Error Formatting

Present errors with the following enhanced format:

### ERROR messages
```
[ERROR] <error_message>
  Location: <file_path>:<line_number>
  Function: <function_name>
  Details: <additional_context>

  Stack Trace:
    at <function> (<file>:<line>)
    at <function> (<file>:<line>)
```

### WARNING messages
```
[WARNING] <warning_message>
  Location: <file_path>:<line_number>
  Context: <relevant_context>
```

### INFO/DEBUG messages
```
[INFO] <message>
```

## Common Error Patterns to Recognize

### 1. Null Reference Errors
Pattern: `Attempt to call function .* in base 'null instance'`

Response:
```
[ERROR] Null Reference Error
  Trying to call a method on a null object

  Quick Fixes:
  - Check if the object exists before calling methods
  - Verify @onready node paths are correct
  - Ensure nodes aren't freed before being accessed

  Example fix:
    if my_node != null:
        my_node.some_method()
```

### 2. Node Not Found
Pattern: `Node not found: .*` or `get_node: .*not found`

Response:
```
[ERROR] Node Not Found
  Path: <node_path>

  Possible Causes:
  - Node doesn't exist in the scene tree
  - Incorrect node path (check capitalization)
  - Node hasn't been added yet (timing issue)

  Quick Fixes:
  - Use get_node_or_null() to check if node exists
  - Verify the node path in the scene tree
  - Use @onready for scene tree references
```

### 3. Index Out of Range
Pattern: `Index .* out of range`

Response:
```
[ERROR] Array Index Out of Bounds
  Index: <index_value>
  Array Size: <size>

  Quick Fixes:
  - Check array size before accessing: if index < array.size()
  - Use range-based loops instead of index access
  - Validate index is not negative
```

### 4. Type Errors
Pattern: `Invalid operands .* and .* in operator`

Response:
```
[ERROR] Type Mismatch
  Cannot perform operation between incompatible types

  Quick Fixes:
  - Ensure variables are initialized
  - Check for null values before operations
  - Verify type annotations match actual types
```

### 5. Signal Errors
Pattern: `Signal .* already connected` or `Attempt to call an invalid function`

Response:
```
[ERROR] Signal Connection Error

  Quick Fixes:
  - Check if signal is already connected before connecting
  - Verify method signature matches signal parameters
  - Ensure method exists and is spelled correctly
```

## Enhanced Features

### Error Grouping
- Group repeated errors together
- Show count of occurrences
- Display first occurrence time

Example:
```
[ERROR] (x5) Null instance access
  First occurred at: 14:32:15
  Last occurred at: 14:32:23

  See details with: /gd:debug --expand=<error_id>
```

### Filtering Options

Ask user if they want to filter output:

Question: "Would you like to filter the debug output?"
Header: "Filter"
Multi-select: false
Options:
- Show All: Display all messages (errors, warnings, info)
- Errors Only: Show only ERROR messages
- Errors + Warnings: Show errors and warnings
- Custom Filter: Filter by keyword

### Auto-suggestions

For each error, provide:
1. **Error Type**: Classification of the error
2. **Likely Cause**: Most common reason for this error
3. **Suggested Fix**: Code example or action to take
4. **Related Documentation**: Link to relevant Godot docs if applicable

Example output:
```
─────────────────────────────────────
[ERROR] Invalid get index 'health' (on base: 'null instance')

Location: res://scripts/player.gd:45
Function: take_damage()

Likely Cause:
  The player node is null when trying to access the 'health' property.
  This usually happens when:
  - A node reference (@onready var) points to a non-existent node
  - The node was freed/removed before this code runs
  - The node path is incorrect

Suggested Fix:
  # Add null check before accessing:
  if player != null:
      player.health -= damage

  # Or verify node exists in _ready():
  func _ready():
      assert(player != null, "Player node not found!")

Related Code (player.gd:45):
  45 | func take_damage(amount):
  46 |     player.health -= amount  # ERROR HERE
  47 |     update_health_bar()

Next Steps:
  1. Check that the player node exists in the scene tree
  2. Verify the node path for @onready variables
  3. Add null checks before accessing node properties

─────────────────────────────────────
```

## Watch Mode

Offer to enable watch mode:

"Would you like to enable watch mode? This will continuously monitor for new errors."

If yes:
- Poll mcp__godot__get_debug_output every 2 seconds
- Display new errors as they occur
- Highlight new errors in real-time
- User can press Ctrl+C or type 'stop' to exit watch mode

Example watch mode output:
```
[WATCH MODE] Monitoring debug output... (Press Ctrl+C to stop)

14:35:12 | [INFO] Game started
14:35:15 | [WARNING] Texture not found: res://sprites/missing.png
14:35:18 | [ERROR] Null instance access in enemy.gd:23

Press Enter to see error details, or type 'stop' to exit...
```

## Additional Commands

After showing debug output, offer helpful commands:

```
Debug output retrieved.

Helpful commands:
  /gd:debug --errors-only     Show only errors
  /gd:debug --watch           Enable watch mode
  /gd:restart                 Restart the game

  Need help fixing an error? Just ask! The godot-debugging skill can help interpret and fix these errors.
```

# Integration with godot-debugging Skill

After displaying errors, automatically activate the godot-debugging skill to provide:
- Detailed error explanations
- Code fixes
- Prevention strategies

# Example Full Output

```
Debug Output (Last 50 lines)
═══════════════════════════════════════

[INFO] Project initialized
[INFO] Scene loaded: res://scenes/main.tscn

[WARNING] Node has been removed from scene: Label
  Location: res://scenes/ui/menu.tscn
  Context: Attempting to access removed node

  Note: This usually happens when you call queue_free() on a node
  and then try to access it later in the same frame.

─────────────────────────────────────

[ERROR] Attempt to call function 'move_and_slide' in base 'null instance' on a null instance
  Location: res://scripts/player.gd:67
  Function: _physics_process(delta)

  Stack Trace:
    at CharacterBody2D._physics_process (res://scripts/player.gd:67)
    at Node._propagate_process (core)

  🔍 Analysis:
  The player node (CharacterBody2D) is trying to call move_and_slide()
  but the instance is null. This typically means:
  - The player was freed but physics_process is still running
  - The script is on a freed node

  💡 Suggested Fix:
    func _physics_process(delta):
        if not is_instance_valid(self):
            return

        velocity.y += gravity * delta
        move_and_slide()

─────────────────────────────────────

Summary:
  • Total Messages: 24
  • Errors: 3 (🔴)
  • Warnings: 5 (🟡)
  • Info: 16 (🔵)

Most Recent Error:
  res://scripts/player.gd:67 - Null instance in _physics_process

═══════════════════════════════════════

Would you like me to help fix any of these errors?
```

# Error History Tracking

Keep track of errors across debug sessions:
- Store error fingerprints (file + line + error type)
- Track if error is new or recurring
- Show resolution history if previously fixed

Example:
```
[ERROR] (Recurring) Null instance access
  This error has occurred 3 times in the last hour
  Previously seen: 14:15, 14:22, 14:35

  Note: This might indicate a deeper issue with your code structure.
  Consider adding more robust null checks or restructuring your node references.
```

# Implementation Notes

1. **Parse debug output intelligently**
   - Extract file paths as clickable links (if terminal supports it)
   - Parse stack traces into structured format
   - Identify error patterns automatically

2. **Color coding** (if terminal supports it)
   - Red for errors
   - Yellow for warnings
   - Blue for info
   - Gray for debug

3. **Smart filtering**
   - Remember user's last filter choice
   - Allow regex patterns for advanced filtering
   - Group similar errors together

4. **Quick actions**
   - Offer to open file at error line
   - Suggest running godot-debugging skill
   - Provide quick fix options

After displaying the enhanced debug output, remind the user:
"💡 Tip: I can help fix these errors! Just ask about any specific error and I'll provide a detailed explanation and fix using the godot-debugging skill."
