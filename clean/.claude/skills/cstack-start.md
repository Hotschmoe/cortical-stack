---
name: cstack-start
description: Read context and show current status
---

# /cstack-start - Initialize Session

Read cortical stack state and display current context. Run this at the start of every session.

## Usage

```
/cstack-start
```

## What It Does

1. **Read all stack files**
   - `.cstack/CURRENT.md` - Active work
   - `.cstack/PLAN.md` - Task backlog
   - `.cstack/MEMORY.md` - Long-term knowledge
   - `.cstack/QUICKREF.md` - Command reference

2. **Display status summary**
   - Active task (if any)
   - Current focus from "Now" section
   - Next steps
   - Recent memories (last 3)

3. **Check for issues**
   - Orphaned in-progress tasks
   - Stale active task (no activity > 3 days)
   - Inconsistencies between files

## Output Format

```
# Session Status

## Active Task
P1: Implement JWT authentication #auth #backend
Status: in_progress | Started: 2026-01-20

## Now
- Writing token validation middleware
- Need to add refresh token logic

## Next Steps
1. Complete validateToken function
2. Add refresh endpoint
3. Write tests

## Recent Memories
- Gotcha: Token expiry is in seconds, not milliseconds
- Preference: Use table-driven tests

## Backlog Summary
- 3 pending tasks
- 1 blocked task
- 12 completed tasks

Ready to continue. Pick up from Next Steps or run /cstack-task to see full backlog.
```

## No Active Work

If no task is in progress:

```
# Session Status

## Active Task
None

## Backlog Summary
- 5 pending tasks (2 high priority)
- 1 blocked task

Top pending:
1. [P1] Fix login redirect #bug #urgent
2. [P1] Add rate limiting #security
3. [P2] Update docs #docs

Run /cstack-task start N to begin work.
```

## When to Use

- Start of every new session
- After context compaction
- When unsure of current state
- Returning after a break

## After Compaction

If context was compacted, this command restores working memory:

```
Context restored from .cstack/

Active task: P1: JWT authentication
Resume from: "Complete validateToken function"

Relevant memories loaded:
- Token expiry is in seconds, not milliseconds
```
