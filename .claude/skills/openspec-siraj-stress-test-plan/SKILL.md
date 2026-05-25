---
name: openspec-siraj-stress-test-plan
description: >
  Stress-test a polished per-commit plan by having N subagents implement
  it in parallel; read divergences as plan-gap signals (NOT as
  winner-picking). Use when a plan is locked but you want empirical
  evidence it does what it says before committing the implementation.
  Distinct from `openspec-siraj-stress-test-tasks` (agents produce
  PLANS from tasks.md, find tasks gaps) and `openspec-siraj-execute-task`
  Curated mode (agents produce CODE you commit). Trigger on phrasing
  like "stress-test the plan for commit N", "is the plan ready for
  implementation", "run a plan bake-off", or invoke after
  `openspec-siraj-walk-plan` produces a fresh plan and you want to
  validate it before invoking execute-task. Defaults to the
  most-recently-modified change folder.
---

# OpenSpec Siraj — Stress-Test Plan

A per-commit plan is supposed to give an implementing agent enough
context to produce strict-YAGNI, correct code without guessing. This
skill empirically tests whether it does.

**The test:** spawn N subagents in parallel against the plan; have them
implement the commit; aggregate their outputs. **Convergent failures**
(both agents got the same thing wrong) signal the plan is unclear.
**Divergent outcomes** (agents disagreed) signal the plan didn't pin a
choice that matters. **Convergent successes** are sanity checks (no
action).

**The output is a plan-gap report**, NOT picked code. The code is
throwaway. The user reads the report → invokes `openspec-siraj-walk-plan`
to refine the plan based on findings → re-runs this skill until the
report is clean → invokes `openspec-siraj-execute-task` for actual
production execution.

---

## How this differs from sibling skills

| Skill | Input | Agents produce | Output | Action on result |
|---|---|---|---|---|
| `verify-plan` | a plan file (text) | text reviews | review findings | edit plan |
| `openspec-siraj-stress-test-tasks` | `tasks.md` | implementation plans for each commit | tasks.md gaps | edit tasks.md |
| **`openspec-siraj-stress-test-plan`** | **a per-commit plan** | **CODE for that commit** | **plan-gap report** | **edit the plan via walk-plan** |
| `openspec-siraj-execute-task` Curated mode | a per-commit plan | code | side-by-side comparison | pick winner + commit |

The two right columns matter: **the action you take after.** stress-test-plan
pushes back to plan refinement; Curated mode commits a winner.

---

## When to use

- After `openspec-siraj-walk-plan` produces a fresh plan and you want
  empirical validation before committing the implementation.
- Before any load-bearing commit where you'd regret a YAGNI violation
  or scope creep landing on `main`.
- After substantial plan revisions, to check the polish held.
- Whenever Siraj says "stress-test the plan for commit N", "is the plan
  ready", or "run a bake-off on this plan."

## When NOT to use

- For trivial commits where the comparison overhead isn't earned (small
  refactor, single-line additions — invoke `openspec-siraj-execute-task`
  in Single-subagent mode with Haiku instead).
- For tasks.md gaps — use `openspec-siraj-stress-test-tasks`.
- For static plan review only — use `verify-plan`.

---

## The flow

This skill is a **thin wrapper** around `parallel-implement-compare`.
The mechanics (worktree dance, sequenced reveal, comparison render)
live there. This skill adds OpenSpec context + the gap-finding
orientation + the post-report pushback.

### Step 1 — Identify the plan

If Siraj names a commit explicitly, use it. Otherwise default to the
next un-implemented commit in the most-recently-modified OpenSpec
change folder.

> "Stress-testing the plan at
> `openspec/changes/<change>/plans/commit-N-<slug>.md` against scenarios
> `<list>`. Ready?"

Wait for go.

### Step 2 — Pre-flight

Same pre-flight as `openspec-siraj-execute-task` Curated mode: plan +
supporting docs (spec, design, testing.md) must be committed to
`origin/main`. The subagents will read these from `origin/main`-derived
worktrees, NOT from the dirty working tree.

If uncommitted:
> "Stress-test needs the plan + docs committed and pushed to origin/main
> first (worktrees inherit from there). Commit + push these now? (y/n)"

Wait for approval. After commit, push.

### Step 3 — Invoke `parallel-implement-compare`

With:

- **Models:** `["sonnet", "opus"]` by default. For cheaper stress-testing
  on lower-stakes commits, use `["haiku", "haiku", "haiku"]` — three
  Haiku voices for divergence detection without paying for top models.
  Ask Siraj if the default doesn't fit.
- **Pre-flight check:** "plan + supporting docs committed to origin/main."
- **Report orientation:** `"gap-find"`.
- **Prompt template:** the OpenSpec subagent prompt from
  `openspec-siraj-execute-task` Curated mode (identical so a polished
  plan that holds in Curated mode also holds here).

### Step 4 — Receive the gap-find report

`parallel-implement-compare` renders the report in `"gap-find"`
orientation: convergent failures, divergent outcomes, convergent
successes (sanity check).

### Step 5 — Push back to plan refinement (or all-clear)

Three outcomes:

**(a) Clean report — no convergent failures, no divergences.**

> "Stress-test passed. The plan held — both agents produced functionally
> identical strict-YAGNI code. Safe to invoke `openspec-siraj-execute-task`
> Curated mode for production commit."

Cleanup the worktrees (commands at bottom of the comparison report).

**(b) Convergent failures present.**

> "<N> convergent failure(s). Both agents <did wrong thing>. This is a
> plan-clarity issue, not an agent issue. Invoke `openspec-siraj-walk-plan`
> to refine §<N> of the plan: <specific suggestion>. After refining,
> re-run stress-test."

The user invokes walk-plan, you re-run. Iterate until clean.

**(c) Divergent outcomes present.**

> "<N> divergent outcome(s). <Model A> did <X>; <Model B> did <Y>. The
> plan didn't pin this choice. Either pin it in §<N> of the plan (via
> walk-plan), or accept either output as valid."

User decides per divergence — pin it via walk-plan, or accept both.

### Step 6 — Cleanup

Always. The composable skill emits the cleanup commands at the bottom
of the report — copy them. Stash drop, worktree remove, branch delete.

---

## What this skill does NOT do

- **Pick a winner.** The code is throwaway. Use `execute-task` Curated
  mode for picking + committing.
- **Commit anything.** Stress-test runs are exploratory; no commit
  hits `main`.
- **Modify the plan.** Plan refinement is `openspec-siraj-walk-plan`'s
  job. This skill only produces the gap report.
- **Loop automatically.** Each stress-test → walk-plan → stress-test
  cycle is user-driven. The skill doesn't auto-iterate.

---

## Choosing N + model fan-out

| Stakes | N | Models | Why |
|---|---|---|---|
| **High-stakes** load-bearing commit | 2 | Sonnet + Opus | Two top-tier voices give the highest-signal comparison. |
| **Medium** typical commit | 2 | Sonnet + Opus | Same default; if cheaper acceptable, drop Opus. |
| **Low-stakes** small commit | 3 | Haiku × 3 | Three cheap voices — divergence-detection without top-tier cost. The trick: with 3 agents, convergent failures (all 3 agree) are more diagnostic than a 2-agent agreement. |
| **Cross-model bake-off** | 3 | Haiku + Sonnet + Opus | Different voices entirely; max signal at moderate cost. |

The skill defaults to Sonnet + Opus. Ask Siraj for an override when the
task complexity suggests otherwise.

---

## Anti-patterns

- **Treating stress-test output as code to commit.** This skill is for
  PLAN VALIDATION, not implementation. Use `execute-task` for the latter.
- **Iterating without walk-plan in between.** If a stress-test surfaces
  gaps, invoke `walk-plan` to refine BEFORE re-running. Re-running
  against the same plan produces the same gaps.
- **Skipping the pre-flight.** Worktrees read from `origin/main`. If
  the plan isn't committed there, agents read stale state.
- **Stress-testing every commit.** Trivial commits don't earn the
  comparison overhead. Reserve for load-bearing slices (verb-template
  skeletons, contract-locking commits, anything that sets a pattern
  later commits inherit).
- **Reading the comparison as winner-picking.** The orientation is
  gap-finding. "Sonnet's version is cleaner" is the wrong frame here.
  "Both agents missed the YAGNI directive" is the right frame.

---

## Integration with the OpenSpec workflow

The full validated workflow:

```
opsx:new
  → spec.md authored
  → openspec-siraj-walk-decisions → design.md
  → tasks.md authored (manual or via opsx)
  → openspec-siraj-review-change   (cross-doc consistency)
  → openspec-siraj-stress-test-tasks   (validates tasks.md)
  → for each commit:
      → openspec-siraj-walk-plan       (authors the plan)
      → review-document                 (lens-polish on the plan)
      → openspec-siraj-stress-test-plan (THIS skill — validates the plan)
      → openspec-siraj-execute-task     (Curated mode — produces commit)
  → opsx:verify
  → opsx:archive
```

This skill sits between `walk-plan` (produces the plan) and
`execute-task` (consumes the plan). It's the empirical validation step
that catches plan weaknesses before they become commit weaknesses.

Skip this skill for trivial commits; invoke it on load-bearing slices.
