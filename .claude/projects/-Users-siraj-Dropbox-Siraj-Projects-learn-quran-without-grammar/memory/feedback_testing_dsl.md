---
name: Always use feather-testing-core DSL for tests
description: Write Playwright and RTL tests using feather-testing-core chainable DSL, never raw page.locator() calls
type: feedback
---

Always use feather-testing-core DSL when writing Playwright E2E or RTL tests. Install it if not present.

**Why:** User wants tests to be readable like user stories, not walls of `.locator()` chains. The DSL (`session.visit("/").assertText("...").clickButton("...")`) reads like intent, not implementation.

**How to apply:** Before writing any new test file, check if feather-testing-core is installed. If not, `npm install feather-testing-core`. Use `createPlaywrightSession(page)` adapter and write chainable assertions. Only fall back to raw Playwright if the DSL genuinely can't express it.
