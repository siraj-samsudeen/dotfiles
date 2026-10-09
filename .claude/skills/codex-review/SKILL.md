---
name: codex-review
description: Have OpenAI Codex independently review a code change, using the Codex plugin's reviewer. Use after any non-trivial code change (logic in Python, SQL/dbt, scripts, behaviour-changing config) before calling the work done, committing, or opening a PR; or when the user says "codex review", "have codex review this", "second opinion from codex", or "adversarial review".
---

# Codex review

An agent-callable wrapper around the `codex@openai-codex` plugin's reviewer. The plugin's own
`/codex:review` and `/codex:adversarial-review` are user-only (`disable-model-invocation`), so
this skill runs the same companion script directly.

## Run it

From the repo root. Resolve the plugin's newest installed version each time; the cache path
carries the version number and changes on update:

```bash
CODEX_PLUGIN=$(ls -d ~/.claude/plugins/cache/openai-codex/codex/*/ | sort -V | tail -1)
node "$CODEX_PLUGIN/scripts/codex-companion.mjs" review --wait --scope auto
```

Pick the target:

| What you changed | Flags |
|---|---|
| Uncommitted work in this checkout | `--scope working-tree` |
| A branch | `--base main` (or the real base) |
| Not sure | `--scope auto` |

**Adversarial review** — challenges the approach, design choices and assumptions, not just
defects. Use it for design-shaping work (new data models, business rules, architecture). It
accepts focus text after the flags:

```bash
node "$CODEX_PLUGIN/scripts/codex-companion.mjs" adversarial-review --wait --base main "focus: is the incremental key immutable?"
```

Each review takes roughly 3–6 minutes, even on a modest diff (longer focus text makes it
slower — one run with a long accepted-items list took 16). Run the Bash call with
`run_in_background: true` and carry on with other work until it finishes; the standard and
adversarial reviews can run in parallel. Use the real base branch, not a reflexive `main` — a
vendor or feature branch may target something else.

**Reading the output.** A long `[codex] Running command…` log comes first; the verdict starts
at the `# Codex Review` / `# Codex Adversarial Review` heading:
`sed -n '/^# Codex \(Adversarial \)\{0,1\}Review/,$p' <output-file>`.

**Codex does not run your tests.** It reads code; it usually can't execute the project's test
suite (missing interpreter, DB, deps). Run the tests yourself, and don't read "no findings" as
"tested". On adversarial runs you can put the test command and result in the focus text.

**It sends code to OpenAI.** The review uploads the diff and surrounding repo context. Siraj has
approved this for all repos, including client and vendor code (09-Oct-2026) — no need to ask.

## Not a git repo, or not a "code" task

Codex reviews a git diff. Folder work (a Dropbox accounting folder, a file reorganisation) is
often driven by scripts — matchers, parsers, register builders — and those scripts are code
that needs review: on a Bisquared reorg, Codex found documents marked Matched without
amount corroboration and statements silently dropped on PDF-extraction failure.

- **Folder isn't a git repo** → build a scratch repo in your scratchpad: copy only the code
  (scripts, configs) at its *before* state, `git init` + commit as the baseline, copy the
  *after* state over it, then review with `--scope working-tree` from that directory. Leave
  data files (statements, bills, workbooks) out — they're large, often private, and Codex
  doesn't need them; it will note that it couldn't verify against data, so run the scripts
  on the real data yourself.
- **Pure moves/renames with no logic** → no Codex review needed (it's in the skip list).
  Review the script that did the moving instead, if there is one.

## Before running

Check there is something to review: `git status --short --untracked-files=all` for working-tree,
`git diff --shortstat <base>...HEAD` for a branch. Untracked files count as reviewable.

## After it returns

1. Read every finding. Verify each one against the code before acting — Codex can be wrong.
2. Fix the real ones. For each one you reject, say why in one line.
3. **Both reviews loop until no blockers remain.** Fix, then re-run the same review on the new
   state; repeat until it reports nothing you'd call a blocker. Siraj wants a clean exit, not a
   capped number of rounds. Adversarial rounds often dig deeper each time (one real run found
   genuine defects in rounds 1–5); that is the point, not a reason to stop.
4. **You may not waive a finding yourself.** A finding you reject on the merits (Codex is wrong
   about the code) can be rejected with a one-line reason. But if you want to stop while Codex
   is still raising something — it's a design trade-off, it keeps re-raising a settled item, it
   contradicts an earlier round, or the rounds have stopped converging — **ask Siraj for explicit
   approval to set those findings aside**, listing each one with Codex's point and your reason.
   Do everything else first so the question is the only thing left.
5. On adversarial re-runs, pass what's already decided as focus text so it doesn't re-raise
   them or contradict an earlier round, e.g.
   `"Known and accepted, do not re-report: <item — reason>; …"`. It may still re-raise some in new
   wording; treat those as already decided. (The standard review takes no focus text.)
6. Report a short summary in your close-out and in the PR body's Review section: what Codex
   found, what you fixed, what you rejected and why.

## If it fails

If `node`, the plugin, or `codex` is missing, or the review errors (e.g. not signed in — check
`codex login status`), say so plainly. Never skip the review silently. Fallback that needs no
plugin: `codex review --uncommitted` or `codex review --base main`.
