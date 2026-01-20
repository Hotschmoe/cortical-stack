# Hook: Inject context at session start
# Output is shown to Claude to provide context

Write-Output "=== CONTEXT-BY-MD: SESSION START ==="
Write-Output ""
Write-Output "Please read the following context files to understand the current state:"
Write-Output ""

if (Test-Path ".context-by-md\CURRENT.md") {
    Write-Output "--- CURRENT.md ---"
    Get-Content ".context-by-md\CURRENT.md"
    Write-Output ""
}

if (Test-Path ".context-by-md\PLAN.md") {
    Write-Output "--- PLAN.md (task status) ---"
    Get-Content ".context-by-md\PLAN.md"
    Write-Output ""
}

Write-Output "=== Ready to continue. Ask the user what they'd like to work on. ==="
