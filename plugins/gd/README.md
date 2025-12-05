# Godot Development Plugin for Claude Code

A comprehensive Godot game development plugin for Claude Code that streamlines your Godot workflow with project setup, scene/UI templates, debugging tools, performance optimization, and interactive planning agents.

**Version:** 2.0.0

## Features

### 🎮 Project Management
- **Environment Setup** - Automatic Godot and MCP server detection and configuration
- **Interactive Planning** - Guided game and UI design process
- **Project Initialization** - Create new Godot projects with proper structure

### 🎨 Scene & UI Creation
- **Scene Templates** - Quick creation of common 2D scenes (player, enemy, level, projectiles, collectibles)
- **UI Templates** - Pre-built UI screens (main menu, pause menu, settings, HUD, inventory, dialogue)
- **Interactive UI Architect** - Plan complex UI systems with guided questions

### 🐛 Debugging & Error Handling
- **Enhanced Debug Output** - Color-coded error display with quick tips
- **Error Interpretation** - Automatic explanation of common Godot errors
- **Smart Suggestions** - Context-aware fix recommendations

### ⚡ Performance Optimization
- **Performance Analysis** - Identify bottlenecks and optimization opportunities
- **Best Practices** - Built-in knowledge of Godot optimization techniques
- **Platform-Specific Tips** - Mobile and web optimization guidance

### 🔄 Rapid Iteration
- **Quick Restart** - Fast game reload for testing changes
- **Watch Mode** - Monitor for file changes during development
- **Live Error Monitoring** - Real-time error detection while game runs

## Commands

| Command | Description |
|---------|-------------|
| `/gd:setup` | Validate Godot environment and configure MCP server |
| `/gd:init-game` | Initialize a new Godot game project with interactive planning |
| `/gd:run` | Run the project with enhanced error display and optional watch mode |
| `/gd:stop` | Stop the running Godot game |
| `/gd:restart` | Quickly restart the game for rapid iteration |
| `/gd:debug` | View enhanced debug output with error highlighting and filtering |
| `/gd:scene` | Create common scene templates (player, enemy, level, projectiles, etc.) |
| `/gd:ui-template` | Create UI templates (menus, HUD, dialogs, inventory, etc.) |

## Agents

### game-planner
Interactive game design planning agent that helps you:
- Define game genre and mechanics
- Choose art style and technical specs
- Plan scene structure and organization
- Set up project architecture

### ui-architect
Interactive UI planning agent that helps you:
- Design screen layouts and navigation
- Plan Control node hierarchies
- Define theme and styling
- Create responsive, accessible UIs

## Skills

### godot-dev
Expert knowledge of Godot Engine including:
- Scene tree architecture
- Node types (2D, 3D, Control, etc.)
- GDScript programming patterns
- Project structure best practices
- MCP tool usage

### godot-ui
Specialized UI system expertise covering:
- Control nodes and containers
- Theme system and styling
- Responsive layout design
- Common UI patterns (menus, HUD, dialogs)
- Accessibility features

### godot-debugging
Debugging and error resolution expertise:
- Error message interpretation
- Common bug patterns and solutions
- Stack trace analysis
- Debug logging best practices
- Performance debugging

### godot-optimization
Performance optimization knowledge:
- Profiling techniques
- Bottleneck identification
- Memory management
- Rendering optimization
- Platform-specific optimization

## Installation

1. **Prerequisites**
   - [Claude Code](https://claude.com/claude-code)
   - [Godot Engine 4.x](https://godotengine.org/)
   - [Godot MCP Server](https://github.com/godotengine/godot-mcp)

2. **Install Plugin**
   ```bash
   # Clone or copy the plugin to your Claude Code plugins directory
   cd ~/.claude-code/plugins
   git clone https://github.com/Zate/cc-godot gd
   ```

3. **Setup MCP Server**
   ```bash
   # Clone and build Godot MCP server
   cd ~/projects
   git clone https://github.com/godotengine/godot-mcp
   cd godot-mcp
   npm install
   npm run build
   ```

4. **Configure Plugin**
   ```bash
   # Run setup command in Claude Code
   /gd:setup
   ```

   This will:
   - Detect your Godot installation
   - Verify MCP server location
   - Create `.mcp.json` configuration
   - Validate the setup

## Quick Start

### Creating a New Game

```bash
# 1. Initialize a new game project
/gd:init-game

# Follow the interactive prompts to define:
# - 2D or 3D
# - Genre (platformer, RPG, puzzle, etc.)
# - Art style
# - Core mechanics
# - Target platform

# 2. Create your first scene
/gd:scene

# Choose a template:
# - 2D Player Character
# - 2D Enemy
# - 2D Level
# - etc.

# 3. Create UI
/gd:ui-template

# Choose a template:
# - Main Menu
# - Pause Menu
# - Game HUD
# - etc.

# 4. Run your game
/gd:run

# 5. Make changes and restart quickly
# (edit your code)
/gd:restart
```

### Debugging Workflow

```bash
# Run with enhanced error display
/gd:run

# If errors occur, view detailed debug info
/gd:debug

# Ask for help fixing specific errors
# "Help me fix the null instance error in player.gd"

# Restart after fixes
/gd:restart
```

### UI Development Workflow

```bash
# Plan your UI system
# Use the ui-architect agent for complex UIs

# Create quick UI templates for common screens
/gd:ui-template

# Customize the generated scenes
# The godot-ui skill provides guidance on:
# - Control node types
# - Theme customization
# - Responsive layouts
# - Accessibility
```

## Example Workflows

### Rapid Prototyping

Perfect for game jams and quick experiments:

```bash
1. /gd:init-game (choose "game jam" preset)
2. /gd:scene (create player character)
3. /gd:scene (create level)
4. /gd:ui-template (create HUD)
5. /gd:run --watch
6. Edit, save, /gd:restart (repeat)
```

### Production Development

For longer-term projects:

```bash
1. /gd:init-game (detailed planning)
2. Plan UI with ui-architect agent
3. Create scenes with /gd:scene
4. Implement gameplay logic
5. Use /gd:debug for troubleshooting
6. Optimize with godot-optimization skill
7. Test and iterate with /gd:restart
```

## Advanced Features

### Watch Mode

Monitor for errors while the game runs:

```bash
/gd:run

# When prompted, choose:
# "Yes, watch for errors"

# Claude will alert you when new errors occur
```

### Error Filtering

View specific types of errors:

```bash
/gd:debug

# Choose filter options:
# - Show All
# - Errors Only
# - Errors + Warnings
# - Custom Filter
```

### Template Customization

All templates are fully customizable:
- Generated scenes are standard Godot .tscn files
- Generated scripts are standard GDScript
- Modify them directly in Godot Editor or with Claude Code

## Tips & Best Practices

### Rapid Iteration

- Use `/gd:restart` instead of manually stopping/starting
- Keep Claude Code open alongside Godot Editor
- Make small changes and test frequently

### Debugging

- Use `/gd:debug` to understand errors before asking for help
- The godot-debugging skill can explain any error
- Add print statements, then use `/gd:restart` to see output

### UI Development

- Use ui-architect agent for planning before coding
- Start with templates, then customize
- Test UI on different resolutions

### Performance

- Profile early and often
- Use godot-optimization skill for guidance
- Test on target platforms regularly

## Troubleshooting

### MCP Server Not Found

```bash
# Re-run setup
/gd:setup

# Manually specify paths if needed
# Check ~/.mcp.json for correct paths
```

### Godot Not Detected

```bash
# Set GODOT_PATH environment variable
export GODOT_PATH="/path/to/Godot.app/Contents/MacOS/Godot"

# Then re-run setup
/gd:setup
```

### Commands Not Working

```bash
# Restart Claude Code session
# Verify plugin is in ~/.claude-code/plugins/gd
# Check that all files are present in the plugin directory
```

## Architecture

```
plugins/gd/
├── .claude-plugin/
│   └── plugin.json          # Plugin metadata
├── agents/
│   ├── game-planner.md      # Game design planning agent
│   └── ui-architect.md      # UI planning agent
├── commands/
│   ├── setup.md             # Environment setup
│   ├── init-game.md         # Project initialization
│   ├── run.md               # Run with watch mode
│   ├── stop.md              # Stop game
│   ├── restart.md           # Quick restart
│   ├── debug.md             # Enhanced debug viewer
│   ├── scene.md             # Scene templates
│   └── ui-template.md       # UI templates
├── hooks/
│   └── hooks.json           # SessionStart validation
├── scripts/
│   ├── validate-env.sh      # Environment validation
│   ├── setup-mcp.sh         # MCP configuration
│   └── init-project.sh      # Project structure creation
├── skills/
│   ├── godot-dev/           # General Godot expertise
│   ├── godot-ui/            # UI system expertise
│   ├── godot-debugging/     # Debugging assistance
│   └── godot-optimization/  # Performance optimization
└── README.md                # This file
```

## Version History

### 2.0.0 (Current)
- Added UI development tools (ui-architect agent, godot-ui skill, /gd:ui-template)
- Added debugging tools (godot-debugging skill, enhanced /gd:debug)
- Added performance optimization (godot-optimization skill)
- Enhanced /gd:run with watch mode and better error display
- Added /gd:restart for rapid iteration
- Added /gd:scene for common scene templates
- Improved error highlighting and suggestions
- Better integration between commands and skills

### 1.0.0
- Initial release
- Basic commands: /gd:setup, /gd:init-game, /gd:run, /gd:stop
- game-planner agent
- godot-dev skill
- MCP server integration

## Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

MIT License - See LICENSE file for details

## Author

**Zate**
- Email: zate75@gmail.com
- GitHub: [@Zate](https://github.com/Zate)

## Support

- **Issues**: [GitHub Issues](https://github.com/Zate/cc-godot/issues)
- **Discussions**: [GitHub Discussions](https://github.com/Zate/cc-godot/discussions)
- **Documentation**: [Wiki](https://github.com/Zate/cc-godot/wiki)

## Acknowledgments

- Godot Engine team for the amazing game engine
- Anthropic for Claude Code
- Godot MCP server contributors

---

**Happy Game Development! 🎮**
