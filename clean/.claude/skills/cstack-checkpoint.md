---
name: cstack-checkpoint
description: Save current state to all stack files
---

# /cstack-checkpoint - Save State

Persist current session state to all `.cstack/` files.

## Usage

```
/cstack-checkpoint
/cstack-checkpoint --message "optional context"
```

## What It Does

1. **Update CURRENT.md**
   - Set "Last Updated" timestamp
   - Ensure "Now" section reflects current work
   - Update "Next Steps" with immediate actions
   - Save any scratch notes

2. **Update PLAN.md**
   - Update `modified:` dates on changed tasks
   - Move completed tasks to Completed section
   - Move closed tasks to Closed section
   - Ensure task states match reality

3. **Update MEMORY.md** (if applicable)
   - Prompt: "Any learnings to record?"
   - Add any gotchas discovered this session
   - Record decisions made

4. **Verify consistency**
   - Active task in CURRENT.md matches in-progress task in PLAN.md
   - No orphaned references

## Output Format

```
Checkpoint saved at 2026-01-21 14:30

CURRENT.md:
  - Updated: Now, Next Steps
  - Active task: P1: JWT auth

PLAN.md:
  - 1 task marked in-progress
  - 2 tasks updated

MEMORY.md:
  - No new entries

Ready to resume from Next Steps after compaction.
```

## When to Use

- Before ending a session
- Before context compaction
- After completing significant work
- When switching to a different task
- Before `git commit`

## Checkpoint Checklist

The checkpoint verifies:

```
[x] CURRENT.md has valid "Now" content
[x] CURRENT.md "Next Steps" are actionable
[x] Active task matches PLAN.md in-progress task
[x] No stale "in_progress" tasks in PLAN.md
[x] Modified dates are current
```

## Recovery

If checkpoint finds inconsistencies:

```
Warning: CURRENT.md shows "JWT auth" but PLAN.md has no in-progress task.

Fix options:
1. Mark "JWT auth" as in-progress in PLAN.md
2. Clear active task in CURRENT.md
3. Skip (leave inconsistent)

Which? [1/2/3]
```
