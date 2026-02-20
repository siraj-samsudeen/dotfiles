# Feather Design v2

**Question:** How should Feather's workflow change to produce both architecture quality (GSD's strength) AND working tests (Feather's strength) — validated by empirical comparison, not theory?
**Status:** In Progress
**Started:** 2026-02-16
**Last Updated:** 2026-02-16

## Context

Reviewed two client projects built with different methodologies:

- **TalentBridge** (GSD standalone): Great architecture, zero `any`, strong auth — but ALL 6 test files fail (import modules that don't exist)
- **WinWork** (GSD+Feather): 216 tests ALL pass, 98% backend coverage — but 61 `any`, 15 auth gaps, god components, no error boundaries

**Root cause:** GSD decomposes horizontally (Phase 1: all backend → Phase 2: all frontend). Feather decomposes vertically (Slice 1: one feature end-to-end). When GSD builds the entire backend first, you can't retrofit TDD vertical slices — the backend doesn't align with slices. Past attempt at handoff was "all messed up."

**Key tensions from past experiments:**
- "The slice is too thin to launch research" — a single CRUD operation doesn't justify a research phase
- "When I give AI control to write, it just writes it all" — AI defeats TDD by generating everything at once
- "I want absolute control in the initial stages... once I have a certain amount of code and it passes certain benchmarks, I want to relax"
- "GSD's strength is when things are complex. But it burns a lot of tokens and then only I realise it has gone on the wrong track"

**Related:** `gsd-to-feather/` experiment explored integrating Feather's quality layer into GSD's codebase. This experiment takes the opposite approach — what changes should Feather itself make, validated empirically?

## Evaluation Framework: 6 Dimensions + Violation Counts

Use the same 6 dimensions from the TalentBridge/WinWork review, scored by **violation counts** (objective, no subjective /10 scores):

| Dimension | Violation Metrics |
|-----------|-------------------|
| **1. Test Quality** | Tests passing Y/N, test count, coverage %, tests with useless mocks, tests that don't verify DB state, tests testing implementation not behavior |
| **2. Code Organization** | Files >300 lines, god components (>5 responsibilities), code duplication (copy-paste patterns) |
| **3. Type Safety** | `any` count in source, `any` count in tests, untyped function params, broken type chains |
| **4. Error Handling** | Silent `catch(() => {})`, missing error boundaries, unhandled promise rejections |
| **5. Security** | Mutations missing auth checks, missing ownership validation, exposed internal IDs |
| **6. Documentation** | Missing ARCHITECTURE.md, undocumented domain model, no inline comments on complex logic |

**Two-layer review for each run:**
- **Automated** (`evaluate.sh`): Counts violations mechanically
- **Human** (Siraj + Claude): Reviews test quality specifically — are tests testing the right things? Are mocks preventing readability? Is coverage meaningful or just line-touching?

## Benchmark Design

### Project: Task Management System (dogfooding)

The system tracks its own bugs during development. Three phases:

| Phase | Features |
|-------|----------|
| **Phase 1 (Basic)** | Create, list, update, delete, complete/uncomplete, filter (all/active/completed) |
| **Phase 2 (Rich)** | Comments, projects/categories, priorities, due dates, search |
| **Phase 3 (Workflow)** | Auth + ownership, assign to users, notifications, export, bulk ops |

**Stack:** React + Vite + Convex (all runs identical)

### 5 Methodology Runs

| Run | Methodology | What It Tests |
|-----|-------------|---------------|
| **A** | GSD Alone | Baseline: horizontal decomposition, no TDD enforcement |
| **B** | GSD + tdd-guard only | Just TDD enforcement added to GSD (via `/feather:setup-tdd-guard`), nothing else from Feather |
| **C** | Feather Alone | Baseline: vertical slices, TDD, no architecture guidance |
| **D** | GSD Research → Feather Slices | Handoff (known problematic — re-running for quantitative data) |
| **E** | Feather + Bootstrap + Conventions + Progressive Trust | The proposed solution |
| **F** | Feather + Post-Slice Quality Gates (no conventions) | Reactive vs proactive — is catching after enough? |

### Execution Order

1. Runs A, B, C — need no new skills, establish baselines
2. Run D — handoff approach (needs GSD research + Feather execution)
3. Analyze results A–D — what specifically did the violations tell us?
4. Build new Feather skills (bootstrap, check-conventions, set-trust-level)
5. Runs E, F — test the enhanced approaches
6. Final comparison across all 6

## Proposed New Feather Skills

### `feather:bootstrap`
Runs ONCE at project start, BEFORE `/feather:slice-project`. Produces:
- `CONVENTIONS.md` — Auth pattern, validator pattern, error handling, file org, test structure
- Golden path slice — AUTH + TASK-CREATE under maximum scrutiny (1 test → 1 implementation)
- Executable conventions — real working code the AI references, not just rules

### `feather:check-conventions`
Post-slice automated + human check. Runs after each `/feather:work-slice`:
- **Automated:** `any` count, auth gaps, file sizes, duplication, silent catches, untyped validators
- **Human review:** Are tests testing the right things? Useless mocks? Meaningful coverage?
- Must pass before slice is marked complete

### `feather:set-trust-level`
Controls work unit granularity:
- **bootstrap:** 1 test → 1 implementation, human approves each
- **established:** 1 full slice, human reviews at boundary (gate: 3 clean slices)
- **cruise:** Multiple slices, automated checks only (gate: automated + dogfooding passes)

## Log

### 2026-02-16 — Started

- Reviewed TalentBridge (GSD) and WinWork (GSD+Feather) across 6 dimensions
- Identified root cause: horizontal vs vertical decomposition mismatch
- Designed 5-run benchmark with dogfooding task management system
- Decided: violation counts (no subjective scores), both automated + human review
- Key insight from user: test review step needed — WinWork tests pass but many don't test real behavior, mocks prevent readability
- Key insight from user: use same 6 dimensions from initial review as ranking criteria across all runs

## Findings

(Populated as runs complete)

## Next Steps

1. Write the shared Project Brief (`benchmark/PROJECT-BRIEF.md`)
2. Build the evaluation script (`benchmark/evaluate.sh`)
3. Start Run A (GSD alone) and Run B (Feather alone) — can run in parallel since independent
