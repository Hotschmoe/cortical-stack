# Cortical Stack Installer (PowerShell)
# Usage: irm https://raw.githubusercontent.com/hotschmoe/cortical-stack/main/install.ps1 | iex

$ErrorActionPreference = "Stop"

$StackDir = ".cstack"
$ClaudeDir = ".claude"
$RepoBase = "https://raw.githubusercontent.com/hotschmoe/cortical-stack/main/clean"

function Write-Status($msg) {
    Write-Host "[cstack] " -ForegroundColor Cyan -NoNewline
    Write-Host $msg
}

function Write-Success($msg) {
    Write-Host "[cstack] " -ForegroundColor Green -NoNewline
    Write-Host $msg
}

function Write-Warn($msg) {
    Write-Host "[cstack] " -ForegroundColor Yellow -NoNewline
    Write-Host $msg
}

Write-Host ""
Write-Host "Cortical Stack Installer" -ForegroundColor Cyan
Write-Host ""

# Check for existing installation
if (Test-Path $StackDir) {
    Write-Warn "$StackDir already exists. Skipping stack file creation."
    $SkipStack = $true
} else {
    $SkipStack = $false
}

# Create directories
if (-not $SkipStack) {
    Write-Status "Creating $StackDir directory..."
    New-Item -ItemType Directory -Path $StackDir -Force | Out-Null
}

New-Item -ItemType Directory -Path "$ClaudeDir\hooks" -Force | Out-Null

# Download or create stack files
if (-not $SkipStack) {
    $stackFiles = @("CURRENT.md", "PLAN.md", "INBOX.md", "OUTBOX.md")

    foreach ($file in $stackFiles) {
        Write-Status "Downloading $StackDir/$file..."
        $url = "$RepoBase/.cstack/$file"
        $dest = Join-Path $StackDir $file
        try {
            Invoke-RestMethod -Uri $url -OutFile $dest
        } catch {
            Write-Warn "Failed to download $file, creating from template..."
            switch ($file) {
                "CURRENT.md" {
                    @"
# Current State

## Current Task
(No active task)

## Focus
(Awaiting initial directive)

## Next Steps
- Review PLAN.md for pending tasks
- Check INBOX.md for new messages
"@ | Set-Content $dest
                }
                "PLAN.md" {
                    @"
# Plan

## Tasks
- [ ] (Add your first task here)

## Notes
(Project notes and context)
"@ | Set-Content $dest
                }
                "INBOX.md" {
                    @"
# Inbox

(Messages to this agent will appear here)
"@ | Set-Content $dest
                }
                "OUTBOX.md" {
                    @"
# Outbox

(Messages from this agent will appear here)
"@ | Set-Content $dest
                }
            }
        }
    }
    Write-Success "Stack files created."
}

# Download hooks
Write-Status "Installing hooks..."

$hooks = @(
    @{ name = "cstack-start.ps1"; url = "$RepoBase/.claude/hooks/cstack-start.ps1" },
    @{ name = "cstack-start.sh"; url = "$RepoBase/.claude/hooks/cstack-start.sh" },
    @{ name = "cstack-stop.ps1"; url = "$RepoBase/.claude/hooks/cstack-stop.ps1" },
    @{ name = "cstack-stop.sh"; url = "$RepoBase/.claude/hooks/cstack-stop.sh" }
)

foreach ($hook in $hooks) {
    $dest = Join-Path "$ClaudeDir\hooks" $hook.name
    try {
        Invoke-RestMethod -Uri $hook.url -OutFile $dest
    } catch {
        Write-Warn "Failed to download $($hook.name)"
    }
}

Write-Success "Hooks installed."

# Handle settings.local.json
$settingsFile = "$ClaudeDir\settings.local.json"

if (Test-Path $settingsFile) {
    Write-Warn "$settingsFile already exists."
    Write-Status "Please add these hooks manually to your settings:"
    Write-Host @"

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
"@
} else {
    Write-Status "Creating $settingsFile..."
    try {
        Invoke-RestMethod -Uri "$RepoBase/.claude/settings.local.json" -OutFile $settingsFile
    } catch {
        @"
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
"@ | Set-Content $settingsFile
    }
    Write-Success "Settings configured."
}

# Handle CLAUDE.md
if (Test-Path "CLAUDE.md") {
    Write-Warn "CLAUDE.md already exists."
    Write-Status "Consider adding cortical stack instructions from:"
    Write-Host "  $RepoBase/CLAUDE.md"
} else {
    Write-Status "Creating CLAUDE.md..."
    try {
        Invoke-RestMethod -Uri "$RepoBase/CLAUDE.md" -OutFile "CLAUDE.md"
        Write-Success "CLAUDE.md created."
    } catch {
        Write-Warn "Failed to download CLAUDE.md template."
    }
}

# Success
Write-Host ""
Write-Success "Cortical Stack installed!"
Write-Host ""
Write-Host "Files created:" -ForegroundColor White
Write-Host "  $StackDir/CURRENT.md   - Active task, focus, next steps"
Write-Host "  $StackDir/PLAN.md      - Task backlog with states"
Write-Host "  $StackDir/INBOX.md     - Messages TO this agent"
Write-Host "  $StackDir/OUTBOX.md    - Messages FROM this agent"
Write-Host "  $ClaudeDir/hooks/      - Start/stop hooks"
Write-Host "  $ClaudeDir/settings.local.json"
Write-Host ""
Write-Host "Next steps:" -ForegroundColor White
Write-Host "  1. Start a new Claude Code session"
Write-Host "  2. The start hook will load your stack automatically"
Write-Host "  3. Update .cstack/ files as you work"
Write-Host ""
Write-Host "Docs: https://github.com/hotschmoe/cortical-stack" -ForegroundColor Gray
