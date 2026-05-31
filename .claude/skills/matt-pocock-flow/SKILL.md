---
name: matt-pocock-flow
description: Overview and router for the Matt Pocock engineering skills installed in this setup — triage, to-issues, to-prd, diagnose, grill-me, grill-with-docs, zoom-out, improve-codebase-architecture (configured by setup-matt-pocock-skills). Use when the user asks what skills are available, which skill fits a task, "what are the matt pocock skills", or when a task clearly matches one of them and the user should be reminded it exists — a bug to diagnose, a plan/PRD to break into issues, an investigation to file, unfamiliar code to orient in, or architecture to improve. Also the reference for how they chain into a workflow and where they overlap with Siraj's own skills.
---

# Matt Pocock Skills — Overview & Router

A GitHub-issue-driven engineering loop installed globally at `~/.claude/skills/`. Per-repo config (issue tracker, triage labels, domain docs) is scaffolded by `setup-matt-pocock-skills` into `CLAUDE.md` + `docs/agents/` — already run for `data-warehouse`.

## The skills, by phase

| Phase | Skill | Reach for it when |
|---|---|---|
| **Sharpen** | `grill-me` | You have a plan/design and want it stress-tested by relentless questioning until every branch is resolved. |
| **Sharpen** | `grill-with-docs` | Same, but challenged against the project's domain model — sharpens terminology and writes `CONTEXT.md` / ADRs as decisions crystallise. |
| **Capture** | `to-prd` | Turn the current conversation into a PRD and publish it as a GitHub issue. |
| **Capture** | `to-issues` | Break a plan/spec/PRD into independently-grabbable issues via tracer-bullet vertical slices. |
| **Manage** | `triage` | Move incoming issues through the lifecycle (needs-triage → needs-info → ready-for-agent / ready-for-human / wontfix). |
| **Understand** | `zoom-out` | You're in unfamiliar code and need the higher-level picture of how it fits together. |
| **Fix** | `diagnose` | A bug or perf regression — runs reproduce → minimise → hypothesise → instrument → fix → regression-test. |
| **Improve** | `improve-codebase-architecture` | Find deepening/refactor opportunities; consolidate coupling; make code more testable and AI-navigable. |
| **Config** | `setup-matt-pocock-skills` | Re-run only to switch issue tracker or reconfigure labels/domain layout. |

## How they chain

```
idea → grill-me / grill-with-docs (sharpen)
     → to-prd (publish PRD)  → to-issues (slice into tickets) → triage (manage lifecycle)
     → (build)
     → diagnose (bugs)       → improve-codebase-architecture (structural debt the bug exposed)
zoom-out: reach for any time you're lost in unfamiliar code.
```

`diagnose` hands off to `improve-codebase-architecture` after a fix when the root cause is architectural. `triage` invokes `grill-with-docs` when an issue needs fleshing out.

## Fit for data-warehouse (dlt + dbt)

- **feather-etl candidate** spotted → `to-issues` / `triage` to file and shepherd it.
- **dlt pipeline breaking** (e.g. a load failing on one day) → `diagnose`.
- **dbt model sprawl / coupling** → `improve-codebase-architecture` (works on the SQL/model layer; weaker on glue scripts).
- **reconciliation finding** worth tracking → `to-prd` then `to-issues`.

## Overlap with Siraj's own skills — pick consciously

- **Filing issues:** Siraj's `file-issue` / `file-issue-and-plan` already encode the feather-etl-vs-local routing and the plan step. Prefer those for the standard "spotted something → file it" flow; use `to-issues` when slicing a *larger* plan/PRD into many vertical-slice tickets, and `to-prd` to author the PRD first.
- **Stress-testing:** `grill-me` / `grill-with-docs` overlap with `deep-thinking` and the openspec stress-test skills. `grill-*` is interactive interrogation of one plan; `deep-thinking` runs parallel reasoning lenses; openspec stress-tests are spec/tasks-bound.
- **Bug work:** `diagnose` is the disciplined loop; reach for it over ad-hoc debugging when the bug is hard or a perf regression.
