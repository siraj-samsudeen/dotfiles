# Reference Example — Full Walkthrough: CLI Bridge (`cli/init.py`)

This is the complete walkthrough of the third file in the feather-etl session (May 2026).
It is the best example of the skill in action — full picture first, block by block with
design callouts, and a loop-closed close that stitches all three files together.

The two files that preceded this one (the test file and core.py) were already explained
before this walkthrough. References to "the previous session" or "what we've already seen"
refer to those. Their full walkthroughs are in the sibling reference files.

---

## The Code

```python
from pathlib import Path

import typer

from feather_etl.commands.init import core


def echo(msg: str) -> None:
    typer.echo(msg, err=True)


def register(app: typer.Typer) -> None:
    @app.command(name="init")
    def init(dir: str | None = None, dev: bool = False) -> None:
        result = core.init_project(Path.cwd(), dev=dev)
        for m in result.messages:
            echo(m)
```

---

## Full Picture First

```
echo          ← thin wrapper: prints to stderr via typer
register      ← wires the init command into the CLI app
  └── init    ← the command itself: calls core, prints messages
```

This file is the **bridge** between the CLI layer and the domain layer. It doesn't do
any real work — it translates a terminal invocation into a call to `core.init_project`
and prints whatever messages come back. That's its entire job.

The runtime flow when a user types `feather-etl init`:

```
CLI receives "init"
    → register has already wired init() to that command name
    → init() calls core.init_project(Path.cwd())
        → core does the real work, returns InitResult
    → init() loops over result.messages and echoes each one to stderr
    → process exits
```

How this file connects to everything already seen:

| Layer    | File          | Responsibility                                          |
|----------|---------------|---------------------------------------------------------|
| Test     | test_cli.py   | Verifies the command works end to end                   |
| CLI      | this file     | Receives terminal input, calls core, prints output      |
| Domain   | core.py       | Does the actual work, returns InitResult                |
| Template | FEATHER_YAML  | The content stamped to disk                             |

---

## Block 1 — The Imports

```python
from pathlib import Path
import typer
from feather_etl.commands.init import core
```

You know `Path` well by now. Two new ones:

**`import typer`** — the CLI framework. `typer` turns Python functions into terminal
commands. You import the whole module here because you need multiple things from it —
`typer.Typer`, `typer.echo`, `typer.command`.

**`from feather_etl.commands.init import core`** — this pulls in the domain module from
the previous session. `core` is not a class or a function — it's the entire module. You
call things on it like `core.init_project(...)`. Importing the module rather than the
function directly is a deliberate style choice: it makes the call site read as
`core.init_project` which is self-documenting — you always know where `init_project`
lives.

---

## Block 2 — The `echo` Helper

```python
def echo(msg: str) -> None:
    typer.echo(msg, err=True)
```

One line of body. But the design choice matters.

`typer.echo` prints to stdout by default. `err=True` redirects to **stderr** instead.
This is Unix convention — normal output goes to stdout, status messages and logs go to
stderr. They can be separated by the shell:

```bash
feather-etl init 2>/dev/null   # suppress messages, keep output
feather-etl init 1>/dev/null   # suppress output, keep messages
```

Why wrap it in `echo` at all instead of calling `typer.echo(..., err=True)` directly?
Two reasons: keeps call sites clean, and if you ever want to change how messages are
printed — add timestamps, colour, logging — you change one function, not every call site.

---

## Block 3 — `register` and the `init` Command

```python
def register(app: typer.Typer) -> None:
    @app.command(name="init")
    def init(dir: str | None = None, dev: bool = False) -> None:
        result = core.init_project(Path.cwd(), dev=dev)
        for m in result.messages:
            echo(m)
```

This is the heart of the file. Three ideas to build up.

---

**`register(app: typer.Typer)`**

The outer function receives the `app` object — the same `app` imported in the test file.
It doesn't run the command. It **wires** the command into the app. This pattern lets each
command module register itself cleanly, keeping the main `app` definition free of clutter.
Somewhere in `feather_etl/cli.py`, you'd see `init.register(app)` being called.

---

**`@app.command(name="init")`**

A decorator that tells typer: "the function below is a CLI command, and its name on the
terminal is `init`." From this point, typing `feather-etl init` in the terminal routes
here.

Notice this decorator is *inside* `register` — it's applied at the moment `register` is
called, not at import time. This is intentional: the command is only registered when the
app is ready to receive it.

---

**The `init` function body**

```python
def init(dir: str | None = None, dev: bool = False) -> None:
    result = core.init_project(Path.cwd(), dev=dev)
    for m in result.messages:
        echo(m)
```

Two observations worth making explicit:

**`dir` is accepted but silently ignored.** `dir: str | None = None` appears in the
signature — which means the CLI will accept `feather-etl init some/path` without
erroring — but the body never uses `dir`. It always calls `Path.cwd()`. This is the same
YAGNI pattern spotted in the core layer. The hook is there, the behaviour isn't.

**`Path.cwd()`** — this is why `monkeypatch.chdir(tmp_path)` in the test worked. The CLI
always asks "what is the current working directory right now?" at call time. The test
pre-moves that directory to `tmp_path` before invoking, so `Path.cwd()` returns `tmp_path`.
The production code never knew it was being redirected.

The loop `for m in result.messages` is currently doing nothing useful — `core.init_project`
never appends to `messages`. But the pipeline is wired: when messages are added to the
domain layer, the CLI layer will print them without any changes here.

---

## Full Picture Close — The Loop Closed

Now you can see the full vertical slice from test to terminal:

```
test file
    → monkeypatch.chdir(tmp_path)       ← controls what Path.cwd() returns
    → runner.invoke(app, ["init"])      ← simulates the terminal call
        → register has wired "init" to the init() function
            → init() calls core.init_project(Path.cwd())
                → core stamps feather.yaml into tmp_path
                → returns InitResult with files and messages
            → init() echoes messages to stderr
    → test asserts exit code and file existence
```

Three files, one behaviour, cleanly separated by responsibility. That's the architecture.

The tests were not testing arbitrary behaviour — they were pinning down exactly these
lines of production code:

| Test                              | What it verified          | Where in production code           |
|-----------------------------------|---------------------------|------------------------------------|
| test_init...stamps_files          | feather.yaml exists       | `_stamp_feather_yaml` line 1       |
| test_stamped...matches_template   | content matches template  | `FEATHER_YAML_TEMPLATE` constant   |

---

## What Made This Walkthrough Work

- The full picture diagram opened before any detail — Siraj knew the shape first
- The runtime flow trace made execution concrete, not abstract
- The connection table explicitly named the other files and their roles
- YAGNI was called out twice by name — `dir` and the messages loop
- The `monkeypatch.chdir` / `Path.cwd()` connection was made explicit — the test and the
  production code were shown to be two halves of the same mechanism
- The loop-closed table at the end stitched all three files into one picture
- No padding. Every sentence earned its place.
