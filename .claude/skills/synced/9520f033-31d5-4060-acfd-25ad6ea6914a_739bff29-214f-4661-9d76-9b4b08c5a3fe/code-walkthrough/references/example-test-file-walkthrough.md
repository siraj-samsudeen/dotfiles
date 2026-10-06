# Reference Example — Full Walkthrough: Test File (`test_cli_init.py`)

This is the complete walkthrough of the first file in the feather-etl session (May 2026).
It was the starting point — no prior files had been discussed. The production code
(core.py and the CLI bridge) were explained afterward, in the sibling reference files.

Note: this file was originally walked through block by block with confirmation pauses
between each block. The full picture and key terms map were presented first, then Siraj
confirmed before each block. The final "full picture close" stitched everything together.
The compiled result below is the complete picture.

---

## The Code

```python
from pathlib import Path
import pytest
from typer.testing import CliRunner
from feather_etl.cli import app

@pytest.fixture
def runner() -> CliRunner:
    return CliRunner(mix_stderr=False)

def test_init_with_no_arg_stamps_files_into_cwd_if_empty(
    runner: CliRunner, tmp_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    monkeypatch.chdir(tmp_path)
    result = runner.invoke(app, ["init"])
    assert result.exit_code == 0, result.stderr
    assert (tmp_path / "feather.yaml").is_file()

def test_stamped_feather_yaml_content_matches_template(
    runner: CliRunner, tmp_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    monkeypatch.chdir(tmp_path)
    result = runner.invoke(app, ["init"])
    assert result.exit_code == 0, result.stderr
    content = (tmp_path / "feather.yaml").read_text()
    assert "defaults:\n  sample_threshold: 100000" in content
    assert "# sources:" in content
```

---

## Full Picture First

This is a **test file** for a CLI tool called `feather-etl`. It tests one command:
`init`. That command is supposed to stamp template files into a directory. The tests
verify that the files land in the right place with the right content.

```
Imports          ← bring in the tools
Fixture          ← configure the shared tool (CliRunner)
Test 1           ← does init create the file?
Test 2           ← does init put the right content in the file?
```

---

## Key Terms Map

**`Path` (from `pathlib`)** — A Python object representing a file or directory location.
Better than raw strings because it gives you methods like `.is_file()`, `.read_text()`,
and `/` for joining paths.

**`pytest`** — The testing framework. It finds functions named `test_*`, runs them, and
reports pass/fail.

**`@pytest.fixture`** — A decorator that marks a function as setup code that tests can
request by name. A reusable building block that pytest injects automatically.

**`tmp_path`** — A built-in pytest fixture. Gives each test its own fresh temporary
directory, automatically cleaned up afterward. You didn't write it — pytest provides it.

**`monkeypatch`** — Also a built-in pytest fixture. Lets you temporarily replace
attributes, environment variables, and the working directory, with automatic restoration
after the test.

**`CliRunner`** (from `typer.testing`) — A test harness for CLI apps. Lets you simulate
running a command from the terminal, inside your test, without spawning a subprocess.
Captures output and exit codes.

**`app`** — The actual CLI application object, imported from your production code. This
is the thing being tested.

**`runner.invoke(app, ["init"])`** — The moment the simulated CLI call happens.
Equivalent to a user typing `feather-etl init` in their terminal.

**`result.exit_code`** — Did the command succeed? `0` = success, anything else =
failure. Unix convention.

**`result.stderr`** — If the command failed, what error message did it print? Used in
the assert message so you see it when a test fails.

---

## Key Ideas

**1. Fixtures are injected by name.** When a test function declares `tmp_path` or
`monkeypatch` as a parameter, pytest sees those names and automatically calls the
corresponding fixture functions and passes the result in. You never call fixtures
manually.

**2. The test controls the environment, not the production code.** `monkeypatch.chdir(tmp_path)`
makes the production code think it's running in a specific directory — the production
code doesn't know it's being tested.

**3. Subprocess vs. in-process.** `CliRunner` runs the CLI function inside the same
Python process as your test. Without it, you'd spawn a real OS subprocess — your
`monkeypatch` changes wouldn't reach it, exceptions wouldn't give you tracebacks, and
you'd be testing a black box. CliRunner is a flight simulator, not a real plane: the
pilot (your CLI code) experiences everything normally, but you're in full control of the
environment.

---

## Block 1 — The Imports

```python
from pathlib import Path
import pytest
from typer.testing import CliRunner
from feather_etl.cli import app
```

Three groups:

| Import             | Where it comes from      | Role in the test           |
|--------------------|--------------------------|----------------------------|
| `Path`, `pytest`   | Python standard / pytest | Infrastructure             |
| `CliRunner`        | Third-party (typer)      | Test harness               |
| `app`              | Your own code            | The thing being tested     |

`from feather_etl.cli import app` is the only import from your own production code. Everything
else exists to put `app` in a controlled situation and make assertions about what it does.

`import pytest` is needed specifically for `pytest.MonkeyPatch` as a type annotation
in the test signatures. The fixtures themselves (`tmp_path`, `monkeypatch`) are provided
by pytest automatically — you don't import them.

---

## Block 2 — The Fixture

```python
@pytest.fixture
def runner() -> CliRunner:
    return CliRunner(mix_stderr=False)
```

`@pytest.fixture` registers this function with pytest. Any test that declares a parameter
named `runner` will receive the result of calling this function. You never call it yourself.

`-> CliRunner` is a type annotation — no runtime effect, but tells your editor that
`runner` is a `CliRunner` so autocomplete works correctly inside tests.

`CliRunner(mix_stderr=False)` — by default stderr and stdout get mixed together. Setting
this to `False` keeps them separate so `result.stderr` is purely errors. This matters
for the assert messages:

```python
assert result.exit_code == 0, result.stderr
```

If stderr were mixed with stdout, the failure message would be noisy. Keeping them
separate means when something goes wrong, you see exactly the error.

This fixture is a shared, pre-configured tool that every test in this file can pick up.
Without it, every test would write `CliRunner(mix_stderr=False)` itself.

---

## Block 3 — Test 1

```python
def test_init_with_no_arg_stamps_files_into_cwd_if_empty(
    runner: CliRunner, tmp_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    monkeypatch.chdir(tmp_path)
    result = runner.invoke(app, ["init"])
    assert result.exit_code == 0, result.stderr
    assert (tmp_path / "feather.yaml").is_file()
```

The name is long deliberately — it's documentation. A failing test name alone should
tell you exactly what broke without reading the body.

Three fixtures requested. `runner` is your own fixture from Block 2. `tmp_path` and
`monkeypatch` are built-in pytest fixtures. pytest sees these names, finds the matching
fixtures, and injects the results. You never wire this up manually.

`-> None` — tests don't return values. They either pass or raise an `AssertionError`.

The body follows Arrange → Act → Assert:

```
monkeypatch.chdir(tmp_path)          ← Arrange: control the environment
result = runner.invoke(app, ["init"]) ← Act: run the command
assert result.exit_code == 0, ...    ← Assert: did it succeed?
assert (tmp_path / "feather.yaml")... ← Assert: did it do the right thing?
```

`(tmp_path / "feather.yaml").is_file()` — the `/` operator on a `Path` object joins
path segments. `.is_file()` returns `True` if something exists at that path and is a
file (not a directory).

---

## Block 4 — Test 2

```python
def test_stamped_feather_yaml_content_matches_template(
    runner: CliRunner, tmp_path: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    monkeypatch.chdir(tmp_path)
    result = runner.invoke(app, ["init"])
    assert result.exit_code == 0, result.stderr
    content = (tmp_path / "feather.yaml").read_text()
    assert "defaults:\n  sample_threshold: 100000" in content
    assert "# sources:" in content
```

The setup is identical to Test 1 — same fixtures, same first three lines. Each test is
fully self-contained. It doesn't borrow state from the previous test. Run them in any
order, run only one — it still works.

What's new:

`content = (tmp_path / "feather.yaml").read_text()` — Test 1 asked "does the file
exist?" This test goes one level deeper — "what's inside it?" `.read_text()` opens the
file, reads the entire contents as a string, and returns it.

```python
assert "defaults:\n  sample_threshold: 100000" in content
assert "# sources:" in content
```

`in` means "is this string a substring of `content`?" — not an exact match of the whole
file, just confirming these pieces are present.

`\n` is a newline character. The first assertion checks for this exact two-line chunk:

```yaml
defaults:
  sample_threshold: 100000
```

The indentation matters — YAML is whitespace-sensitive, so if the template stamped it
wrong, this assertion catches it.

`"# sources:"` checks for a commented-out section marker — verifying the template gives
users the right scaffolding, not just a bare file.

---

## Full Picture Close

Test 1 tests **existence**. Test 2 tests **correctness**. Together they answer two
distinct questions. This is a pattern worth internalising: one test, one concern. When
a test fails you want to know immediately whether the problem is "file wasn't created"
or "file was created but content is wrong."

```
Imports          ← bring in the tools
Fixture          ← configure the shared tool (CliRunner)
Test 1           ← does init create the file?
Test 2           ← does init put the right content in the file?
```

The runtime flow every test follows:

```
pytest injects fixtures
    → monkeypatch moves cwd to tmp_path
    → CliRunner simulates the CLI call in-process
    → result captures exit code + output
    → assertions verify behaviour
    → monkeypatch restores cwd automatically
    → tmp_path is cleaned up automatically
```

The production code (`app`) never knows it's being tested. It just runs — and the test
harness observes everything.
