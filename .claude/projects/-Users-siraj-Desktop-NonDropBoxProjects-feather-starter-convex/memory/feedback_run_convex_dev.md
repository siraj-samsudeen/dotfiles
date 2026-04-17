---
name: Always run convex dev for API type generation
description: When adding new Convex functions/tables, run npx convex dev --once to regenerate API types. Don't claim "needs dev server" as an excuse.
type: feedback
---

When testing generated features or adding new Convex backend functions, ALWAYS run `npx convex dev --once` to regenerate `convex/_generated/api.d.ts` before typechecking.

**Why:** User pointed out that "can't typecheck without Convex dev server" is not an acceptable excuse. `npx convex dev` starts both Convex and frontend. `npx convex dev --once` does a single push to regenerate types. This should be automatic when testing generators.

**How to apply:** After running any generator that creates new `convex/{name}/` files, immediately run `npx convex dev --once` before attempting typecheck. If that fails (no deployment configured), at minimum note it as a known limitation rather than presenting it as "expected."
