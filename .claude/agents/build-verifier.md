---
name: build-verifier
description: Comprehensive build validation for Go package
model: sonnet
tools:
  - Bash
  - Read
---

Validates that the cstack package builds and passes tests.

## Trigger

Use this agent when:
- Preparing to merge a PR
- After significant refactoring
- Before releases
- When parser logic changes

## Workflow

1. **Build Go package** - verify compilation
2. **Run Go tests** - with race detection
3. **Check coverage** - optionally report coverage
4. **Report results** - build success/failure, test summary

## Output Format

```
BUILD VERIFICATION REPORT
=========================
GO BUILD:
---------
./...         PASS (0.5s)

GO TESTS:
---------
./...         PASS (1.2s, 12 tests)

COVERAGE:
---------
pkg/cstack    85.2%

RESULT: ALL CHECKS PASS
```

## Failure Handling

If a component fails:
1. Report the specific error
2. Include relevant compiler/test output
3. Suggest potential fixes

## Commands

```bash
# Build Go package
go build ./...

# Run tests with race detection
go test -race ./...

# Run tests with coverage
go test -race -coverprofile=coverage.out ./...
go tool cover -func=coverage.out

# Vet code
go vet ./...
```
