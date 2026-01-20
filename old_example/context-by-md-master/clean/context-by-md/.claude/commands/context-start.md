# Context Start

Read context and show task list.

## Steps

1. **Read CURRENT.md** - Check active task, next steps
2. **Read PLAN.md** - Get task list

## Output

Show status summary:
```
Active: [task name] - [current subtask]
   or: No active task

Tasks:
1. [P1] Task name | context
2. [P2] Another task | context
...

What would you like to work on?
```

If there's an active task, ask if user wants to continue or switch.
