---
name: cstack-task
description: Manage tasks with labels, filtering, and close reasons
---

# /cstack-task - Task Management

List, filter, complete, and close tasks in `.cstack/PLAN.md`.

## Usage

```
/cstack-task [command] [args]
```

## Commands

| Command | Description |
|---------|-------------|
| (none) | List all tasks with numbers |
| `#label` | Filter tasks by label(s) |
| `start N` | Start task #N (mark in-progress) |
| `start N --plan` | Start with planning interview |
| `add P#: Title` | Add new task |
| `done [reason]` | Complete active task with optional reason |
| `close N "reason"` | Close task #N without completing |
| `block N [reason]` | Block task #N |
| `ready N` | Unblock task #N |

## Label Filtering

Filter tasks by one or more labels:

```
/cstack-task #bug           # All bugs
/cstack-task #auth #urgent  # Tasks with BOTH labels
/cstack-task #feature       # All features
```

## Completing Tasks

Complete the active task with an optional reason:

```
/cstack-task done                    # Mark done, no reason
/cstack-task done "Shipped in v1.2"  # Mark done with reason
```

Result in PLAN.md:
```markdown
## Completed
- [x] P1: JWT auth #auth | closed: 2026-01-15 | reason: Shipped in v1.2
```

## Closing Tasks (Won't Fix)

Close a task without completing it:

```
/cstack-task close 3 "Out of scope for MVP"
/cstack-task close 5 "Duplicate of #2"
```

Result in PLAN.md:
```markdown
## Closed
- [~] P3: Add GraphQL #api | closed: 2026-01-15 | reason: Out of scope for MVP
```

## Task States

| Marker | Status | Description |
|--------|--------|-------------|
| `[ ]` | pending | Not started |
| `[>]` | in_progress | Currently active |
| `[x]` | completed | Done successfully |
| `[!]` | blocked | Waiting on dependency |
| `[~]` | closed | Won't fix / abandoned |

## Task Format (V1.5)

```markdown
- [status] P#: Title #label1 #label2 | modified: YYYY-MM-DD
- [status] P#: Title #label | blocked: reason | modified: YYYY-MM-DD
- [x] P#: Title #label | closed: YYYY-MM-DD | reason: Why
- [~] P#: Title #label | closed: YYYY-MM-DD | reason: Why
```

## Reserved Labels

| Label | Meaning |
|-------|---------|
| `#bug` | Bug fix |
| `#debt` | Technical debt |
| `#feature` | New feature |
| `#urgent` | Needs immediate attention |

Custom labels: Any `#word` is valid.

## Examples

```
/cstack-task                         # List all tasks
/cstack-task #bug                    # Filter to bugs
/cstack-task start 1                 # Start task #1
/cstack-task done "Fixed and tested" # Complete with reason
/cstack-task close 4 "Duplicate"     # Close task #4
/cstack-task add P2: New feature #feature
```
