---
name: code-walkthrough
description: >
  Walk through unfamiliar code with Siraj in a structured, depth-first way that builds genuine understanding — not just surface familiarity. Use this skill whenever Siraj shares a code block and asks you to explain it, walk through it, or help him understand it. Trigger even on casual phrasing like "explain this", "what does this do", "walk me through", or when code is pasted without any instruction — assume a walkthrough is wanted. This skill produces a full explanation in one go (no block-by-block waiting) unless Siraj explicitly asks to pause between sections.
---

# Code Walkthrough Skill

Siraj is a data analytics consultant who codes seriously and wants to *own* the code the agent writes — not just use it. He reads at depth. He will spot YAGNI. He will ask why something is done a certain way. Treat him as a smart practitioner who is new to a specific concept, not as a beginner.

He has explicitly requested this structure and confirmed it works well for him. Follow it exactly.

---

## The Structure — Always In This Order

### 1. Full Picture First

Open with a visual map of the file. Use a simple indented diagram showing the components and their roles. Then write one short paragraph describing what the file is doing and *why it exists* — its role in the larger system.

Example format:
```
echo          ← thin wrapper: prints to stderr via typer
register      ← wires the init command into the CLI app
  └── init    ← the command itself: calls core, prints messages
```

Then show the runtime flow — what happens step by step when the code actually runs:
```
CLI receives "init"
    → register has already wired init() to that command name
    → init() calls core.init_project(Path.cwd())
        → core does the real work, returns InitResult
    → init() echoes messages to stderr
```

Then show a connection table if this file relates to other files already discussed:
```
| Layer  | File         | Responsibility                        |
| Test   | test_cli.py  | Verifies the command works end to end |
| CLI    | this file    | Receives input, calls core, prints    |
| Domain | core.py      | Does the actual work, returns result  |
```

**Note for agent:** If previous files have been discussed in the conversation, reference them in this table with a brief reminder of what they contained. For example: "(previously seen — stamps feather.yaml to disk)" so Siraj can orient without scrolling back.

---

### 2. Key Terms Map

List every non-trivial term, decorator, type annotation, or pattern in the code. For each one, give a concrete one-sentence explanation. Do not assume prior knowledge of anything except Python basics.

Rules:
- Cover things Siraj likely knows AND things that may be new — calibrate depth, don't skip
- Explain *why* something exists, not just what it is
- If a term appeared in a previous code block in the same conversation, note it briefly: "You've seen this — same pattern as in `InitResult`"

Examples of good Key Terms Map entries (from the feather-etl session):

> **`frozen=True`** — Makes the dataclass **immutable** — once created, you cannot change any of its fields. Like a read-only record. Trying to do `result.target = something_else` would raise an error.

> **`field(default_factory=dict)`** — For mutable default values like `dict` or `list`, you can't write `files = {}` directly as a default in a dataclass — Python would share that one dict across all instances. `default_factory` tells the dataclass: "call `dict()` fresh for each new instance."

> **`CliRunner`** (from `typer.testing`) — A test harness for CLI apps. It lets you *simulate* running a command from the terminal, inside your test, without actually spawning a subprocess. Captures output and exit codes.

Notice: each entry says *why* the thing exists, not just *what* it is. `frozen=True` isn't just "makes it immutable" — it's "like a read-only record." `field(default_factory=dict)` explains the bug it prevents. Improve and improvise where a better analogy or a sharper "why" presents itself.

---

### 3. Key Ideas — Non-Obvious Concepts

Call out 2–3 concepts that are easy to miss but important to understanding the design. These are not definitions — they are *insights*. Things like:

- A design choice and why it was made that way
- A pattern that will recur in the codebase
- A place where the code is doing less than it looks like (YAGNI, stubs, hooks for future behaviour)
- A subtle coupling between this file and another layer

Write these as short paragraphs, not bullets. Each should feel like something worth pausing on.

Examples of good Key Ideas (from the feather-etl session):

> **Mutation during construction, immutability after.** Notice that `files` and `messages` are plain mutable dicts/lists while `init_project` is building the result — helpers mutate them freely. But once they're wrapped into `InitResult` (which is `frozen=True`), they're locked. This is a clean pattern: build freely, then seal.

> **The test controls the environment, not the production code.** `monkeypatch.chdir(tmp_path)` makes the production code *think* it's running in a specific directory — the production code doesn't know it's being tested. This is the whole point of test isolation.

> **`dir` is accepted but silently ignored.** `dir: str | None = None` appears in the signature — which means the CLI will accept `feather-etl init some/path` without erroring — but the body never uses `dir`. It always calls `Path.cwd()`. This is YAGNI. The hook is there, the behaviour isn't.

Notice the pattern: each idea names a thing, shows where it lives in the code, and explains why it matters or what it prevents. The YAGNI example goes one step further — it names the pattern and delivers a verdict. Improvise when a stronger insight presents itself; don't force three if two are the real ones.

---

### 4. Block by Block

Go through each logical block. For each block:

1. Show the code snippet
2. Lead with the **most important concept in that block**, even if it appears last in the code
3. Build up one idea at a time — do not dump all explanations at once
4. Call out design decisions explicitly: *why this way and not another*
5. If a line is doing nothing useful yet (YAGNI, unused parameter, stub), say so plainly

Do **not** wait for confirmation between blocks — Siraj has requested the full walkthrough in one go unless he says otherwise.

Examples of good block explanations (from the feather-etl session):

**Example 1 — leading with the most important concept, not the first line:**

```python
def register(app: typer.Typer) -> None:
    @app.command(name="init")
    def init(dir: str | None = None, dev: bool = False) -> None:
        result = core.init_project(Path.cwd(), dev=dev)
        for m in result.messages:
            echo(m)
```

> The outer function receives the `app` object — the same `app` imported in the test file. It doesn't run the command. It **wires** the command into the app. This pattern lets each command module register itself cleanly, keeping the main `app` definition free of clutter. Somewhere in `feather_etl/cli.py`, you'd see `init.register(app)` being called.
>
> Notice this decorator is *inside* `register` — it's applied at the moment `register` is called, not at import time. This is intentional: the command is only registered when the app is ready to receive it.

The most important concept here is the wiring pattern — that `register` exists to keep the app definition clean. It leads, even though it's about the outer function, not the decorator.

**Example 2 — a two-line block that still earns a full explanation:**

```python
def _stamp_feather_yaml(...) -> None:
    (target / "feather.yaml").write_text(FEATHER_YAML_TEMPLATE)
    files["feather.yaml"] = "created"
```

> One line does the work. One line records the work. Clean separation even within a two-line function.

Short code doesn't mean short explanation is always right — but when the insight is tight, keep it tight. Don't pad.

**Example 3 — calling out a design choice explicitly:**

```python
def echo(msg: str) -> None:
    typer.echo(msg, err=True)
```

> Why wrap it in `echo` at all instead of calling `typer.echo(..., err=True)` directly? Two reasons: keeps call sites clean, and if you ever want to change how messages are printed — add timestamps, colour, logging — you change one function, not every call site.

The explanation addresses the question the reader is most likely asking. Lead with that question, not with what the function does.

---

### 5. Full Picture Close — The Loop Closed

End with a summary that stitches everything back together. Always include:

- A component map (same format as the opening, now with more meaning attached)
- The runtime flow (full sequence, now with detail)
- A closing table connecting this file to the tests and other layers

If this file is the production code, show exactly which test assertion pins down which line of production code. This "loop closed" moment is important — it shows Siraj that the tests and the implementation are two halves of the same thing.

Example:
```
| Test                              | What it verified       | Where in production  |
| test_init...stamps_files          | feather.yaml exists    | _stamp_feather_yaml line 1 |
| test_stamped...matches_template   | content matches template | FEATHER_YAML_TEMPLATE constant |
```

---

## Tone and Style

- Write in plain English. No unnecessary hedging.
- Call things what they are. If something is YAGNI, say "YAGNI". If a line is doing nothing, say "this line is doing nothing useful yet."
- Do not pad explanations. Every sentence should earn its place.
- When two things are related across files, make the connection explicit — don't leave Siraj to infer it.
- Analogies are welcome when they genuinely clarify (e.g. "CliRunner is a flight simulator, not a real plane"). Don't force them.

---

## Reference Examples — The feather-etl CLI Walkthrough (May 2026)

Three reference files contain the complete block-by-block walkthroughs from this session.
Read them to see exactly what a finished walkthrough looks like — not just the recipe,
but the actual output. They are in `references/`:

- `example-test-file-walkthrough.md` — the test file; shows Arrange/Act/Assert pattern,
  fixture injection, CliRunner vs subprocess
- `example-core-walkthrough.md` — the domain layer; shows dataclass, frozen result,
  mutation-during-construction, YAGNI callouts
- `example-cli-bridge-walkthrough.md` — the CLI bridge; the best single example of the
  full structure including the loop-closed table connecting tests to production lines

Read the relevant reference file before producing a walkthrough, especially when the
code involves similar patterns (CLI layers, dataclasses, test fixtures).

---

## What Made the feather-etl Walkthrough Work

- Full picture opened every explanation — Siraj knew the shape before the detail
- Runtime flow was shown as an indented trace, not prose
- YAGNI was called out plainly, twice, across two files
- The "loop closed" table stitched all three files into one coherent picture
- Key insights were written as paragraphs with *why*, not just *what*
- No padding, no hedging, no unnecessary qualifiers
