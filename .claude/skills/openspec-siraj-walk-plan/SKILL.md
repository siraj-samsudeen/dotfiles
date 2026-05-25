---
name: openspec-siraj-walk-plan
description: >
  Author or walk through a per-commit plan file for an OpenSpec change.
  Plan files live at openspec/changes/<change>/plans/commit-N-<slug>.md
  and define the canonical 8-section shape that openspec-siraj-execute-task
  consumes. Use this skill whenever Siraj asks to draft, walk, refine, or
  revise a per-commit plan. Trigger on phrasing like "draft the plan for
  commit N", "walk the plan", "author commit-N plan", "plan walkthrough",
  "let's walk through commit N", or whenever an OpenSpec change has
  tasks.md locked but no plan file for the next commit. Defaults to the
  most-recently-modified change folder if no name is given.
---

# OpenSpec Siraj — Walk Plan

Plan files are the bridge between the across-the-change view (`tasks.md`)
and the per-commit execution (`openspec-siraj-execute-task`). They describe
ONE commit at a time with enough orientation for an implementing agent or
human reviewer to load the slice into their head in 60 seconds.

This skill defines the canonical 8-section shape, plus the 8
sub-perspectives that live inside §1. Both were derived empirically — a
3-way agent-implementation comparison (Sonnet R1 + Opus R1 + Sonnet R2 +
Opus R2 against the same Commit 1) showed that the polished shape flipped
Opus from YAGNI-violating to YAGNI-clean. The shape isn't decoration; it
materially affects what agents produce.

**Where this fits:** Stage 6 of the openspec-siraj pipeline — invoked after `openspec-siraj-stress-test-tasks` clears, before `openspec-siraj-execute-task` consumes the plan. Produces ONE per-commit plan file at a time. See `openspec-siraj-flow` for the full pipeline diagram, sibling-skills graph, and the artifact-tree convention. After authoring, run `/review-document` for the structural lens pass; for load-bearing commits, `openspec-siraj-stress-test-plan` empirically validates the plan before execution.

---

## When to use

- Authoring a fresh plan for a new commit after `tasks.md` is locked.
- Revising an existing plan when scope changes or YAGNI is discovered.
- After `openspec-siraj-stress-test-tasks` surfaces gaps that affect a
  specific commit's slice.
- Whenever Siraj says "draft commit N's plan" or "walk through the plan"
  or pauses on an OpenSpec change folder whose next commit lacks a plan.

## When NOT to use

- Authoring `tasks.md` (commit blocks across the change) — hand-edited
  per the six-section commit-block shape in `openspec-siraj-flow`.
- Authoring `spec.md` or `design.md` — separate concerns
  (`openspec-siraj-walk-decisions` for design; spec is hand-edited per
  the numbering / title rules in `openspec-siraj-flow`).
- Pure structural polish on a finished plan — use `review-document`.

## What this skill does NOT do

- Does not validate the plan empirically — that's `openspec-siraj-stress-test-plan`.
- Does not implement anything — that's `openspec-siraj-execute-task`.
- Does not author `tasks.md` (the cross-commit overview).
- Does not run the per-commit review gates by itself — author the plan, then invoke `review-document` and (optionally) `stress-test-plan` separately.

---

## The 8-section canonical shape

Every per-commit plan follows this shape. Sections appear in this order.
Sections §6–§8 are template stubs that fill in over the commit's life.

```
# Commit N — <short subject>

## 1. Full picture           ← multi-altitude orientation (8 sub-perspectives, see below)
## 2. Key terms              ← codebase-specific glossary; NOT Python language features
## 3. Key ideas              ← 2–3 named design insights for THIS commit
## 4. Tests to write         ← H3 per scenario; BDD English; code as *Implementation hints*
## 5. Implementation outline ← H3 grouped by file; floor-not-wall preamble; YAGNI directive
## 6. Open question          ← template stub; "_None._" when empty
## 7. Decisions taken        ← template stub; filled when contracts get changed mid-walk
## 8. Deviations             ← template stub; filled by execute-task at commit time
```

---

## §1 Full picture — 8 sub-perspectives

§1 is the load-bearing section. An agent who reads ONLY §1 (and skims §4)
should be able to start implementing. The 8 H3 sub-perspectives give
multi-altitude views — each is a question heading.

### `### What this commit ships?`

One-paragraph concept-level summary. Names the load-bearing contribution
(usually a pattern or a slice, not a feature list). Example from Commit 1
of `add-feather-init`:

> This commit establishes the verb-template skeleton every later verb
> will inherit. The file contents are minimal — just enough to stamp
> `feather.yaml` into the working directory — but the *shape* (core/cli
> split, register-pattern, accumulator dataclass) is the load-bearing
> contract.

### `### What is in scope?`

Bullet list of spec scenarios this commit closes. Each bullet uses the
canonical `<capability>.<num><letter>` form + the verbatim scenario title:

> - `init.1a` (Init with no arg stamps files into CWD, if empty)
> - `init.2a` (Stamped feather.yaml content matches template)

### `### What is out of scope?`

Bullet list of scenario themes deferred to later commits. **Themes only,
not specific scenario IDs**, and **NO commit numbers** (those are forward
references to other plan files):

> - skip-if-exists
> - `dir` resolution
> - `pyproject.toml` stamping

### `### What files this commit creates/modifies?`

Tree-shaped file listing with human-concrete role labels (NOT
symbol/code-level). A non-Python reviewer should grasp ownership:

```
src/feather_etl/
  cli.py                 ← entry point users type
  commands/init/
    core.py              ← does the init work
    cli.py               ← terminal wrapper for init
    cli_test.py          ← tests for this commit
```

### `### What the user sees externally — Before/After state?`

Observable behavior change. Zero internal symbols. Example:

> **Before:** running `feather init` errors (command doesn't exist).
> **After:** running `feather init` in an empty directory creates
> `feather.yaml` containing the template (`sample_threshold`, commented
> `sources:` placeholder). Process exits 0.

### `### What's still missing after this commit?`

Themes that remain after this commit lands — across-the-change arc view.
Themes only, no commit numbers:

> - skip-if-exists message
> - `dir` arg resolution
> - `pyproject.toml` stamping

### `### How the runtime flows after this commit — what calls what?`

Indented dynamic-view trace. Mid-detail: name the symbols being called
(unlike §1's file tree which is concept-level). Example:

```
CLI receives "feather init"
    → cli.py root app dispatches to init command
    → init() calls core.init_project(Path.cwd())
        → _stamp_feather_yaml writes FEATHER_YAML_TEMPLATE to cwd/feather.yaml
        → records files["feather.yaml"] = "created"
    → returns InitResult; process exits 0
```

### `### The layer map — which file owns which responsibility?`

Tabular detail view. Short file names (qualified by Layer column if
ambiguous). Responsibility column uses bullets, one technical idea each:

| Layer       | File          | Responsibility |
|-------------|---------------|----------------|
| Test        | `cli_test.py` | • Pins scenarios<br>• Uses `CliRunner` to invoke root `app`<br>• Asserts exit code + file state |
| Verb (CLI)  | `init/cli.py` | • Exports `register(app)`<br>• Defines `init()`<br>• Body calls `core.init_project(Path.cwd())` |
| Verb (Core) | `init/core.py`| • `FEATHER_YAML_TEMPLATE` constant<br>• `_stamp_feather_yaml` writer<br>• `init_project` orchestrator |
| Root        | `cli.py`      | • `typer.Typer(name="feather")`<br>• No-op `@app.callback()` for multi-command parsing<br>• `register_init(app)` wires verb |

**Two structural views, two behavioral views, one concept view, one
glossary-style view — same world from 8 angles. Each earns its place by
serving a different reader (concept reader / structural reader / runtime
reader / observable-state reader).**

---

## §2 Key terms

Codebase-specific terms, decorators, types, or patterns the reader will
encounter in later sections. **NOT Python language features** — assume
the reader knows `@dataclass`, `Path.cwd()`, etc.

Each term gets a bold header + sub-bullets, one idea per bullet:

```
- **`register(app)` pattern.**
  - Each verb exports `register(app: typer.Typer)` that attaches its
    `@app.command(...)` to a Typer app passed in.
  - Adding a new verb is one line in root `cli.py`.
  - Alternative would be module-level `@app.command` decorators triggered
    by import; the `register` pattern avoids that import-side-effect
    spaghetti.
```

If a term recurs from a previous commit's plan, link back rather than
restating: `"See Commit N's plan for the `_stamp_*` pattern; same shape."`

If this commit introduces no new terms, skip §2 — leave the header with
`_No new terms this commit._` as the body.

---

## §3 Key ideas

2–3 named design insights for THIS commit. Insights, not definitions.
Each names a pattern, points to where it lives, delivers a verdict. Same
bullet style as §2:

```
- **Verb-template skeleton.**
  - What matters in this commit is the *shape* every later verb copies —
    not the 4 lines of behavior.
  - `init_project` is 4 lines today; what matters is that those 4 lines
    live in `core.py`, the Typer adapter lives in `cli.py`, and the root
    wires it through `register(app)`.
  - Every later verb (`source add`, `curate`, `extract`) copies this triple.

- **YAGNI lean — no future-proofing.**
  - `init_project` takes only `target: Path` this commit.
  - **DO NOT add `dev`, `dir`, `feather_etl_source_path`, the `messages`
    field, or the `echo` helper this commit.** Each lands in the commit
    that demands it.
```

The YAGNI directive uses **DO NOT** in bold. Permissive wording ("X waits
for the commit that needs it") invites slip — agents pattern-match it as
permission to land things early. Empirical evidence: when this directive
was permissive, Opus R1 added a 4-field `InitResult`; when it was
directive, Opus R2 added 2 fields.

---

## §4 Tests to write

H3 heading per scenario, using the **verbatim spec.md title** + scenario
ID in parens. Each scenario gets BDD English Given/When/Then up top,
code in an *Implementation hints* sub-bullet:

```markdown
### Init with no arg stamps files into CWD, if empty (`init.1a`)

- **Given:** an empty working directory.
- **When:** the user runs `feather init` with no arguments.
- **Then:** the command exits 0 and a `feather.yaml` file exists in that
  directory.
- *Implementation hints:*
  - Set up with `monkeypatch.chdir(tmp_path)` and `CliRunner()`.
  - Invoke as `runner.invoke(app, ["init"])`.
  - Assert `result.exit_code == 0` and `(tmp_path / "feather.yaml").is_file()`.
```

**English is the contract. Code is the suggestion.** An agent reading
the Then line should know what to assert before reading the
*Implementation hints*. The hints are only there because writing pytest
commands from scratch is friction.

Test function names mirror scenario titles verbatim (snake-cased) — per
`docs/testing.md`. The H3 heading already gives the agent the right
function name by snake-casing.

---

## §5 Implementation outline

Two structural rules govern §5:

**Floor, not wall** — open with a preamble:

> **Floor, not wall:** bullets below describe the smallest impl that
> satisfies §4 tests.

This converts §5 from prescription ("you must write these") into floor
("nothing less; more if the test demands"). Without this preamble,
agents (and reviewers) read §5 as a wall.

**H3 grouped by file** — each `### <file path> — <one-line role>` becomes
a section. Inside, deliverables use bold-header + sub-bullets when more
than one deliverable lives in the file; flat bullets when only one:

```markdown
### `core.py` — template + dataclass + stamper + orchestrator

- **YAML template constant.**
  - Module-level `FEATHER_YAML_TEMPLATE: str`.
  - Verbatim content from spec Req 2.
  - Uses `sample_threshold: 100_000`.
- **Frozen result dataclass.**
  - `@dataclass(frozen=True) class InitResult`.
  - Field 1: `target: Path`.
  - Field 2: `files: dict[str, Literal["created", "skipped"]]`.
- **Per-file stamper.**
  - `_stamp_feather_yaml(target, files)`.
  - Writes the template to `target/feather.yaml`.
  - Records `files["feather.yaml"] = "created"`.
- **Orchestrator.**
  - `init_project(target: Path) -> InitResult`.
  - Allocates `files = {}`.
  - Calls `_stamp_feather_yaml(target, files)`.
  - Returns `InitResult(target=target, files=files)`.

### `commands/init/cli.py` — Typer adapter for the verb

- Exports `register(app)`.
- Decorates a parameterless `init()` function.
- Body calls `core.init_project(Path.cwd())`.
```

**Mix of bold-headers and flat bullets is principled, not lazy** — use
bold when sub-ideas need separating, flat when a single deliverable's
ideas read as one bullet list.

When a §5 deliverable LOOKS like YAGNI but actually isn't, call it out
explicitly inline (e.g., the no-op `@app.callback()` is required this
commit to keep Typer in multi-command mode — an agent told "strip YAGNI"
would otherwise delete it).

---

## §6 Open question — template stub

```markdown
## 6. Open question

_None._
```

If there's a genuine open choice (e.g., literal vs metadata-based
version pin), use a single bullet stating the question + the
provisionally-chosen default + an invitation to push back. Otherwise the
section stays empty.

---

## §7 Decisions taken — template stub

```markdown
## 7. Decisions taken

Decisions that change a previously-stated contract or convention. Note
any out-of-band follow-up.

_None._
```

Use when the plan walk surfaces a needed change to spec / design /
testing / tasks docs. Each entry names the change + the out-of-band
follow-up (e.g., "update `spec.md` Req 2 from `100000` to `100_000`").
This is how plan-walk findings cascade out to the rest of the change
folder.

---

## §8 Deviations — template stub

```markdown
## 8. Deviations

Executor deviations from this plan, recorded before commit with a
one-line rationale.

_None._
```

This section is filled by `openspec-siraj-execute-task`, not by the plan
author. If the executor adds a deliverable, drops one, renames a symbol,
or otherwise diverges from §5 during impl, they record the deviation
here before the commit lands.

---

## Tone rules

- **Question-style H3 headings** throughout §1 ("What this commit ships?"
  not "Overview").
- **Preferred bullet style:** bold header + sub-bullets, one idea per
  bullet. Apply wherever a list has 2+ items with distinct sub-ideas.
- **BDD English up top, code as *Implementation hints* below.** §4's
  Given/When/Then is the contract; code is the convenience.
- **Floor-not-wall preamble** at the top of §5.
- **No forward references** — to other plans, other commits, future
  sections. `tasks.md` carries cross-commit links; `design.md` carries
  Decision N anchors; the plan stays self-contained.
- **Empty stubs in §6/§7/§8** are templates that fill in over the
  commit's life. Don't delete them just because they're empty.
- **Cross-doc anchors verbatim** — spec.md scenario titles word-for-word;
  symbol names exact; scenario IDs in canonical form.

---

## Checklist (for repeat-use scans)

After drafting, scan and tick:

**Section presence:**
- [ ] §1 Full picture — present, with all 8 H3 sub-perspectives?
- [ ] §2 Key terms — present (or `_No new terms this commit._`)?
- [ ] §3 Key ideas — 2–3 named insights, each with bold header + sub-bullets?
- [ ] §4 Tests to write — H3 per scenario with verbatim title + scenario ID?
- [ ] §5 Implementation outline — floor-not-wall preamble + H3 per file?
- [ ] §6 Open question — present (`_None._` if empty)?
- [ ] §7 Decisions taken — present (`_None._` if empty)?
- [ ] §8 Deviations — present (`_None._` if empty)?

**Sub-perspective coverage in §1:**
- [ ] What this commit ships? — concept-level paragraph
- [ ] What is in scope? — scenario IDs + verbatim titles
- [ ] What is out of scope? — themes, no commit numbers
- [ ] What files this commit creates/modifies? — tree with human-concrete labels
- [ ] What the user sees externally — Before/After state? — observable, zero internals
- [ ] What's still missing after this commit? — themes, no commit numbers
- [ ] How the runtime flows — what calls what? — indented symbol-level trace
- [ ] The layer map — which file owns which responsibility? — table with bulleted cells

**Structural rules:**
- [ ] §3 uses **DO NOT** for YAGNI directives (not permissive "waits for…")?
- [ ] §4 has BDD English up top, code as *Implementation hints* sub-bullet?
- [ ] §5 has the "Floor, not wall" preamble?
- [ ] §5 deliverables use bold-header + sub-bullets where they have multiple sub-ideas?
- [ ] No forward references (`see §N`, "Commit M does X")?
- [ ] No dead-link footnotes (`(Decision N)` without inline content)?
- [ ] No restatement of training data (pytest commands, etc.)?
- [ ] No restatement of `docs/testing.md` cadence?
- [ ] Each fact has ONE canonical home — not duplicated in spec / design / tasks?

**After ticking:** run `review-document` for the final lens pass.

---

## Anti-patterns

- **"Land final shape now" trap.** Decision N in design.md shows the
  across-the-change target shape; an agent (or human) reads this as
  "land all of it in Commit 1." This is the single biggest failure
  mode — Opus R1 made this exact mistake. Counter with strict YAGNI
  in §3 and per-commit specifics in tasks.md.
- **Empty section noise.** Template stubs in §6/§7/§8 are useful;
  empty bullets elsewhere are noise. Delete content-free sub-sections
  (e.g., §2 when no new terms).
- **Forward references to other plans.** "See Commit 2's plan" creates
  an inherited expectation that breaks when Commit 2's plan doesn't
  exist yet. Each plan stands alone.
- **Over-detailing what `testing.md` covers.** RED→GREEN→coverage
  cadence lives in `testing.md`. Don't restate per commit.
- **Stating training data.** pytest invocations, standard library
  methods, Python conventions — drop. Trust the reader's training.
- **Code embedded in prose.** §4's Given/When/Then in English; code in
  *Implementation hints* sub-bullets. Don't mix.
- **Run-on paragraphs in §3 or §5.** Always bullet when distinct ideas
  exist.

---

## Section-by-section role for the executor

The plan file feeds `openspec-siraj-execute-task`. Each section serves a different read by the executor:

- **§1** orients (file tree, runtime flow, before/after). An executor who's read §1 loads the slice into head before any test or code.
- **§2** provides the glossary for unfamiliar patterns mid-impl.
- **§3** gives design intent — especially the YAGNI directive that shapes what the executor MUST NOT add.
- **§4** is the test list — executor writes these first (RED), runs them to confirm RED, then GREEN after impl.
- **§5** is the impl checklist.
- **§6** lets the executor surface a question that wasn't resolved at plan-walk time.
- **§7** captures any contract changes the executor needs to make upstream (spec.md tweaks, testing.md updates).
- **§8** records any divergence from §5 before committing.

If `execute-task` can't find a plan for the next commit, it either invokes this skill OR halts and asks the user.

---

**Next:** `/review-document` on the freshly-authored plan (structural lens pass), then for load-bearing commits `/openspec-siraj-stress-test-plan` (empirical validation), then `/openspec-siraj-execute-task`. See `openspec-siraj-flow` for the full Stage 6 pipeline.
