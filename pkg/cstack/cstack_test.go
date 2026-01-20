package cstack

import (
	"os"
	"path/filepath"
	"testing"
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

func TestInitStack(t *testing.T) {
	tmpDir := t.TempDir()

	err := InitStack(tmpDir)
	if err != nil {
		t.Fatalf("InitStack() error = %v", err)
	}

	files := []string{"CURRENT.md", "PLAN.md", "QUICKREF.md"}
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
