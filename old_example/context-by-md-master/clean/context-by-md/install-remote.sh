#!/bin/bash
# Remote install - downloads and installs context-by-md from GitHub
# Usage: curl -fsSL https://raw.githubusercontent.com/hotschmoe/context-by-md/master/clean/context-by-md/install-remote.sh | bash

set -e

REPO="hotschmoe/context-by-md"
BRANCH="master"
BASE_URL="https://raw.githubusercontent.com/$REPO/$BRANCH/clean/context-by-md"

# Get new version
NEW_VERSION=$(curl -fsSL "$BASE_URL/.context-by-md/_VERSION" | tr -d '\n\r')

echo -e "\033[36mcontext-by-md installer v$NEW_VERSION\033[0m"
echo ""

# Check for existing installation
EXISTING_VERSION=""
IS_UPGRADE=false

if [ -f ".context-by-md/_VERSION" ]; then
    EXISTING_VERSION=$(cat ".context-by-md/_VERSION" | tr -d '\n\r')
elif [ -f ".context-by-md/CURRENT.md" ]; then
    # Legacy install (no version file)
    EXISTING_VERSION="1.x (legacy)"
fi

if [ -n "$EXISTING_VERSION" ]; then
    if [ "$EXISTING_VERSION" = "$NEW_VERSION" ]; then
        echo -e "\033[32mAlready installed: v$NEW_VERSION\033[0m"
        echo ""
        echo "To reinstall, delete .context-by-md/ and run again."
        exit 0
    fi

    echo -e "\033[33mExisting installation detected: v$EXISTING_VERSION\033[0m"
    echo -e "\033[36mNew version available: v$NEW_VERSION\033[0m"
    echo ""
    echo "Upgrade will:"
    echo "  1. Backup your CURRENT.md and PLAN.md"
    echo "  2. Install fresh templates and updated commands"
    echo "  3. Provide migration guidance"
    echo ""
    read -p "Upgrade now? [y/N] " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "\033[36mUpgrade cancelled.\033[0m"
        exit 0
    fi
    IS_UPGRADE=true
fi

# Create backup if upgrading
BACKUP_DIR=""
if [ "$IS_UPGRADE" = true ]; then
    BACKUP_DATE=$(date +"%Y-%m-%d_%H%M")
    BACKUP_DIR=".context-by-md/backup/$BACKUP_DATE"

    echo ""
    echo -e "\033[36mCreating backup...\033[0m"
    mkdir -p "$BACKUP_DIR"

    # Backup user data files
    [ -f ".context-by-md/CURRENT.md" ] && cp ".context-by-md/CURRENT.md" "$BACKUP_DIR/"
    [ -f ".context-by-md/PLAN.md" ] && cp ".context-by-md/PLAN.md" "$BACKUP_DIR/"
    # Backup legacy files if they exist
    [ -f ".context-by-md/ACTIONPLAN.md" ] && cp ".context-by-md/ACTIONPLAN.md" "$BACKUP_DIR/"
    [ -f ".context-by-md/BACKLOG.md" ] && cp ".context-by-md/BACKLOG.md" "$BACKUP_DIR/"

    echo -e "  \033[32mBacked up to: $BACKUP_DIR\033[0m"
fi

echo ""
echo -e "\033[36mDownloading and installing...\033[0m"

# Create directories
mkdir -p .context-by-md
mkdir -p .claude/commands
mkdir -p .claude/hooks

# Download context files
curl -fsSL "$BASE_URL/.context-by-md/CURRENT.md" -o .context-by-md/CURRENT.md
curl -fsSL "$BASE_URL/.context-by-md/PLAN.md" -o .context-by-md/PLAN.md
curl -fsSL "$BASE_URL/.context-by-md/QUICKREF.md" -o .context-by-md/QUICKREF.md
curl -fsSL "$BASE_URL/.context-by-md/_VERSION" -o .context-by-md/_VERSION

# Remove legacy files if they exist
[ -f ".context-by-md/ACTIONPLAN.md" ] && rm ".context-by-md/ACTIONPLAN.md"
[ -f ".context-by-md/BACKLOG.md" ] && rm ".context-by-md/BACKLOG.md"
[ -d ".context-by-md/sessions" ] && rm -rf ".context-by-md/sessions"

# Download Claude commands
curl -fsSL "$BASE_URL/.claude/commands/context-start.md" -o .claude/commands/context-start.md
curl -fsSL "$BASE_URL/.claude/commands/context-checkpoint.md" -o .claude/commands/context-checkpoint.md
curl -fsSL "$BASE_URL/.claude/commands/context-task.md" -o .claude/commands/context-task.md

# Download hooks (bash versions for Unix)
curl -fsSL "$BASE_URL/.claude/hooks/context-start.sh" -o .claude/hooks/context-start.sh
curl -fsSL "$BASE_URL/.claude/hooks/context-stop.sh" -o .claude/hooks/context-stop.sh
chmod +x .claude/hooks/*.sh

# Download or merge settings
if [ -f .claude/settings.local.json ]; then
    echo -e "  \033[33m.claude/settings.local.json exists - please verify hooks config\033[0m"
else
    curl -fsSL "$BASE_URL/.claude/settings.local.unix.json" -o .claude/settings.local.json
fi

# Handle CLAUDE.md
if [ "$IS_UPGRADE" = false ]; then
    if [ -f CLAUDE.md ]; then
        echo "" >> CLAUDE.md
        echo "---" >> CLAUDE.md
        echo "" >> CLAUDE.md
        curl -fsSL "$BASE_URL/CLAUDE.md" >> CLAUDE.md
        echo -e "  \033[32mAppended to existing CLAUDE.md\033[0m"
    else
        curl -fsSL "$BASE_URL/CLAUDE.md" -o CLAUDE.md
        echo -e "  \033[32mCreated CLAUDE.md\033[0m"
    fi
fi

# Success message
echo ""
echo -e "\033[32mInstalled context-by-md v$NEW_VERSION\033[0m"

if [ "$IS_UPGRADE" = true ]; then
    echo ""
    echo -e "\033[36m========================================\033[0m"
    echo -e "\033[36m  MIGRATION GUIDE\033[0m"
    echo -e "\033[36m========================================\033[0m"
    echo ""
    echo "Your data was backed up to:"
    echo -e "  \033[33m$BACKUP_DIR\033[0m"
    echo ""
    echo "To migrate your tasks:"
    echo "  1. Open your backup files in the folder above"
    echo "  2. Copy tasks to the new PLAN.md format"
    echo "  3. Copy any active work to CURRENT.md"
    echo ""
    echo "Or let Claude help:"
    echo "  Just ask Claude to review your backup files and migrate"
    echo "  your tasks to the new format. For example:"
    echo -e "  \033[36m'Review .context-by-md/backup/ and migrate my tasks to the new format'\033[0m"
    echo ""
    echo "Once verified, you can delete the backup folder."
    echo ""
else
    echo ""
    echo "Files created:"
    echo "  .context-by-md/CURRENT.md  - Session state + active task"
    echo "  .context-by-md/PLAN.md     - Task list + backlog"
    echo "  .context-by-md/QUICKREF.md - Command cheat sheet"
    echo "  .claude/commands/          - Slash commands"
    echo "  .claude/hooks/             - Auto-checkpoint reminder"
    echo ""
    echo "Get started:"
    echo "  /context-task add P1: Your first task | description"
    echo "  /context-task start 1"
fi
