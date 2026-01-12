#!/bin/bash
# install.sh - Install rovodevloop prompts and subagents
#
# Usage:
#   ./install.sh                    # Global install to ~/.rovodev (symlink)
#   ./install.sh --local <path>     # Local install to repo (symlink)
#   ./install.sh --no-link          # Global install (copy files)
#   ./install.sh --local <path> --no-link  # Local install (copy files)
#   ./install.sh -u                 # Update global install
#   ./install.sh -u --local <path>  # Update local install
#   ./install.sh --uninstall        # Remove global install
#   ./install.sh --uninstall --local <path>  # Remove local install

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory (where rovodevloop is cloned)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Default values
MODE="install"        # install, update, uninstall
TARGET="global"       # global or local
USE_SYMLINK=true
LOCAL_PATH=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -u|--update)
            MODE="update"
            shift
            ;;
        --uninstall)
            MODE="uninstall"
            shift
            ;;
        --local)
            TARGET="local"
            LOCAL_PATH="$2"
            shift 2
            ;;
        --no-link)
            USE_SYMLINK=false
            shift
            ;;
        -h|--help)
            cat << EOF
Usage: ./install.sh [OPTIONS]

Install rovodevloop prompts, subagents, skills, and scripts.

OPTIONS:
    (none)              Global install to ~/.rovodev with symlinks
    --local <path>      Local install to specified repo
    --no-link           Copy files instead of symlinking
    -u, --update        Update existing installation
    --uninstall         Remove installation
    -h, --help          Show this help message

EXAMPLES:
    # Global install (symlink)
    ./install.sh

    # Local install to acra-python (symlink)
    ./install.sh --local ~/projects/acra-python

    # Global install (copy files)
    ./install.sh --no-link

    # Update global install
    ./install.sh -u

    # Update local install
    ./install.sh -u --local ~/projects/acra-python

    # Uninstall global
    ./install.sh --uninstall

    # Uninstall local
    ./install.sh --uninstall --local ~/projects/acra-python

EOF
            exit 0
            ;;
        *)
            echo -e "${RED}Error: Unknown option $1${NC}"
            echo "Run './install.sh --help' for usage information."
            exit 1
            ;;
    esac
done

# Validate local path if specified
if [[ "$TARGET" == "local" ]]; then
    if [[ -z "$LOCAL_PATH" ]]; then
        echo -e "${RED}Error: --local requires a path argument${NC}"
        exit 1
    fi
    
    # Expand ~ if present
    LOCAL_PATH="${LOCAL_PATH/#\~/$HOME}"
    
    if [[ ! -d "$LOCAL_PATH" ]]; then
        echo -e "${RED}Error: Directory does not exist: $LOCAL_PATH${NC}"
        exit 1
    fi
fi

# Determine target directory
if [[ "$TARGET" == "global" ]]; then
    TARGET_DIR="$HOME/.rovodev"
else
    TARGET_DIR="$LOCAL_PATH/.rovodev"
fi

# Print configuration
echo -e "${BLUE}=== Rovodevloop Installer ===${NC}"
echo -e "Mode:        ${YELLOW}$MODE${NC}"
echo -e "Target:      ${YELLOW}$TARGET${NC}"
echo -e "Target dir:  ${YELLOW}$TARGET_DIR${NC}"
echo -e "Method:      ${YELLOW}$([ "$USE_SYMLINK" = true ] && echo "symlink" || echo "copy")${NC}"
echo -e "Source:      ${YELLOW}$SCRIPT_DIR${NC}"
echo ""

# Function to create symlink or copy
install_item() {
    local src="$1"
    local dest="$2"
    local item_name="$3"
    
    if [[ "$USE_SYMLINK" = true ]]; then
        if [[ -e "$dest" || -L "$dest" ]]; then
            if [[ "$MODE" == "update" ]]; then
                rm -rf "$dest"
                ln -sf "$src" "$dest"
                echo -e "  ${GREEN}✓${NC} Updated symlink: $item_name"
            else
                echo -e "  ${YELLOW}⚠${NC}  Already exists: $item_name (skipping)"
            fi
        else
            ln -sf "$src" "$dest"
            echo -e "  ${GREEN}✓${NC} Created symlink: $item_name"
        fi
    else
        if [[ -e "$dest" ]]; then
            if [[ "$MODE" == "update" ]]; then
                rm -rf "$dest"
                cp -r "$src" "$dest"
                echo -e "  ${GREEN}✓${NC} Updated copy: $item_name"
            else
                echo -e "  ${YELLOW}⚠${NC}  Already exists: $item_name (skipping)"
            fi
        else
            cp -r "$src" "$dest"
            echo -e "  ${GREEN}✓${NC} Copied: $item_name"
        fi
    fi
}

# Function to uninstall
uninstall_item() {
    local dest="$1"
    local item_name="$2"
    
    if [[ -e "$dest" || -L "$dest" ]]; then
        rm -rf "$dest"
        echo -e "  ${GREEN}✓${NC} Removed: $item_name"
    else
        echo -e "  ${YELLOW}⚠${NC}  Not found: $item_name (already removed)"
    fi
}

# Uninstall mode
if [[ "$MODE" == "uninstall" ]]; then
    echo -e "${YELLOW}Uninstalling rovodevloop...${NC}"
    echo ""
    
    uninstall_item "$TARGET_DIR/prompts/devloop" "prompts/devloop"
    uninstall_item "$TARGET_DIR/subagents/devloop" "subagents/devloop"
    uninstall_item "$TARGET_DIR/skills/plan-management.md" "skills/plan-management.md"
    uninstall_item "$TARGET_DIR/skills/python-patterns.md" "skills/python-patterns.md"
    uninstall_item "$TARGET_DIR/skills/git-workflows.md" "skills/git-workflows.md"
    uninstall_item "$TARGET_DIR/scripts/check-plan-complete.sh" "scripts/check-plan-complete.sh"
    uninstall_item "$TARGET_DIR/scripts/parse-local-config.sh" "scripts/parse-local-config.sh"
    
    echo ""
    echo -e "${GREEN}✓ Uninstall complete!${NC}"
    echo ""
    echo -e "${YELLOW}Note: You may need to manually remove entries from:${NC}"
    echo -e "  $TARGET_DIR/prompts.yml"
    echo ""
    exit 0
fi

# Install/Update mode
echo -e "${YELLOW}$([ "$MODE" == "update" ] && echo "Updating" || echo "Installing") rovodevloop...${NC}"
echo ""

# Create target directories
mkdir -p "$TARGET_DIR/prompts"
mkdir -p "$TARGET_DIR/subagents"
mkdir -p "$TARGET_DIR/skills"
mkdir -p "$TARGET_DIR/scripts"

# Install prompts
echo -e "${BLUE}Installing prompts...${NC}"
install_item "$SCRIPT_DIR/prompts" "$TARGET_DIR/prompts/devloop" "prompts/devloop"

# Install subagents
echo -e "${BLUE}Installing subagents...${NC}"
install_item "$SCRIPT_DIR/subagents" "$TARGET_DIR/subagents/devloop" "subagents/devloop"

# Install skills
echo -e "${BLUE}Installing skills...${NC}"
install_item "$SCRIPT_DIR/skills/plan-management.md" "$TARGET_DIR/skills/plan-management.md" "skills/plan-management.md"
install_item "$SCRIPT_DIR/skills/python-patterns.md" "$TARGET_DIR/skills/python-patterns.md" "skills/python-patterns.md"
install_item "$SCRIPT_DIR/skills/git-workflows.md" "$TARGET_DIR/skills/git-workflows.md" "skills/git-workflows.md"

# Install scripts
echo -e "${BLUE}Installing scripts...${NC}"
install_item "$SCRIPT_DIR/scripts/check-plan-complete.sh" "$TARGET_DIR/scripts/check-plan-complete.sh" "scripts/check-plan-complete.sh"
install_item "$SCRIPT_DIR/scripts/parse-local-config.sh" "$TARGET_DIR/scripts/parse-local-config.sh" "scripts/parse-local-config.sh"

# Make scripts executable
chmod +x "$TARGET_DIR/scripts/check-plan-complete.sh" 2>/dev/null || true
chmod +x "$TARGET_DIR/scripts/parse-local-config.sh" 2>/dev/null || true

echo ""
echo -e "${GREEN}✓ Installation complete!${NC}"
echo ""

# Check for prompts.yml
PROMPTS_YML="$TARGET_DIR/prompts.yml"
if [[ ! -f "$PROMPTS_YML" ]]; then
    echo -e "${YELLOW}⚠  prompts.yml not found at: $PROMPTS_YML${NC}"
    echo ""
    echo -e "Would you like to create it with rovodevloop prompts? [y/N] "
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        cat > "$PROMPTS_YML" << 'EOF'
# Rovodev prompts configuration
prompts:
  # Devloop Workflow - Spike → Plan → Execute
  - name: devloop
    description: "Start new development work with structured planning"
    content_file: prompts/devloop/rovodev.md
  
  - name: spike
    description: "Time-boxed investigation and exploration (15-20 min)"
    content_file: prompts/devloop/spike.md
  
  - name: continue
    description: "Resume work from existing plan or saved state"
    content_file: prompts/devloop/continue.md
  
  - name: fresh
    description: "Save state for context reset"
    content_file: prompts/devloop/fresh.md
  
  - name: quick
    description: "Fast fixes without planning overhead"
    content_file: prompts/devloop/quick.md
  
  - name: review
    description: "Code review for changes or PRs"
    content_file: prompts/devloop/review.md
  
  - name: ship
    description: "Commit and create PR"
    content_file: prompts/devloop/ship.md
EOF
        echo -e "${GREEN}✓${NC} Created prompts.yml with rovodevloop entries"
    else
        echo -e "${YELLOW}→${NC} Skipped creating prompts.yml"
        echo ""
        echo -e "To register prompts manually, add this to $PROMPTS_YML:"
        echo -e "${BLUE}---${NC}"
        cat "$SCRIPT_DIR/prompts.yml.snippet"
        echo -e "${BLUE}---${NC}"
    fi
else
    echo -e "${YELLOW}⚠  prompts.yml already exists${NC}"
    echo ""
    echo -e "To register rovodevloop prompts, add entries from:"
    echo -e "  ${BLUE}$SCRIPT_DIR/prompts.yml.snippet${NC}"
    echo ""
    echo -e "To your existing prompts.yml at:"
    echo -e "  ${BLUE}$PROMPTS_YML${NC}"
fi

echo ""
echo -e "${GREEN}=== Next Steps ===${NC}"
echo ""
if [[ "$TARGET" == "global" ]]; then
    echo -e "1. Verify prompts.yml has rovodevloop entries:"
    echo -e "   ${BLUE}cat ~/.rovodev/prompts.yml${NC}"
    echo ""
    echo -e "2. Test with rovodev:"
    echo -e "   ${BLUE}rovodev run \"@devloop Test workflow\"${NC}"
else
    echo -e "1. Verify prompts.yml has rovodevloop entries:"
    echo -e "   ${BLUE}cat $LOCAL_PATH/.rovodev/prompts.yml${NC}"
    echo ""
    echo -e "2. Test with rovodev in your project:"
    echo -e "   ${BLUE}cd $LOCAL_PATH${NC}"
    echo -e "   ${BLUE}rovodev run \"@devloop Test workflow\"${NC}"
fi
echo ""
echo -e "3. Try the full workflow:"
echo -e "   ${BLUE}@devloop${NC}   - Start new work"
echo -e "   ${BLUE}@spike${NC}     - Time-boxed investigation"
echo -e "   ${BLUE}@continue${NC}  - Resume from plan"
echo -e "   ${BLUE}@fresh${NC}     - Save state"
echo -e "   ${BLUE}@review${NC}    - Code review"
echo -e "   ${BLUE}@ship${NC}      - Commit and PR"
echo ""
echo -e "${GREEN}Happy coding! 🚀${NC}"
