---
name: gsd:polish
description: Work through polish queue with TDD (no spec/gherkin ceremony)
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - AskUserQuestion
  - Task
---

<objective>
Work through feedback items (bugs, UX tweaks) using TDD but without the full spec/gherkin ceremony. Each item gets RED-GREEN treatment.

Requires `quality.feedback: true` and items in `.feedback/open/`.
</objective>

<execution_context>
@/Users/siraj/.claude/get-shit-done/workflows/polish.md
@/Users/siraj/.claude/get-shit-done/references/quality-enforcement.md
</execution_context>

<process>
**Follow the polish workflow** from `@/Users/siraj/.claude/get-shit-done/workflows/polish.md`.

Usage:
- `/gsd:polish` — Work through highest priority items
- `/gsd:polish {ID}` — Work on specific item
</process>
