# Cortical Stack - V1 Specification

## Overview

V1 is pure markdown files in `.cstack/` - simple, portable, human-readable, no external dependencies.

## File Structure

```
repo/
  .cstack/
    CURRENT.md    # Active task, focus, next steps
    PLAN.md       # Task backlog with states
    INBOX.md      # Messages TO this agent
    OUTBOX.md     # Messages FROM this agent
    CONTEXT.md    # Long-term context/memory (optional)
```

## File Formats

### CURRENT.md

```markdown
# Current State

## Current Task
<description of active task>

## Focus
<what the agent is currently focused on>

## Next Steps
- Step 1
- Step 2
- Step 3
```

### PLAN.md

Task states use checkbox notation:

| Syntax | Status |
|--------|--------|
| `- [ ]` | Pending |
| `- [>]` | In Progress |
| `- [x]` | Completed |
| `- [!]` | Blocked |

```markdown
# Plan

## Tasks
- [ ] Pending task
- [>] In progress task
- [x] Completed task
- [!] Blocked task

## Notes
Additional context and notes
```

### INBOX.md / OUTBOX.md

Messages use YAML frontmatter:

```markdown
---
ID: msg-a7f3
From: agent-id
To: agent-id (or "manager")
Thread: optional-thread-id
Type: task|question|milestone|blocked|done
Time: 2026-01-19T10:30:00Z
---
Message content here.
```

**Message Types:**
- `task` - New task assignment
- `question` - Question needing answer
- `milestone` - Progress update
- `blocked` - Agent is blocked
- `done` - Work completed

## Go Package

### Installation

```bash
go get github.com/hotschmoe/cortical-stack/pkg/cstack
```

### Usage

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

// Read outbox
messages, err := cstack.ReadOutbox("/path/to/workspace")

// Clear outbox after processing
err = cstack.ClearOutbox("/path/to/workspace")

// Initialize stack in new directory
err = cstack.InitStack("/path/to/workspace")
```

## V1 Scope

### Included

- [x] Markdown file parsers (CURRENT.md, PLAN.md)
- [x] Message read/write (INBOX.md, OUTBOX.md)
- [x] Template files for initialization
- [x] Go package with full test coverage
- [x] Graceful handling of missing files
- [x] No external dependencies

### Excluded (V2+)

- [ ] Hash-based message IDs (deduplication)
- [ ] Thread tracking
- [ ] Parent/child task notation
- [ ] Semantic compaction
- [ ] Dependency-aware task graph
- [ ] Beads integration

## Versioning

This project uses SemVer. V1.x releases will maintain backward compatibility with the file format.
