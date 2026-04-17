---
name: Upstream update strategy — phased approach
description: Updates to downstream projects follow 3 phases: git upstream (now), feather update CLI (next), npm core package (later). Each phase adds value.
type: project
---

Downstream projects receive upstream updates in 2 phases, decided 2026-03-28 (updated 2026-03-29):

1. **Git upstream remote (now)** — `git pull upstream main`, resolve conflicts manually. Works today, zero build.
2. **`feather update` CLI (next)** — pulls upstream, auto-resolves non-conflicting files, flags conflicts with diff UI. Built in 999.1-05, to be wired in 999.4.

~~3. **npm core package (dropped 2026-03-29)** — user decided CLI + git upstream is sufficient. Extracting `@feather/core` adds complexity without enough benefit at this stage.~~

**Why:** Git upstream + `feather update` CLI covers the realistic update workflow. The generated/custom split (D-08, D-11) ensures `feather update` can hard-overwrite generated files safely.

**How to apply:** When designing DX features, ensure compatibility with git upstream + CLI update. No need to design for npm package separation.
