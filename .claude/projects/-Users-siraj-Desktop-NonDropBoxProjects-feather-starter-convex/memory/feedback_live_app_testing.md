---
name: Live app testing is mandatory after generator tests
description: Tests passing != app working. Always verify generated features in the running app via agent-browser. Record this pattern for every feature.
type: feedback
---

After generating a new feature, the verification sequence is:

1. **Typecheck** — `npm run typecheck` (catches type errors)
2. **Unit tests** — `npm test` (catches logic errors)
3. **Live app test** — start dev server, open browser, actually USE the feature

Step 3 is MANDATORY and catches issues that steps 1-2 miss:
- Convex mutations failing silently (zCustomMutation + Zod v4 issues)
- Convex module paths not deployed (hyphenated dirs, stale codegen)
- React components rendering but not interactive (event handlers not wired)
- Missing data in lists (queries returning empty despite data existing)

**Why:** The todos example passed 346 tests with 100% coverage but the create form didn't work in the live app. The Convex dev server hadn't deployed the new modules.

**How to apply:** After any `gen:feature` run:
```bash
# 1. Typecheck
npm run typecheck

# 2. Tests
npm test

# 3. Live test via agent-browser
AB_SESSION="${PILOT_SESSION_ID:-default}"
agent-browser --session "$AB_SESSION" open http://localhost:5173
agent-browser --session "$AB_SESSION" snapshot -i
# Navigate to the new feature page
# Create an item via the form
# Verify it appears in the list
# Edit/delete it
# Screenshot for evidence
agent-browser --session "$AB_SESSION" close
```

**For stress-testing generators with sub-agents:**
- Spawn agents to generate features (typecheck + test)
- Then do live app testing on main (dev server runs on main, not worktrees)
- Both rounds of testing are required before declaring the generator working
