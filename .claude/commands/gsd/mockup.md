---
name: gsd:mockup
description: Create HTML mockup for a phase — visual validation before code
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - AskUserQuestion
  - mcp__playwright__browser_navigate
  - mcp__playwright__browser_snapshot
  - mcp__playwright__browser_take_screenshot
---

<objective>
Create lightweight HTML mockups for visual validation before implementation.
Requires `quality.mockups: true`.

Quick visual checkpoint — not production code, just enough to confirm layout and flow.
</objective>

<execution_context>
@/Users/siraj/.claude/get-shit-done/workflows/create-mockup.md
</execution_context>

<process>
**Follow the mockup workflow** from `@/Users/siraj/.claude/get-shit-done/workflows/create-mockup.md`.

Usage:
- `/gsd:mockup {phase}` — Create mockup for a phase
- `/gsd:mockup {phase} --screen {name}` — Create specific screen
</process>
