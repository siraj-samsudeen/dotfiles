---
name: gsd:setup-quality
description: Configure quality enforcement features (TDD, specs, review, feedback)
allowed-tools:
  - Read
  - Write
  - Bash
  - AskUserQuestion
---

<objective>
Interactive configuration of quality enforcement features via preset or custom selection.
Routes to the setup-quality workflow.
</objective>

<execution_context>
@/Users/siraj/.claude/get-shit-done/workflows/setup-quality.md
</execution_context>

<process>
**Follow the setup-quality workflow** from `@/Users/siraj/.claude/get-shit-done/workflows/setup-quality.md`.

Supports arguments:
- `/gsd:setup-quality` — Interactive preset selection
- `/gsd:setup-quality --minimal` — Enable minimal preset directly
- `/gsd:setup-quality --standard` — Enable standard preset directly
- `/gsd:setup-quality --full` — Enable all quality features directly
- `/gsd:setup-quality --off` — Disable all quality features
</process>
