#!/usr/bin/env bash
# Cortical Stack Installer (Bash)
# Usage: curl -fsSL https://raw.githubusercontent.com/hotschmoe/cortical-stack/main/install.sh | bash

set -e

STACK_DIR=".cstack"
REPO_URL="https://raw.githubusercontent.com/hotschmoe/cortical-stack/main/clean/.cstack"

# Colors
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
WHITE='\033[0;37m'
GRAY='\033[0;90m'
NC='\033[0m'

status() { echo -e "${CYAN}[cstack]${NC} $1"; }
success() { echo -e "${GREEN}[cstack]${NC} $1"; }
warn() { echo -e "${YELLOW}[cstack]${NC} $1"; }

# Check if already initialized
if [ -d "$STACK_DIR" ]; then
    warn "$STACK_DIR already exists. Skipping file creation."
else
    status "Creating $STACK_DIR directory..."
    mkdir -p "$STACK_DIR"

    for file in CURRENT.md PLAN.md INBOX.md OUTBOX.md; do
        status "Downloading $file..."
        if curl -fsSL "$REPO_URL/$file" -o "$STACK_DIR/$file" 2>/dev/null; then
            :
        else
            warn "Failed to download $file, creating empty template..."
            case $file in
                CURRENT.md)
                    cat > "$STACK_DIR/$file" << 'EOF'
# Current State

## Current Task
(No active task)

## Focus
(Awaiting initial directive)

## Next Steps
- Review PLAN.md for pending tasks
- Check INBOX.md for new messages
EOF
                    ;;
                PLAN.md)
                    cat > "$STACK_DIR/$file" << 'EOF'
# Plan

## Tasks
- [ ] (Add your first task here)

## Notes
(Project notes and context)
EOF
                    ;;
                INBOX.md)
                    cat > "$STACK_DIR/$file" << 'EOF'
# Inbox

(Messages to this agent will appear here)
EOF
                    ;;
                OUTBOX.md)
                    cat > "$STACK_DIR/$file" << 'EOF'
# Outbox

(Messages from this agent will appear here)
EOF
                    ;;
            esac
        fi
    done
    success "Stack files created."
fi

# Set up Claude Code hooks (optional)
CLAUDE_DIR=".claude"
SETTINGS_FILE="$CLAUDE_DIR/settings.local.json"

if [ -f "$SETTINGS_FILE" ]; then
    warn "$SETTINGS_FILE already exists. Skipping hook setup."
    status "To add the stop hook manually, add this to your settings:"
    cat << 'EOF'
{
  "hooks": {
    "stop": [
      {
        "command": "echo '[cstack] Remember to update .cstack/CURRENT.md with your progress!'"
      }
    ]
  }
}
EOF
else
    status "Setting up Claude Code hooks..."
    mkdir -p "$CLAUDE_DIR"

    cat > "$SETTINGS_FILE" << 'EOF'
{
  "hooks": {
    "stop": [
      {
        "command": "echo '[cstack] Remember to update .cstack/CURRENT.md with your progress!'"
      }
    ]
  }
}
EOF
    success "Hook configured in $SETTINGS_FILE"
fi

echo ""
success "Cortical Stack initialized!"
echo ""
echo -e "${WHITE}Files created:${NC}"
echo "  $STACK_DIR/CURRENT.md  - Active task, focus, next steps"
echo "  $STACK_DIR/PLAN.md     - Task backlog with states"
echo "  $STACK_DIR/INBOX.md    - Messages TO this agent"
echo "  $STACK_DIR/OUTBOX.md   - Messages FROM this agent"
echo ""
echo -e "${WHITE}Next steps:${NC}"
echo "  1. Add .cstack/ instructions to your CLAUDE.md"
echo "  2. Start working - update CURRENT.md as you go"
echo ""
echo -e "${GRAY}Docs: https://github.com/hotschmoe/cortical-stack${NC}"
