---
name: gsd:feedback
description: Manage structured feedback (list/add/resolve/dashboard)
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - AskUserQuestion
---

<objective>
Manage structured feedback items in `.feedback/` directory.
Requires `quality.feedback: true`.

Subcommands:
- `/gsd:feedback` or `/gsd:feedback list` — Show dashboard
- `/gsd:feedback add` — Create new feedback item interactively
- `/gsd:feedback resolve {ID}` — Mark item as resolved
- `/gsd:feedback dashboard` — Regenerate INDEX.md from files
</objective>

<execution_context>
@/Users/siraj/.claude/get-shit-done/workflows/feedback.md
@/Users/siraj/.claude/get-shit-done/templates/feedback-item.md
@/Users/siraj/.claude/get-shit-done/templates/feedback-index.md
</execution_context>

<process>
**Follow the feedback workflow** from `@/Users/siraj/.claude/get-shit-done/workflows/feedback.md`.
</process>
