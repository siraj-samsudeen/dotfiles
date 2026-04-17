---
name: single-current-state-doc-in-docs
description: Exactly ONE current-state doc per project, always under docs/ (never in subproject folders or repo root)
type: feedback
originSessionId: 51a3cead-7211-41cb-9b24-ac2a74a5d17e
---
A project must have **exactly one** "current state" document, and it must live under `docs/` — never in subproject folders like `instantdb-app/CURRENT-STATE.md`, never at repo root, never duplicated.

**Why:** Teacher hit this 2026-04-14 when two files — `docs/current_state.md` (a completed scoring-v3 migration task log) and `instantdb-app/CURRENT-STATE.md` (the InstantDB prototype living state) — collided in meaning. A future session picking up work has no way to know which one describes the canonical present. Even when the two files cover different subsystems, the shared name creates ambiguity that costs time every time someone (human or agent) onboards.

**How to apply:**
- Never create a new `CURRENT-STATE.md` / `current_state.md` outside `docs/`. If a subproject needs its own living state doc, rename it to describe its scope (e.g. `docs/instantdb-app-state.md`) and put it under `docs/`.
- When an in-flight task log or migration scratchpad has served its purpose, archive it under `docs/migrations/<task-name>.md` — not `current_state.md`. Example from this repo: `docs/current_state.md` → `docs/migrations/scoring-v3-phase-2.md` (commit `7cb8a15e`).
- If you encounter a current-state doc outside `docs/` in any project, flag it and propose consolidation before starting other work.
- This rule also applies to near-synonyms: `STATE.md`, `status.md`, `NOW.md`, etc. — if it's describing "what's the current state," it belongs in `docs/` under a single canonical name.
