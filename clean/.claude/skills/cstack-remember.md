---
name: cstack-remember
description: Add long-term memory entries to MEMORY.md
---

# /cstack-remember - Record Long-Term Memory

Add knowledge that should persist across sessions to `.cstack/MEMORY.md`.

## Usage

```
/cstack-remember "fact or observation"
/cstack-remember --decision "choice" --why "rationale"
/cstack-remember --gotcha "non-obvious behavior"
/cstack-remember --preference "user preference"
```

## Categories

| Category | When to Use | Format |
|----------|-------------|--------|
| Fact | Project knowledge that took effort to discover | Bullet under `## Facts` |
| Gotcha | Non-obvious behavior, edge case, thing that bit you | Dated bullet under `## Gotchas` |
| Decision | Architectural choice with rationale | Row in `## Decisions` table |
| Preference | User/project preference learned over time | Bullet under `## Preferences` |

## Auto-Categorization

If no category flag is provided, determine category from content:

- Contains "prefer", "always", "never", "don't like" -> Preference
- Contains "decided", "chose", "picked X over Y", "because" -> Decision
- Contains "gotcha", "careful", "watch out", "actually", "turns out" -> Gotcha
- Otherwise -> Fact

## Examples

```
/cstack-remember "ParseCurrent returns empty state for missing files, not an error"
# -> Added to Facts

/cstack-remember --gotcha "Windows paths need filepath.Join, not string concat"
# -> Added to Gotchas with date

/cstack-remember --decision "JWT over sessions" --why "Stateless fits serverless deploy"
# -> Added to Decisions table

/cstack-remember "User prefers table-driven tests"
# -> Auto-detected as Preference
```

## What It Does

1. Parse the input and determine category
2. Read `.cstack/MEMORY.md`
3. Format entry appropriately:
   - **Facts**: `- {content}`
   - **Gotchas**: `- **{date}**: {content}`
   - **Preferences**: `- {content}`
   - **Decisions**: `| {decision} | {choice} | {why} | {date} |`
4. Append to the correct section
5. Write updated MEMORY.md
6. Confirm what was added

## Output Format

```
Added to Gotchas:
- **2026-01-21**: Windows paths need filepath.Join, not string concat
```

## Good Candidates for Memory

- Non-obvious API behaviors
- Project conventions not in docs
- User preferences expressed during work
- Architecture decisions with rationale
- Bugs that were hard to diagnose
- File locations that took effort to find
- Build/test quirks

## When NOT to Use

- Temporary task context (use CURRENT.md)
- Task tracking (use PLAN.md)
- Session notes (use CURRENT.md Notes section)
