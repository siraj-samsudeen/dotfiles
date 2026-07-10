---
name: feedback_followup_items_filed_at_closeout
description: "Follow-ups noted during planning are RECORDED in the plan's Out-of-scope, NOT filed as issues yet; file them proactively at implementation close-out — don't make Siraj chase, and don't file prematurely"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 086ed6e0-d98f-4948-85b2-0a5328ed9044
---

Tangents/follow-ups are captured **by the phase they surface in**:

1. **Found during PLANNING** — record in the plan's **Out of scope**, each item **prefixed `Follow-up:`** so Siraj sees at a glance it's captured and doesn't have to switch attention. **Do NOT file an issue yet.** File them at **close-out** (after the plan is implemented + committed + deployed) — that's the best moment because by then the follow-up often has more detail or needs rewriting. At close-out, file proactively as part of definition-of-done and surface them; he should never have to force it.
2. **Found during IMPLEMENTATION** — when a tangential thing is hit mid-build, use the **background-task chip** (`spawn_task`): a self-contained prompt parked as a one-click session+worktree, current thread uninterrupted. This is the right tool for impl-time tangents specifically.
3. **Any time** — something independently valuable or urgent (security bug) → act immediately (issue or chip), don't wait.

**Why:** Siraj settled this 2026-06-24 during the #202 grill. He wants planning tangents parked in-place (the `Follow-up:` prefix is the signal) and only turned into issues once the work is done and the follow-up is well-understood; impl-time tangents are where the chip earns its keep. Pairs with [[feedback_implementation_closeout_loop]] (definition of done = code + commit + deploy + update tracker) — this pins *when* and *how* follow-ups become issues.

**How to apply:** Prefix every planning follow-up `Follow-up:` in Out of scope; don't ask "file it now?" mid-plan; file at close-out. Mid-implementation, offer/spawn a chip for tangents. The background-task chip = my `spawn_task` tool (a chip appears for Siraj → one click spins an isolated session+worktree; the spawned session has NO memory of the thread, so the prompt must be self-contained; ephemeral until clicked — for durable capture use a GitHub issue). Separately, document tunable-number rationale inline in the artifact a future editor opens (model header, seed schema), not only the plan/ADR.
