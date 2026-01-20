# Cortical Stack - V2 Specification

CLI tooling for multi-agent coordination.

## Philosophy

V2 adds the `cstack` CLI for scenarios where pure markdown isn't enough:
- Multi-agent message routing
- Hash-based message IDs for deduplication
- Atomic file operations
- Orchestration tooling

The CLI is written in Go and distributed as pre-built binaries.

## Installation

### Pre-built Binaries

```bash
# macOS/Linux
curl -fsSL https://github.com/hotschmoe/cortical-stack/releases/latest/download/cstack-$(uname -s)-$(uname -m) -o /usr/local/bin/cstack
chmod +x /usr/local/bin/cstack

# Windows (PowerShell)
irm https://github.com/hotschmoe/cortical-stack/releases/latest/download/cstack-windows-amd64.exe -OutFile cstack.exe
```

### From Source

```bash
go install github.com/hotschmoe/cortical-stack/cmd/cstack@latest
```

## CLI Commands

### Initialize Stack

```bash
cstack init [path]
```

Creates `.cstack/` directory with template files.

### Send Message

```bash
cstack send --to agent-backend --type task "Implement the login endpoint"
```

Atomically appends to target agent's INBOX.md with:
- Generated hash-based ID
- Timestamp
- Proper formatting

### Receive Messages

```bash
cstack recv [--clear]
```

Reads INBOX.md, optionally clears after reading.

### Check Status

```bash
cstack status
```

Shows:
- Current task from CURRENT.md
- In-progress tasks from PLAN.md
- Unread inbox message count

### Watch for Messages

```bash
cstack watch --inbox
```

Polls INBOX.md for new messages. Useful for orchestrators.

## Hash-Based Message IDs

V2 generates collision-resistant IDs from content hash:

```
ID = base62(sha256(From + Type + Content + truncated_timestamp)[:6])
```

Example: `msg-a7f3bc`

Benefits:
- Deduplication (same message = same ID)
- No central ID coordinator needed
- Merge-friendly in git

## File Format Extensions

### INBOX.md / OUTBOX.md

V2 adds `ID` field (V1 format still supported):

```markdown
---
ID: msg-a7f3bc
From: manager
To: agent-backend
Type: task
Time: 2026-01-19T10:30:00Z
---
Implement the login endpoint.
```

### Thread Support

Optional thread grouping:

```markdown
---
ID: msg-b8c4de
From: agent-frontend
Thread: auth-implementation
ReplyTo: msg-a7f3bc
Type: question
Time: 2026-01-19T11:00:00Z
---
Should login return user profile data?
```

## Go Library

The V1 Go code becomes the foundation for the CLI:

```go
import "github.com/hotschmoe/cortical-stack/pkg/cstack"

// V2 additions
msg := cstack.Message{
    From:    "manager",
    To:      "agent-backend",
    Type:    "task",
    Content: "Implement login",
}

// Generates hash-based ID automatically
id, err := cstack.SendMessage("/path/to/agent", msg)

// Atomic write with file locking
err = cstack.WriteInboxAtomic("/path/to/agent", msg)
```

## Multi-Agent Orchestration

```
                    Orchestrator
                         |
          +--------------+--------------+
          |              |              |
     agent-api     agent-frontend   agent-db
          |              |              |
      .cstack/       .cstack/       .cstack/
```

Orchestrator workflow:
1. Read each agent's OUTBOX.md
2. Route messages to appropriate INBOX.md
3. Clear processed OUTBOX.md entries
4. Monitor for blocked agents

## AGENTS.md Support

V2 introduces `AGENTS.md` for defining multi-agent systems:

```markdown
# Agents

## agent-backend
- Role: API and backend development
- Stack: ./backend/.cstack/
- Skills: /deploy, /test, /migrate

## agent-frontend
- Role: UI and client development
- Stack: ./frontend/.cstack/
- Skills: /build, /lint, /preview

## agent-devops
- Role: Infrastructure and deployment
- Stack: ./infra/.cstack/
- Skills: /provision, /monitor
```

### Agent Definition Fields

| Field | Required | Description |
|-------|----------|-------------|
| Role | Yes | What this agent is responsible for |
| Stack | Yes | Path to agent's `.cstack/` directory |
| Skills | No | Slash commands this agent can execute |
| Hooks | No | Custom hooks for this agent |

### CLI Commands for Agents

```bash
cstack agents list              # List all defined agents
cstack agents status            # Show status of all agents
cstack agents send backend task "Deploy v1.2"  # Send to specific agent
```

### Agent-Specific Hooks

Each agent can have custom hooks in their stack:

```
./backend/.cstack/
  .claude/
    hooks/
      deploy.ps1      # Triggered by /deploy skill
      deploy.sh
```

## V2 Scope

### Included
- `cstack` CLI binary
- Hash-based message IDs
- Atomic file operations
- Thread support
- AGENTS.md multi-agent definitions
- Agent-specific skills and hooks
- Go library with full API
- Pre-built binaries for major platforms

### Excluded (V3+)
- Task dependency graph
- Semantic compaction
- Memory decay
- Search indexing

## Migration from V1

V2 is fully backward compatible with V1:
- V1 files work without changes
- Missing IDs auto-generated on read
- CLI commands work on V1 stacks

## Release Strategy

- Binaries built via GitHub Actions on tag
- Platforms: linux-amd64, linux-arm64, darwin-amd64, darwin-arm64, windows-amd64
- Checksums published with each release

## Related Projects

- [context-by-md](https://github.com/Hotschmoe/context-by-md) - V1 inspiration
- [beads](https://github.com/steveyegge/beads) - V3 inspiration for advanced features
