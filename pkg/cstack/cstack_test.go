package cstack

import (
	"os"
	"path/filepath"
	"strings"
	"testing"
	"time"
)

func TestParseCurrent(t *testing.T) {
	tests := []struct {
		name      string
		content   string
		want      *CurrentState
		wantErr   bool
		fileError bool
	}{
		{
			name: "complete CURRENT.md",
			content: `## Current Task
Implement authentication service

## Focus
Building JWT middleware and user session management

## Next Steps
- Write unit tests
- Add integration tests
- Update documentation
`,
			want: &CurrentState{
				Task:      "Implement authentication service",
				Focus:     "Building JWT middleware and user session management",
				NextSteps: []string{"Write unit tests", "Add integration tests", "Update documentation"},
			},
		},
		{
			name: "partial CURRENT.md",
			content: `## Current Task
Fix bug in API handler

## Next Steps
- Debug issue
- Deploy fix
`,
			want: &CurrentState{
				Task:      "Fix bug in API handler",
				NextSteps: []string{"Debug issue", "Deploy fix"},
			},
		},
		{
			name:      "missing file",
			fileError: true,
			want: &CurrentState{
				NextSteps: []string{},
			},
		},
		{
			name:    "empty file",
			content: "",
			want: &CurrentState{
				NextSteps: []string{},
			},
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			tmpDir := t.TempDir()

			if !tt.fileError {
				contextDir := filepath.Join(tmpDir, StackDir)
				if err := os.MkdirAll(contextDir, 0755); err != nil {
					t.Fatalf("failed to create test directory: %v", err)
				}

				filePath := filepath.Join(contextDir, "CURRENT.md")
				if err := os.WriteFile(filePath, []byte(tt.content), 0644); err != nil {
					t.Fatalf("failed to write test file: %v", err)
				}
			}

			got, err := ParseCurrent(tmpDir)
			if (err != nil) != tt.wantErr {
				t.Errorf("ParseCurrent() error = %v, wantErr %v", err, tt.wantErr)
				return
			}

			if got.Task != tt.want.Task {
				t.Errorf("ParseCurrent() Task = %v, want %v", got.Task, tt.want.Task)
			}

			if got.Focus != tt.want.Focus {
				t.Errorf("ParseCurrent() Focus = %v, want %v", got.Focus, tt.want.Focus)
			}

			if len(got.NextSteps) != len(tt.want.NextSteps) {
				t.Errorf("ParseCurrent() NextSteps length = %v, want %v", len(got.NextSteps), len(tt.want.NextSteps))
			} else {
				for i, step := range got.NextSteps {
					if step != tt.want.NextSteps[i] {
						t.Errorf("ParseCurrent() NextSteps[%d] = %v, want %v", i, step, tt.want.NextSteps[i])
					}
				}
			}
		})
	}
}

func TestParsePlan(t *testing.T) {
	tests := []struct {
		name      string
		content   string
		want      *PlanState
		wantErr   bool
		fileError bool
	}{
		{
			name: "complete PLAN.md with all statuses",
			content: `## Tasks
- [ ] Pending task
- [>] In progress task
- [x] Completed task
- [!] Blocked task

## Notes
Additional context about the plan.
`,
			want: &PlanState{
				Tasks: []Task{
					{Description: "Pending task", Status: "pending"},
					{Description: "In progress task", Status: "in_progress"},
					{Description: "Completed task", Status: "completed"},
					{Description: "Blocked task", Status: "blocked"},
				},
				Notes: "## Notes\nAdditional context about the plan.",
			},
		},
		{
			name: "tasks only",
			content: `## Tasks
- [ ] Task 1
- [ ] Task 2
`,
			want: &PlanState{
				Tasks: []Task{
					{Description: "Task 1", Status: "pending"},
					{Description: "Task 2", Status: "pending"},
				},
			},
		},
		{
			name:      "missing file",
			fileError: true,
			want: &PlanState{
				Tasks: []Task{},
			},
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			tmpDir := t.TempDir()

			if !tt.fileError {
				contextDir := filepath.Join(tmpDir, StackDir)
				if err := os.MkdirAll(contextDir, 0755); err != nil {
					t.Fatalf("failed to create test directory: %v", err)
				}

				filePath := filepath.Join(contextDir, "PLAN.md")
				if err := os.WriteFile(filePath, []byte(tt.content), 0644); err != nil {
					t.Fatalf("failed to write test file: %v", err)
				}
			}

			got, err := ParsePlan(tmpDir)
			if (err != nil) != tt.wantErr {
				t.Errorf("ParsePlan() error = %v, wantErr %v", err, tt.wantErr)
				return
			}

			if len(got.Tasks) != len(tt.want.Tasks) {
				t.Errorf("ParsePlan() Tasks length = %v, want %v", len(got.Tasks), len(tt.want.Tasks))
			} else {
				for i, task := range got.Tasks {
					if task.Description != tt.want.Tasks[i].Description {
						t.Errorf("ParsePlan() Tasks[%d].Description = %v, want %v", i, task.Description, tt.want.Tasks[i].Description)
					}
					if task.Status != tt.want.Tasks[i].Status {
						t.Errorf("ParsePlan() Tasks[%d].Status = %v, want %v", i, task.Status, tt.want.Tasks[i].Status)
					}
				}
			}
		})
	}
}

func TestWriteInbox(t *testing.T) {
	tests := []struct {
		name    string
		msg     Message
		wantErr bool
	}{
		{
			name: "write message with all fields",
			msg: Message{
				ID:        "msg-abc123",
				From:      "manager",
				To:        "agent-alice",
				Thread:    "thread-001",
				Type:      "directive",
				Content:   "Please implement feature X",
				Timestamp: time.Date(2026, 1, 19, 10, 0, 0, 0, time.UTC),
			},
			wantErr: false,
		},
		{
			name: "write message without timestamp",
			msg: Message{
				From:    "agent-1",
				Type:    "milestone",
				Content: "Task completed",
			},
			wantErr: false,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			tmpDir := t.TempDir()

			err := WriteInbox(tmpDir, tt.msg)
			if (err != nil) != tt.wantErr {
				t.Errorf("WriteInbox() error = %v, wantErr %v", err, tt.wantErr)
				return
			}

			if !tt.wantErr {
				filePath := filepath.Join(tmpDir, StackDir, "INBOX.md")
				if _, err := os.Stat(filePath); os.IsNotExist(err) {
					t.Errorf("WriteInbox() did not create INBOX.md")
				}

				content, err := os.ReadFile(filePath)
				if err != nil {
					t.Fatalf("failed to read INBOX.md: %v", err)
				}

				contentStr := string(content)
				if tt.msg.From != "" && !strings.Contains(contentStr, "From: "+tt.msg.From) {
					t.Errorf("WriteInbox() content missing From field")
				}
				if tt.msg.Type != "" && !strings.Contains(contentStr, "Type: "+tt.msg.Type) {
					t.Errorf("WriteInbox() content missing Type field")
				}
				if !strings.Contains(contentStr, tt.msg.Content) {
					t.Errorf("WriteInbox() content missing message content")
				}
			}
		})
	}
}

func TestReadOutbox(t *testing.T) {
	tests := []struct {
		name      string
		content   string
		wantCount int
		wantErr   bool
		fileError bool
	}{
		{
			name: "single message",
			content: `---
ID: msg-001
From: agent-1
Type: milestone
Time: 2026-01-19T10:00:00Z
---
Task completed successfully

`,
			wantCount: 1,
		},
		{
			name: "multiple messages",
			content: `---
From: agent-1
Type: milestone
Time: 2026-01-19T10:00:00Z
---
First message

---
From: agent-2
Type: question
Time: 2026-01-19T11:00:00Z
---
Second message

`,
			wantCount: 2,
		},
		{
			name:      "missing file",
			fileError: true,
			wantCount: 0,
		},
		{
			name:      "empty file",
			content:   "",
			wantCount: 0,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			tmpDir := t.TempDir()

			if !tt.fileError {
				contextDir := filepath.Join(tmpDir, StackDir)
				if err := os.MkdirAll(contextDir, 0755); err != nil {
					t.Fatalf("failed to create test directory: %v", err)
				}

				filePath := filepath.Join(contextDir, "OUTBOX.md")
				if err := os.WriteFile(filePath, []byte(tt.content), 0644); err != nil {
					t.Fatalf("failed to write test file: %v", err)
				}
			}

			got, err := ReadOutbox(tmpDir)
			if (err != nil) != tt.wantErr {
				t.Errorf("ReadOutbox() error = %v, wantErr %v", err, tt.wantErr)
				return
			}

			if len(got) != tt.wantCount {
				t.Errorf("ReadOutbox() returned %d messages, want %d", len(got), tt.wantCount)
			}

			for i, msg := range got {
				if msg.From == "" {
					t.Errorf("ReadOutbox() message[%d] missing From field", i)
				}
				if msg.Type == "" {
					t.Errorf("ReadOutbox() message[%d] missing Type field", i)
				}
				if msg.Content == "" {
					t.Errorf("ReadOutbox() message[%d] missing Content", i)
				}
			}
		})
	}
}

func TestClearOutbox(t *testing.T) {
	tests := []struct {
		name      string
		content   string
		wantErr   bool
		fileError bool
	}{
		{
			name: "clear existing file",
			content: `---
From: agent-1
Type: milestone
Time: 2026-01-19T10:00:00Z
---
Some content

`,
			wantErr: false,
		},
		{
			name:      "clear non-existent file",
			fileError: true,
			wantErr:   false,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			tmpDir := t.TempDir()

			if !tt.fileError {
				contextDir := filepath.Join(tmpDir, StackDir)
				if err := os.MkdirAll(contextDir, 0755); err != nil {
					t.Fatalf("failed to create test directory: %v", err)
				}

				filePath := filepath.Join(contextDir, "OUTBOX.md")
				if err := os.WriteFile(filePath, []byte(tt.content), 0644); err != nil {
					t.Fatalf("failed to write test file: %v", err)
				}
			}

			err := ClearOutbox(tmpDir)
			if (err != nil) != tt.wantErr {
				t.Errorf("ClearOutbox() error = %v, wantErr %v", err, tt.wantErr)
				return
			}

			if !tt.fileError {
				filePath := filepath.Join(tmpDir, StackDir, "OUTBOX.md")
				content, err := os.ReadFile(filePath)
				if err != nil {
					t.Fatalf("failed to read OUTBOX.md: %v", err)
				}

				if len(content) != 0 {
					t.Errorf("ClearOutbox() did not clear file, content length = %d", len(content))
				}
			}
		})
	}
}

func TestInitStack(t *testing.T) {
	tmpDir := t.TempDir()

	err := InitStack(tmpDir)
	if err != nil {
		t.Fatalf("InitStack() error = %v", err)
	}

	files := []string{"CURRENT.md", "PLAN.md", "INBOX.md", "OUTBOX.md"}
	for _, f := range files {
		filePath := filepath.Join(tmpDir, StackDir, f)
		if _, err := os.Stat(filePath); os.IsNotExist(err) {
			t.Errorf("InitStack() did not create %s", f)
		}
	}

	// Running again should not overwrite existing files
	testContent := "# Test"
	currentPath := filepath.Join(tmpDir, StackDir, "CURRENT.md")
	if err := os.WriteFile(currentPath, []byte(testContent), 0644); err != nil {
		t.Fatalf("failed to write test content: %v", err)
	}

	err = InitStack(tmpDir)
	if err != nil {
		t.Fatalf("InitStack() second call error = %v", err)
	}

	content, _ := os.ReadFile(currentPath)
	if string(content) != testContent {
		t.Errorf("InitStack() overwrote existing file")
	}
}
