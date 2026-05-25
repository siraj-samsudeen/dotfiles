---
name: openspec-siraj-execute-task
description: >
  Execute an OpenSpec change's tasks.md one checkbox at a time with a
  mini-plan → execute → verify → tick → ask gate loop. Use when the user
  wants disciplined per-task progress with explicit review before commits,
  instead of /opsx:apply's run-to-blocker loop. The tasks.md already encodes
  the TDD cadence (write tests → RED → implement → GREEN → coverage); this
  skill enforces the rhythm and the review gates around it.
---

# OpenSpec Execute Task

One checkbox per cycle. A gate at every step. The user owns the loop.

**Core philosophy:** the agent is good at writing code. The discipline is
at the boundaries. A mini-plan catches "about to write the wrong thing"
cheaply. A verify step confirms it worked. A commit gate prevents
unreviewed work from landing.

---

## Execution Modes

Three modes for HOW each task's code gets written. The user picks at
session start (sticky for the session) and may override per task. All
subagent modes use `run_in_background: true` so the main chat stays
responsive while agents work.

- **Curated (default)** — Sonnet and Opus run in parallel in isolated
  worktrees, implementing the same task independently. After both
  finish, the skill shows a side-by-side comparison and the user picks
  the winner (wholesale or hand-picked per file). Highest signal;
  ~2× time/cost of single-subagent mode.

- **Single subagent** — one subagent (Sonnet / Opus / Haiku) implements
  the task in a worktree. User reviews the output and accepts (or
  switches to inline for the revision). Model picked by task complexity:
  - **Haiku** for trivial tasks (~30–60 s runtime).
  - **Sonnet** for typical tasks — the in-mode default.
  - **Opus** for architecturally hard tasks.

- **Inline** — the current-session agent writes the code directly in
  the working tree. No subagent, no worktree, no comparison. Fastest.

To switch mid-session: "Switch to single subagent with sonnet" /
"Go inline for this one" / "Curated for the rest." The skill confirms
the change and applies it from the next task forward.

**Auto-mode keeps Curated as default.** When the harness is in auto-mode
("Work without stopping for clarifying questions"), this skill still
spawns Sonnet + Opus in parallel — Siraj's stated preference is that
auto-mode favors quality over spend. The skill still shows the
side-by-side comparison and waits for an explicit pick rather than
auto-selecting silently. Picking a winner without showing the
comparison is never auto-mode behavior.

---

## Session Start

1. **Pick the change.** Run `openspec list --json`. If exactly one change has
   unticked tasks, auto-select. Otherwise use AskUserQuestion. Never guess.
2. **Load context once.** Run `openspec instructions apply --change <name> --json`.
   Read every path under `contextFiles` (proposal, design, specs, tasks). Do
   not re-shell on every cycle.
3. **Note repo conventions.** Skim `git log -5 --oneline` to learn the commit
   message style. This is only for drafting commit messages later.
4. **Announce orientation.**

```
──────────────────────────────────────────────────────
  OpenSpec Execute — active: <change-name>

  Next: <task-id> — <one-line task title>
  <N> tasks remaining.

  Say 'start' to begin, or name a specific task.
──────────────────────────────────────────────────────
```

---

## The Gate Loop (one cycle per checkbox)

```
┌─────────────────────────────────────────┐
│ 1. Mini-plan                            │
│    Agent describes what will be built   │
│    User reviews and approves            │
├─────────────────────────────────────────┤
│ 2. Execute                              │
│    Curated: Sonnet+Opus → pick winner   │
│    Single: 1 subagent  → review         │
│    Inline: in-session  → review diff    │
├─────────────────────────────────────────┤
│ 3. Verify                               │
│    Run the verification the task        │
│    specifies (RED, GREEN, coverage)     │
│    Classify findings before acting      │
├─────────────────────────────────────────┤
│ 4. Tick                                 │
│    Mark - [x] in tasks.md ONLY after    │
│    verification passes                  │
├─────────────────────────────────────────┤
│ 5. Ask                                  │
│    "Commit now / continue to next /     │
│     stop?"                              │
└─────────────────────────────────────────┘
```

**One checkbox per cycle.** Sub-items like `1.1`, `1.2`, `1.3` are separate
cycles. Never batch.

---

## Step 1 — Mini-Plan

Produce a mini-plan before any code is written. Even for small tasks.

Before writing the plan, **read the relevant spec sections**. Spec refs
follow `docs/spec-conventions.md`: local (`1a`, `2b`) inside one spec
file, qualified (`init.1a`) across files. If a reference is unclear,
surface it before writing the plan rather than inventing one.

### Plan persistence — write the plan to a file

The plan is the user's reviewable artifact, not ephemeral chat. Write it
to disk under the change folder so the user can review in their editor
and so it survives archive:

```
openspec/changes/<change>/plans/commit-N-<slug>.md
```

- `N` is the commit number (matches the `## Commit N — …` heading in `tasks.md`).
- `<slug>` is a short kebab-case version of the commit subject (e.g.,
  `commit-1-feather-yaml-in-cwd`).
- Create `plans/` if it does not exist.

Then in chat: print a lightweight **Preflight** (≤15 lines) pointing at
the file. The Preflight names the commit, lists the test functions, and
gives the verification commands — enough for the user to know what to
expect. Full detail lives in the file.

### Test-first ordering

`docs/testing.md §2` locks the cadence: write tests → RED → impl →
GREEN → coverage. The plan file must reflect that order. Lead with
the test list; impl follows because the tests demand it.

### Plan file format

```markdown
# Commit N — <subject>

Spec scenarios: <list> · Status: drafted (RED not yet run)

## Tests to write (testing.md §2 steps 2–3)

1. `<test_function_name>` (`<spec-ref>`)
   - **Given:** <setup>
   - **When:** <invocation>
   - **Then:** <assertion(s)>

2. `<test_function_name>` (`<spec-ref>`)
   - ...

## Impl that makes them pass (step 4)

- `<file>` — <what lands here, named by what the test forces into existence>
- ...

## Out of scope this commit

- <deferred thing> → Commit M

## Verification (steps 3, 5, 6)

1. RED: `<command>` — expect failures of the form <kind>
2. GREEN: `<command>` — expect both tests passing
3. Coverage: `<command>` — expect 100% line+branch on touched files (full-verb gate is the final smoke-test commit)

## Spec references

- <ref> — <design pointer>
```

### Preflight format (chat, ≤15 lines)

```
**Commit N — <subject>** — plan: `openspec/changes/<change>/plans/commit-N-<slug>.md`

Tests (test-first per testing.md §2):
- <test_function_name> (<spec-ref>)
- <test_function_name> (<spec-ref>)

Verification: <one-line summary of pytest + coverage commands>

Open question (if any): <one-line>
```

After the Preflight is in chat, confirm or set the execution mode for
this task. If the session has a sticky mode, lead with it:

> "Plan written: `<plan-path>`.
>
> Mode for `<task-id>` — sticky default is **<current-mode>**:
> (a) Curated — Sonnet + Opus in parallel, you pick winner.
> (b) Single subagent — name the model (Sonnet / Opus / Haiku).
> (c) Inline — I write the code in this session.
>
> Say 'go' to proceed with the sticky default, or pick a letter to override."

Wait for an answer (or 'go') before doing anything. The mode chosen
governs Step 2's execution flow.

If the plan reveals the task is larger than the checkbox implies:
> "This looks larger than one checkbox. Want to split <task-id> before starting?"
Stop until decided.

---

## Step 2 — Execute

The flow depends on the mode chosen in Step 1. All three converge on
Step 3 (Verify) after producing code in the main working tree.

### Curated mode

Delegates the subagent dance + comparison rendering to
[`parallel-implement-compare`](../parallel-implement-compare/SKILL.md).
This skill provides the OpenSpec-specific orchestration around it:
pre-flight, prompt template, post-comparison apply/verify/commit.

1. **Pre-flight.** Plan + supporting docs (spec, design, testing.md)
   must be committed to `origin/main` (worktrees inherit from there).
   If uncommitted docs exist:
   > "Curated mode needs the plan + docs committed and pushed first.
   > Commit + push these now? (y/n)"
   Wait for approval. Use `git push origin main` after commit.

2. **Invoke `parallel-implement-compare`** with:
   - **Models:** `["sonnet", "opus"]` (the curated default).
   - **Pre-flight check:** "plan + supporting docs committed to origin/main."
   - **Report orientation:** `"winner-pick"`.
   - **Prompt template:** see Subagent Prompt Template below.

3. **Receive comparison report.** Sequenced reveal happens inside the
   composable skill — Sonnet's report arrives first, then Opus, then
   the side-by-side comparison.

4. **User picks.** User chooses wholesale winner OR hand-picks per
   file. Wait for the answer; never pick silently.

5. **Apply.** Copy picked code from the chosen worktree(s) into the
   main repo via `cp` with explicit paths (not `rsync -a`).

6. **Verify in main repo.** Run RED→GREEN→coverage in the main repo
   (verifies the picked code passes outside the worktree).

7. **Commit.** Standard Step 5 ask-before-commit flow.

8. **Cleanup.** `git stash drop`, `git worktree remove -f -f` both
   worktrees, `git worktree prune`, delete the worktree branches.
   (These commands appear at the bottom of the comparison report from
   the composable skill — copy them.)

### Single subagent mode

1. Pre-check (same as Curated).
2. Stash impl (same).
3. Launch ONE subagent: chosen model, `isolation: "worktree"`,
   `run_in_background: true`. Same prompt template.
4. Wait for the single completion report.
5. **Brief review.** Read the worktree's code, summarize what changed
   in chat (one paragraph per file).
6. User accepts OR asks for changes. If changes: either relaunch the
   subagent with revised prompt or switch to inline for this revision.
7. Apply (copy worktree → main).
8. Verify in main repo.
9. Commit (Step 5 flow).
10. Cleanup (drop stash, remove worktree, prune branches).

### Inline mode

1. Agent writes code in the current session (in the working tree).
2. Show the diff.
3. Say:
   > "Review the changes above. Ready to verify?"
4. Wait for explicit confirmation before running verification.

### Subagent Prompt Template (Curated + Single)

Each subagent gets the SAME prompt structure (identical text in Curated
mode so the comparison is apples-to-apples):

> You are implementing **<task-id> of the <change-name> change** in
> the feather-etl repo. Your worktree is `<worktree-path>`.
>
> ## Read these files first (in order)
> 1. `openspec/changes/<change>/plans/commit-N-<slug>.md` — primary brief.
> 2. `openspec/changes/<change>/specs/<capability>/spec.md` — scenarios.
> 3. `docs/testing.md` — cadence (vertical slicing, test-first batch).
> 4. `openspec/changes/<change>/design.md` — decisions referenced by plan.
>
> ## Your task
> Implement <task-id> per the plan. Follow the test-first cadence:
> write tests → confirm RED → write impl → confirm GREEN → run coverage.
>
> ## Constraints
> - Strict YAGNI per plan §3 (the **DO NOT add** directive).
> - Floor-not-wall per plan §5.
> - PEP-420 namespace packages — no empty `__init__.py` markers.
> - Use `uv run` for all Python invocations.
>
> ## Report back (under 400 words)
> 1. Files created/modified — full paths.
> 2. RED step result — exact failures seen at collection time.
> 3. GREEN step result — test names + pass/fail.
> 4. Coverage report — line + branch percentages on touched files.
> 5. Deviations recorded in plan §8 with one-line rationale.
> 6. Consult moments — any decision where you considered consulting
>    the user per `docs/testing.md` "consult before reaching for
>    non-default tools."

In ALL modes: do not auto-commit. Do not proceed to verification
without the user's go-ahead (Curated and Single-subagent verify in
the main repo after Apply; Inline verifies in the same tree).

---

## Step 3 — Verify

Run the verification step **the task itself specifies**. Examples:

- Test-writing checkbox (`.1`): run pytest, confirm expected RED with
  informative failure messages.
- Implementation checkbox (`.2`): run pytest, confirm GREEN.
- Coverage checkbox (`.3`): run `pytest --cov=<package> --cov-branch`, confirm 100% line + branch.
- Also run `openspec validate` once per session to catch doc-side drift.

Classify every finding before acting.

### Finding classifier

| Finding | Action |
|---|---|
| Verification failed (test/lint/coverage) | Fix inline, re-verify before tick |
| Code and spec disagree (divergence) | Divergence conversation (below) |
| Spec is ambiguous — unstated choice made | Ambiguity conversation (below) |
| Cross-cutting issue (affects > 1 capability) | Surface to user before continuing |
| Scope creep on current task | Three-option prompt (below) |
| Unrelated bug or improvement noticed | Mention once, then drop — not this task's job |

Treat "tests pass" as proof of what tests assert — not proof of correctness.
A divergence means the tests followed the wrong source.

### Divergence conversation

> "While verifying <task-id>, I noticed a divergence between code and spec:
>
> **Spec (`<capability>.<N><letter>`):** <what spec says>
> **Code:** <what code does>
> **Tests:** <whether they caught it or followed the code>
>
> Three ways to reconcile:
> (a) Fix code to match spec — <concrete change>
> (b) Update spec to match code — <concrete change>
> (c) Update both — <concrete change>
>
> Which?"

After user decides: make the change, re-verify before ticking.

### Ambiguity conversation

> "Implementing <task-id> surfaced an ambiguity in `<spec-ref>`: <what was
> unclear>. I implemented <what was chosen>. Want me to update the spec
> to lock this in, or do you want different handling?"

### Scope creep prompt

> "<task-id> reveals it also needs <X>, which isn't in the task.
> (a) Add it to <task-id> now
> (b) Add a new <task-id>b for it
> (c) Defer to <later task>
> Which?"

Stop until decided.

---

## Step 4 — Tick

After verification passes, mark the checkbox in `openspec/changes/<change>/tasks.md`:

```markdown
- [x] 1.1 Write tests for 1a + 2a — confirmed RED
```

A short suffix after the original text is fine if it makes the verification
visible at a glance. Optional, not required.

Do **not** tick until verification has actually passed.

---

## Step 5 — Ask

Default closing prompt:

> "<task-id> done.
> (a) commit now — proposed message:
>     ```
>     <subject line in repo style>
>
>     <body referencing spec scenarios, e.g., 'Implements init.1a + init.2a.'>
>     ```
> (b) continue to <next-task-id>
> (c) stop here
> Which?"

### Commit rule

- The agent **may commit** when the user picks (a) or otherwise explicitly approves.
- The agent **never commits without explicit approval**. Default is ask.
- Approval forms that count: "commit", "go ahead and commit", "yes commit",
  explicit yes to "shall I commit?". Anything ambiguous = ask again.
- The user may edit the proposed message before approving.
- After committing, run `git status` once to confirm the working tree is clean
  for the next cycle.
- Never `git push`. Never `git add -A`. Stage explicit paths.

If the user picks (b) without committing, carry forward — multiple checkboxes
may be grouped into one commit at the user's discretion.

---

## End of Change

When all checkboxes are ticked:

> "All tasks complete. Want me to run `/opsx:verify` to check
> implementation against the spec? Once that's clean, archive with
> `/opsx:archive`."

Do not auto-run either.

---

## Anti-Patterns

| ❌ Don't | ✅ Do |
|---|---|
| Skip mini-plan because "task is small" | Every checkbox gets a mini-plan |
| Batch multiple checkboxes into one cycle | One checkbox per cycle |
| Auto-continue after tick | Always ask before next cycle |
| Pick a curated winner silently without showing comparison | Always render Sonnet + Opus side-by-side; wait for the user's pick |
| Use curated mode for trivial Haiku-tier tasks | Match mode to task — single-subagent with Haiku is right for small refactors |
| Launch curated subagents without committing the plan first | Pre-commit plan + supporting docs and push to `origin/main` (worktrees inherit from `origin/main`, not the dirty working tree) |
| Auto-pick a winner in auto-mode | Auto-mode keeps Curated as the default; it does NOT change the "wait for user's pick" gate |
| Keep the mini-plan in chat only | Always write it to `openspec/changes/<change>/plans/commit-N-<slug>.md`; chat carries a Preflight pointer |
| List impl deliverables first, tests last | Lead with the test list; impl is what the tests force into existence (testing.md §2) |
| Tick before verification passes | Verification is non-optional |
| Commit without explicit user approval | Always ask, even if context "obviously" wants a commit |
| Silently fix code when spec says otherwise | Surface as divergence, three options |
| Silently update spec when code is convenient | Same — divergence is a conversation |
| Run `git push` | Never push; the user pushes |
| Use `git add -A` | Stage explicit paths only |
| Re-shell `openspec instructions apply` every cycle | Load once at session start |
| Invent spec references | If unclear, ask before drafting the plan |
