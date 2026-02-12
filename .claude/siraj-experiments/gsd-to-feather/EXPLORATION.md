# GSD to Feather Integration

> **Question:** What are the best ideas from GSD that should come into Feather?
> **Status:** Research Complete
> **Started:** 2026-02-10
> **Last Updated:** 2026-02-10

---

## Context

GSD (Get Shit Done) is a context engineering system for project-scale AI work — 11 specialized subagents, milestone/phase/plan/task hierarchy, wave-based parallel execution. Feather is a quality enforcement system for feature-level work — TDD enforcement, spec traceability, feedback tracking. This exploration asked: should they merge, and how?

---

## Log

### Complementary Analysis

Mapped where each framework is stronger. Key finding: **GSD = infrastructure, Feather = quality control — they operate at different altitudes and don't compete.** GSD is clearly stronger at research (4 parallel researchers with Context7), goal-backward planning, parallel execution, stub detection, context budget tracking, and cross-phase integration. Feather plugs 12 concrete gaps: TDD enforcement, coverage gates, read-only test contracts, EARS specs, Gherkin derivation, end-to-end traceability, structured feedback, full-stack test strategy, two-stage review, design exploration, polish queue, and UI mockups.

### Integration Plan

Designed a 10-phase plan to bring Feather's quality layer into a GSD fork (`feather-gsd`). Key design decisions: artifacts live in GSD's `.planning/phases/` structure (not Feather's `docs/specs/`), `.feedback/` at project root, all quality features default to off (additive config), TDD as three tiers (off/basic/full), Gherkin review always a gate (non-negotiable test contract).

Mapped 14 modified files and 25 new files across phases: config foundation, settings UI, EARS specs, Gherkin derivation, TDD hooks, two-stage review, structured feedback, design exploration, coverage gates, and UI mockups.

### Execution Context

Documented fork paths, critical file references, and per-phase reading lists. The GSD fork lives at `/Users/siraj/Desktop/NonDropBoxProjects/feather-gsd/`. Feather skills at `~/.claude/skills/` are the source material — each maps to a specific GSD structure (agents, workflows, references, templates).

---

## Findings

1. **Different altitudes, not competing.** GSD orchestrates the project lifecycle (what to build, in what order, with what agents). Feather enforces quality at the implementation level (how to build it correctly). They compose naturally — Feather's quality layer slots into GSD's executor/verifier/planner.

2. **Config-gated integration.** All Feather features default to off. Existing GSD users see zero behavioral change. Quality enforcement is opt-in per project, per feature.

3. **Three TDD tiers bridge the gap.** `off` (GSD default), `basic` (prompt-based RED-GREEN), `full` (hook-based enforcement with coverage gates). This respects GSD's "vibes to enterprise" philosophy.

---

## Artifacts

Original research documents preserved verbatim in `artifacts/` — needed for execution:

| File | Content |
|------|---------|
| `feather-gsd-comparison.md` | Complementary analysis showing 12 gaps Feather plugs |
| `feather-gsd-integration-plan.md` | 10-phase implementation plan with all file mappings |
| `feather-gsd-execution-context.md` | Fork paths, critical file refs, per-phase reading lists |

---

## Next Steps

Execute the 10-phase integration plan in the feather-gsd fork. Phase 1 (config foundation) is the prerequisite for everything else.
