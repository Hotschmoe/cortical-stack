<!-- cstack:begin version="1.5.0" -->
# Cortical Stack Instructions

This project uses cortical stack for agent memory persistence.

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
| `/cstack-search QUERY` | Search across stack files |
| `/cstack-stale [days]` | Find stale tasks (default: 7 days) |
| `/cstack-checkpoint` | Save all state |
| `/cstack-start` | Read context and show status |
| `/cstack-remember "fact"` | Add entry to MEMORY.md |

## Stack Files

| File | Purpose |
|------|---------|
| `.cstack/CURRENT.md` | Session state + active task detail |
| `.cstack/PLAN.md` | Task list + backlog |
| `.cstack/MEMORY.md` | Long-term knowledge (decisions, gotchas, facts) |
| `.cstack/QUICKREF.md` | Command quick reference |

## Task Format (V1.5)

```
- [status] P#: Title #label1 #label2 | modified: YYYY-MM-DD
```

| Syntax | Status |
|--------|--------|
| `- [ ]` | Pending |
| `- [>]` | In Progress |
| `- [x]` | Completed |
| `- [!]` | Blocked |
| `- [~]` | Closed (won't fix) |

**Priority:** P0=Critical P1=High P2=Medium P3=Low

## Labels

| Label | Meaning |
|-------|---------|
| `#bug` | Bug fix |
| `#debt` | Technical debt |
| `#feature` | New feature |
| `#urgent` | Needs immediate attention |

Custom: Any `#word` is valid.

## Workflow

```
/cstack-task                  # See numbered task list
    |
/cstack-task start 1          # Start task (or --plan for interview)
    |
[work on task]                # Check off subtasks in CURRENT.md
    |
/cstack-task done "reason"    # Complete with reason
    |
/cstack-checkpoint            # Save state
```

## Search and Review

```
/cstack-search JWT            # Find mentions
/cstack-search #auth          # Find by label
/cstack-stale                 # Find stale tasks (7 days)
/cstack-stale 14              # Tasks older than 14 days
```

## On Context Loss / Compaction

If you notice context was lost:
1. Read `.cstack/CURRENT.md` immediately
2. Check "Active Task" for goal and subtasks
3. Resume from "Next Steps" or `<-- you are here` marker
4. Read `.cstack/PLAN.md` for broader context

**Signs:** You don't remember what you were working on, user references something unfamiliar, or unsure of task state.

## Memory

When you learn something important about this project, write it to `.cstack/MEMORY.md`:

- **Decisions**: Architectural choices with rationale (add to table)
- **Gotchas**: Non-obvious behaviors, bugs, edge cases that bit you
- **Preferences**: User preferences not documented elsewhere
- **Facts**: Project knowledge that took effort to discover

Use `/cstack-remember "fact"` or edit MEMORY.md directly. Good candidates:
- "ParseCurrent returns empty state for missing files, not an error"
- "User prefers table-driven tests"
- "Windows paths need filepath.Join"
<!-- cstack:end -->
