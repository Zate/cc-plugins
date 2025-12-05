#!/bin/bash

# Initialize Godot Project Structure
# Creates standard folder organization for game development

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"

echo "📁 Initializing Godot project structure..."
echo ""

# Create standard directories
mkdir -p "$PROJECT_DIR/scenes"/{main,ui,characters,levels,environment}
mkdir -p "$PROJECT_DIR/scripts"/{autoload,characters,systems,ui}
mkdir -p "$PROJECT_DIR/assets"/{sprites,audio,fonts,shaders,textures}
mkdir -p "$PROJECT_DIR/resources"/{materials,animations,themes}

echo "✓ Created folder structure:"
echo "  scenes/        - Game scene files (.tscn)"
echo "    ├── main/    - Main game scenes"
echo "    ├── ui/      - User interface scenes"
echo "    ├── characters/ - Character scenes"
echo "    ├── levels/  - Level scenes"
echo "    └── environment/ - Environment/props"
echo ""
echo "  scripts/       - GDScript files (.gd)"
echo "    ├── autoload/   - Singleton/autoload scripts"
echo "    ├── characters/ - Character logic"
echo "    ├── systems/    - Game systems"
echo "    └── ui/         - UI logic"
echo ""
echo "  assets/        - Art, audio, and media files"
echo "    ├── sprites/    - 2D images and sprites"
echo "    ├── audio/      - Music and sound effects"
echo "    ├── fonts/      - Font files"
echo "    ├── shaders/    - Custom shaders"
echo "    └── textures/   - 3D textures"
echo ""
echo "  resources/     - Godot resource files (.tres)"
echo "    ├── materials/  - Material resources"
echo "    ├── animations/ - Animation resources"
echo "    └── themes/     - UI themes"
echo ""

# Create .gdignore files for asset directories that shouldn't be imported
touch "$PROJECT_DIR/assets/.gdignore" 2>/dev/null || true

echo "✅ Project structure initialized!"
echo ""

exit 0
