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

**Windows (PowerShell):**
```powershell
irm https://raw.githubusercontent.com/hotschmoe/cortical-stack/master/install.ps1 | iex
```

**macOS/Linux (Bash):**
```bash
curl -fsSL https://raw.githubusercontent.com/hotschmoe/cortical-stack/master/install.sh | bash
```

### What Gets Installed

```
your-project/
  .cstack/
    CURRENT.md        # Active task, focus, next steps
    PLAN.md           # Task backlog with states
    QUICKREF.md       # Command quick reference
  .claude/
    commands/
      cstack-task.md       # Task management command
      cstack-checkpoint.md # Save state command
      cstack-start.md      # Load context command
    hooks/
      cstack-start.*  # Loads stack on session start
      cstack-stop.*   # Reminds to save on session end
    settings.local.json
  CLAUDE.md           # Instructions for the agent
```

### Manual Install

1. Copy `clean/.cstack/` to your project root
2. Copy `clean/.claude/` to your project root
3. Copy `clean/CLAUDE.md` to your project (or append to existing)

## Uninstall

**Windows (PowerShell):**
```powershell
Remove-Item -Recurse -Force .cstack, .claude\commands\cstack-*.md, .claude\hooks\cstack-*.ps1, .claude\hooks\cstack-*.sh
```

**macOS/Linux:**
```bash
rm -rf .cstack .claude/commands/cstack-*.md .claude/hooks/cstack-*.sh .claude/hooks/cstack-*.ps1
```

Note: This preserves other `.claude/` settings. Also remove the cortical stack section from CLAUDE.md if present.

## Why Markdown?

- **Human readable** - Open in any text editor
- **Human editable** - Inject tasks, fix state, debug
- **Git native** - Version controlled, diffable
- **Portable** - Copy a directory, copy the state
- **Survives anything** - No database to corrupt

## Commands

| Command | What it does |
|---------|--------------|
| `/cstack-task` | List tasks with numbers |
| `/cstack-task start 1` | Start task #1 (quick) |
| `/cstack-task start 1 --plan` | Start task #1 with planning interview |
| `/cstack-task add P1: X` | Add new task |
| `/cstack-task done` | Complete active task |
| `/cstack-task block 1 \| reason` | Block task #1 |
| `/cstack-task ready 1` | Unblock task #1 |
| `/cstack-checkpoint` | Save all state |
| `/cstack-start` | Read context and show status |

## File Formats

### CURRENT.md - Active State

```markdown
## Current Task
Implement user authentication

## Focus
Building JWT middleware

## Next Steps
- Write unit tests
- Add integration tests
```

### PLAN.md - Task Backlog

```markdown
## Tasks
- [ ] Pending task
- [>] In progress task
- [x] Completed task
- [!] Blocked task

## Notes
Project context here.
```

| Syntax | Status |
|--------|--------|
| `- [ ]` | Pending |
| `- [>]` | In Progress |
| `- [x]` | Completed |
| `- [!]` | Blocked |

## Hooks

The installer sets up Claude Code hooks:

- **Start hook** - Loads `.cstack/` contents into context on session start
- **Stop hook** - Reminds agent to save state before session ends

## Workflow

```
/cstack-start                 # Load context, see task list
    |
/cstack-task start 1          # Start task (or --plan for interview)
    |
[work on task]                # Check off subtasks in CURRENT.md
    |
/cstack-task done             # Complete, clear active task
    |
/cstack-checkpoint            # Save state
```

### On Session Start
1. Start hook automatically loads CURRENT.md, PLAN.md
2. Resume work from saved state

### During Work
- Update CURRENT.md as you progress
- Mark tasks in PLAN.md as status changes

### On Session End
1. Stop hook reminds agent to checkpoint
2. Agent updates CURRENT.md with progress
3. Agent updates PLAN.md with task status

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
