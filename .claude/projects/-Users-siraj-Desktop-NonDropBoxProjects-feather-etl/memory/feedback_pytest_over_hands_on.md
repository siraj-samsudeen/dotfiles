---
name: Deprecate hands_on_test.sh; all tests belong in pytest
description: scripts/hands_on_test.sh is deprecated — don't add new checks; migrate related checks to pytest when touching adjacent code
type: feedback
originSessionId: f9e63b32-f092-4c35-8523-edfddbac5674
---
`scripts/hands_on_test.sh` is considered deprecated. Do not add new checks to it. When a change would modify or break existing entries in that file, delete those entries and add equivalent coverage in pytest.

**Why:** The shell script was created by an agent and duplicates what pytest already does — fixtures, subprocess invocation, and assertions are all cleaner in Python with real DuckDB fixtures (per existing project convention). Maintaining two test suites causes drift; fixing bugs in one doesn't propagate to the other.

**How to apply:**
- Never add a new `check "..."` line to `hands_on_test.sh`.
- When touching CLI behavior, locate existing hands_on_test.sh entries covering that behavior, delete them, and recreate the coverage as pytest cases in `tests/`.
- Prefer subprocess-based pytest (`subprocess.run(["feather", ...])`) for end-to-end CLI checks so the coverage loss is nil.
- Full removal of the file is out of scope for incidental work — migrate what the current change touches, leave the rest.

**Origin:** User direction during issue #16 brainstorming (2026-04-13). I was about to extend `hands_on_test.sh` with a new discover check; user corrected that all new and relevant adjacent checks should live in pytest.
