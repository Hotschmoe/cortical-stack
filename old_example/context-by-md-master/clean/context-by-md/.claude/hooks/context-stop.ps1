# Hook: Remind to checkpoint before session ends
# Output is shown to Claude as a reminder

Write-Output "=== CONTEXT-BY-MD: SESSION ENDING ==="
Write-Output ""
Write-Output "IMPORTANT: Before this session ends, please save state by running /context-checkpoint"
Write-Output ""
Write-Output "This will:"
Write-Output "1. Update CURRENT.md with the current state"
Write-Output "2. Update PLAN.md with task progress"
Write-Output ""
Write-Output "Do this now to preserve context for the next session."
