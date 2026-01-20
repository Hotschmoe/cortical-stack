# Cortical Stack Installer (PowerShell)
# Usage: irm https://raw.githubusercontent.com/hotschmoe/cortical-stack/master/install.ps1 | iex

$ErrorActionPreference = "Stop"

$StackDir = ".cstack"
$ClaudeDir = ".claude"
$RepoBase = "https://raw.githubusercontent.com/hotschmoe/cortical-stack/master/clean"

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

# Get remote version
$NewVersion = "1.0.0"
try {
    $NewVersion = (Invoke-RestMethod -Uri "$RepoBase/_VERSION").Trim()
} catch {
    Write-Warn "Could not fetch version, using default: $NewVersion"
}

Write-Host ""
Write-Host "Cortical Stack Installer v$NewVersion" -ForegroundColor Cyan
Write-Host ""

# Check for existing installation version
$ExistingVersion = $null
if (Test-Path "$StackDir\_VERSION") {
    $ExistingVersion = (Get-Content "$StackDir\_VERSION" -Raw).Trim()
}

if ($ExistingVersion) {
    if ($ExistingVersion -eq $NewVersion) {
        Write-Success "Already at version $NewVersion"
        Write-Host ""
        Write-Host "To reinstall, delete .cstack/ and run again."
        exit 0
    }
    Write-Status "Upgrading from v$ExistingVersion to v$NewVersion"
}

# Create directories
if (-not (Test-Path $StackDir)) {
    Write-Status "Creating $StackDir directory..."
    New-Item -ItemType Directory -Path $StackDir -Force | Out-Null
}

New-Item -ItemType Directory -Path "$ClaudeDir\hooks" -Force | Out-Null
New-Item -ItemType Directory -Path "$ClaudeDir\commands" -Force | Out-Null

# Download or create stack files (only if they don't exist)
$stackFiles = @("CURRENT.md", "PLAN.md", "INBOX.md", "OUTBOX.md", "QUICKREF.md")

foreach ($file in $stackFiles) {
    $dest = Join-Path $StackDir $file
    if (-not (Test-Path $dest)) {
        Write-Status "Creating $StackDir/$file..."
        $url = "$RepoBase/.cstack/$file"
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
}

# Save version file
$NewVersion | Set-Content "$StackDir\_VERSION"
Write-Success "Stack files ready."

# Download hooks (always update on install/upgrade)
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

# Download commands (always update on install/upgrade)
Write-Status "Installing commands..."

$commands = @(
    @{ name = "cstack-task.md"; url = "$RepoBase/.claude/commands/cstack-task.md" },
    @{ name = "cstack-checkpoint.md"; url = "$RepoBase/.claude/commands/cstack-checkpoint.md" },
    @{ name = "cstack-start.md"; url = "$RepoBase/.claude/commands/cstack-start.md" }
)

foreach ($cmd in $commands) {
    $dest = Join-Path "$ClaudeDir\commands" $cmd.name
    try {
        Invoke-RestMethod -Uri $cmd.url -OutFile $dest
    } catch {
        Write-Warn "Failed to download $($cmd.name)"
    }
}

Write-Success "Commands installed."

# Handle settings.local.json
$settingsFile = "$ClaudeDir\settings.local.json"

if (Test-Path $settingsFile) {
    Write-Warn "$settingsFile already exists."
    Write-Status "Please verify hooks are configured. Expected config:"
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

# Handle CLAUDE.md with version-tagged block
Write-Status "Checking CLAUDE.md..."

$claudeInstructions = $null
try {
    $claudeInstructions = Invoke-RestMethod -Uri "$RepoBase/CLAUDE.md"
} catch {
    Write-Warn "Failed to download CLAUDE.md template"
}

if ($claudeInstructions) {
    $claudeMdPath = "CLAUDE.md"
    $beginTag = "<!-- cstack:begin"
    $endTag = "<!-- cstack:end -->"

    if (Test-Path $claudeMdPath) {
        $existingContent = Get-Content $claudeMdPath -Raw

        if ($existingContent -match "<!-- cstack:begin version=""([^""]+)""") {
            $existingCstackVersion = $matches[1]

            if ($existingCstackVersion -eq $NewVersion) {
                Write-Success "CLAUDE.md cstack block already at v$NewVersion"
            } else {
                Write-Status "Updating CLAUDE.md cstack block from v$existingCstackVersion to v$NewVersion..."
                # Remove old block and add new one
                $newContent = $existingContent -replace "(?s)<!-- cstack:begin.*?<!-- cstack:end -->", ""
                $newContent = $newContent.TrimEnd() + "`n`n" + $claudeInstructions
                $newContent | Set-Content $claudeMdPath -NoNewline
                Write-Success "CLAUDE.md updated."
            }
        } else {
            Write-Status "Appending cstack instructions to CLAUDE.md..."
            $newContent = $existingContent.TrimEnd() + "`n`n" + $claudeInstructions
            $newContent | Set-Content $claudeMdPath -NoNewline
            Write-Success "CLAUDE.md updated."
        }
    } else {
        Write-Status "Creating CLAUDE.md..."
        $claudeInstructions | Set-Content $claudeMdPath -NoNewline
        Write-Success "CLAUDE.md created."
    }
}

# Success
Write-Host ""
Write-Success "Cortical Stack v$NewVersion installed!"
Write-Host ""
Write-Host "Files:" -ForegroundColor White
Write-Host "  $StackDir/CURRENT.md   - Active task, focus, next steps"
Write-Host "  $StackDir/PLAN.md      - Task backlog with states"
Write-Host "  $StackDir/INBOX.md     - Messages TO this agent"
Write-Host "  $StackDir/OUTBOX.md    - Messages FROM this agent"
Write-Host "  $StackDir/QUICKREF.md  - Command quick reference"
Write-Host "  $ClaudeDir/commands/   - Slash commands"
Write-Host "  $ClaudeDir/hooks/      - Start/stop hooks"
Write-Host ""
Write-Host "Next steps:" -ForegroundColor White
Write-Host "  1. Start a new Claude Code session"
Write-Host "  2. The start hook will load your stack automatically"
Write-Host "  3. Update .cstack/ files as you work"
Write-Host ""
Write-Host "Docs: https://github.com/hotschmoe/cortical-stack" -ForegroundColor Gray
