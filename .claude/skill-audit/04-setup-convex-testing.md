# Audit: setup-convex-testing

**Status:** Analyzed — needs planning
**Verdict:** NEEDS WORK (3 fails, 3 warns)

## Context

- **Origin:** Custom skill, created for Convex + React + Vite testing infrastructure
- **Location:** `/Users/siraj/.claude/skills/setup-convex-testing/SKILL.md` (596 lines)
- **Standalone:** Not in feather namespace
- **References:** convex-test-provider npm package (authored by user)

## Findings

### FAIL (must fix)

**[F1] 596 lines — exceeds 500 line limit**
Tries to be tutorial + reference + decision guide all at once.
Fix: Break into SKILL.md (~300 lines) + `layer3-alternative.md` + move "Discovery" section out.

**[F2] "Discovery: Approaches We Investigated" (lines 82-117) is narrative storytelling**
Documents what was tried and failed — valuable for learning but violates "skills are references, not war stories."
Fix: Move to docs/DIALOGUE.md or a discovery.md file. Keep only the conclusion.

**[F3] Version-specific content (line 96)**
`"convex-test@0.0.41 returns these properties"` — will go stale.
Fix: Remove version number or move to Discovery file.

### WARN (should fix)

**[W1] Description is outcome-focused, not trigger-focused**
Current: `"Set up integration testing for React + Convex + Vite projects. Enables testing React components with real Convex backend function execution."`
Fix: Rewrite to `"Use when starting a React + Convex + Vite project that needs integration testing with real backend execution."`

**[W2] MECE Test Design section (lines 370-396) is educational, not setup**
A developer invoking `/setup-convex-testing` wants to set up testing, not learn MECE theory.
Fix: Move to a separate `test-patterns.md` reference file or trim to just the table.

**[W3] Three separate data seeding pattern sections are overwhelming**
Lines 409-447 show seed fixture, mutations, and direct DB insert approaches.
Fix: Keep `seed` fixture as primary, mention others exist in a one-liner.

### PASS (good)
- Installation steps are clear and numbered
- vitest.config.ts is concrete and copy-pasteable
- Troubleshooting section is practical
- References section is excellent
- Test Strategy Decision Guide table is well-structured
- Official architecture explanation is valuable context

## Open Questions for Planning

1. Should this move into feather namespace? (feather:setup-convex-testing?)
2. Is the Layer 3 alternative still relevant? Has the user moved to convex-test-provider exclusively?
3. Should the Discovery section be preserved anywhere or just deleted?
4. Is convex-test-provider still the right approach or has Convex released official tooling?

## Source File
- `/Users/siraj/.claude/skills/setup-convex-testing/SKILL.md`
