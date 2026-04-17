---
name: Test philosophy review required
description: All tests (new and existing) must be reviewed against testing philosophy before marking complete
type: feedback
---

When generating or modifying tests, have an agent review them against the testing philosophy (in `feather-testing-convex/TESTING-PHILOSOPHY.md` and `.claude/rules/feather-starter-convex-testing.md`) to ensure they are in sync.

**Why:** Tests written under time pressure or by agents optimizing for coverage can drift from the project's testing philosophy — testing implementation instead of behavior, using mocks incorrectly, or covering branches with ignore annotations instead of real tests.

**How to apply:**
- After writing new tests: run a review pass against the testing philosophy document
- For existing tests: audit them against the philosophy and fix any deviations
- This should be an explicit tracked task in any phase plan, not an afterthought
- The review checks: behavior vs implementation testing, correct mock usage, no unnecessary v8 ignore annotations, test isolation, and naming conventions
