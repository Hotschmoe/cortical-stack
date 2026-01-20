#!/usr/bin/env bash
# Cortical Stack Installer (Bash)
# Usage: curl -fsSL https://raw.githubusercontent.com/hotschmoe/cortical-stack/main/install.sh | bash

set -e

STACK_DIR=".cstack"
CLAUDE_DIR=".claude"
REPO_BASE="https://raw.githubusercontent.com/hotschmoe/cortical-stack/main/clean"

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

echo ""
echo -e "${CYAN}Cortical Stack Installer${NC}"
echo ""

# Check for existing installation
SKIP_STACK=false
if [ -d "$STACK_DIR" ]; then
    warn "$STACK_DIR already exists. Skipping stack file creation."
    SKIP_STACK=true
fi

# Create directories
if [ "$SKIP_STACK" = false ]; then
    status "Creating $STACK_DIR directory..."
    mkdir -p "$STACK_DIR"
fi

mkdir -p "$CLAUDE_DIR/hooks"

# Download or create stack files
if [ "$SKIP_STACK" = false ]; then
    for file in CURRENT.md PLAN.md INBOX.md OUTBOX.md; do
        status "Downloading $STACK_DIR/$file..."
        if curl -fsSL "$REPO_BASE/.cstack/$file" -o "$STACK_DIR/$file" 2>/dev/null; then
            :
        else
            warn "Failed to download $file, creating from template..."
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

# Download hooks
status "Installing hooks..."

for hook in cstack-start.ps1 cstack-start.sh cstack-stop.ps1 cstack-stop.sh; do
    if curl -fsSL "$REPO_BASE/.claude/hooks/$hook" -o "$CLAUDE_DIR/hooks/$hook" 2>/dev/null; then
        chmod +x "$CLAUDE_DIR/hooks/$hook" 2>/dev/null || true
    else
        warn "Failed to download $hook"
    fi
done

success "Hooks installed."

# Handle settings.local.json
SETTINGS_FILE="$CLAUDE_DIR/settings.local.json"

if [ -f "$SETTINGS_FILE" ]; then
    warn "$SETTINGS_FILE already exists."
    status "Please add these hooks manually to your settings:"
    cat << 'EOF'

{
  "hooks": {
    "start": [
      { "command": "powershell -ExecutionPolicy Bypass -File .claude/hooks/cstack-start.ps1", "os": ["windows"] },
      { "command": "bash .claude/hooks/cstack-start.sh", "os": ["linux", "darwin"] }
    ],
    "stop": [
      { "command": "powershell -ExecutionPolicy Bypass -File .claude/hooks/cstack-stop.ps1", "os": ["windows"] },
      { "command": "bash .claude/hooks/cstack-stop.sh", "os": ["linux", "darwin"] }
    ]
  }
}
EOF
else
    status "Creating $SETTINGS_FILE..."
    if curl -fsSL "$REPO_BASE/.claude/settings.local.json" -o "$SETTINGS_FILE" 2>/dev/null; then
        :
    else
        cat > "$SETTINGS_FILE" << 'EOF'
{
  "hooks": {
    "start": [
      { "command": "powershell -ExecutionPolicy Bypass -File .claude/hooks/cstack-start.ps1", "os": ["windows"] },
      { "command": "bash .claude/hooks/cstack-start.sh", "os": ["linux", "darwin"] }
    ],
    "stop": [
      { "command": "powershell -ExecutionPolicy Bypass -File .claude/hooks/cstack-stop.ps1", "os": ["windows"] },
      { "command": "bash .claude/hooks/cstack-stop.sh", "os": ["linux", "darwin"] }
    ]
  }
}
EOF
    fi
    success "Settings configured."
fi

# Handle CLAUDE.md
if [ -f "CLAUDE.md" ]; then
    warn "CLAUDE.md already exists."
    status "Consider adding cortical stack instructions from:"
    echo "  $REPO_BASE/CLAUDE.md"
else
    status "Creating CLAUDE.md..."
    if curl -fsSL "$REPO_BASE/CLAUDE.md" -o "CLAUDE.md" 2>/dev/null; then
        success "CLAUDE.md created."
    else
        warn "Failed to download CLAUDE.md template."
    fi
fi

# Success
echo ""
success "Cortical Stack installed!"
echo ""
echo -e "${WHITE}Files created:${NC}"
echo "  $STACK_DIR/CURRENT.md   - Active task, focus, next steps"
echo "  $STACK_DIR/PLAN.md      - Task backlog with states"
echo "  $STACK_DIR/INBOX.md     - Messages TO this agent"
echo "  $STACK_DIR/OUTBOX.md    - Messages FROM this agent"
echo "  $CLAUDE_DIR/hooks/      - Start/stop hooks"
echo "  $CLAUDE_DIR/settings.local.json"
echo ""
echo -e "${WHITE}Next steps:${NC}"
echo "  1. Start a new Claude Code session"
echo "  2. The start hook will load your stack automatically"
echo "  3. Update .cstack/ files as you work"
echo ""
echo -e "${GRAY}Docs: https://github.com/hotschmoe/cortical-stack${NC}"
