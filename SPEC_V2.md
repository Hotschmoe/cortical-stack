# Cortical Stack - V2 Specification

## Overview

V2 evolves the stack format with features borrowed from beads_rust, while maintaining markdown compatibility.

## Evolution Path

```
V1 (Current):
  - Pure markdown files in .cstack/
  - Simple, portable, human-readable
  - No external dependencies

V2 (This Spec):
  - Fork beads_rust for advanced features
  - Maintain markdown as storage format
  - Add computed features on top
```

## New Features

### Hash-based Message IDs

Automatic deduplication via content hashing:

```markdown
---
ID: msg-a7f3bc12
From: agent-alice
Type: milestone
Time: 2026-01-19T10:30:00Z
---
```

ID is generated from hash of (From + Type + Content + truncated timestamp).

### Thread Tracking

Group related messages:

```markdown
---
ID: msg-b8c4
From: agent-bob
Thread: thread-auth-impl
Type: question
---
Should we use JWT or session auth?
```

### Parent/Child Task Notation

Hierarchical task dependencies:

```markdown
## Tasks
- [ ] Implement authentication (task-001)
  - [ ] Design auth flow (task-002, parent: task-001)
  - [ ] Build JWT middleware (task-003, parent: task-001)
  - [ ] Write tests (task-004, parent: task-001)
```

### Dependency-Aware Task Graph

Tasks can declare dependencies:

```markdown
- [ ] Deploy to staging (depends: task-003, task-004)
```

Parser builds dependency graph, enables:
- Topological sorting
- Critical path analysis
- Blocked task detection

### Semantic Compaction

When stack files grow large:
1. Completed tasks archived to HISTORY.md
2. Old messages compacted to summaries
3. Original content preserved in git history

### CONTEXT.md

Long-term memory file:

```markdown
# Context

## Project Overview
This is an e-commerce platform...

## Key Decisions
- Using PostgreSQL for persistence
- JWT for auth, refresh tokens for sessions

## Learned Patterns
- API endpoints follow /api/v1/{resource} pattern
- Tests live in _test.go files adjacent to code
```

## Beads Integration

### What We Take from Beads

1. **Task graph structure** - DAG for dependencies
2. **Compaction algorithm** - Semantic summarization
3. **Search indexing** - Fast content lookup

### What We Keep from V1

1. **Markdown format** - Human readable/editable
2. **Git native** - No separate database
3. **Graceful degradation** - Works without beads features

## Decision Trigger

When to move from V1 to V2:
- Markdown grep becomes painful at scale
- Task dependencies become complex
- Semantic compaction needed for large histories
- Search across many agents required

## File Format Changes

### CURRENT.md (unchanged)

Same format as V1.

### PLAN.md (extended)

```markdown
## Tasks
- [ ] Task description (id: task-001)
  - [ ] Subtask (id: task-002, parent: task-001)
- [ ] Another task (id: task-003, depends: task-001)

## Graph
task-001 -> task-002
task-001 -> task-003
```

### INBOX.md / OUTBOX.md (extended)

```markdown
---
ID: msg-a7f3bc12
From: agent-alice
To: manager
Thread: thread-feature-x
ReplyTo: msg-previous
Type: milestone
Time: 2026-01-19T10:30:00Z
---
Message content here.
```

### HISTORY.md (new)

```markdown
# History

## Compacted: 2026-01-15

### Summary
Completed initial setup phase: project structure, CI pipeline, basic auth.

### Archived Tasks
- [x] Set up project structure
- [x] Configure CI pipeline
- [x] Implement basic auth
```

## Go Package Extensions

```go
// V2 additions
type TaskGraph struct {
    Tasks map[string]*Task
    Edges map[string][]string
}

func ParseTaskGraph(workspacePath string) (*TaskGraph, error)
func (g *TaskGraph) TopologicalSort() ([]*Task, error)
func (g *TaskGraph) FindBlocked() []*Task

func CompactHistory(workspacePath string, olderThan time.Time) error
func SearchStack(workspacePath string, query string) ([]SearchResult, error)
```

## Migration Path

V1 stacks work in V2 without changes. New features are additive:
- Missing IDs auto-generated on read
- Missing thread fields ignored
- Task graph built from flat list if no dependencies

## Potential Beads Fork

If we fork beads_rust:

```
github.com/hotschmoe/cortical-stack
  pkg/stack/         # V1 markdown parser (stable)
  pkg/beads/         # V2 beads-style features (fork)
  pkg/compat/        # Bridging between formats
```
