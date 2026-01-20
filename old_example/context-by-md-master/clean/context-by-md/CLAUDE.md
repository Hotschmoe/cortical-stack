# Claude Instructions

## Context System

This project uses markdown context in `.context-by-md/`.

### Commands
| Command | What it does |
|---------|--------------|
| `/context-task` | List tasks (default) |
| `/context-task start 1` | Start task #1 |
| `/context-task start 1 --plan` | Start with interview |
| `/context-task add P1: X` | Add task |
| `/context-task done` | Complete active task |
| `/context-checkpoint` | Save state |

### Files
| File | Purpose |
|------|---------|
| `CURRENT.md` | Session state + active task |
| `PLAN.md` | Task list + backlog |

### Workflow
```
/context-task          # List tasks
/context-task start 1  # Start task #1
[work]                 # Update subtasks in CURRENT.md
/context-task done     # Complete task
/context-checkpoint    # Save state
```

### On Compaction / Context Loss

If you notice you've lost context (compaction happened, or session restarted):

1. Read `.context-by-md/CURRENT.md` immediately
2. Check the "Active Task" section for current goal and subtasks
3. Resume from the "Next Steps" or current subtask marker (`<-- you are here`)
4. Read `.context-by-md/PLAN.md` if you need broader project context

**Signs you need recovery:** You don't remember what you were working on, the user references something unfamiliar, or you're unsure of the current task state.
