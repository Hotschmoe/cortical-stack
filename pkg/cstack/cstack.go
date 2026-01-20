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

// Message represents a message in INBOX.md or OUTBOX.md.
type Message struct {
	ID        string
	From      string
	To        string
	Thread    string
	Type      string
	Content   string
	Timestamp time.Time
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

// WriteInbox appends a message to INBOX.md.
func WriteInbox(workspacePath string, msg Message) error {
	dirPath := filepath.Join(workspacePath, StackDir)
	filePath := filepath.Join(dirPath, "INBOX.md")

	if err := os.MkdirAll(dirPath, 0755); err != nil {
		return fmt.Errorf("failed to create %s directory: %w", StackDir, err)
	}

	file, err := os.OpenFile(filePath, os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0644)
	if err != nil {
		return fmt.Errorf("failed to open INBOX.md: %w", err)
	}
	defer file.Close()

	timestamp := msg.Timestamp
	if timestamp.IsZero() {
		timestamp = time.Now()
	}

	messageText := formatMessage(msg, timestamp)

	if _, err := file.WriteString(messageText); err != nil {
		return fmt.Errorf("failed to write to INBOX.md: %w", err)
	}

	return nil
}

// WriteOutbox appends a message to OUTBOX.md.
func WriteOutbox(workspacePath string, msg Message) error {
	dirPath := filepath.Join(workspacePath, StackDir)
	filePath := filepath.Join(dirPath, "OUTBOX.md")

	if err := os.MkdirAll(dirPath, 0755); err != nil {
		return fmt.Errorf("failed to create %s directory: %w", StackDir, err)
	}

	file, err := os.OpenFile(filePath, os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0644)
	if err != nil {
		return fmt.Errorf("failed to open OUTBOX.md: %w", err)
	}
	defer file.Close()

	timestamp := msg.Timestamp
	if timestamp.IsZero() {
		timestamp = time.Now()
	}

	messageText := formatMessage(msg, timestamp)

	if _, err := file.WriteString(messageText); err != nil {
		return fmt.Errorf("failed to write to OUTBOX.md: %w", err)
	}

	return nil
}

func formatMessage(msg Message, timestamp time.Time) string {
	var sb strings.Builder
	sb.WriteString("---\n")

	if msg.ID != "" {
		sb.WriteString(fmt.Sprintf("ID: %s\n", msg.ID))
	}
	sb.WriteString(fmt.Sprintf("From: %s\n", msg.From))
	if msg.To != "" {
		sb.WriteString(fmt.Sprintf("To: %s\n", msg.To))
	}
	if msg.Thread != "" {
		sb.WriteString(fmt.Sprintf("Thread: %s\n", msg.Thread))
	}
	sb.WriteString(fmt.Sprintf("Type: %s\n", msg.Type))
	sb.WriteString(fmt.Sprintf("Time: %s\n", timestamp.Format(time.RFC3339)))
	sb.WriteString("---\n")
	sb.WriteString(msg.Content)
	sb.WriteString("\n\n")

	return sb.String()
}

// ReadOutbox reads all messages from OUTBOX.md.
func ReadOutbox(workspacePath string) ([]Message, error) {
	return readMessages(filepath.Join(workspacePath, StackDir, "OUTBOX.md"))
}

// ReadInbox reads all messages from INBOX.md.
func ReadInbox(workspacePath string) ([]Message, error) {
	return readMessages(filepath.Join(workspacePath, StackDir, "INBOX.md"))
}

func readMessages(filePath string) ([]Message, error) {
	file, err := os.Open(filePath)
	if err != nil {
		if os.IsNotExist(err) {
			return []Message{}, nil
		}
		return nil, fmt.Errorf("failed to open %s: %w", filepath.Base(filePath), err)
	}
	defer file.Close()

	var messages []Message
	var currentMsg *Message
	var inHeader bool
	var contentLines []string

	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		line := scanner.Text()

		if line == "---" {
			if !inHeader && currentMsg == nil {
				currentMsg = &Message{}
				inHeader = true
			} else if inHeader {
				inHeader = false
			} else {
				contentLines = append(contentLines, line)
			}
			continue
		}

		if inHeader && currentMsg != nil {
			parseHeaderField(currentMsg, line)
		} else if currentMsg != nil && !inHeader {
			if strings.TrimSpace(line) == "" && len(contentLines) > 0 {
				currentMsg.Content = strings.TrimSpace(strings.Join(contentLines, "\n"))
				messages = append(messages, *currentMsg)
				currentMsg = nil
				contentLines = []string{}
			} else if strings.TrimSpace(line) != "" {
				contentLines = append(contentLines, line)
			}
		}
	}

	if currentMsg != nil && len(contentLines) > 0 {
		currentMsg.Content = strings.TrimSpace(strings.Join(contentLines, "\n"))
		messages = append(messages, *currentMsg)
	}

	if err := scanner.Err(); err != nil {
		return nil, fmt.Errorf("error reading %s: %w", filepath.Base(filePath), err)
	}

	return messages, nil
}

func parseHeaderField(msg *Message, line string) {
	parts := strings.SplitN(line, ": ", 2)
	if len(parts) != 2 {
		return
	}

	key := strings.TrimSpace(parts[0])
	value := strings.TrimSpace(parts[1])

	switch key {
	case "ID":
		msg.ID = value
	case "From":
		msg.From = value
	case "To":
		msg.To = value
	case "Thread":
		msg.Thread = value
	case "Type":
		msg.Type = value
	case "Time":
		if t, err := time.Parse(time.RFC3339, value); err == nil {
			msg.Timestamp = t
		}
	}
}

// ClearOutbox clears the contents of OUTBOX.md.
func ClearOutbox(workspacePath string) error {
	filePath := filepath.Join(workspacePath, StackDir, "OUTBOX.md")

	if _, err := os.Stat(filePath); os.IsNotExist(err) {
		return nil
	}

	if err := os.Truncate(filePath, 0); err != nil {
		return fmt.Errorf("failed to clear OUTBOX.md: %w", err)
	}

	return nil
}

// InitStack creates the .cstack directory and template files.
func InitStack(workspacePath string) error {
	dirPath := filepath.Join(workspacePath, StackDir)

	if err := os.MkdirAll(dirPath, 0755); err != nil {
		return fmt.Errorf("failed to create %s directory: %w", StackDir, err)
	}

	templates := map[string]string{
		"CURRENT.md": currentTemplate,
		"PLAN.md":    planTemplate,
		"INBOX.md":   inboxTemplate,
		"OUTBOX.md":  outboxTemplate,
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

const currentTemplate = `# Current State

## Current Task
(No active task)

## Focus
(Awaiting initial directive)

## Next Steps
- Await directive from manager
`

const planTemplate = `# Plan

## Tasks
(No tasks yet)

## Notes
(No notes)
`

const inboxTemplate = `# Inbox
`

const outboxTemplate = `# Outbox
`
