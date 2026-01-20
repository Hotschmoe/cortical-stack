# Quick Reference

## Commands

| Command | What it does |
|---------|--------------|
| `/cstack-task` | List tasks with numbers |
| `/cstack-task #label` | Filter tasks by label |
| `/cstack-task start 1` | Start task #1 (quick) |
| `/cstack-task start 1 --plan` | Start task #1 with interview |
| `/cstack-task add P1: X #label` | Add new task with labels |
| `/cstack-task done` | Complete active task |
| `/cstack-task done "reason"` | Complete with close reason |
| `/cstack-task close N "reason"` | Close task without completing |
| `/cstack-task block 1` | Block task #1 |
| `/cstack-task ready 1` | Unblock task #1 |
| `/cstack-search QUERY` | Search across stack files |
| `/cstack-stale [days]` | Find tasks with no recent activity |
| `/cstack-checkpoint` | Save all state |

## Task Format (V1.5)

```
- [status] P#: Title #label1 #label2 | modified: YYYY-MM-DD
```

**Status:** `- [ ]` Pending | `- [>]` In Progress | `- [x]` Completed | `- [!]` Blocked | `- [~]` Closed
**Priority:** P0=Critical P1=High P2=Medium P3=Low

## Labels

| Label | Meaning |
|-------|---------|
| `#bug` | Bug fix |
| `#debt` | Technical debt |
| `#feature` | New feature |
| `#urgent` | Needs immediate attention |

Custom: Any `#word` is valid.

## Files

| File | Purpose |
|------|---------|
| `CURRENT.md` | Session state + active task detail |
| `PLAN.md` | Task list + backlog |

## Workflow

```
/cstack-task                     # See numbered task list
    |
/cstack-task start 1             # Start task (or --plan for interview)
    |
[work on task]                   # Check off subtasks in CURRENT.md
    |
/cstack-task done "reason"       # Complete with reason
    |
/cstack-checkpoint               # Save state
```

## Search and Review

```
/cstack-search JWT               # Find mentions
/cstack-search #auth             # Find by label
/cstack-stale                    # Find stale tasks (7 days)
/cstack-stale 14                 # Find tasks older than 14 days
```

## Close Reasons

```
/cstack-task done "Shipped in v1.2"      # Completed with reason
/cstack-task close 3 "Out of scope"      # Won't fix (uses [~] marker)
/cstack-task close 5 "Duplicate of #2"   # Close as duplicate
```

## On Compaction

1. Run `/cstack-checkpoint`
2. Read CURRENT.md
3. Continue from Next Steps / current subtask
