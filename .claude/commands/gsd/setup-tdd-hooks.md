---
name: gsd:setup-tdd-hooks
description: Install TDD enforcement hooks (only for tdd_mode full)
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - AskUserQuestion
---

<objective>
Install TDD Guard hooks that block implementation writes when tests are failing.
Only applicable when `quality.tdd_mode` is `"full"`.
Routes to the setup-tdd-hooks workflow.
</objective>

<execution_context>
@/Users/siraj/.claude/get-shit-done/workflows/setup-tdd-hooks.md
</execution_context>

<process>
**Follow the setup-tdd-hooks workflow** from `@/Users/siraj/.claude/get-shit-done/workflows/setup-tdd-hooks.md`.

**Prerequisites:**
- Node.js project with `package.json`
- `quality.tdd_mode` set to `"full"` in `.planning/config.json`
- Vitest (will be installed if missing)
</process>
