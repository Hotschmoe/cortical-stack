#!/bin/bash
# Hook: Inject context at session start
# Output is shown to Claude to provide context

echo "=== CONTEXT-BY-MD: SESSION START ==="
echo ""
echo "Please read the following context files to understand the current state:"
echo ""

if [ -f ".context-by-md/CURRENT.md" ]; then
    echo "--- CURRENT.md ---"
    cat ".context-by-md/CURRENT.md"
    echo ""
fi

if [ -f ".context-by-md/PLAN.md" ]; then
    echo "--- PLAN.md (task status) ---"
    cat ".context-by-md/PLAN.md"
    echo ""
fi

echo "=== Ready to continue. Ask the user what they'd like to work on. ==="
