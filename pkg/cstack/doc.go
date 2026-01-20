// Package cstack provides utilities for reading and writing cortical stack markdown files
// used for AI agent state and memory persistence.
//
// The package handles four types of markdown files stored in the .cstack directory:
//
//   - CURRENT.md: Contains the agent's current task, focus, and next steps
//   - PLAN.md: Contains a task list with checkboxes and notes
//   - INBOX.md: Contains messages received from the manager or other agents
//   - OUTBOX.md: Contains messages to be sent to the manager
//
// Example usage:
//
//	// Read current state
//	state, err := cstack.ParseCurrent("/path/to/workspace")
//	if err != nil {
//	    log.Fatal(err)
//	}
//	fmt.Println("Current task:", state.Task)
//
//	// Read plan
//	plan, err := cstack.ParsePlan("/path/to/workspace")
//	if err != nil {
//	    log.Fatal(err)
//	}
//	for _, task := range plan.Tasks {
//	    fmt.Printf("- [%s] %s\n", task.Status, task.Description)
//	}
//
//	// Write to inbox
//	msg := cstack.Message{
//	    From:      "manager",
//	    Type:      "directive",
//	    Content:   "Please implement feature X",
//	    Timestamp: time.Now(),
//	}
//	if err := cstack.WriteInbox("/path/to/workspace", msg); err != nil {
//	    log.Fatal(err)
//	}
//
//	// Read outbox
//	messages, err := cstack.ReadOutbox("/path/to/workspace")
//	if err != nil {
//	    log.Fatal(err)
//	}
//	for _, msg := range messages {
//	    fmt.Printf("[%s] %s: %s\n", msg.Type, msg.From, msg.Content)
//	}
//
// All functions gracefully handle missing files by returning empty states rather than errors.
//
// This package is designed to be project-agnostic and can be used with any AI CLI tool
// or orchestration system, not just Protectorate.
package cstack
