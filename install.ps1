# Cortical Stack Installer (PowerShell)
# Usage: irm https://raw.githubusercontent.com/hotschmoe/cortical-stack/main/install.ps1 | iex

$ErrorActionPreference = "Stop"

$StackDir = ".cstack"
$RepoUrl = "https://raw.githubusercontent.com/hotschmoe/cortical-stack/main/clean/.cstack"

function Write-Status($msg) {
    Write-Host "[cstack] $msg" -ForegroundColor Cyan
}

function Write-Success($msg) {
    Write-Host "[cstack] $msg" -ForegroundColor Green
}

function Write-Warn($msg) {
    Write-Host "[cstack] $msg" -ForegroundColor Yellow
}

# Check if already initialized
if (Test-Path $StackDir) {
    Write-Warn "$StackDir already exists. Skipping file creation."
} else {
    Write-Status "Creating $StackDir directory..."
    New-Item -ItemType Directory -Path $StackDir -Force | Out-Null

    $files = @("CURRENT.md", "PLAN.md", "INBOX.md", "OUTBOX.md")

    foreach ($file in $files) {
        Write-Status "Downloading $file..."
        $url = "$RepoUrl/$file"
        $dest = Join-Path $StackDir $file
        try {
            Invoke-RestMethod -Uri $url -OutFile $dest
        } catch {
            Write-Warn "Failed to download $file, creating empty template..."
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

# Set up Claude Code hooks (optional)
$ClaudeDir = ".claude"
$SettingsFile = Join-Path $ClaudeDir "settings.local.json"

if (Test-Path $SettingsFile) {
    Write-Warn "$SettingsFile already exists. Skipping hook setup."
    Write-Status "To add the stop hook manually, add this to your settings:"
    Write-Host @"
{
  "hooks": {
    "stop": [
      {
        "command": "echo '[cstack] Remember to update .cstack/CURRENT.md with your progress!'"
      }
    ]
  }
}
"@
} else {
    Write-Status "Setting up Claude Code hooks..."
    if (-not (Test-Path $ClaudeDir)) {
        New-Item -ItemType Directory -Path $ClaudeDir -Force | Out-Null
    }

    @"
{
  "hooks": {
    "stop": [
      {
        "command": "echo '[cstack] Remember to update .cstack/CURRENT.md with your progress!'"
      }
    ]
  }
}
"@ | Set-Content $SettingsFile
    Write-Success "Hook configured in $SettingsFile"
}

Write-Host ""
Write-Success "Cortical Stack initialized!"
Write-Host ""
Write-Host "Files created:" -ForegroundColor White
Write-Host "  $StackDir/CURRENT.md  - Active task, focus, next steps"
Write-Host "  $StackDir/PLAN.md     - Task backlog with states"
Write-Host "  $StackDir/INBOX.md    - Messages TO this agent"
Write-Host "  $StackDir/OUTBOX.md   - Messages FROM this agent"
Write-Host ""
Write-Host "Next steps:" -ForegroundColor White
Write-Host "  1. Add .cstack/ instructions to your CLAUDE.md"
Write-Host "  2. Start working - update CURRENT.md as you go"
Write-Host ""
Write-Host "Docs: https://github.com/hotschmoe/cortical-stack" -ForegroundColor Gray
