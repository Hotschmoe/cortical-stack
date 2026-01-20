---
name: cstack-stale
description: Find tasks with no recent activity
---

# /cstack-stale - Find Stale Tasks

Surface tasks that haven't been touched in a while.

## Usage

```
/cstack-stale [days]
```

## Options

| Option | Default | Description |
|--------|---------|-------------|
| `days` | 7 | Threshold in days for staleness |

## Examples

- `/cstack-stale` - Find tasks older than 7 days
- `/cstack-stale 14` - Find tasks older than 14 days
- `/cstack-stale 3` - Find tasks older than 3 days

## What It Does

1. Reads `.cstack/PLAN.md`
2. Extracts tasks with `modified:` metadata or checks git history
3. Compares against threshold
4. Lists stale tasks with last activity date

## Output Format

```markdown
# Stale Tasks (no activity > 7 days)

1. [P3] Write API docs | #docs | last: 2026-01-10
2. [P2] Fix mobile layout | #bug #frontend | last: 2026-01-08
3. [BLOCKED] Stripe integration | #payment | last: 2026-01-05

3 stale tasks found. Review or close?
```

## Staleness Detection

Priority order:
1. `modified: YYYY-MM-DD` metadata in task line
2. Git blame on the task line
3. File modification date (fallback)

## Task Line Format

Tasks should include modified date for accurate tracking:

```markdown
- [ ] P2: Fix mobile layout #bug | modified: 2026-01-08
```

## When to Use

- Weekly task review
- Sprint planning
- Identifying abandoned work
- Cleaning up backlog
