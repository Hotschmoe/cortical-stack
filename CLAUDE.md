# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## RULE 1 - ABSOLUTE (DO NOT EVER VIOLATE THIS)

You may NOT delete any file or directory unless I explicitly give the exact command **in this session**.

- This includes files you just created (tests, tmp files, scripts, etc.).
- You do not get to decide that something is "safe" to remove.
- If you think something should be removed, stop and ask. You must receive clear written approval **before** any deletion command is even proposed.

Treat "never delete files without permission" as a hard invariant.

---

### IRREVERSIBLE GIT & FILESYSTEM ACTIONS

Absolutely forbidden unless I give the **exact command and explicit approval** in the same message:

- `git reset --hard`
- `git clean -fd`
- `rm -rf`
- Any command that can delete or overwrite code/data

Rules:

1. If you are not 100% sure what a command will delete, do not propose or run it. Ask first.
2. Prefer safe tools: `git status`, `git diff`, `git stash`, copying to backups, etc.
3. After approval, restate the command verbatim, list what it will affect, and wait for confirmation.
4. When a destructive command is run, record in your response:
   - The exact user text authorizing it
   - The command run
   - When you ran it

If that audit trail is missing, then you must act as if the operation never happened.

---

### Code Editing Discipline

- Do **not** run scripts that bulk-modify code (codemods, invented one-off scripts, giant `sed`/regex refactors).
- Large mechanical changes: break into smaller, explicit edits and review diffs.
- Subtle/complex changes: edit by hand, file-by-file, with careful reasoning.
- **NO EMOJIS** - do not use emojis or non-textual characters.
- ASCII diagrams are encouraged for visualizing flows.
- Keep in-line comments to a minimum. Use external documentation for complex logic.
- In-line commentary should be value-add, concise, and focused on info not easily gleaned from the code.

---

### No Legacy Code - Full Migrations Only

We optimize for clean architecture, not backwards compatibility. **When we refactor, we fully migrate.**

- No "compat shims", "v2" file clones, or deprecation wrappers
- When changing behavior, migrate ALL callers and remove old code **in the same commit**
- No `_legacy` suffixes, no `_old` prefixes, no "will remove later" comments
- New files are only for genuinely new domains that don't fit existing modules
- The bar for adding files is very high

**Rationale**: Legacy compatibility code creates technical debt that compounds. A clean break is always better than a gradual migration that never completes.

---

## Session Completion Checklist

```
[ ] File issues for remaining work
[ ] Run quality gates (tests, linters)
[ ] Run git push and verify success
[ ] Confirm git status shows "up to date"
```

**Work is not complete until `git push` succeeds.**

---

## Project Overview

Cortical Stack is a Go library for markdown-based memory persistence for AI agents. Named after the consciousness storage device in Altered Carbon - when the container dies, the stack survives. Resleeve into a new container with memory intact.

The core philosophy: agent state lives in plain markdown files. No database, no service dependencies, no proprietary formats.

## Build and Development Commands

```bash
# Run tests with race detection
go test -race ./...

# Run tests with coverage
go test -race -coverprofile=coverage.out ./...
go tool cover -func=coverage.out

# Build (verify compilation)
go build ./...

# Format code
go fmt ./...

# Vet code
go vet ./...
```

## Architecture

### Package Structure

```
cortical-stack/
  pkg/cstack/           # Core library
    cstack.go           # Main API (ParseCurrent, ParsePlan, InitStack)
    cstack_test.go      # Tests
    doc.go              # Package documentation
  templates/            # Example stack files
  examples/             # Usage examples
```

### Core Types

- **CurrentState**: Active task, focus, next steps (from CURRENT.md)
- **PlanState**: Task backlog with statuses (from PLAN.md)
- **Task**: Description + status (pending, in_progress, completed, blocked)

### Stack File Format

Agent state uses markdown files in `.cstack/`:

```
repo/
  .cstack/
    CURRENT.md    # Active task, focus, next steps
    PLAN.md       # Task backlog with states
    QUICKREF.md   # Command quick reference
```

### Task States (PLAN.md)

| Syntax | Status |
|--------|--------|
| `- [ ]` | Pending |
| `- [>]` | In Progress |
| `- [x]` | Completed |
| `- [!]` | Blocked |

## Key Design Decisions

1. **Markdown as database** - human readable, git native, survives anything
2. **No external dependencies** - pure Go standard library
3. **Graceful degradation** - missing files return empty state, not errors
4. **Project agnostic** - works with any AI CLI, any orchestration system, or standalone

---

## Claude Agents

Specialized agents are available in `.claude/agents/`. Agents use YAML frontmatter format:

```yaml
---
name: agent-name
description: What this agent does
model: sonnet|haiku|opus
tools:
  - Bash
  - Read
  - Edit
---
```

### Available Agents

| Agent | Model | Purpose |
|-------|-------|---------|
| coder-sonnet | sonnet | Fast, precise code changes with atomic commits |
| gemini-analyzer | sonnet | Large-context analysis via Gemini CLI (1M+ context) |
| build-verifier | sonnet | Pre-merge validation for Go build and tests |

### Disabling Agents

To disable specific agents in `settings.json` or `--disallowedTools`:
```json
{
  "disallowedTools": ["Task(build-verifier)", "Task(gemini-analyzer)"]
}
```

---

## Go Best Practices

### Error Handling

```go
// Wrap errors with context
if err != nil {
    return fmt.Errorf("failed to parse %s: %w", filename, err)
}

// Use errors.Is/As for type checking
if errors.Is(err, os.ErrNotExist) {
    return &CurrentState{}, nil
}
```

### File Operations

```go
// Always close files
file, err := os.Open(filePath)
if err != nil {
    return nil, fmt.Errorf("failed to open %s: %w", filePath, err)
}
defer file.Close()

// Handle missing files gracefully
if os.IsNotExist(err) {
    return emptyState, nil
}
```

### Testing

```go
// Table-driven tests
func TestParseTask(t *testing.T) {
    tests := []struct {
        name    string
        input   string
        want    Task
        wantOK  bool
    }{
        {"pending", "- [ ] Do thing", Task{Description: "Do thing", Status: "pending"}, true},
        {"in_progress", "- [>] Doing thing", Task{Description: "Doing thing", Status: "in_progress"}, true},
    }
    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            got, ok := parseTaskLine(tt.input)
            if ok != tt.wantOK || got != tt.want {
                t.Errorf("parseTaskLine(%q) = %v, %v; want %v, %v", tt.input, got, ok, tt.want, tt.wantOK)
            }
        })
    }
}
```

---

## Bug Severity

### Critical - Must Fix Immediately

- Nil pointer dereference
- Data races (use `-race` flag)
- Resource leaks (goroutines, file handles)
- Security vulnerabilities (path traversal)

### Important - Fix Before Merge

- Missing error handling
- File handle leaks (missing defer Close())
- Incorrect markdown parsing

### Contextual - Address When Convenient

- TODO/FIXME comments
- Suboptimal performance
- Missing test coverage
- Code style inconsistencies
