<!-- cstack:begin version="1.0.0" -->
# Cortical Stack Instructions

This project uses cortical stack for agent memory persistence.

## Stack Files

| File | Purpose |
|------|---------|
| `.cstack/CURRENT.md` | Active task, focus, next steps |
| `.cstack/PLAN.md` | Task backlog with status |
| `.cstack/INBOX.md` | Messages TO this agent |
| `.cstack/OUTBOX.md` | Messages FROM this agent |

## Task Status (PLAN.md)

| Syntax | Status |
|--------|--------|
| `- [ ]` | Pending |
| `- [>]` | In Progress |
| `- [x]` | Completed |
| `- [!]` | Blocked |

## Workflow

### On Session Start
1. Read `.cstack/CURRENT.md` for active state
2. Check `.cstack/INBOX.md` for new messages (unread messages shown automatically)
3. Review `.cstack/PLAN.md` for task context

### During Work
- Update `CURRENT.md` as you progress
- Mark tasks in `PLAN.md` as status changes
- Write questions/updates to `OUTBOX.md`

### On Session End
1. Update `CURRENT.md` with current progress
2. Update `PLAN.md` with task status
3. Write any outgoing messages to `OUTBOX.md`

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

The start hook automatically marks inbox messages as `read` after displaying them.

**When writing to OUTBOX**, always use `Status: unread` so the recipient knows it's new:

```markdown
---
To: manager
Type: milestone
Time: 2026-01-19T14:00:00Z
Status: unread
---
Completed authentication module.
```

## On Context Loss / Compaction

If you notice context was lost:
1. Read `.cstack/CURRENT.md` immediately
2. Check "Current Task" and "Next Steps" sections
3. Resume from where the state indicates
4. Read `.cstack/PLAN.md` for broader context
<!-- cstack:end -->
