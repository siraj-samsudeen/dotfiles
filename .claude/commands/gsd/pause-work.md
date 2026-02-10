---
name: gsd:pause-work
description: Create context handoff when pausing work mid-phase
allowed-tools:
  - Read
  - Write
  - Bash
  - Edit
  - AskUserQuestion
---

<objective>
Create `.continue-here.md` handoff file to preserve complete work state across sessions. Also updates `docs/DIALOGUE.md` with a permanent session record (auto-drafted, user-reviewed).

Routes to the pause-work workflow which handles:
- Current phase detection from recent files
- Complete state gathering (position, completed work, remaining work, decisions, blockers)
- Handoff file creation with all context sections
- DIALOGUE.md session entry (auto-draft + user review)
- Git commit as WIP (handoff + dialogue)
- Resume instructions
</objective>

<execution_context>
@.planning/STATE.md
@docs/DIALOGUE.md
@/Users/siraj/.claude/get-shit-done/workflows/pause-work.md
</execution_context>

<process>
**Follow the pause-work workflow** from `@/Users/siraj/.claude/get-shit-done/workflows/pause-work.md`.

The workflow handles all logic including:
1. Phase directory detection
2. State gathering with user clarifications
3. Handoff file writing with timestamp
4. DIALOGUE.md update (auto-draft + user review)
5. Git commit (handoff + dialogue)
6. Confirmation with resume instructions
</process>
