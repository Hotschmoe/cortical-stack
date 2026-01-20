#!/bin/bash
# Hook: Inject context at session start
# Output is shown to Claude to provide context

echo "=== CORTICAL STACK: SESSION START ==="
echo ""
echo "Reading agent state from .cstack/..."
echo ""

if [ -f ".cstack/CURRENT.md" ]; then
    echo "--- CURRENT.md (active state) ---"
    cat ".cstack/CURRENT.md"
    echo ""
fi

if [ -f ".cstack/PLAN.md" ]; then
    echo "--- PLAN.md (task backlog) ---"
    cat ".cstack/PLAN.md"
    echo ""
fi

# Check for unread inbox messages
if [ -f ".cstack/INBOX.md" ]; then
    INBOX_CONTENT=$(cat ".cstack/INBOX.md")

    # Check if there are any messages (--- delimiter) without "Status: read"
    # A message is unread if it has "Status: unread" or no Status field at all
    if echo "$INBOX_CONTENT" | grep -q "^---$"; then
        # Check if any message lacks "Status: read"
        HAS_UNREAD=false

        # Simple check: if there's a --- block without "Status: read" before the next ---
        if echo "$INBOX_CONTENT" | perl -0777 -ne 'exit(1) if /---\n(?:(?!Status:\s*read)(?!---).)*\n---/s'; then
            HAS_UNREAD=false
        else
            HAS_UNREAD=true
        fi

        if [ "$HAS_UNREAD" = true ]; then
            echo "--- INBOX.md (UNREAD MESSAGES) ---"
            echo ""
            echo "$INBOX_CONTENT"
            echo ""

            # Mark all messages as read
            # 1. Add "Status: read" to headers that don't have a Status field
            # 2. Change "Status: unread" to "Status: read"

            if command -v perl &> /dev/null; then
                # Use perl for reliable multiline processing
                UPDATED_CONTENT=$(echo "$INBOX_CONTENT" | perl -0777 -pe '
                    # Add Status: read to headers without Status field
                    s/(---\n)((?:(?!Status:)[^\n]*\n)*?)(---)/\1\2Status: read\n\3/g;
                    # Change unread to read
                    s/Status:\s*unread/Status: read/g;
                ')
                echo "$UPDATED_CONTENT" > ".cstack/INBOX.md"
                echo "[Messages marked as read]"
                echo ""
            else
                echo "[Warning: perl not available, messages not marked as read]"
                echo ""
            fi
        fi
    fi
fi

echo "=== Stack loaded. Ask the user what they'd like to work on. ==="
