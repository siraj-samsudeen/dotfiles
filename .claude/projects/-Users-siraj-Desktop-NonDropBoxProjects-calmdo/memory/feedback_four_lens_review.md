---
name: Four-Lens Requirements Review
description: After generating requirements, run a structured review through 4 lenses before asking for approval — user journey, edge cases, testability, pitfalls
type: feedback
---

After generating requirements and BEFORE asking "does this look good?", run a four-lens analysis. Write findings to `.planning/REQUIREMENTS-REVIEW.md`.

### Lens 1: User Journey Completeness
Walk through every distinct user workflow end-to-end. For each step, verify a requirement exists. Look for:
- **Bootstrap gaps** — how does the first user get in?
- **Navigation gaps** — how does the user move between features?
- **Exit gaps** — can the user log out, undo, go back?

### Lens 2: Edge Cases
Document scenarios where requirements interact in non-obvious ways. Categorize by severity:
- **Critical** — will cause bugs (concurrent timers, cascade deletes, timezone handling)
- **Important** — affects UX quality (empty states, status inconsistencies)
- **Minor** — nice to handle, not blocking

These aren't missing requirements — they're implementation questions that phase plans must answer.

### Lens 3: Testability
Every requirement must have an unambiguous test. Flag requirements where:
- The acceptance criteria is unclear ("structured report" — structured how?)
- The trigger is undefined ("visit count is tracked" — what counts as a visit?)
- Multiple interpretations exist

### Lens 4: Pitfalls
Scan for:
- **Gold-plating risk** — features that could become rabbit holes (report generation, activity feeds)
- **YAGNI** — features that won't be used in the first month
- **Implicit requirements** — things everyone expects but nobody stated (responsive design, loading states, error handling)

**Why:** In CalmDo, the confirmation gate alone missed 8 journey gaps, 4 ambiguous requirements, and 13 edge cases across 55 requirements.

**How to apply:** Every time requirements are generated (new project, new milestone), run the four lenses before the approval gate. Present findings, then ask for confirmation.
