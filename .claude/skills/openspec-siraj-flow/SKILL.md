---
name: openspec-siraj-flow
description: >
  The OpenSpec-Siraj pipeline overview. Canonical orchestrator for the
  openspec-siraj-* family of skills (walk-decisions, walk-plan,
  review-change, stress-test-tasks, stress-test-plan, execute-task) plus
  the /openspec-siraj:* CLI commands (new, verify, archive, sync, etc.).
  Use this skill to orient on the full pipeline (proposal → spec →
  design → tasks → per-commit plans → execution → verify → archive), to
  figure out which verb fires next given an OpenSpec change folder's
  current state, or as the canonical reference for numbering, scenario
  titles, cross-file references, renumbering, tasks.md commit-block
  shape, and artifact-tree conventions. Trigger on phrasing like "what's
  the openspec workflow", "where am I in this change", "walk me through
  the openspec pipeline", "start a new openspec change", "how do I
  author tasks.md", or whenever the user pauses on an
  openspec/changes/<X>/ folder and asks what's next. For lightweight
  greenfield app/feature builds use feather-flow instead; the two are
  peer pipelines, not variants. Defaults to the most-recently-modified
  change folder if no name is given.
---

# OpenSpec-Siraj Flow

End-to-end pipeline for OpenSpec changes with full review rigor. Two
families of verbs cooperate:

- **Project-local `/openspec-siraj:*` commands** — thin wrappers around
  the `openspec` CLI from `@fission-ai/openspec`. Handle artifact
  lifecycle (create, verify, archive, sync).
- **Global `openspec-siraj-*` SKILL skills** — author the artifacts
  themselves and run the review gates between them.

**Sibling pipeline:** `feather-flow` covers lightweight greenfield work
(project-level brainstorm → 15-section spec → mini-plan + execute). Use
feather-flow when there's no spec yet and you're exploring. Use this
pipeline when behavior is precise enough to spec, and you want the
review gates (walk-decisions / review-change / stress-tests) that catch
ambiguity before it becomes code.

---

## When invoked

Three invocation patterns. **Always quietly check what's in
`openspec/changes/` first** — that tells you the pipeline state and
routes the response.

| Input shape | Behaviour |
|---|---|
| **Bare** (skill invoked alone) | If a change folder exists with active state → show the **state-aware orientation** (below). If `openspec/` is empty or absent → show the **pipeline diagram**. Do not ask "what are you working on" — the filesystem answers. |
| **Help-shaped** ("how does this work?", "walk me through the openspec pipeline") | Show the **pipeline diagram**. Even with active state, the user is asking to learn, not to resume. |
| **Work description** ("start a new openspec change for X", "I want to add Y as a verb") | Route directly to `/openspec-siraj:new` with a derived kebab-case name. Do NOT show the pipeline diagram first — they're past it. |

**Quietly** means: don't display `ls` output to the user. State checks
are for routing, not user-facing chatter.

---

## The pipeline

```
                            ┌─────────────────────────────────────────────┐
                            │ /openspec-siraj:*   — thin CLI wrappers     │
                            │ openspec-siraj-*    — authoring + gates     │
                            └─────────────────────────────────────────────┘

STAGE 0 — Optional thinking
        /openspec-siraj:explore
        (think through the problem before committing to a change)

STAGE 1 — Create the change folder
        /openspec-siraj:new <change-name>
        → openspec/changes/<X>/proposal.md       (scaffold)
        → openspec/changes/<X>/specs/<cap>/spec.md   (skeleton)

STAGE 2 — Author spec (manual)
        edit spec.md by hand
        (numbering + scenario titles per §Numbering + §Scenario title shape)

STAGE 3 — Walk design decisions
        /openspec-siraj-walk-decisions
        → design.md (Format A — Question / Alternatives / Recommendation)
                    │
                    ▼
        /review-document on design.md
        (7-lens structural polish)

STAGE 4 — Author tasks.md (manual)
        edit tasks.md by hand
        (six-section commit-block shape per §tasks.md commit-block shape)

STAGE 5 — Pre-implementation gates
        /openspec-siraj-review-change
        (3-subagent cross-doc audit)
                    │
                    ▼
        /openspec-siraj-stress-test-tasks
        (N-agent fanout; auto-applies convergent fixes)
                    │
                    ▼  (maybe re-run review-change if many edits landed)

STAGE 6 — Per-commit loop (repeat for each commit in tasks.md)
        /openspec-siraj-walk-plan
        → plans/commit-N-<slug>.md       (8-section shape)
                    │
                    ▼
        /review-document on the plan
                    │
                    ▼
        /openspec-siraj-stress-test-plan
        (optional — load-bearing commits only; pushes back to walk-plan)
                    │
                    ▼
        /openspec-siraj-execute-task
        (per-checkbox gate loop; Curated = Sonnet+Opus parallel default)
                    │
                    ▼
        git commit (user-approved)

STAGE 7 — Verify + archive
        /openspec-siraj:verify
        (checks implementation matches artifacts)
                    │
                    ▼
        /openspec-siraj:archive
                    │
                    ▼
        /openspec-siraj:sync
        (delta specs → openspec/specs/)
```

### Avoided CLI verbs (project-local discipline)

| Verb | Why avoided |
|---|---|
| `/openspec-siraj:apply` | Run-to-blocker loop. **Replaced** by `openspec-siraj-execute-task`'s per-checkbox gates. |
| `/openspec-siraj:propose` | Auto-generates `design.md` + `tasks.md` in shapes that don't follow Format A or the six-section shape — you just rewrite them. |
| `/openspec-siraj:ff` | Same — fast-forward variant of propose. |
| `/openspec-siraj:continue` | Walks artifact-by-artifact in the CLI default shape; the siraj skills do this with richer structure. |

`/openspec-siraj:bulk-archive` and `/openspec-siraj:onboard` are
situational — bulk-archive for cleanup, onboard for a new collaborator's
tour. Neither is part of the regular flow.

---

## State-aware orientation

When invoked bare on a project with an active change, derive state from
which artifacts exist on disk and print the banner matching the next
verb:

| State on disk | Next verb |
|---|---|
| No `openspec/` at all | `/openspec-siraj:new <name>` |
| `openspec/` exists, no `changes/<X>/` | `/openspec-siraj:new <name>` |
| `proposal.md` only, no `specs/<cap>/spec.md` | Hand-edit `spec.md` per §Numbering |
| `proposal.md + spec.md` exist, no `design.md` | `/openspec-siraj-walk-decisions` |
| `design.md` exists, no `tasks.md` | Hand-author `tasks.md` per §tasks.md commit-block shape |
| `tasks.md` exists, not yet reviewed | `/openspec-siraj-review-change` |
| Reviewed, not yet stress-tested | `/openspec-siraj-stress-test-tasks` |
| Stress-tested, no `plans/commit-1-*.md` | `/openspec-siraj-walk-plan` |
| Plan exists, not yet polished | `/review-document` then (optional) `/openspec-siraj-stress-test-plan` |
| Plan ready, no implementation | `/openspec-siraj-execute-task` |
| All commits done | `/openspec-siraj:verify` → `:archive` → `:sync` |

Banner shape:

```
──────────────────────────────────────────────────────
  OpenSpec-Siraj — active: <change-name>

  Last completed: <verb> on <date>
  Next verb:      <verb>
  Why:            <one-line — what state on disk triggered this>
──────────────────────────────────────────────────────
```

After showing the banner, **stop and wait**. Never auto-invoke the next
verb. The user owns the loop.

---

## Artifact tree

```
openspec/
  changes/
    <change-name>/
      proposal.md             ← /openspec-siraj:new scaffolds
      specs/
        <capability>/
          spec.md             ← hand-authored; numbering per §Numbering
      design.md               ← /openspec-siraj-walk-decisions writes
      tasks.md                ← hand-authored; shape per §tasks.md commit-block shape
      plans/
        commit-1-<slug>.md    ← /openspec-siraj-walk-plan writes
        commit-2-<slug>.md
        ...
  specs/
    <capability>/
      spec.md                 ← /openspec-siraj:sync moves deltas here after archive
```

A change folder is the unit of work. One change = one PR's worth of
behavior. Multiple changes can be in flight in parallel.

---

## Numbering convention

Requirements and scenarios carry position numbers inside their headings:

```markdown
### Requirement: 1. <Name>

#### Scenario: 1a. <Scenario name>
- **WHEN** ...
- **THEN** ...

#### Scenario: 1b. <Scenario name>
...

### Requirement: 2. <Name>

#### Scenario: 2a. <Scenario name>
```

- **Requirements:** integers from `1`, monotonic within a spec file.
- **Scenarios:** `<requirement-number><letter>`, lowercase from `a`.
- **Separator:** period (`.`) between number and name.
- **Scope:** numbers reset to `1` in every spec file (per capability).

**Why inside the heading.** OpenSpec parses requirements by matching
`### Requirement: <name>` and uses `<name>` as canonical ID. Putting the
number inside the name keeps it visible in any markdown render AND
honors the parsing contract.

**Why local-per-spec.** Inserting at `init.3` shifts only `init`'s
subsequent numbers. Other capabilities untouched. Global numbering would
propagate the edit across every later spec file in the project.

### Renumbering protocol

When inserting / removing / reordering requirements:

1. **Edit the spec.md** with new numbering applied to every affected
   requirement + its scenarios.
2. **Update any references** in the same change folder — `tasks.md`,
   `design.md`, sibling spec files, test names that embed numbers.
3. **Commit the renumber as one atomic change** — e.g.,
   `spec(init): renumber after inserting req 3`. Reviewers see one
   consistent diff.
4. **`/openspec-siraj:sync` treats renumbers as renames.** Expect a
   RENAME block for every renumbered requirement when the change is
   eventually synced into main specs. Manageable cost.

Early-stage specs renumber often; mature specs almost never. The
renumber cost is concentrated in the design window where churn is
expected.

---

## Scenario title shape

Every scenario title states what was *asserted*, not just what triggered
the assertion. (Requirement titles are noun phrases naming a capability
— no such rule.)

### The rule

```
<subject> <verb> <outcome>
```

When the trigger needs disambiguation, append `, if <precondition>` or
`, when <condition>` — after the outcome, not before.

**Good titles:**

```markdown
#### Scenario: 1a. Init with no arg stamps files into CWD, if empty
#### Scenario: 3a. Default mode writes pyproject.toml with PyPI version pin
#### Scenario: 4b. Existing .env is preserved silently
```

**Weak titles (avoid):**

```markdown
#### Scenario: 1a. Init in current directory       ← WHEN only, no THEN
#### Scenario: 6a. Default mode confirmation        ← label, no assertion
#### Scenario: 4a. Create empty .env when absent    ← imperative mood
```

### Three principles

1. **Subject + verb + outcome.** Every title names the actor, action,
   and result. A bare WHEN or a bare label fails this.
2. **Self-contained — name the artifact.** A reader scanning a flat
   list of titles should know which file/feature each scenario
   concerns. Say `feather.yaml`, `pyproject.toml`, `.env` in the title —
   unless the scenario is genuinely artifact-agnostic.
3. **Declarative mood throughout one spec.** Pick declarative
   (`X is preserved`, `X writes Y`). Imperative
   (`Preserve X`, `Create Y`) reads like a TODO, not an assertion.

### Litmus test

Before committing a title, read it as `test_<title>_PASSED`. If you can
answer "what was verified?" from that line alone, the title is good. If
you have to open the spec, the title is too thin — revise until you can.

This matters because test names mirror scenario titles verbatim (each
project's `docs/testing.md` enforces this). The title becomes the
pass/fail line in pytest output:

```
test_init_with_no_arg_stamps_files_into_cwd_if_empty PASSED
test_default_mode_confirmation PASSED              ← what was verified?
```

### Quick reference

| Pattern | Example |
|---|---|
| `<actor> <verb> <artifact>` | `3a. Default mode writes pyproject.toml with PyPI version pin` |
| `<artifact> <state-verb>` | `2b. feather.yaml present is preserved` |
| `<actor> <verb> <outcome>, <condition>` | `1a. Init with no arg stamps files into CWD, if empty` |
| `<actor> <verb> <outcome>` (failure path) | `3c. --dev without local checkout exits non-zero` |

---

## Cross-file references

Use `<capability>.<N><letter>`:

- `init.1a` — scenario `1a` in `specs/init/spec.md`
- `source-add.3` — whole requirement `3` in `specs/source-add/spec.md`
- `init` — the whole capability (the directory name)

In-file refs just use the position (`1a`, `3b`). Cross-file refs should
be rare; if you reach for them often, the requirements probably belong
in the same spec.

---

## tasks.md commit-block shape

Each commit in `tasks.md` follows a six-section shape after the H2
title. The shape answers five questions for the implementing agent:
*what behaviour ships*, *which tests prove it*, *why this grouping*,
*what files land*, *where to read for how*, *what is intentionally
deferred*.

The cadence (RED → impl → GREEN → coverage) lives in each project's
`docs/testing.md` and does NOT appear in commit blocks — restating it
per commit is noise.

### The shape

```
## Commit N — <short subject>

New behaviour: <one declarative sentence — the slice outcome>

Spec scenarios (= tests; names mirror titles per docs/testing.md):
- Na. <scenario title verbatim>
- Nb. <scenario title verbatim>

Notes:
- <test hints, slice-metadata clarifications, partial-state observations>

Implementation outline:
- <file/component-level deliverable> (— Decision N if local)
- <file/component-level deliverable>

Design pointers:
- <topical headline> — Decision N / Req N / Smaller choice N
- <topical headline> — Decision N

Out of scope (lands later):
- <deferred thing> → Commit M (Req/Decision pointer)
```

### Rules

1. **`New behaviour:`** is one declarative sentence. If two sentences
   are needed, the slice is probably two commits.
2. **`Spec scenarios:`** lists verbatim from `spec.md`. Test names
   mirror these titles — the block IS the test list. Do not duplicate
   as a separate `Tests:` block.
3. **`Notes:`** is optional. Non-obvious context only: test design
   hints, partial-state observations, test harness conventions on the
   first commit that establishes them. Resist using Notes for restating
   the banner or the scenarios.
4. **`Implementation outline:`** is file/component-level and
   architecturally self-contained. A reader on the first commit should
   grasp the introduced shape without reading design.md first — name
   the orchestration pattern, not just individual file edits.
5. **`Design pointers:`** uses topical headlines (not file paths)
   pointing at Decisions / Requirements / Smaller choices. Each bullet
   pairs a concern with where-to-read.
6. **`Out of scope:`** makes deferrals explicit so an agent does not
   speculatively over-build. Each bullet names what's deferred, the
   commit that will land it, and the relevant Req/Decision. Omit the
   section if nothing is deferred.
7. **No `- [ ] 1.1 Write tests` checklist inside the commit block.**
   The commit itself is the unit of work; the cadence is in
   testing.md.

### Why this shape

A traditional checklist forces the reader to re-derive design rationale
and slice scope from a flat sequence. The six-section shape separates
concerns: scenarios carry the contract, Implementation outline carries
the slice boundary, Design pointers carry the architectural index,
Out of scope carries the negative space. Multi-model stress-testing
(Sonnet / Opus / Haiku reading the same tasks.md) showed convergent
improvements in plan quality and reduction of guesswork once this shape
replaced flat checklists.

---

## Sibling-skills graph

| Skill / verb | Stage | One-line job |
|---|---|---|
| `/openspec-siraj:explore` | 0 | Think through ideas before committing to a change |
| `/openspec-siraj:new` | 1 | Creates `openspec/changes/<X>/` with proposal + skeleton spec |
| (hand-edit `spec.md`) | 2 | Author the spec per numbering + title rules above |
| `openspec-siraj-walk-decisions` | 3 | Walks design decisions in Format A → `design.md` |
| `review-document` | 3, 6 | 7-lens structural pass on any agent-produced doc |
| (hand-edit `tasks.md`) | 4 | Author per six-section commit-block shape above |
| `openspec-siraj-review-change` | 5 | 3-subagent audit: consistency / right-sizing / structural lenses |
| `openspec-siraj-stress-test-tasks` | 5 | N-agent plan fanout; finds tasks.md gaps; auto-applies convergent fixes |
| `openspec-siraj-walk-plan` | 6 | Authors per-commit plan files (canonical 8-section shape) |
| `openspec-siraj-stress-test-plan` | 6 | N-agent code fanout; reads divergences as plan-gap signals; pushes back to walk-plan |
| `openspec-siraj-execute-task` | 6 | Per-checkbox gate loop, Curated default (Sonnet+Opus parallel worktrees) |
| `/openspec-siraj:verify` | 7 | Validates implementation matches artifacts |
| `/openspec-siraj:archive` | 7 | Finalizes the change |
| `/openspec-siraj:sync` | 7 | Moves delta specs into `openspec/specs/` |
| `parallel-implement-compare` | 6 | Composable mechanic invoked by stress-test-plan and execute-task Curated mode |

### Disambiguation between similar-sounding skills

These three are often confused. They run in **sequence**, not as
alternatives:

| Skill | What it audits | When it fires | What it produces |
|---|---|---|---|
| `openspec-siraj-review-change` | Cross-doc consistency (spec ↔ design ↔ tasks contradictions, stale refs, scenario→commit mapping) | After tasks.md is hand-authored, before stress-testing | Findings categorized as Apply / Surface for decision / Dismiss |
| `openspec-siraj-stress-test-tasks` | Implementability of tasks.md (would an agent know what to do, or have to guess?) | After review-change clears, before per-commit work begins | Per-commit plans + gap-find report; convergent gaps auto-applied |
| `openspec-siraj-stress-test-plan` | Per-commit plan clarity (does an agent following the plan land strict-YAGNI correct code?) | After walk-plan + review-document polish the plan; load-bearing commits only | Convergent failures + divergences as plan-refinement signals (NOT winner-picking) |

Two more often-confused pairs:

| Pair | What sets them apart |
|---|---|
| `verify-plan` (generic) vs `openspec-siraj-stress-test-plan` | verify-plan: 3 parallel agents review the plan TEXT; stress-test-plan: N agents IMPLEMENT the plan and divergences signal plan gaps |
| `/openspec-siraj:verify` (CLI) vs `openspec-siraj-review-change` (skill) | `:verify` checks IMPLEMENTATION matches artifacts (post-impl gate); `review-change` checks ARTIFACT consistency (pre-impl gate) |

---

## Discovery defaults

All `openspec-siraj-*` skills that take a change-name argument default
to the most-recently-modified change folder when none is given. The
canonical snippet:

```bash
ls -td openspec/changes/*/ 2>/dev/null | head -5
```

Pick the top one if exactly one recent candidate. Confirm with the user
if multiple recent candidates.

---

## Anti-patterns

| ❌ Don't | ✅ Do |
|---|---|
| Run `ls openspec/changes/` and dump output to the user on bare invocation | Quietly inspect state; show the orientation banner |
| Skip the orientation when bare; jump straight to "what do you want to do?" | Bare invocation = state banner first; routing comes only after a work description |
| Auto-invoke the next verb after one completes | Always stop. The user owns the loop; they say "go" to continue |
| Restate the pipeline diagram inside each sub-skill's SKILL.md | This orchestrator is the canonical home; sub-skills point here |
| Restate the numbering / title / tasks-shape conventions inside each sub-skill | Same — canonical home is here |
| Use `/openspec-siraj:apply` for production work | Use `openspec-siraj-execute-task` (per-checkbox gates) instead |
| Use `/openspec-siraj:propose` or `:ff` to bootstrap a change | They auto-generate `design.md` + `tasks.md` in the wrong shapes; you'll rewrite them. Use `:new` then walk-decisions + hand-author tasks.md |
| Confuse review-change with stress-test-tasks | They run in sequence; see disambiguation table |
| Treat stress-test-plan as winner-picking | Orientation is gap-finding; the code is throwaway; refinement goes back to walk-plan |
| Tick a checkbox before verification passes | Per execute-task's gate loop, verification is non-negotiable |
| Pick a Curated-mode winner silently under auto-mode | Always render the side-by-side and wait for the user's explicit pick |
