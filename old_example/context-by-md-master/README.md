# Markdown Context System

A lightweight context management system for Claude Code using plain markdown files.

## Philosophy

Achieve 80% of the value with 20% of the complexity:
- Plain markdown files (human-readable, git-friendly)
- Claude Code slash commands for context management
- Zero dependencies (no binaries, no daemons)

## Quick Start

### One-Line Install

**Windows (PowerShell):**
```powershell
irm https://raw.githubusercontent.com/hotschmoe/context-by-md/master/clean/context-by-md/install-remote.ps1 | iex
```

**Linux/macOS:**
```bash
curl -fsSL https://raw.githubusercontent.com/hotschmoe/context-by-md/master/clean/context-by-md/install-remote.sh | bash
```

### After Install

```
/context-task                    # List tasks
/context-task add P1: My task    # Add a task
/context-task start 1            # Start task #1
```

## Directory Structure

```
.context-by-md/
├── CURRENT.md       # Session state + active task detail
├── PLAN.md          # Task list + backlog
├── QUICKREF.md      # Command reference
└── _VERSION         # Installed version (for upgrades)

.claude/
├── commands/        # Slash commands
├── hooks/           # Checkpoint reminder on stop
└── settings.local.json
```

## Workflow

### List Tasks
```
/context-task
```
Shows numbered task list:
```
Tasks:
1. [P1] User auth | JWT approach | next: session mgmt
2. [P2] Fix navbar | responsive issue
3. [P3] Add tests

Active: none
```

### Start a Task
```
/context-task start 1              # Quick start (no interview)
/context-task start 1 --plan       # Start with planning interview
```

Quick start copies context from PLAN.md into CURRENT.md's Active Task section.

With `--plan`, Claude runs an **interview**:
- What's the goal? What does "done" look like?
- What's explicitly OUT of scope?
- Any hard constraints?
- Main steps? First concrete action?

### During Work
- Check off subtasks in CURRENT.md
- `/context-task decide "Question" | choice | rationale` - Record decisions
- `/context-checkpoint` - Save state (also auto-prompted on session stop)

### Complete a Task
```
/context-task done
```
Removes task from PLAN.md, clears Active Task section in CURRENT.md.

## Task Format (PLAN.md)

Terse, one line per task:
```markdown
## Tasks

- [WIP] P1: User auth | JWT approach | next: session management
- [READY] P2: Rate limiting | token bucket | next: implement middleware
- [BLOCKED] P1: Payments | Stripe | blocked: API keys

## Notes

### User auth
Using JWT with 15min access + 7day refresh. Login endpoint done.

## Backlog

### Bugs
- [BUG] P2: Login fails on mobile | auth.js:42

### Ideas
- [IDEA] Add dark mode toggle
```

**Status:** `[READY]` `[WIP]` `[BLOCKED]` `[PAUSED]`

**Priority:** P0=Critical, P1=High, P2=Medium, P3=Low

## Commands Reference

| Command | Purpose |
|---------|---------|
| `/context-task` | List tasks with numbers |
| `/context-task start 1` | Start task #1 (quick) |
| `/context-task start 1 --plan` | Start with interview |
| `/context-task add P1: X` | Add task to PLAN.md |
| `/context-task done` | Complete active task |
| `/context-task block 1 \| reason` | Block task |
| `/context-task ready 1` | Unblock task |
| `/context-task decide` | Record decision |
| `/context-checkpoint` | Save all state |

## File Purposes

### CURRENT.md - Session State + Active Task
What Claude reads on compaction/session start:
- **Now** - Current focus (1-3 items)
- **Next Steps** - Ordered actions to continue
- **Active Task** - Goal, scope, subtasks, decisions
- **Context** - Key files, blockers, critical info

### PLAN.md - Task List + Backlog
- **Tasks** - One line per task with status/priority
- **Notes** - Detail for tasks that need it
- **Backlog** - Bugs, debt, ideas (discovered work)

## Hooks

Stop hook automatically reminds Claude to run `/context-checkpoint` when a session ends.

- **Windows:** PowerShell scripts in `.claude/hooks/`
- **Unix:** Bash scripts in `.claude/hooks/`

## Manual Install

1. Copy `clean/context-by-md/.context-by-md/` to your project root
2. Copy `clean/context-by-md/.claude/` to your project
3. Copy `clean/context-by-md/CLAUDE.md` to your project root (or append to existing)

## Uninstall

Remove the context system from your project:

**Windows (PowerShell):**
```powershell
Remove-Item -Recurse -Force .context-by-md, .claude\commands\context-*.md, .claude\hooks\context-*.ps1
```

**Linux/macOS:**
```bash
rm -rf .context-by-md .claude/commands/context-*.md .claude/hooks/context-*.sh
```

Note: This preserves other `.claude/` settings. To remove everything context-by-md added, also delete the CLAUDE.md file (or remove the context system section if you have other instructions in it).

## vs Beads

**What you lose:** Automated ready-work queries, hash-based IDs, formal dependency tracking, LLM summarization, multi-repo coordination, daemon sync.

**What you gain:** Zero dependencies, human-readable everything, works offline, easy to customize, meaningful git diffs, portable across AI tools.

**Use this for:** Solo/small team, simplicity over features, personal projects.

**Use beads for:** Large teams, multiple agents, formal dependencies, multi-repo.
