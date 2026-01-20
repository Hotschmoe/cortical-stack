# Quick Reference

## Commands

| Command | What it does |
|---------|--------------|
| `/context-task` | List tasks with numbers |
| `/context-task start 1` | Start task #1 (quick) |
| `/context-task start 1 --plan` | Start task #1 with interview |
| `/context-task add P1: X` | Add new task |
| `/context-task done` | Complete active task |
| `/context-task block 1` | Block task #1 |
| `/context-task ready 1` | Unblock task #1 |
| `/context-task decide` | Record decision |
| `/context-checkpoint` | Save all state |

## Task Format

```
- [STATUS] P#: Title | context | next: action
```

**Status:** `[READY]` `[WIP]` `[BLOCKED]` `[PAUSED]`
**Priority:** P0=Critical P1=High P2=Medium P3=Low

## Files

| File | Purpose |
|------|---------|
| `CURRENT.md` | Session state + active task detail |
| `PLAN.md` | Task list + backlog |

## Workflow

```
/context-task                     # See numbered task list
    ↓
/context-task start 1             # Start task (or --plan for interview)
    ↓
[work on task]                    # Check off subtasks in CURRENT.md
    ↓
/context-task done                # Complete, clear active task
    ↓
/context-checkpoint               # Save state
```

## On Compaction

1. Run `/context-checkpoint`
2. Read CURRENT.md
3. Continue from Next Steps / current subtask
