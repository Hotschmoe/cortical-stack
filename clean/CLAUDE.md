<!-- cstack:begin version="1.0.0" -->
# Cortical Stack Instructions

This project uses cortical stack for agent memory persistence.

## Commands

| Command | What it does |
|---------|--------------|
| `/cstack-task` | List tasks with numbers |
| `/cstack-task start 1` | Start task #1 (quick) |
| `/cstack-task start 1 --plan` | Start task #1 with interview |
| `/cstack-task add P1: X` | Add new task |
| `/cstack-task done` | Complete active task |
| `/cstack-checkpoint` | Save all state |
| `/cstack-start` | Read context and show status |

## Stack Files

| File | Purpose |
|------|---------|
| `.cstack/CURRENT.md` | Session state + active task detail |
| `.cstack/PLAN.md` | Task list + backlog |
| `.cstack/INBOX.md` | Messages TO this agent |
| `.cstack/OUTBOX.md` | Messages FROM this agent |
| `.cstack/QUICKREF.md` | Command quick reference |

## Task Format (PLAN.md)

```
- [status] P#: Title | context | next: action
```

| Syntax | Status |
|--------|--------|
| `- [ ]` | Pending |
| `- [>]` | In Progress |
| `- [x]` | Completed |
| `- [!]` | Blocked |

**Priority:** P0=Critical P1=High P2=Medium P3=Low

## Workflow

```
/cstack-task                  # See numbered task list
    |
/cstack-task start 1          # Start task (or --plan for interview)
    |
[work on task]                # Check off subtasks in CURRENT.md
    |
/cstack-task done             # Complete, clear active task
    |
/cstack-checkpoint            # Save state
```

## Message Format (INBOX/OUTBOX)

```markdown
---
From: sender-id
To: recipient-id
Type: task|question|milestone|blocked|done
Time: 2026-01-19T10:30:00Z
Status: unread
---
Message content here.
```

**Status field:**
- `unread` - New message, not yet seen
- `read` - Message has been displayed to agent

## On Context Loss / Compaction

If you notice context was lost:
1. Read `.cstack/CURRENT.md` immediately
2. Check "Active Task" for goal and subtasks
3. Resume from "Next Steps" or `<-- you are here` marker
4. Read `.cstack/PLAN.md` for broader context

**Signs:** You don't remember what you were working on, user references something unfamiliar, or unsure of task state.
<!-- cstack:end -->
