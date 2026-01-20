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

# Check for unread inbox messages
if (Test-Path ".cstack\INBOX.md") {
    $inboxContent = Get-Content ".cstack\INBOX.md" -Raw

    # Check for messages (indicated by --- delimiter) that are unread
    # Messages are unread if they have "Status: unread" or no Status field
    if ($inboxContent -match "(?s)---\s*\n((?:(?!Status:\s*read).)*?)---") {
        Write-Output "--- INBOX.md (UNREAD MESSAGES) ---"
        Write-Output ""

        # Show full inbox for context
        Write-Output $inboxContent
        Write-Output ""

        # Mark all messages as read by adding/updating Status field
        # This regex finds message headers and ensures they have Status: read
        $updatedContent = $inboxContent

        # Pattern: find headers without Status field and add it
        # Match: ---\n<headers without Status>\n---
        $updatedContent = [regex]::Replace(
            $updatedContent,
            '(?m)(---\s*\n)((?:(?!Status:)[^\n]+\n)*?)(---)',
            {
                param($m)
                $header = $m.Groups[1].Value
                $fields = $m.Groups[2].Value
                $closer = $m.Groups[3].Value
                "${header}${fields}Status: read`n${closer}"
            }
        )

        # Pattern: find Status: unread and change to Status: read
        $updatedContent = $updatedContent -replace 'Status:\s*unread', 'Status: read'

        # Write back
        $updatedContent | Set-Content ".cstack\INBOX.md" -NoNewline

        Write-Output "[Messages marked as read]"
        Write-Output ""
    }
}

Write-Output "=== Stack loaded. Ask the user what they'd like to work on. ==="
