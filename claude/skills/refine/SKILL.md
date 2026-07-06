---
name: refine
description: Refine code to conform to project guidelines from AGENTS.md, PYTHON.md, TYPESCRIPT.md, and relevant skills. Use proactively after implementing substantial changes (new files, new features, multi-file edits) and when the user asks to refine or clean up code.
---

# Refine

Refactor changed code so it follows the project's own guidelines. Make the fixes directly — don't just report them.

## Workflow

### 1. Determine scope

Default to files edited in this conversation. Only widen scope (branch diff, specific files) if the user explicitly asks.

### 2. Collect applicable guidelines

Read the root `AGENTS.md`, the language guide (`PYTHON.md` or `TYPESCRIPT.md`), and the `AGENTS.md` in the subdirectory being edited.

Then discover which **skills** are relevant by scanning the changed code for imports, libraries, and patterns that match skill descriptions in the system prompt. Read each matching skill's `SKILL.md` — the conventions are in there.

### 3. Read, compare, and fix

For each changed file: read it, compare against the collected guidelines and skill conventions, and fix violations directly.

### 4. Verify

Run the relevant checks (typecheck, lints, tests for affected files). Fix any regressions introduced by the refactoring.

### 5. Summarize

Brief summary of what was changed and why. The diff speaks for itself.
