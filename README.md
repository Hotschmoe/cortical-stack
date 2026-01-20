# Cortical Stack

Markdown-based memory persistence for AI agents.

Named after the consciousness storage device in Altered Carbon: when the container dies, the stack survives. Resleeve into a new container with memory intact.

## Philosophy

Agent state lives in plain markdown files. No database, no service dependencies, no proprietary formats.

## File Structure

```
repo/
  .cstack/
    CURRENT.md    # Active task, focus, next steps
    PLAN.md       # Task backlog with states
    INBOX.md      # Messages TO this agent
    OUTBOX.md     # Messages FROM this agent
```

## Why Markdown?

- **Human readable** - Open in any text editor
- **Human editable** - Inject tasks, fix state, debug
- **Git native** - Version controlled, diffable
- **Portable** - Copy a directory, copy the state
- **Survives anything** - No database to corrupt

## File Formats

**CURRENT.md**
```markdown
## Current Task
Implement user authentication

## Focus
Building JWT middleware

## Next Steps
- Write unit tests
- Add integration tests
```

**PLAN.md**
```markdown
## Tasks
- [ ] Pending task
- [>] In progress task
- [x] Completed task
- [!] Blocked task
```

**INBOX.md / OUTBOX.md**
```markdown
---
ID: msg-a7f3
From: agent-id
To: manager
Type: task|question|milestone|blocked|done
Time: 2026-01-19T10:30:00Z
---
Message content here.
```

## Go Package

```bash
go get github.com/hotschmoe/cortical-stack/pkg/cstack
```

```go
import "github.com/hotschmoe/cortical-stack/pkg/cstack"

// Read current state
state, err := cstack.ParseCurrent("/path/to/workspace")

// Read plan
plan, err := cstack.ParsePlan("/path/to/workspace")

// Write to inbox
msg := cstack.Message{
    From:    "manager",
    Type:    "task",
    Content: "Implement feature X",
}
err = cstack.WriteInbox("/path/to/workspace", msg)

// Read and clear outbox
messages, err := cstack.ReadOutbox("/path/to/workspace")
err = cstack.ClearOutbox("/path/to/workspace")
```

## Standalone Use

Works with any AI CLI tool, any orchestration system, or none at all. Just add `.cstack/` to your repo.

## Related

- [protectorate](../repo_protectorate) - Orchestration system that uses cortical-stack
