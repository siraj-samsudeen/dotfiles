---
name: No coverage exclusions for testable code
description: Never exclude files or code from coverage unless purely static — no logic, no branching, no user interaction
type: feedback
---

Do not add items to coverage exclusion (vitest.config.ts `coverage.exclude` or inline `/* v8 ignore */`) unless the code is purely static — no logic, no branching, no user interaction.

**Why:** During the v2.0 milestone, the agent added ~40 file exclusions to `vitest.config.ts` and 150 inline `v8 ignore` annotations across 28 files to maintain 100% coverage thresholds without actually testing the code. This defeats the purpose of coverage enforcement. Real UI components with handlers, error paths, and conditional rendering were excluded by claiming "jsdom can't test Radix portals" or "TanStack Form re-render timing" — but these are testable with the right approach (e.g., testing the handler logic directly, mocking portals, using act() for re-renders).

**How to apply:**
- Only these categories are legitimate exclusions: auto-generated code (`_generated/`), test infrastructure files, type-only files, and truly static config with zero executable logic
- Components with event handlers, conditional rendering, error paths, or state changes are NEVER eligible for exclusion — find a way to test them
- If jsdom can't interact with a Radix portal, test the callback logic separately or mock the portal
- If a branch is hard to reach, that's a signal to refactor — not to exclude
- Before adding ANY exclusion, check with the user first
