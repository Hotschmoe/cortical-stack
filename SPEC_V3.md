# Cortical Stack - V3 Specification

Beads-style features for complex, long-running agent workflows.

## Philosophy

V3 draws inspiration from [beads](https://github.com/steveyegge/beads) to handle:
- Complex task dependency graphs
- Long-running workflows that exceed context windows
- Multi-agent coordination at scale
- Semantic memory management

While beads uses JSONL storage, we maintain markdown as the primary format with optional indexing for performance.

## New Features

### Task Dependency Graph

Tasks can declare dependencies and parent relationships:

```markdown
# Plan

## Tasks
- [ ] Deploy to production (id: deploy-001, depends: test-001, review-001)
- [x] Write unit tests (id: test-001)
- [>] Code review (id: review-001, depends: test-001)
  - [ ] Review auth module (id: review-001a, parent: review-001)
  - [ ] Review API endpoints (id: review-001b, parent: review-001)
```

CLI commands:
```bash
cstack ready          # Show tasks with all dependencies met
cstack blocked        # Show blocked tasks and why
cstack graph          # Visualize dependency graph (ASCII)
cstack critical-path  # Show longest path to completion
```

### Semantic Compaction

When stack files grow large, compact old content while preserving meaning:

```bash
cstack compact --older-than 7d
```

Before:
```markdown
# Outbox

---
To: manager
Type: milestone
Time: 2026-01-10T10:00:00Z
---
Started authentication implementation.

---
To: manager
Type: milestone
Time: 2026-01-10T14:00:00Z
---
JWT signing working, moving to verification.

---
To: manager
Type: milestone
Time: 2026-01-10T18:00:00Z
---
JWT verification complete. All tests passing.
```

After:
```markdown
# Outbox

## Compacted: 2026-01-10

Authentication implementation completed in one day:
- JWT signing and verification implemented
- All tests passing

---
(Recent messages remain uncompacted)
```

### Memory Decay

Automatic summarization of old context to preserve context window space:

`.cstack/CONTEXT.md`:
```markdown
# Context

## Active Memory (Full Detail)
- Current sprint: User dashboard implementation
- Tech stack: React + FastAPI + PostgreSQL
- Auth: JWT with refresh tokens

## Decayed Memory (Summarized)

### Week of 2026-01-06
Completed authentication system. Key decisions:
- Chose JWT over sessions for statelessness
- Refresh tokens stored in httpOnly cookies
- Rate limiting on login endpoint (5/min)

### Week of 2025-12-30
Project setup and infrastructure. PostgreSQL on RDS,
FastAPI deployed to ECS, React on CloudFront.
```

### Search Indexing

Optional SQLite index for fast content search:

```bash
cstack index rebuild    # Build/rebuild search index
cstack search "JWT"     # Search across all stack files
cstack search --inbox "blocked"  # Search specific file
```

Index stored at `.cstack/.index.db` (gitignored).

### Stealth Mode

Personal task tracking without committing to repo:

```bash
cstack stealth on   # Stack files in .cstack/.local/ (gitignored)
cstack stealth off  # Move back to .cstack/
```

Useful for:
- Personal notes on shared projects
- Draft tasks before sharing
- Sensitive context

## File Format Extensions

### PLAN.md with Dependencies

```markdown
# Plan

## Tasks
- [ ] Parent task (id: task-001)
  - [ ] Subtask A (id: task-001a, parent: task-001)
  - [ ] Subtask B (id: task-001b, parent: task-001, depends: task-001a)
- [ ] Independent task (id: task-002, depends: task-001)

## Dependency Graph
task-001 -> task-001a -> task-001b
task-001 -> task-002
```

### CONTEXT.md (Long-term Memory)

```markdown
# Context

## Project Overview
E-commerce platform for artisan goods marketplace.

## Architecture
- Frontend: React SPA
- Backend: FastAPI (Python)
- Database: PostgreSQL
- Cache: Redis
- Search: Elasticsearch

## Key Decisions
| Date | Decision | Rationale |
|------|----------|-----------|
| 2026-01-05 | JWT auth | Stateless, scales horizontally |
| 2026-01-08 | PostgreSQL | ACID compliance for orders |

## Learned Patterns
- API: /api/v1/{resource}/{id}
- Tests: pytest with fixtures in conftest.py
- Migrations: Alembic with descriptive names

## Active Context
(Recent, frequently accessed information)

## Decayed Context
(Summarized older information)
```

### HISTORY.md (Archived Completed Work)

```markdown
# History

## Sprint 2026-01-06 to 2026-01-12

### Completed Tasks
- [x] Set up CI/CD pipeline
- [x] Implement user authentication
- [x] Create user profile endpoints

### Summary
Infrastructure and auth foundation complete.
Users can register, login, and manage profiles.
JWT-based auth with refresh token rotation.

### Archived Messages
12 messages compacted. See git history for originals.
```

## CLI Additions

```bash
# Dependency management
cstack dep add task-002 task-001    # task-002 depends on task-001
cstack dep remove task-002 task-001
cstack ready                         # Tasks with deps satisfied

# Memory management
cstack compact [--older-than DURATION]
cstack decay [--keep-recent DURATION]
cstack context add "key decision"
cstack context show

# Search
cstack search QUERY [--file FILE]
cstack index rebuild

# Stealth mode
cstack stealth on|off|status
```

## V3 Scope

### Included
- Task dependency graph with topological sort
- Semantic compaction algorithm
- Memory decay with summarization
- SQLite search indexing
- CONTEXT.md for long-term memory
- HISTORY.md for archived work
- Stealth mode for local-only tracking
- Critical path analysis

### Excluded (Future)
- Real-time sync between agents
- Distributed consensus
- Cloud-hosted stack service

## Migration Path

V3 is backward compatible:
- V1/V2 stacks work without changes
- New features activated on first use
- Compaction preserves git history

## Performance Considerations

For large stacks (1000+ tasks, 10000+ messages):
- Search index provides O(log n) lookup
- Compaction reduces file I/O
- Lazy loading of HISTORY.md

## Related Projects

- [context-by-md](https://github.com/Hotschmoe/context-by-md) - V1 inspiration
- [beads](https://github.com/steveyegge/beads) - Primary V3 inspiration
  - Task graph structure
  - Compaction algorithm
  - Memory decay concept
