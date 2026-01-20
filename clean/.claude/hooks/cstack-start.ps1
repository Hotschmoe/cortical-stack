# Hook: Inject context at session start
# Output is shown to Claude to provide context

Write-Output "=== CORTICAL STACK: SESSION START ==="
Write-Output ""
Write-Output "Reading agent state from .cstack/..."
Write-Output ""

if (Test-Path ".cstack\CURRENT.md") {
    Write-Output "--- CURRENT.md (active state) ---"
    Get-Content ".cstack\CURRENT.md"
    Write-Output ""
}

if (Test-Path ".cstack\PLAN.md") {
    Write-Output "--- PLAN.md (task backlog) ---"
    Get-Content ".cstack\PLAN.md"
    Write-Output ""
}

if (Test-Path ".cstack\INBOX.md") {
    $inbox = Get-Content ".cstack\INBOX.md" -Raw
    if ($inbox -match "---") {
        Write-Output "--- INBOX.md (has messages) ---"
        Write-Output "You have unread messages. Check .cstack/INBOX.md"
        Write-Output ""
    }
}

Write-Output "=== Stack loaded. Ask the user what they'd like to work on. ==="
