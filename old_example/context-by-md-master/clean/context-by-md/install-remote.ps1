# Remote install - downloads and installs context-by-md from GitHub
# Usage: irm https://raw.githubusercontent.com/hotschmoe/context-by-md/master/clean/context-by-md/install-remote.ps1 | iex

$ErrorActionPreference = "Stop"

$Repo = "hotschmoe/context-by-md"
$Branch = "master"
$BaseUrl = "https://raw.githubusercontent.com/$Repo/$Branch/clean/context-by-md"

# Get new version
$NewVersion = (Invoke-RestMethod "$BaseUrl/.context-by-md/_VERSION").Trim()

Write-Host "context-by-md installer v$NewVersion" -ForegroundColor Cyan
Write-Host ""

# Check for existing installation
$ExistingVersion = $null
$IsUpgrade = $false

if (Test-Path ".context-by-md\_VERSION") {
    $ExistingVersion = (Get-Content ".context-by-md\_VERSION" -Raw).Trim()
}
elseif (Test-Path ".context-by-md\CURRENT.md") {
    # Legacy install (no version file)
    $ExistingVersion = "1.x (legacy)"
}

if ($ExistingVersion) {
    if ($ExistingVersion -eq $NewVersion) {
        Write-Host "Already installed: v$NewVersion" -ForegroundColor Green
        Write-Host ""
        Write-Host "To reinstall, delete .context-by-md/ and run again."
        exit 0
    }

    Write-Host "Existing installation detected: v$ExistingVersion" -ForegroundColor Yellow
    Write-Host "New version available: v$NewVersion" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Upgrade will:" -ForegroundColor White
    Write-Host "  1. Backup your CURRENT.md and PLAN.md"
    Write-Host "  2. Install fresh templates and updated commands"
    Write-Host "  3. Provide migration guidance"
    Write-Host ""
    $response = Read-Host "Upgrade now? [y/N]"
    if ($response -notmatch "^[Yy]$") {
        Write-Host "Upgrade cancelled." -ForegroundColor Cyan
        exit 0
    }
    $IsUpgrade = $true
}

# Create backup if upgrading
if ($IsUpgrade) {
    $BackupDate = Get-Date -Format "yyyy-MM-dd_HHmm"
    $BackupDir = ".context-by-md\backup\$BackupDate"

    Write-Host ""
    Write-Host "Creating backup..." -ForegroundColor Cyan
    New-Item -ItemType Directory -Force -Path $BackupDir | Out-Null

    # Backup user data files
    if (Test-Path ".context-by-md\CURRENT.md") {
        Copy-Item ".context-by-md\CURRENT.md" "$BackupDir\"
    }
    if (Test-Path ".context-by-md\PLAN.md") {
        Copy-Item ".context-by-md\PLAN.md" "$BackupDir\"
    }
    # Backup legacy files if they exist
    if (Test-Path ".context-by-md\ACTIONPLAN.md") {
        Copy-Item ".context-by-md\ACTIONPLAN.md" "$BackupDir\"
    }
    if (Test-Path ".context-by-md\BACKLOG.md") {
        Copy-Item ".context-by-md\BACKLOG.md" "$BackupDir\"
    }

    Write-Host "  Backed up to: $BackupDir" -ForegroundColor Green
}

Write-Host ""
Write-Host "Downloading and installing..." -ForegroundColor Cyan

# Create directories
New-Item -ItemType Directory -Force -Path ".context-by-md" | Out-Null
New-Item -ItemType Directory -Force -Path ".claude\commands" | Out-Null
New-Item -ItemType Directory -Force -Path ".claude\hooks" | Out-Null

# Download context files
Invoke-RestMethod "$BaseUrl/.context-by-md/CURRENT.md" -OutFile ".context-by-md\CURRENT.md"
Invoke-RestMethod "$BaseUrl/.context-by-md/PLAN.md" -OutFile ".context-by-md\PLAN.md"
Invoke-RestMethod "$BaseUrl/.context-by-md/QUICKREF.md" -OutFile ".context-by-md\QUICKREF.md"
Invoke-RestMethod "$BaseUrl/.context-by-md/_VERSION" -OutFile ".context-by-md\_VERSION"

# Remove legacy files if they exist
if (Test-Path ".context-by-md\ACTIONPLAN.md") { Remove-Item ".context-by-md\ACTIONPLAN.md" }
if (Test-Path ".context-by-md\BACKLOG.md") { Remove-Item ".context-by-md\BACKLOG.md" }
if (Test-Path ".context-by-md\sessions") { Remove-Item -Recurse ".context-by-md\sessions" }

# Download Claude commands
Invoke-RestMethod "$BaseUrl/.claude/commands/context-start.md" -OutFile ".claude\commands\context-start.md"
Invoke-RestMethod "$BaseUrl/.claude/commands/context-checkpoint.md" -OutFile ".claude\commands\context-checkpoint.md"
Invoke-RestMethod "$BaseUrl/.claude/commands/context-task.md" -OutFile ".claude\commands\context-task.md"

# Download hooks
Invoke-RestMethod "$BaseUrl/.claude/hooks/context-start.ps1" -OutFile ".claude\hooks\context-start.ps1"
Invoke-RestMethod "$BaseUrl/.claude/hooks/context-stop.ps1" -OutFile ".claude\hooks\context-stop.ps1"

# Download or merge settings
if (Test-Path ".claude\settings.local.json") {
    Write-Host "  .claude\settings.local.json exists - please verify hooks config" -ForegroundColor Yellow
} else {
    Invoke-RestMethod "$BaseUrl/.claude/settings.local.json" -OutFile ".claude\settings.local.json"
}

# Handle CLAUDE.md
if (-not $IsUpgrade) {
    if (Test-Path "CLAUDE.md") {
        Add-Content -Path "CLAUDE.md" -Value ""
        Add-Content -Path "CLAUDE.md" -Value "---"
        Add-Content -Path "CLAUDE.md" -Value ""
        $claudeMd = Invoke-RestMethod "$BaseUrl/CLAUDE.md"
        Add-Content -Path "CLAUDE.md" -Value $claudeMd
        Write-Host "  Appended to existing CLAUDE.md" -ForegroundColor Green
    } else {
        Invoke-RestMethod "$BaseUrl/CLAUDE.md" -OutFile "CLAUDE.md"
        Write-Host "  Created CLAUDE.md" -ForegroundColor Green
    }
}

# Success message
Write-Host ""
Write-Host "Installed context-by-md v$NewVersion" -ForegroundColor Green

if ($IsUpgrade) {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  MIGRATION GUIDE" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Your data was backed up to:" -ForegroundColor White
    Write-Host "  $BackupDir" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "To migrate your tasks:" -ForegroundColor White
    Write-Host "  1. Open your backup files in the folder above"
    Write-Host "  2. Copy tasks to the new PLAN.md format"
    Write-Host "  3. Copy any active work to CURRENT.md"
    Write-Host ""
    Write-Host "Or let Claude help:" -ForegroundColor White
    Write-Host "  Just ask Claude to review your backup files and migrate"
    Write-Host "  your tasks to the new format. For example:" -ForegroundColor Gray
    Write-Host "  'Review .context-by-md/backup/ and migrate my tasks to the new format'" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Once verified, you can delete the backup folder."
    Write-Host ""
} else {
    Write-Host ""
    Write-Host "Files created:"
    Write-Host "  .context-by-md\CURRENT.md  - Session state + active task"
    Write-Host "  .context-by-md\PLAN.md     - Task list + backlog"
    Write-Host "  .context-by-md\QUICKREF.md - Command cheat sheet"
    Write-Host "  .claude\commands\          - Slash commands"
    Write-Host "  .claude\hooks\             - Auto-checkpoint reminder"
    Write-Host ""
    Write-Host "Get started:"
    Write-Host "  /context-task add P1: Your first task | description"
    Write-Host "  /context-task start 1"
}
