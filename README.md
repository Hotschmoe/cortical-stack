# Cortical Stack

Markdown-based memory persistence for AI agents.

Named after the consciousness storage device in Altered Carbon: when the container dies, the stack survives. Resleeve into a new container with memory intact.

## Philosophy

Agent state lives in plain markdown files. No database, no service dependencies, no proprietary formats.

Inspired by:
- [context-by-md](https://github.com/Hotschmoe/context-by-md) - Lightweight context management for Claude Code
- [beads](https://github.com/steveyegge/beads) - Git-backed issue tracker for AI agents

## Quick Start

### One-Line Install

**PowerShell (Windows):**
```powershell
irm https://raw.githubusercontent.com/hotschmoe/cortical-stack/main/install.ps1 | iex
```

**Bash (macOS/Linux):**
```bash
curl -fsSL https://raw.githubusercontent.com/hotschmoe/cortical-stack/main/install.sh | bash
```

### Manual Install

Copy `clean/.cstack/` to your project root:

```bash
cp -r clean/.cstack /path/to/your/project/
```

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

**CURRENT.md** - Active task state
```markdown
## Current Task
Implement user authentication

## Focus
Building JWT middleware

## Next Steps
- Write unit tests
- Add integration tests
```

**PLAN.md** - Task backlog
```markdown
## Tasks
- [ ] Pending task
- [>] In progress task
- [x] Completed task
- [!] Blocked task
```

**INBOX.md / OUTBOX.md** - Messages
```markdown
---
From: manager
Type: task
Time: 2026-01-19T10:30:00Z
---
Please implement feature X.
```

## Versioning Roadmap

| Version | Focus | Status |
|---------|-------|--------|
| [V1](SPEC_V1.md) | Pure markdown, zero dependencies | Current |
| [V2](SPEC_V2.md) | CLI tooling, hash IDs, atomic ops | Planned |
| [V3](SPEC_V3.md) | Beads-style features (deps, decay) | Future |

## Standalone Use

Works with any AI CLI tool, any orchestration system, or none at all. Just add `.cstack/` to your repo and teach your agent the format.

## Related Projects

- [context-by-md](https://github.com/Hotschmoe/context-by-md) - Original inspiration for markdown-first approach
- [beads](https://github.com/steveyegge/beads) - Advanced features inspiration (V3)

## License

MIT
