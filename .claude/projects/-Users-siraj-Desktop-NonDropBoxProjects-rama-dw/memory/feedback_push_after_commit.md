---
name: push-after-commit
description: "Push after commit when the work is complete; keep commits local while still building"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: adf8a418-c94b-4f66-b9a3-99330d3fafe1
---

Push to the remote default branch after committing **once the work is complete**. While work is
still in progress / mid-build, it is fine to keep commits local and unpushed.

**Why:** completed work belongs on `origin` so the team/CI and the rama_dw hourly gate (which reads
from origin) see it, and so issue-closing keywords (`Closes #N`, `Fixes #N`) actually fire — they
only fire on push to the default branch (leaving such a commit local makes the keyword a no-op and
led to manual `gh issue close`). But pushing every in-progress commit is noise/risk; local-until-done
keeps the building phase private. Confirmed 2026-06-24.

**How to apply:**
- **Work complete** → `git push` is the immediate next step (pre-authorized for this flow — no
  separate confirmation needed). Applies whether or not the commit closes an issue. Never
  `gh issue close` manually when a commit keyword will close it on push.
- **Still building** → keep commits local; don't push until the slice is done.
- Judgment call on "complete": a landed, verified slice (e.g. merged to main, a working feature)
  is complete; a WIP checkpoint mid-debug is not. When genuinely unsure, ask.
