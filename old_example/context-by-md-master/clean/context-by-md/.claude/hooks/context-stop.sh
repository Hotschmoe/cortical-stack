#!/bin/bash
# Hook: Remind to checkpoint before session ends
# Output is shown to Claude as a reminder

echo "=== CONTEXT-BY-MD: SESSION ENDING ==="
echo ""
echo "IMPORTANT: Before this session ends, please save state by running /context-checkpoint"
echo ""
echo "This will:"
echo "1. Update CURRENT.md with the current state"
echo "2. Update PLAN.md with task progress"
echo ""
echo "Do this now to preserve context for the next session."
