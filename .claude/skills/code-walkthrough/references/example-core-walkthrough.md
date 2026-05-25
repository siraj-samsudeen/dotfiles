# Reference Example — Full Walkthrough: Domain Layer (`core.py`)

This is the complete walkthrough of the second file in the feather-etl session (May 2026).
The test file had already been walked through before this. References to "the test file"
or "the previous session" refer to that walkthrough, in the sibling reference file.

---

## The Code

```python
from dataclasses import dataclass, field
from pathlib import Path
from typing import Literal

FEATHER_YAML_TEMPLATE: str = """\
# feather-etl project configuration
# Add sources with: feather source add
# sources:        # populated by `feather source add`
defaults:
  sample_threshold: 100_000   # rows; switch from LIMIT to TABLESAMPLE above this
"""

@dataclass(frozen=True)
class InitResult:
    target: Path
    files: dict[str, Literal["created", "skipped"]] = field(default_factory=dict)
    messages: list[str] = field(default_factory=list)
    feather_etl_source_path: Path | None = None

def _stamp_feather_yaml(
    target: Path,
    files: dict[str, Literal["created", "skipped"]],
    messages: list[str],
) -> None:
    (target / "feather.yaml").write_text(FEATHER_YAML_TEMPLATE)
    files["feather.yaml"] = "created"

def init_project(target: Path, dev: bool = False) -> InitResult:
    files: dict[str, Literal["created", "skipped"]] = {}
    messages: list[str] = []
    _stamp_feather_yaml(target, files, messages)
    return InitResult(target=target, files=files, messages=messages)
```

---

## Full Picture First

This is the **production code** that the tests from the previous session were testing.
It defines what `feather-etl init` actually does: write a template YAML file into a
target directory, and return a structured result describing what happened. It is the
thing the CLI calls when you type `feather-etl init`.

```
FEATHER_YAML_TEMPLATE    ← the content to stamp, stored as a constant
InitResult               ← the frozen record of what happened
_stamp_feather_yaml      ← private helper: writes one file, records it
init_project             ← public orchestrator: sets up, delegates, seals result
```

The runtime flow when the CLI calls `init_project(target)`:

```
init_project called
    → create empty files dict and messages list
    → call _stamp_feather_yaml
        → write FEATHER_YAML_TEMPLATE to disk
        → record "feather.yaml": "created" in files dict
    → wrap everything into frozen InitResult
    → return to CLI
```

---

## Key Terms Map

**`dataclass`** — A decorator that auto-generates boilerplate for a class: `__init__`,
`__repr__`, `__eq__`. Instead of writing all that yourself, you just declare the fields
and Python builds the class for you.

**`frozen=True`** — Makes the dataclass **immutable** — once created, you cannot change
any of its fields. Trying to do `result.target = something_else` raises a
`FrozenInstanceError`.

**`field(default_factory=dict)`** — For mutable default values like `dict` or `list`,
you can't write `files = {}` directly as a default in a dataclass — Python would share
that one dict across all instances. `default_factory` tells the dataclass: "call `dict()`
fresh for each new instance."

**`Literal["created", "skipped"]`** — A type annotation that restricts a value to one
of a fixed set of strings. Only `"created"` or `"skipped"` are valid — your editor will
warn you if you try to assign anything else.

**`Path | None`** — The field can hold either a `Path` object or `None`. `|` is Python
3.10+ shorthand for `Optional[Path]`.

**`FEATHER_YAML_TEMPLATE`** — A module-level constant (all-caps by convention) holding
the content of the template file as a plain string. The `"""\` starts a multi-line
string; the backslash immediately after suppresses the leading newline.

**`_stamp_feather_yaml`** — A private helper function (the leading underscore signals
"internal, not for outside use"). Does one thing: write the template file to disk.

**`init_project`** — The public function. This is what the CLI calls. It orchestrates
the work and returns an `InitResult`.

---

## Key Ideas

**1. Separation of concerns — helper vs. orchestrator.** `_stamp_feather_yaml` does the
physical work (write to disk). `init_project` is the coordinator — it sets up the
containers, calls helpers, and assembles the final result. Adding more stamps later
(e.g. `.gitignore`, `pyproject.toml`) means adding more helper calls, without changing
the orchestrator's shape.

**2. The result object carries the audit trail.** `InitResult` doesn't just say "it
worked." It records what files were touched and what happened to each one. The CLI's job
is easy — it just reads `result.files` and prints a summary. The logic of what happened
lives in the domain layer, not in the CLI layer.

**3. Mutation during construction, immutability after.** `files` and `messages` are plain
mutable dicts/lists while `init_project` is building the result — helpers mutate them
freely. Once they're wrapped into `InitResult` (which is `frozen=True`), they're locked.
Build freely, then seal.

---

## Block 1 — The Imports

```python
from dataclasses import dataclass, field
from pathlib import Path
from typing import Literal
```

Three imports, all standard library — nothing to install.

`from dataclasses import dataclass, field` — you need both: `dataclass` is the decorator,
`field` is the helper for declaring fields that need special behaviour like mutable
defaults.

`from pathlib import Path` — same as the test file. Represents a file system location
as an object.

`from typing import Literal` — `typing` is the standard library module for type
annotations. `Literal` restricts a type to a fixed set of values.

Compare to the test file's imports:

| Test file                       | Production file                         |
|---------------------------------|-----------------------------------------|
| `pytest`, `CliRunner`           | `dataclass`, `field`                    |
| `app` (the thing under test)    | `Path`, `Literal` (tools to build with) |

The test file imports the harness and the subject. The production file imports only what
it needs to do its actual job.

---

## Block 2 — The Template Constant

```python
FEATHER_YAML_TEMPLATE: str = """\
# feather-etl project configuration
# Add sources with: feather source add
# sources:        # populated by `feather source add`
defaults:
  sample_threshold: 100_000   # rows; switch from LIMIT to TABLESAMPLE above this
"""
```

All-caps name signals a module-level constant — not meant to change at runtime.

The `"""\` opening: `"""` starts a multi-line string. The `\` immediately after
suppresses the newline that would otherwise appear at the very start of the string.
Without it, the file would begin with a blank line.

The content itself has three deliberate design choices:
- `# sources:` is commented out — a hint to the user, not live config. The test in the
  previous session explicitly checked for this string.
- `sample_threshold: 100_000` — Python allows underscores in numeric literals for
  readability. `100_000` is the same as `100000`.
- Inline comments are documentation embedded in the template — they guide the user
  without requiring a separate README.

Why a module-level constant and not a file on disk? For a single small template, keeping
it as a string constant is simpler — no file path resolution, no file-not-found errors,
no packaging concerns.

---

## Block 3 — The `InitResult` Dataclass

```python
@dataclass(frozen=True)
class InitResult:
    target: Path
    files: dict[str, Literal["created", "skipped"]] = field(default_factory=dict)
    messages: list[str] = field(default_factory=list)
    feather_etl_source_path: Path | None = None
```

`@dataclass(frozen=True)` generates `__init__`, `__repr__`, and `__eq__` automatically,
and makes every field read-only after construction.

`target: Path` — required field, no default. Always supplied.

`files: dict[str, Literal["created", "skipped"]]` — the audit trail. Keys are filenames,
values are what happened to them. `default_factory=dict` creates a fresh empty dict per
instance — plain `= {}` would share one dict object across all instances, a classic bug.

`messages: list[str]` — human-readable messages the CLI can print. Same
`default_factory` pattern.

`feather_etl_source_path: Path | None = None` — optional, defaults to `None`. Not used
in the current code. The hook is there for future behaviour. **YAGNI.**

Note: `= None` uses a plain default, not `field(default_factory=...)`. Correct — `None`
is immutable, no risk of shared state.

**Sharp observation Siraj made:** the `default_factory` defaults are never actually
triggered by the orchestrator, which always passes `files` and `messages` explicitly.
They're defensive — protecting against direct construction that never happens in this
codebase. Redundant given how the orchestrator works.

---

## Block 4 — The Private Helper

```python
def _stamp_feather_yaml(
    target: Path,
    files: dict[str, Literal["created", "skipped"]],
    messages: list[str],
) -> None:
    (target / "feather.yaml").write_text(FEATHER_YAML_TEMPLATE)
    files["feather.yaml"] = "created"
```

The leading underscore: internal, not part of the public API. A helper for
`init_project` only.

Why pass `files` and `messages` in rather than returning them? This is the
mutation-during-construction pattern. `files` and `messages` are created in
`init_project` and passed into helpers so each helper can record what it did — writing
directly into the shared dict rather than returning values to be merged.

The two lines of body:

```python
(target / "feather.yaml").write_text(FEATHER_YAML_TEMPLATE)  # physical act
files["feather.yaml"] = "created"                             # record the act
```

One line does the work. One line records the work. Clean separation even within a
two-line function.

---

## Block 5 — The Orchestrator

```python
def init_project(target: Path, dev: bool = False) -> InitResult:
    files: dict[str, Literal["created", "skipped"]] = {}
    messages: list[str] = []
    _stamp_feather_yaml(target, files, messages)
    return InitResult(target=target, files=files, messages=messages)
```

`target: Path` — where to write. Always required.

`dev: bool = False` — accepted but never used in the body. **YAGNI.** The hook is there
for future behaviour without changing the function's interface.

`-> InitResult` — always returns an `InitResult`. The type annotation makes that
contract explicit.

Lines 1–2: create empty containers. These will be mutated by helpers as work is done.

Line 3: delegate to the helper. The orchestrator doesn't write files itself. If you
later add `_stamp_gitignore(target, files, messages)`, this is where it appears — one
line each. The orchestrator stays readable no matter how many files get stamped.

Line 4: seal the result. Everything that happened is now packaged into the frozen result
object. The mutable phase is over. The record phase begins.

---

## Full Picture Close

```
FEATHER_YAML_TEMPLATE    ← the content to stamp, stored as a constant
InitResult               ← the frozen record of what happened
_stamp_feather_yaml      ← private helper: writes one file, records it
init_project             ← public orchestrator: sets up, delegates, seals result
```

And the connection back to the tests closes:

| Test                              | What it verified          | Where in production code         |
|-----------------------------------|---------------------------|----------------------------------|
| test_init...stamps_files          | feather.yaml exists       | `_stamp_feather_yaml` line 1     |
| test_stamped...matches_template   | content matches template  | `FEATHER_YAML_TEMPLATE` constant |

The tests weren't testing arbitrary behaviour — they were pinning down exactly these two
lines of production code.
