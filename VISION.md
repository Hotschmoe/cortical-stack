# Cortical Stack - Vision

## What is a Cortical Stack?

In the Altered Carbon universe, a cortical stack is a device implanted at the base of the skull that stores a person's consciousness (DHF - Digital Human Freight). When the body dies, the stack survives. The consciousness can be "resleeved" into a new body, memories and personality intact.

This project applies that concept to AI agents: the stack is the persistent memory and state that survives container destruction and respawning.

## Core Philosophy

### Memory as Markdown

Agent state lives in plain markdown files in a `.cstack/` directory:

```
repo/
  .cstack/
    CURRENT.md    # Active task, focus, next steps
    PLAN.md       # Task backlog with states
    INBOX.md      # Messages TO this agent
    OUTBOX.md     # Messages FROM this agent
```

### Why Markdown?

1. **Human readable** - Open in any text editor to see agent state
2. **Human editable** - Inject tasks, fix state, debug issues
3. **Git native** - Version controlled, diffable, mergeable
4. **Portable** - Copy a directory, you have the full state
5. **Survives anything** - No database to corrupt, no service to fail

### Project Agnostic

This package is designed to work with ANY:
- AI CLI tool (Claude Code, Gemini CLI, OpenCode, etc.)
- Orchestration system (Protectorate, custom, none)
- Project type (any language, any framework)

You can use cortical-stack:
- With Protectorate (the companion orchestration system)
- Standalone (just add `.cstack/` to your repo)
- With your own orchestration layer

### No Lock-in

We explicitly avoid:
- Proprietary formats
- Complex dependencies
- Tight coupling to any orchestrator
- Features that only work with specific AI tools

## File Format Spec

### CURRENT.md

Tracks the agent's active state:

```markdown
## Current Task
Implement user authentication

## Focus
Building JWT middleware

## Next Steps
- Write unit tests
- Add integration tests
```

### PLAN.md

Task backlog with checkbox states:

```markdown
## Tasks
- [ ] Pending task
- [>] In progress task
- [x] Completed task
- [!] Blocked task

## Notes
Context and notes here
```

### INBOX.md / OUTBOX.md

Message format (YAML frontmatter style):

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

## Design Principles

1. **Simplicity over features** - The format should be obvious
2. **Text editor is the debugger** - No special tools needed
3. **Graceful degradation** - Missing files = empty state, not errors
4. **Forward compatible** - New fields ignored by old parsers
5. **Universal** - Works anywhere markdown works
