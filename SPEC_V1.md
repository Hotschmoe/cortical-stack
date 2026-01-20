# Cortical Stack - V1 Specification

Pure markdown. Zero dependencies. Claude-native.

## Philosophy

V1 is inspired by [context-by-md](https://github.com/Hotschmoe/context-by-md) - the insight that AI agents can read and write markdown directly without needing parsing libraries. The "library" is the file format itself plus Claude Code instructions.

## Installation

### One-Line Install (PowerShell)

```powershell
irm https://raw.githubusercontent.com/hotschmoe/cortical-stack/master/install.ps1 | iex
```

### One-Line Install (Bash)

```bash
curl -fsSL https://raw.githubusercontent.com/hotschmoe/cortical-stack/master/install.sh | bash
```

### Manual Install

1. Copy `clean/.cstack/` to your project root
2. Add `.cstack/` instructions to your CLAUDE.md (or use the provided template)
3. Optionally configure hooks in `.claude/settings.local.json`

## File Structure

```
repo/
  .cstack/
    CURRENT.md    # Active task, focus, next steps
    PLAN.md       # Task backlog with states
    INBOX.md      # Messages TO this agent
    OUTBOX.md     # Messages FROM this agent
```

## File Formats

### CURRENT.md

Tracks the agent's active state. Updated frequently during work.

```markdown
# Current State

## Current Task
Implement user authentication

## Focus
Building JWT middleware

## Next Steps
- Write unit tests
- Add integration tests
- Update API documentation
```

### PLAN.md

Task backlog using checkbox notation:

| Syntax | Status | Description |
|--------|--------|-------------|
| `- [ ]` | Pending | Not started |
| `- [>]` | In Progress | Currently working |
| `- [x]` | Completed | Done |
| `- [!]` | Blocked | Waiting on something |

```markdown
# Plan

## Tasks
- [x] Set up project structure
- [>] Implement authentication
- [ ] Add user dashboard
- [!] Deploy to staging (waiting on infra)

## Notes
Using JWT for auth, refresh tokens stored in httpOnly cookies.
```

### INBOX.md

Messages TO this agent. Written by orchestrator or other agents.

```markdown
# Inbox

---
From: manager
Type: task
Time: 2026-01-19T10:30:00Z
---
Please implement the user authentication feature.
Priority: high

---
From: agent-frontend
Type: question
Time: 2026-01-19T11:00:00Z
---
What endpoint should I use for login?
```

### OUTBOX.md

Messages FROM this agent. Agent writes here, orchestrator reads and routes.

```markdown
# Outbox

---
To: manager
Type: milestone
Time: 2026-01-19T14:00:00Z
---
JWT middleware complete. Starting on refresh token logic.

---
To: agent-frontend
Type: done
Time: 2026-01-19T15:30:00Z
---
Login endpoint is POST /api/v1/auth/login
Returns: { token, refreshToken, expiresIn }
```

**Message Types:**
- `task` - New task assignment
- `question` - Question needing answer
- `milestone` - Progress update
- `blocked` - Agent is blocked, needs help
- `done` - Work completed

## Agent Rules

1. **Read your own INBOX.md** - Check for new messages
2. **Write to your own OUTBOX.md** - Send messages out
3. **Never write to another agent's files** - Orchestrator handles routing
4. **Update CURRENT.md** - Keep state current as you work
5. **Update PLAN.md** - Mark tasks as you progress

## Hooks

### Stop Hook (Checkpoint Reminder)

When a Claude Code session ends, remind the agent to checkpoint:

`.claude/settings.local.json`:
```json
{
  "hooks": {
    "stop": [
      {
        "command": "echo 'Remember to update .cstack/CURRENT.md with your progress!'"
      }
    ]
  }
}
```

## V1 Scope

### Included
- Markdown file format specification
- Clean template files (`clean/.cstack/`)
- Install scripts (PowerShell, Bash)
- Claude Code hook examples
- CLAUDE.md template with format instructions

### Excluded (V2+)
- CLI tooling (`cstack` command)
- Hash-based message IDs
- Go parsing library (moved to V2)
- Thread tracking
- Task dependencies

## Message ID Convention

For V1, use simple timestamp-based IDs when needed:

```
msg-2026-01-19T10-30-00
```

Or short random suffixes:

```
msg-a7f3
```

Hash-based IDs for deduplication are a V2 feature.

## Related Projects

- [context-by-md](https://github.com/Hotschmoe/context-by-md) - Original inspiration, lightweight context management
- [beads](https://github.com/steveyegge/beads) - Advanced git-backed issue tracker for AI agents
