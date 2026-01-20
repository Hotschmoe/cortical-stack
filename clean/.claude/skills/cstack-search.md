---
name: cstack-search
description: Search across cortical stack files using ripgrep
---

# /cstack-search - Search Stack Files

Search across all `.cstack/` files using ripgrep.

## Usage

```
/cstack-search QUERY [--file FILE]
```

## Options

| Option | Default | Description |
|--------|---------|-------------|
| `QUERY` | required | Search term or regex pattern |
| `--file FILE` | all files | Limit search to specific file (PLAN.md, CURRENT.md, etc.) |

## Examples

- `/cstack-search JWT` - Find all mentions of JWT
- `/cstack-search "blocked by"` - Find blocked tasks
- `/cstack-search #auth` - Find tasks with auth label
- `/cstack-search --file PLAN.md #bug` - Find bugs in PLAN.md only

## What It Does

1. Runs ripgrep (`rg`) on `.cstack/` directory
2. Returns matches with file:line context
3. Highlights matching text
4. Groups results by file

## Output Format

```markdown
# Search Results for "QUERY"

## .cstack/PLAN.md:15
...context with **QUERY** highlighted...

## .cstack/CURRENT.md:8
...another match with **QUERY**...
```

## Implementation

```bash
# Search all stack files
rg "QUERY" .cstack/ --context 1 --heading

# Search specific file
rg "QUERY" .cstack/PLAN.md --context 1

# Case insensitive
rg -i "QUERY" .cstack/
```

## When to Use

- Finding where a topic is mentioned
- Locating tasks by label
- Finding blocked items
- Searching decision history
