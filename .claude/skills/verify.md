---
name: verify
description: Build and verify Go package
agent: build-verifier
---

# /verify - Build Verification

Build Go package and run tests.

## Usage

```
/verify [--quick] [--cover]
```

## Options

| Option | Description |
|--------|-------------|
| `--quick` | Only build, skip tests |
| `--cover` | Include coverage report |

## What It Does

1. Builds Go package (go build ./...)
2. Runs Go tests with race detection
3. Reports coverage (if --cover)
4. Reports build times and any failures

## Output Format

```
BUILD VERIFICATION REPORT
-------------------------
go build:     PASS (0.5s)
go test:      PASS (1.2s, 12 tests)
go vet:       PASS

COVERAGE (if --cover):
pkg/cstack    85.2%

RESULT: ALL CHECKS PASS
```

## When to Use

- Before merging PRs
- After significant refactors
- Before releases
- When changing parser logic

## Implementation

```bash
# Build Go package
go build ./...

# Run tests
go test -race ./...

# With coverage
go test -race -coverprofile=coverage.out ./...
go tool cover -func=coverage.out

# Vet code
go vet ./...
```

## Exit Codes

- 0: All checks pass
- 1: Build failure or test failure
