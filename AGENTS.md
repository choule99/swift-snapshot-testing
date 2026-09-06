# Project Agent Guide

## Scope

These instructions apply to the entire repository.

## Working Rules

- Ask before writing code when intent, architecture, or requirements are unclear. Never make silent assumptions.
- Implement the simplest solution that works. Do not add unrequested abstractions or flexibility.
- Prefer type-safe constructs that the Swift compiler can check.
- Touch only files and functions directly required by the task.
- State technical uncertainty before proceeding.
- Break large work into small, granular tasks.
- Delete temporary files created under `/tmp` or `/private/tmp` before finishing.

## Project Layout

- `Package.swift`: Swift 6.3 package manifest and supported platforms.
- `Sources/`: library targets.
- `Tests/`: test targets, fixtures, and reference snapshots.
- `Makefile`: canonical setup, lint, format, and test commands.
- `.swiftformat` and `.swiftlint.yml`: repository style rules.

Keep source changes in the owning target and tests in the matching test target. Reuse existing helpers and patterns before adding new ones.

## Commands

```sh
make setup       # Install Homebrew and Mint dependencies
make lint        # Run SwiftLint
make format      # Run SwiftFormat and SwiftLint fixes
make test-swift  # Run the Swift package tests
make test-all    # Run Swift, Apple-platform, and Linux suites
```

Use the smallest relevant test command while iterating. Run broader platform coverage when a change affects platform-specific rendering or conditional compilation. `make test-ios`, `make test-macos`, `make test-tvos`, `make test-watchos`, and `make test-linux` are available for targeted coverage.

## Snapshot Tests

- Missing snapshots are recorded and the first test run fails; rerun to compare against the new reference.
- Treat changes under `Tests/**/__Snapshots__` and `Tests/**/__Fixtures__` as intentional test output. Review them alongside the code that caused them.
- Do not update reference snapshots merely to make a failure pass.
- Image snapshots can vary by OS and renderer. Compare them using the same platform and OS version used to create the reference.

## Before Finishing

- Run tests that cover the changed behavior.
- Run `make lint` for Swift changes.
- Review `git diff` and remove unrelated edits, generated artifacts, and temporary files.
- Report commands run and any checks that could not be completed.
