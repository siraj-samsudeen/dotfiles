---
name: build-tracer-show-dont-finalize
description: "Mid-design, Siraj says 'attempt to build — I want to see first': ship the minimal visible slice, park open forks explicitly, return to them after he's seen it"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 97ab642c-1e32-4e36-8d66-bffa7d22a754
---

During the #436 brainstorm (2026-07-07), with design forks still open (auth depth, cadence,
scoping), Siraj cut in: "attempt to build - then we will come back to looking at design
options, i want to see first." The tracer-first move was right: seeing the MOT dashboard live
resolved forks faster than debating them (auth went from open question → built → flipped on
prod the same day).

**Why:** Siraj evaluates architectures through working software, not through option lists.
A visible slice collapses hypotheticals; unresolved forks stay legible if parked explicitly.

**How to apply:** when he says "let me see it" / "build first" mid-design — stop grilling,
build the smallest end-to-end visible slice, list the parked forks in one numbered block at
delivery, and re-open them one at a time afterwards. Don't silently decide the parked forks
while building; stub them visibly (the `—` Target columns pattern). See
[[feedback-plan-approval-hard-gate]] — "build the attempt" is an explicit go signal for the
tracer, not for the whole epic.
