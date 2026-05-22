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

- **user-execute** (default): agent produces mini-plan + spec refs;
  the user writes the code; the agent verifies.
- **agent-execute** (opt-in): agent produces mini-plan; user approves;
  agent writes code; user reviews the diff.

To switch: "Switch to agent-execute mode" / "Switch to user-execute mode."

**Auto-mode does NOT change the default.** Even when the harness is in
auto-mode (system reminder "Work without stopping for clarifying
questions"), this skill stays in user-execute. The mini-plan IS the
output the user wants from auto-mode; producing it without writing code
is not a clarifying question — it is the deliverable. Only switch to
agent-execute when the user explicitly says so.

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
│    user-execute: user writes code       │
│    agent-execute: agent writes code     │
│    → user reviews diff                  │
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

In **user-execute** mode:
> "Plan written. Open it in your editor, then your turn — let me know when you've landed the tests and impl and I'll verify."

In **agent-execute** mode:
> "Plan written. Shall I proceed?"
Wait for explicit approval before writing any code.

If the plan reveals the task is larger than the checkbox implies:
> "This looks larger than one checkbox. Want to split <task-id> before starting?"
Stop until decided.

---

## Step 2 — Execute

### user-execute mode
Wait for the user to signal done.

### agent-execute mode
Write code. Show the diff. Say:
> "Review the changes above. Ready to verify?"
Wait for explicit confirmation before running verification.

Do not auto-commit. Do not proceed to verification without confirmation.

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
| Write code in user-execute mode | Wait for the user |
| Flip to agent-execute because auto-mode is on | Auto-mode keeps user-execute; only explicit user request switches |
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
