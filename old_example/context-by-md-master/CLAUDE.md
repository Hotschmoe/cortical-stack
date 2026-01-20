# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**context-by-md** is a lightweight markdown-based context management system for Claude Code. Provides session continuity across context window limits without external dependencies.

Philosophy: 80% of the value with 20% of the complexity using plain markdown.

## Repository Structure

```
context-by-md/
├── README.md
└── clean/context-by-md/         # Installable package
    ├── CLAUDE.md                # Installed to user projects
    ├── install.ps1              # Local install (Windows)
    ├── install-remote.ps1       # One-line remote install
    ├── .context-by-md/
    │   ├── CURRENT.md           # Session state + active task
    │   ├── PLAN.md              # Task list + backlog
    │   └── QUICKREF.md          # Command reference
    └── .claude/
        ├── commands/            # Slash commands
        ├── hooks/               # Checkpoint reminder on stop
        └── settings.local.json
```

## Key Concepts

### Files (Just 2)
| File | Purpose |
|------|---------|
| `CURRENT.md` | Session state + active task detail (goal, scope, subtasks, decisions) |
| `PLAN.md` | Task list + backlog (bugs, debt, ideas) |

### Task Format (PLAN.md)
```markdown
- [READY] P1: Task title | context | next: action
```

### Commands
```
/context-task              # List tasks with numbers
/context-task start 1      # Start task #1 (quick)
/context-task start 1 --plan  # Start with interview
/context-task done         # Complete active task
/context-checkpoint        # Save state
```

### Status Markers
`[READY]` `[WIP]` `[BLOCKED]` `[PAUSED]`

### Priority
P0=Critical, P1=High, P2=Medium, P3=Low

## Development

No build system or dependencies. Edit files in `clean/context-by-md/`.

### Testing
1. Install to test project: `.\clean\context-by-md\install.ps1`
2. Test slash commands
3. Verify hooks fire on stop
