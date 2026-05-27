---
name: parallel-implement-compare
description: >
  Run N subagents in parallel against the same prompt in isolated git
  worktrees, then produce a side-by-side comparison of their outputs.
  Composable mechanic invoked by openspec-siraj-execute-plan (Curated
  mode), openspec-siraj-stress-test-plan, and any caller that wants
  multiple model voices on the same task. Use directly when Siraj asks
  "fan out N agents on this", "compare what Sonnet and Opus do for X",
  or "run a 2-agent bake-off". Defaults to Sonnet + Opus (N=2), both
  in worktrees with `run_in_background: true`.
---

# Parallel Implement + Compare

A composable mechanic for "multiple model voices on the same task." N
subagents run in parallel against an identical prompt in isolated git
worktrees; this skill aggregates their outputs into a side-by-side
comparison report. What the caller DOES with the report (pick a
winner, push back to plan refinement, throw away the code) is the
caller's business — this skill just produces the comparison.

The skill exists because the same subagent dance appears in two
contexts:

1. **Curated execution** — you want production code, multiple voices
   compared, pick the best to commit.
2. **Stress-testing a plan** — you want divergences read as gap-signals,
   no commit, push back to plan refinement.

Centralizing the mechanic here keeps both callers DRY.

---

## When to use

- Caller is `openspec-siraj-execute-plan` Curated mode — needs N=2 production-quality outputs to pick from.
- Caller is `openspec-siraj-stress-test-plan` — needs N=2 or N=3 outputs to read for divergences.
- Direct invocation: Siraj says "fan out N agents on this" or "run a 2-agent comparison."

## When NOT to use

- Single subagent runs — use the `Agent` tool directly with `isolation: "worktree"`.
- Tasks that change shared state outside a worktree (CI runs, remote API calls, persistent DB writes) — isolation breaks.
- Pure text review of a doc (no code generation) — use `verify-plan` for parallel text review of a plan file.

---

## Inputs (from the caller)

| Input | Required | Default | Notes |
|---|---|---|---|
| Prompt template | yes | — | Exact text each subagent receives. Caller fills in task context, file paths, constraints. |
| Models | no | `["sonnet", "opus"]` | List of model strings. `["haiku", "haiku", "haiku"]` for cheap stress-testing; `["sonnet", "opus"]` for production winner-picking. |
| Pre-flight check | yes | — | A check the caller specifies — e.g., "plan + docs committed to origin/main." This skill runs it before launching. |
| Report orientation | no | `"winner-pick"` | `"winner-pick"` (emphasizes which output to commit) or `"gap-find"` (emphasizes convergent failures + divergences as plan-issue signals). |
| Files to compare | no | auto-discover via diff | Caller can specify a list to restrict the report scope. |

---

## The flow

### Step 1 — Pre-flight

Run the caller-supplied pre-flight check. If it fails:

> "Pre-flight failed: <reason>. Cannot launch parallel agents without <prerequisite>. Address this and re-invoke."

Stop. Typical pre-flight requirements:

- **OpenSpec callers:** plan + supporting docs committed to `origin/main` (worktrees inherit from there, NOT from the dirty working tree).
- **Greenfield callers:** working tree clean OR stashable.

### Step 2 — Stash any working-tree changes

If the working tree is dirty, stash with a descriptive label:

```bash
git stash push -u -m "parallel-impl-pre-comparison-<timestamp>"
```

Record the stash ref for cleanup later. Skip if the working tree is already clean.

### Step 3 — Launch N subagents in parallel

Use the `Agent` tool with `isolation: "worktree"` and `run_in_background: true` for each subagent.

**All N calls go in the SAME tool-use message** so they execute concurrently. Sequential calls (one Agent call per message) defeat the parallelism.

For each model in the list:

```
Agent(
  description: "<model> implementation of <task>",
  subagent_type: "general-purpose",
  model: <model>,
  isolation: "worktree",
  run_in_background: true,
  prompt: <caller's prompt template>,
)
```

### Step 4 — Wait with sequenced reveal

As each subagent finishes (the harness emits a `task-notification` system reminder):

- **Immediately render the agent's report** in chat — files touched, test results, coverage, deviations.
- Annotate which agents are still running.

Sequenced reveal beats "wait for all, dump everything" — the user can start reading the first result while the second is still running. With N=2 (Sonnet + Opus), the faster model typically lands 1–2 minutes before the slower.

### Step 5 — Read each worktree's code

When all N have finished, read code files from each worktree. The worktree paths arrive in each agent's completion notification (`<worktree><worktreePath>...`).

Files to read:

- If caller specified `files to compare`, read those.
- Otherwise: diff each worktree against its base commit to discover new/modified files, take the union across worktrees, read all from each worktree.

### Step 6 — Render the comparison report

The report is the load-bearing artifact. Shape varies by `report orientation`:

#### `"winner-pick"` orientation — default; caller will pick one

```markdown
# Side-by-side comparison — <task>

## File 1 — `<file path>`

### <Model A>
```<lang>
<full content>
```

### <Model B>
```<lang>
<full content>
```

### Analysis
- <Diff observation 1>
- <Diff observation 2>

### Recommendation
<Pick one, with one-line rationale>

## File 2 — ...
[repeat per file]

## Overall verdict
| File | Winner | Why |
|---|---|---|
| <path> | <Model> | <rationale> |

**Recommended pick:** <wholesale winner OR hand-pick across files>
```

#### `"gap-find"` orientation — caller pushes back to plan refinement

```markdown
# Plan-gap signals from parallel implementation — <plan ID>

## Convergent failures (BOTH agents got it wrong)

These signal the PLAN is unclear or invites the wrong default. **Fix the plan**, not the agents.

- **<topic>**: both agents <did wrong thing>. Plan says <X>; both interpreted as <Y>. Suggested plan rewording: <fix>.

## Divergent outcomes (agents disagreed)

These signal the plan didn't pin a choice that matters. **Either pin it in the plan or accept either output.**

- **<topic>**: <Model A> did <X>; <Model B> did <Y>. Plan says <nothing/ambiguous>. Decision needed.

## Convergent successes

Sanity check — parts of the plan that held cleanly. No action needed.

- <topic>: both agents produced <correct thing>.

## Recommendation
<Push back to create-plan to fix convergent failures + ambiguities. Re-run after polish.>
```

### Step 7 — Hand back to caller

The skill's job ends with the report. The caller decides next steps — pick a winner, push back to plan refinement, archive the worktrees.

### Step 8 — Cleanup (caller-driven; skill provides commands)

After the caller is done with the worktrees:

```bash
# If the caller wants to keep one worktree's code, copy files OUT first:
cp <chosen-worktree>/<file> <main-repo>/<file>

# Then cleanup:
git stash drop <stash-ref>                              # if stash was created in Step 2
git worktree remove -f -f <worktree-path-A>             # per agent
git worktree remove -f -f <worktree-path-B>
git worktree prune
git branch -D <worktree-branch-A> <worktree-branch-B>
```

---

## Subagent prompt template — caller's responsibility

This skill does NOT prescribe prompt content. The caller is responsible for:

- The task ID / what to implement.
- Context files to read (plan, spec, design, testing.md, etc.).
- Constraints (YAGNI directive, floor-not-wall, language conventions).
- The structured report-back format the caller expects.

See `openspec-siraj-execute-plan` Curated mode for an example OpenSpec-style prompt.

**Identical prompt for all N agents.** The comparison only makes sense when every agent receives the same instructions; differences in output reflect model voice, not prompt skew.

---

## Anti-patterns

- **Run N Agent calls sequentially.** All N must go in the SAME tool-use message to execute concurrently. One-per-message = sequential launch = defeats the point.
- **Use `run_in_background: false` for parallel agents.** Blocks the main chat. Always `true` for N ≥ 2.
- **Skip the pre-flight check.** Worktrees inherit from `origin/main` (or the caller-specified base). If plan / docs aren't committed there, agents read STALE state — comparison becomes uninformative.
- **Try to peek at agents' progress mid-flight.** The agent transcript file is too large to safely read. Wait for the completion notification.
- **Auto-pick a winner without showing the comparison.** This skill's job is to PRODUCE the report; only the caller (with user approval) picks. Never silent-pick.
- **Render the comparison as one wall of text.** Per-file sections with explicit boundaries (`## File N — <path>`) make the report scannable. The user reads file by file, decides file by file.
- **Forget cleanup.** Worktrees accumulate disk space + locked branches. Always emit the cleanup commands at the end of the report, even if the caller doesn't run them immediately.
- **Vary the prompt across agents.** Identical prompt is the apples-to-apples discipline. Different prompts produce different outputs that you can't attribute to the model.

---

## Integration with callers

This skill is invoked BY other skills, typically. Division of concerns:

| Concern | Lives in |
|---|---|
| Subagent launch mechanics (worktree, parallel, background) | this skill |
| Sequenced reveal of completion notifications | this skill |
| Comparison report rendering (per-file, multi-column) | this skill |
| Cleanup commands | this skill |
| What pre-flight to require | caller |
| What prompt to send | caller |
| What models to use | caller |
| What to do with the report (pick winner, push back, archive) | caller |
| Whether to commit, verify, apply to main | caller |

That separation IS the point. The mechanic lives here; the orientation lives in the caller.
