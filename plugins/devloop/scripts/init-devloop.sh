#!/bin/bash
# init-devloop.sh - Initialize devloop project structure
# Triggered by: claude --init (Setup hook)
#
# Creates .devloop/ directory with default configuration

set -euo pipefail

DEVLOOP_DIR=".devloop"

# Check if already initialized
if [[ -d "$DEVLOOP_DIR" ]]; then
    echo "devloop already initialized in this project."
    exit 0
fi

# Create directory structure
mkdir -p "$DEVLOOP_DIR"
mkdir -p "$DEVLOOP_DIR/archive"
mkdir -p "$DEVLOOP_DIR/spikes"

# Detect tech stack
detect_language() {
    [ -f "go.mod" ] && { echo "go"; return; }
    [ -f "package.json" ] && {
        [ -f "tsconfig.json" ] && { echo "typescript"; return; }
        echo "javascript"; return
    }
    [ -f "requirements.txt" ] || [ -f "pyproject.toml" ] && { echo "python"; return; }
    [ -f "pom.xml" ] || [ -f "build.gradle" ] && { echo "java"; return; }
    [ -f "Cargo.toml" ] && { echo "rust"; return; }
    echo "unknown"
}

detect_framework() {
    # JavaScript/TypeScript frameworks
    if [ -f "package.json" ]; then
        grep -q '"next"' package.json 2>/dev/null && { echo "nextjs"; return; }
        grep -q '"react"' package.json 2>/dev/null && { echo "react"; return; }
        grep -q '"vue"' package.json 2>/dev/null && { echo "vue"; return; }
        grep -q '"express"' package.json 2>/dev/null && { echo "express"; return; }
    fi

    # Python frameworks
    if [ -f "requirements.txt" ]; then
        grep -qi "django" requirements.txt 2>/dev/null && { echo "django"; return; }
        grep -qi "flask" requirements.txt 2>/dev/null && { echo "flask"; return; }
        grep -qi "fastapi" requirements.txt 2>/dev/null && { echo "fastapi"; return; }
    fi

    echo ""
}

LANG=$(detect_language)
FRAMEWORK=$(detect_framework)
PROJECT_NAME=$(basename "$(pwd)")

# Create context.json with detected stack
cat > "$DEVLOOP_DIR/context.json" << EOF
{
  "project": "$PROJECT_NAME",
  "language": "$LANG",
  "framework": "$FRAMEWORK",
  "initialized_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "devloop_version": "3.12.0"
}
EOF

# Create default local.md (not git-tracked)
cat > "$DEVLOOP_DIR/local.md" << 'EOF'
---
# Local devloop configuration (not git-tracked)
# Customize these settings for your workflow

git:
  auto-branch: false          # Create branch when plan starts
  pr-on-complete: ask         # ask | always | never

commits:
  style: conventional         # conventional | simple
  auto-commit: false          # Auto-commit at phase boundaries

review:
  before-commit: ask          # ask | always | never

github:
  link-issues: false          # Enable issue linking
  auto-close: ask             # ask | always | never

context:
  threshold: 70               # Percent context usage before suggesting /fresh
---

# Project Notes

Add project-specific notes here for devloop context.
EOF

# Create .gitignore entries
GITIGNORE="$DEVLOOP_DIR/.gitignore"
cat > "$GITIGNORE" << 'EOF'
# Devloop local files (not git-tracked)
local.md
spikes/
EOF

# Output JSON result for hook
cat << EOF
{
  "hookSpecificOutput": {
    "hookEventName": "Setup",
    "additionalContext": "devloop initialized in .devloop/ with $LANG${FRAMEWORK:+ ($FRAMEWORK)} project detected. Run /devloop to start planning."
  }
}
EOF

exit 0
