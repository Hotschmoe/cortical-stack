# Cortical Stack - V2 Specification

Single-agent productivity enhancements.

## Philosophy

V2 adds lightweight tooling to improve single-agent workflows:
- Find things fast (search)
- Categorize work (labels)
- Surface forgotten tasks (stale detection)
- Track why things were closed (close reasons)

No binaries required. V2 features are implemented as slash commands and markdown conventions that Claude Code (or any AI agent) can use directly.

## New Features

### Search

Find content across all stack files using ripgrep/grep:

```
/cstack-search JWT
/cstack-search "blocked by" --file PLAN.md
/cstack-search #auth
```

Implementation: Slash command that wraps `rg` or `grep` and formats results.

```markdown
# Search Results for "JWT"

## .cstack/CURRENT.md:15
...implementing **JWT** middleware for auth...

## .cstack/PLAN.md:8
- [>] P1: JWT refresh token rotation | #auth #security
```

### Labels

Inline hashtag syntax for categorization:

```markdown
## Tasks

- [ ] P1: Fix login redirect #bug #auth #urgent
- [>] P2: Add rate limiting #security #api
- [ ] P3: Refactor user model #debt #backend
```

**Reserved labels:**
| Label | Meaning |
|-------|---------|
| `#bug` | Bug fix |
| `#debt` | Technical debt |
| `#feature` | New feature |
| `#urgent` | Needs immediate attention |

**Custom labels:** Any `#word` is valid. Use what makes sense for your project.

**Filter by label:**
```
/cstack-task #bug           # List all bugs
/cstack-task #auth #urgent  # List auth + urgent
```

### Stale Detection

Surface tasks that haven't been touched in a while:

```
/cstack-stale              # Default: 7 days
/cstack-stale 14           # Tasks older than 14 days
```

Output:
```markdown
# Stale Tasks (no activity > 7 days)

1. [P3] Write API docs | #docs | last: 2026-01-10
2. [P2] Fix mobile layout | #bug #frontend | last: 2026-01-08
3. [BLOCKED] Stripe integration | #payment | last: 2026-01-05

3 stale tasks found. Review or close?
```

**Implementation:** Tasks track last-modified date in metadata:

```markdown
- [ ] P2: Fix mobile layout #bug | modified: 2026-01-08
```

Or inferred from git history if not present.

### Close Reasons

When completing or abandoning tasks, record why:

```
/cstack-task done "Shipped in v1.2.0"
/cstack-task close 3 "Won't fix - out of scope"
/cstack-task close 5 "Duplicate of #2"
```

Closed tasks move to a `## Completed` or `## Closed` section with reason:

```markdown
## Completed

- [x] P1: JWT auth | #auth | closed: 2026-01-15 | reason: Shipped in v1.2.0
- [x] P2: Rate limiting | #security | closed: 2026-01-14 | reason: Done

## Closed (Won't Fix)

- [~] P3: Add GraphQL | #api | closed: 2026-01-13 | reason: Staying with REST
```

**New status marker:** `[~]` for closed-won't-fix (distinct from `[x]` completed).

## Updated Commands

| Command | What it does |
|---------|--------------|
| `/cstack-search QUERY` | Search across stack files |
| `/cstack-task #label` | Filter tasks by label |
| `/cstack-stale [days]` | Show tasks with no recent activity |
| `/cstack-task done "reason"` | Complete task with reason |
| `/cstack-task close N "reason"` | Close task without completing |

## File Format Extensions

### PLAN.md with Labels and Metadata

```markdown
# Plan

> **Updated:** 2026-01-15

## Legend
`- [ ]` Pending | `- [>]` In Progress | `- [x]` Completed | `- [!]` Blocked | `- [~]` Closed

## Tasks

- [>] P1: User dashboard #feature #frontend | modified: 2026-01-15
- [ ] P2: Fix login bug #bug #auth | modified: 2026-01-14
- [!] P1: Payment integration #feature #payment | blocked: waiting on Stripe keys | modified: 2026-01-10

## Completed

- [x] P1: JWT authentication #auth #security | closed: 2026-01-12 | reason: Shipped
- [x] P2: Database migrations #backend | closed: 2026-01-10 | reason: Done

## Closed

- [~] P3: GraphQL API #api | closed: 2026-01-08 | reason: Out of scope for MVP
```

### QUICKREF.md Updates

Add V2 commands to quick reference.

## INBOX/OUTBOX - Moving to NEEDLECAST

INBOX and OUTBOX will be migrated to a separate project: **NEEDLECAST**.

**Rationale:** Cross-repo agent communication is a distinct concern from single-agent memory persistence. Separating them allows:
- Cortical Stack to focus purely on memory (CURRENT.md, PLAN.md)
- NEEDLECAST to handle agent-to-agent messaging with proper tooling
- Cleaner single-agent installs without unused messaging files

**NEEDLECAST** (named after the Altered Carbon technology for transmitting consciousness between stacks) will handle:
- Cross-repository agent communication
- Message routing and delivery
- Async coordination between separate Claude Code sessions

**Migration path:**
1. V2 installs will no longer include INBOX.md/OUTBOX.md by default
2. Projects needing cross-repo communication install NEEDLECAST separately
3. Existing INBOX/OUTBOX files continue to work (no breaking changes)

**Not in scope for NEEDLECAST:** Multi-agent orchestration in the same repo. That's a different problem.

## V2 Scope

### Included
- Search command (ripgrep/grep wrapper)
- Label syntax and filtering
- Stale task detection
- Close reasons with new `[~]` marker
- Updated PLAN.md format

### Removed (moved to NEEDLECAST)
- INBOX.md
- OUTBOX.md

### Excluded (V3+)
- CLI binary
- Task dependency graph
- Semantic compaction
- Memory decay
- AGENTS.md for alternative AI agents (Gemini, Codex, etc.)

## Migration from V1

V2 is fully backward compatible:
- V1 PLAN.md files work without changes
- Labels are optional (add when useful)
- Stale detection works on any task format
- Close reasons are optional

## Implementation Notes

V2 features are slash commands, not a binary. They rely on:
- Claude Code's ability to read/write markdown
- Shell tools (rg, grep) for search
- Git for modification dates (fallback)

No installation beyond V1. Just use the new commands.

---

## Related Projects

- [context-by-md](https://github.com/Hotschmoe/context-by-md) - V1 inspiration
- [beads_rust](https://github.com/Dicklesworthstone/beads_rust) - Search and label inspiration
