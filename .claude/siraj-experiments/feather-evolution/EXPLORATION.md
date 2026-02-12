# Feather Workflow Evolution

> **Question:** How should a lightweight TDD workflow for Claude Code be designed?
> **Status:** Complete
> **Started:** 2025-02-04
> **Last Updated:** 2026-02-11

---

## Context

After finding that Superpowers' skills described TDD philosophy but couldn't enforce it (see `superpowers-to-feather/`), this exploration traced the path from research to design to distribution of a replacement: Feather. Three distinct phases, each building on the last.

---

## Log

### 2025-02-04 — TDD Ralph Research

Synthesized 5 sources to understand the state of the art in Claude Code workflows: Anthropic's "Effective Harnesses for Long-Running Agents" (dual-agent architecture, `claude-progress.txt`), Geoffrey Huntley's Ralph loop (one task per iteration, `prd.json`), Huntley's stdlib (composable rules), Huntley's /specs (specification domains, loopback prompt), and GSD (multi-agent orchestration, `STATE.md`, pause/resume).

Identified 12 gaps in my existing skills: no session initializer, no progress file standard, no one-slice-per-session flow, no resume/pause skills, no machine-readable status, no rules folder, no auto-commit on RED→GREEN, no loopback prompt, no plan checker, no fresh context per task, and `debug-issue` needed attribution cleanup.

Proposed architecture: "TDD Ralph with Vertical Slices" — vague request → ordered slices → one slice per session with strict TDD (RED→GREEN, not just run-tests-after). Key insight: **executable enforcement (hooks that block tools) beats philosophical enforcement (instructions the agent ignores)**.

### ~2025-02-05 — Feather Skill Design

Named the workflow "Feather" — lightweight artifacts, quick iteration, not heavyweight ceremonies. Designed 7 skills: `slice-project` (vague idea → ordered slices), `add-slice`, `work-slice` (TDD execution for ONE slice then STOP), `pause-slice` (mid-TDD handoff with cycle position), `resume-slice` (context restoration with recovery mode), `note-issue` (capture bugs to polish queue), `polish` (TDD without spec/gherkin ceremony).

Key decisions: `.slices/` folder for state, both JSON + markdown (machine-readable for routing, human-readable for context), reuse existing skills (`create-spec`, `derive-tests`, `verify-feature`), show-first-refine-later (generate slices, let user critique), slices always editable. DHH-style full-stack tests by default (UI → database), unit tests only for edge cases.

### 2026-02-11 — Standalone Distribution

Packaged Feather as `feather-flow` — a standalone GitHub repo with `curl | bash` installer. Zero dependencies, pure markdown, one command install. Key lesson: `additionalDirectories` controls file access scope, NOT skill scanning — skills must be in `~/.claude/skills/` to be discovered. Solved with symlinks from `~/.claude/skills/feather:*` → `~/.claude/feather-flow/skills/feather:*`.

Published to https://github.com/siraj-samsudeen/feather-flow. Audit found 27 stale cross-references across 11 files before v1.0.

---

## Findings

The evolution produced three key insights:

1. **Executable > philosophical enforcement.** Superpowers said "evidence before claims" but the agent circumvented with words. TDD guard hooks literally block Edit/Write tools — can't circumvent. This is the core Feather differentiator.

2. **One slice per session prevents context rot.** Both Anthropic and GSD research converge on this. Context quality degrades as the 200k window fills. Fresh context per task = consistent quality.

3. **Distribution requires understanding Claude Code's discovery mechanism.** Skills must be in `~/.claude/skills/` — not just accessible via `additionalDirectories`. Symlinks bridge the gap cleanly.

---

## Artifacts

Original research and design documents preserved verbatim in `artifacts/`:

| File | Source | Content |
|------|--------|---------|
| `tdd-ralph-exploration.md` | `tdd-ralph-vertical-slices/EXPLORATION.md` | 5-source research, gap analysis, proposed architecture |
| `tdd-ralph-handoff.md` | `tdd-ralph-vertical-slices/HANDOFF.md` | Session handoff with design decisions and resume instructions |
| `feather-skill-plan.md` | `feather-slice/PLAN.md` | 7 skill designs, file structures, verification plan |
| `feather-flow-exploration.md` | `feather-flow-standalone/EXPLORATION.md` | Distribution solution, symlink discovery, publishing |

---

## Next Steps

None — Feather is designed, built, and published. Active development continues in https://github.com/siraj-samsudeen/feather-flow.
