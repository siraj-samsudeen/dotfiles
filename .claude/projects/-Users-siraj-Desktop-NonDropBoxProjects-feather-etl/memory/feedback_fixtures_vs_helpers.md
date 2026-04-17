---
name: Feedback: fixtures vs helper functions in tests
description: Fixtures are for lifecycle-scoped state; pure utility functions belong in helpers.py, not conftest fixtures
type: feedback
originSessionId: 40ece388-168f-4815-b61c-6d2aafde31a4
---
Fixtures manage lifecycle-scoped state — setup, teardown, database connections, temp directories. If a function has no lifecycle (no scope, no teardown, just takes input and returns output), it is a plain utility function, not a fixture.

**Why:** Wrapping a callable in a fixture makes it look like "test setup data" to readers — something being provided to the test. When it's actually a tool the test uses, that's misleading. A reader sees `write_config` in the signature and has to dig into conftest to discover it's a callable factory, not data. "Doesn't feel pytest-native" is not a real argument — the right question is whether the thing has a lifecycle.

**How to apply:** Pure utilities (e.g. `write_config(tmp_path, config) -> Path`) go in `tests/helpers.py` and are imported explicitly. `tmp_path` gets passed as a regular argument — visible at the call site, greppable, no injection magic needed. Reserve `conftest.py` for actual fixtures: copied database files, temp directories, connection objects with teardown.
