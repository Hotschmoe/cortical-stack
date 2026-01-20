package cstack

import (
	"bufio"
	"fmt"
	"os"
	"path/filepath"
	"strings"
	"time"
)

// StackDir is the directory name for cortical stack files.
const StackDir = ".cstack"

// Task represents a task with description and status.
type Task struct {
	Description string
	Status      string // pending, in_progress, completed, blocked
}

// CurrentState represents the content of CURRENT.md.
type CurrentState struct {
	Task         string
	Focus        string
	NextSteps    []string
	LastModified time.Time
}

// PlanState represents the content of PLAN.md.
type PlanState struct {
	Tasks []Task
	Notes string
}

// ParseCurrent reads and parses CURRENT.md from the workspace.
func ParseCurrent(workspacePath string) (*CurrentState, error) {
	filePath := filepath.Join(workspacePath, StackDir, "CURRENT.md")

	file, err := os.Open(filePath)
	if err != nil {
		if os.IsNotExist(err) {
			return &CurrentState{
				NextSteps:    []string{},
				LastModified: time.Now(),
			}, nil
		}
		return nil, fmt.Errorf("failed to open CURRENT.md: %w", err)
	}
	defer file.Close()

	stat, err := file.Stat()
	if err != nil {
		return nil, fmt.Errorf("failed to stat CURRENT.md: %w", err)
	}

	state := &CurrentState{
		NextSteps:    []string{},
		LastModified: stat.ModTime(),
	}

	scanner := bufio.NewScanner(file)
	var currentSection string
	var contentLines []string

	for scanner.Scan() {
		line := scanner.Text()

		if strings.HasPrefix(line, "## ") {
			if currentSection != "" {
				saveCurrentSection(state, currentSection, contentLines)
			}
			currentSection = strings.TrimPrefix(line, "## ")
			contentLines = []string{}
			continue
		}

		if currentSection != "" && strings.TrimSpace(line) != "" {
			contentLines = append(contentLines, line)
		}
	}

	if currentSection != "" {
		saveCurrentSection(state, currentSection, contentLines)
	}

	if err := scanner.Err(); err != nil {
		return nil, fmt.Errorf("error reading CURRENT.md: %w", err)
	}

	return state, nil
}

func saveCurrentSection(state *CurrentState, section string, lines []string) {
	switch section {
	case "Current Task":
		state.Task = strings.Join(lines, "\n")
	case "Focus":
		state.Focus = strings.Join(lines, "\n")
	case "Next Steps":
		for _, line := range lines {
			trimmed := strings.TrimSpace(line)
			if strings.HasPrefix(trimmed, "- ") {
				state.NextSteps = append(state.NextSteps, strings.TrimPrefix(trimmed, "- "))
			} else if strings.HasPrefix(trimmed, "* ") {
				state.NextSteps = append(state.NextSteps, strings.TrimPrefix(trimmed, "* "))
			}
		}
	}
}

// ParsePlan reads and parses PLAN.md from the workspace.
func ParsePlan(workspacePath string) (*PlanState, error) {
	filePath := filepath.Join(workspacePath, StackDir, "PLAN.md")

	file, err := os.Open(filePath)
	if err != nil {
		if os.IsNotExist(err) {
			return &PlanState{Tasks: []Task{}}, nil
		}
		return nil, fmt.Errorf("failed to open PLAN.md: %w", err)
	}
	defer file.Close()

	state := &PlanState{Tasks: []Task{}}

	scanner := bufio.NewScanner(file)
	var currentSection string
	var notesLines []string

	for scanner.Scan() {
		line := scanner.Text()

		if strings.HasPrefix(line, "## ") {
			currentSection = strings.TrimPrefix(line, "## ")
			continue
		}

		trimmed := strings.TrimSpace(line)
		if trimmed == "" {
			continue
		}

		if currentSection == "Tasks" {
			task, ok := parseTaskLine(trimmed)
			if ok {
				state.Tasks = append(state.Tasks, task)
			}
		} else {
			notesLines = append(notesLines, line)
		}
	}

	if err := scanner.Err(); err != nil {
		return nil, fmt.Errorf("error reading PLAN.md: %w", err)
	}

	state.Notes = strings.Join(notesLines, "\n")
	return state, nil
}

func parseTaskLine(line string) (Task, bool) {
	// Task format per spec:
	// - [ ] Pending task
	// - [>] In progress task
	// - [x] Completed task
	// - [!] Blocked task
	prefixes := map[string]string{
		"- [ ] ": "pending",
		"- [>] ": "in_progress",
		"- [x] ": "completed",
		"- [!] ": "blocked",
	}

	for prefix, status := range prefixes {
		if strings.HasPrefix(line, prefix) {
			return Task{
				Description: strings.TrimPrefix(line, prefix),
				Status:      status,
			}, true
		}
	}
	return Task{}, false
}

// InitStack creates the .cstack directory and template files.
func InitStack(workspacePath string) error {
	dirPath := filepath.Join(workspacePath, StackDir)

	if err := os.MkdirAll(dirPath, 0755); err != nil {
		return fmt.Errorf("failed to create %s directory: %w", StackDir, err)
	}

	templates := map[string]string{
		"CURRENT.md":  currentTemplate,
		"PLAN.md":     planTemplate,
		"QUICKREF.md": quickrefTemplate,
	}

	for filename, content := range templates {
		filePath := filepath.Join(dirPath, filename)
		if _, err := os.Stat(filePath); os.IsNotExist(err) {
			if err := os.WriteFile(filePath, []byte(content), 0644); err != nil {
				return fmt.Errorf("failed to write %s: %w", filename, err)
			}
		}
	}

	return nil
}

const currentTemplate = `# Current Context

> **Last Updated:** -- | **Active Task:** _none_

## Now

<!-- What you're working on RIGHT NOW. 1-3 items max. -->

_No active work. Ready to begin._

## Next Steps

<!-- Ordered actions. Continue from here after compaction. -->

1. _Waiting for direction_

## Active Task

<!-- Populated by /cstack-task start. Cleared by /cstack-task done. -->

**Task:** _none_ | **Status:** -- | **Started:** --

### Goal
_Not yet defined._

### Scope
**In:** _items_
**Out:** _items_

### Constraints
_None identified._

### Subtasks
- [ ] _subtask_

### Decisions
| Decision | Choice | Why | Date |
|----------|--------|-----|------|

---

## Context

<!-- Critical info that must survive compaction. Key files, decisions, blockers. -->

- Project: _describe_
- Key files: _paths_
- Blockers: _none_

## Notes

<!-- Scratch space during session. -->

_Session started._
`

const planTemplate = `# Plan

> **Updated:** --

## Legend
` + "`" + `- [ ]` + "`" + ` Pending | ` + "`" + `- [>]` + "`" + ` In Progress | ` + "`" + `- [x]` + "`" + ` Completed | ` + "`" + `- [!]` + "`" + ` Blocked
Priority: P0=Critical P1=High P2=Medium P3=Low

---

## Tasks

<!-- One line per task: - [status] P#: Title | context | next: action -->

_No tasks. Add with /cstack-task add_

---

## Notes

<!-- 2-3 lines per task that needs detail. Reference by task title. -->

_No notes yet._

---

## Backlog

<!-- Discovered bugs, tech debt, ideas. Promote to Tasks when ready. -->

### Bugs
_None._

### Debt
_None._

### Ideas
_None._
`

const quickrefTemplate = `# Quick Reference

## Commands

| Command | What it does |
|---------|--------------|
| /cstack-task | List tasks with numbers |
| /cstack-task start 1 | Start task #1 (quick) |
| /cstack-task start 1 --plan | Start task #1 with interview |
| /cstack-task add P1: X | Add new task |
| /cstack-task done | Complete active task |
| /cstack-task block 1 | Block task #1 |
| /cstack-task ready 1 | Unblock task #1 |
| /cstack-task decide | Record decision |
| /cstack-checkpoint | Save all state |

## Task Format

- [status] P#: Title | context | next: action

**Status:** - [ ] Pending | - [>] In Progress | - [x] Completed | - [!] Blocked
**Priority:** P0=Critical P1=High P2=Medium P3=Low

## Files

| File | Purpose |
|------|---------|
| CURRENT.md | Session state + active task detail |
| PLAN.md | Task list + backlog |

## Workflow

/cstack-task                  # See numbered task list
    |
/cstack-task start 1          # Start task (or --plan for interview)
    |
[work on task]                # Check off subtasks in CURRENT.md
    |
/cstack-task done             # Complete, clear active task
    |
/cstack-checkpoint            # Save state

## On Compaction

1. Run /cstack-checkpoint
2. Read CURRENT.md
3. Continue from Next Steps / current subtask
`
