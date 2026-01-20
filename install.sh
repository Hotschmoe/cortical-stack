#!/usr/bin/env bash
# Cortical Stack Installer (Bash)
# Usage: curl -fsSL https://raw.githubusercontent.com/hotschmoe/cortical-stack/master/install.sh | bash

set -e

STACK_DIR=".cstack"
CLAUDE_DIR=".claude"
REPO_BASE="https://raw.githubusercontent.com/hotschmoe/cortical-stack/master/clean"

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

# Get remote version
NEW_VERSION="1.0.0"
if command -v curl &> /dev/null; then
    FETCHED_VERSION=$(curl -fsSL "$REPO_BASE/_VERSION" 2>/dev/null | tr -d '[:space:]')
    if [ -n "$FETCHED_VERSION" ]; then
        NEW_VERSION="$FETCHED_VERSION"
    fi
fi

echo ""
echo -e "${CYAN}Cortical Stack Installer v$NEW_VERSION${NC}"
echo ""

# Check for existing installation version
EXISTING_VERSION=""
if [ -f "$STACK_DIR/_VERSION" ]; then
    EXISTING_VERSION=$(cat "$STACK_DIR/_VERSION" | tr -d '[:space:]')
fi

if [ -n "$EXISTING_VERSION" ]; then
    if [ "$EXISTING_VERSION" = "$NEW_VERSION" ]; then
        success "Already at version $NEW_VERSION"
        echo ""
        echo "To reinstall, delete .cstack/ and run again."
        exit 0
    fi
    status "Upgrading from v$EXISTING_VERSION to v$NEW_VERSION"
fi

# Create directories
if [ ! -d "$STACK_DIR" ]; then
    status "Creating $STACK_DIR directory..."
    mkdir -p "$STACK_DIR"
fi

mkdir -p "$CLAUDE_DIR/hooks"
mkdir -p "$CLAUDE_DIR/commands"

# Download or create stack files (only if they don't exist)
for file in CURRENT.md PLAN.md INBOX.md OUTBOX.md QUICKREF.md; do
    dest="$STACK_DIR/$file"
    if [ ! -f "$dest" ]; then
        status "Creating $STACK_DIR/$file..."
        if curl -fsSL "$REPO_BASE/.cstack/$file" -o "$dest" 2>/dev/null; then
            :
        else
            warn "Failed to download $file, creating from template..."
            case $file in
                CURRENT.md)
                    cat > "$dest" << 'EOF'
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
                    cat > "$dest" << 'EOF'
# Plan

## Tasks
- [ ] (Add your first task here)

## Notes
(Project notes and context)
EOF
                    ;;
                INBOX.md)
                    cat > "$dest" << 'EOF'
# Inbox

(Messages to this agent will appear here)
EOF
                    ;;
                OUTBOX.md)
                    cat > "$dest" << 'EOF'
# Outbox

(Messages from this agent will appear here)
EOF
                    ;;
            esac
        fi
    fi
done

# Save version file
echo "$NEW_VERSION" > "$STACK_DIR/_VERSION"
success "Stack files ready."

# Download hooks (always update on install/upgrade)
status "Installing hooks..."

for hook in cstack-start.ps1 cstack-start.sh cstack-stop.ps1 cstack-stop.sh; do
    if curl -fsSL "$REPO_BASE/.claude/hooks/$hook" -o "$CLAUDE_DIR/hooks/$hook" 2>/dev/null; then
        chmod +x "$CLAUDE_DIR/hooks/$hook" 2>/dev/null || true
    else
        warn "Failed to download $hook"
    fi
done

success "Hooks installed."

# Download commands (always update on install/upgrade)
status "Installing commands..."

for cmd in cstack-task.md cstack-checkpoint.md cstack-start.md; do
    if curl -fsSL "$REPO_BASE/.claude/commands/$cmd" -o "$CLAUDE_DIR/commands/$cmd" 2>/dev/null; then
        :
    else
        warn "Failed to download $cmd"
    fi
done

success "Commands installed."

# Handle settings.local.json
SETTINGS_FILE="$CLAUDE_DIR/settings.local.json"

if [ -f "$SETTINGS_FILE" ]; then
    warn "$SETTINGS_FILE already exists."
    status "Please verify hooks are configured. Expected config:"
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

# Handle CLAUDE.md with version-tagged block
status "Checking CLAUDE.md..."

CLAUDE_INSTRUCTIONS=""
CLAUDE_INSTRUCTIONS=$(curl -fsSL "$REPO_BASE/CLAUDE.md" 2>/dev/null) || true

if [ -n "$CLAUDE_INSTRUCTIONS" ]; then
    CLAUDE_MD_PATH="CLAUDE.md"

    if [ -f "$CLAUDE_MD_PATH" ]; then
        EXISTING_CONTENT=$(cat "$CLAUDE_MD_PATH")

        # Check if cstack block exists and extract version
        if echo "$EXISTING_CONTENT" | grep -q '<!-- cstack:begin version="'; then
            EXISTING_CSTACK_VERSION=$(echo "$EXISTING_CONTENT" | grep -o 'cstack:begin version="[^"]*"' | sed 's/.*version="\([^"]*\)".*/\1/')

            if [ "$EXISTING_CSTACK_VERSION" = "$NEW_VERSION" ]; then
                success "CLAUDE.md cstack block already at v$NEW_VERSION"
            else
                status "Updating CLAUDE.md cstack block from v$EXISTING_CSTACK_VERSION to v$NEW_VERSION..."
                # Remove old block using sed and add new one
                # This handles multiline by using a temp file approach
                NEW_CONTENT=$(echo "$EXISTING_CONTENT" | perl -0777 -pe 's/<!-- cstack:begin.*?<!-- cstack:end -->//s')
                NEW_CONTENT=$(echo "$NEW_CONTENT" | sed -e :a -e '/^\s*$/d;N;ba' | sed '$ { /^$/d }')
                echo -e "${NEW_CONTENT}\n\n${CLAUDE_INSTRUCTIONS}" > "$CLAUDE_MD_PATH"
                success "CLAUDE.md updated."
            fi
        else
            status "Appending cstack instructions to CLAUDE.md..."
            echo -e "\n\n${CLAUDE_INSTRUCTIONS}" >> "$CLAUDE_MD_PATH"
            success "CLAUDE.md updated."
        fi
    else
        status "Creating CLAUDE.md..."
        echo "$CLAUDE_INSTRUCTIONS" > "$CLAUDE_MD_PATH"
        success "CLAUDE.md created."
    fi
else
    warn "Failed to download CLAUDE.md template"
fi

# Success
echo ""
success "Cortical Stack v$NEW_VERSION installed!"
echo ""
echo -e "${WHITE}Files:${NC}"
echo "  $STACK_DIR/CURRENT.md   - Active task, focus, next steps"
echo "  $STACK_DIR/PLAN.md      - Task backlog with states"
echo "  $STACK_DIR/INBOX.md     - Messages TO this agent"
echo "  $STACK_DIR/OUTBOX.md    - Messages FROM this agent"
echo "  $STACK_DIR/QUICKREF.md  - Command quick reference"
echo "  $CLAUDE_DIR/commands/   - Slash commands"
echo "  $CLAUDE_DIR/hooks/      - Start/stop hooks"
echo ""
echo -e "${WHITE}Next steps:${NC}"
echo "  1. Start a new Claude Code session"
echo "  2. The start hook will load your stack automatically"
echo "  3. Update .cstack/ files as you work"
echo ""
echo -e "${GRAY}Docs: https://github.com/hotschmoe/cortical-stack${NC}"
