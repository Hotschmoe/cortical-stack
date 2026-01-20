// Package cstack provides utilities for reading and writing cortical stack markdown files
// used for AI agent state and memory persistence.
//
// The package handles markdown files stored in the .cstack directory:
//
//   - CURRENT.md: Contains the agent's current task, focus, and next steps
//   - PLAN.md: Contains a task list with checkboxes and notes
//   - QUICKREF.md: Quick reference for commands and workflow
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
//	// Initialize a new stack
//	if err := cstack.InitStack("/path/to/workspace"); err != nil {
//	    log.Fatal(err)
//	}
//
// All functions gracefully handle missing files by returning empty states rather than errors.
//
// This package is designed to be project-agnostic and can be used with any AI CLI tool
// or orchestration system.
package cstack
