---
name: feedback_persist_handgathered_ops_knowledge
description: "Operational/infra knowledge you discover by hand (deploy topology, runtime IDs, gotchas) → write it to docs/agents/ so future agents don't re-discover it; don't leave it in the transcript"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 2ebd7356-7547-4780-8f20-6162fb99899a
---

When you work out operational/infrastructure knowledge by hand during a task — how a service deploys, runtime/resource IDs, a non-obvious gotcha — **persist it to a place discoverable to future agents** (`docs/agents/`, alongside `issue-tracker.md` / `triage-labels.md` / `parallel-agents-worktrees.md`), and link it from `CLAUDE.md`. Don't let it die in the transcript.

**Why:** Siraj's explicit ask (#205, 2026-06-24): after I reverse-engineered the Railway/Rill deploy model by hand, he said "write to a place discoverable to future agents so we avoid this work for future agents." Hand-gathered infra knowledge is exactly what git/code can't tell the next agent.

**How to apply:** at close-out, scan for operational facts you had to discover (not derive from code). Route them to a `docs/agents/*.md` reference doc (spawn a chip if it's out of scope for the current task), AND a concise memory entry for the sharpest gotchas (cross-session reach). Extends [[feedback_implementation_closeout_loop]] and [[feedback_followup_items_filed_at_closeout]] from *task* close-out to *knowledge* close-out. Example output: [[reference_rama_dw_deployment_topology]].

**Refinement (#229, 2026-06-25):** if the discovery *corrects or extends an existing ADR's premise*, **fold it into that ADR** — update the ADR's title + conclusions and embed the evidence there — rather than spinning up a standalone `docs/agents/` doc. Siraj: "rather than a separate document, update the ADR… as we discover new things, update existing ADRs." An ADR is the living record; a parallel doc fragments it. Standalone `docs/agents/` is for hand-gathered knowledge that *doesn't* belong to an existing ADR. (Concretely: I'd written `docs/agents/box-to-hana-network-path.md` correcting ADR 0011's "HANA on the office LAN" error; he had me fold the path + probe-evidence table into ADR 0011 and delete the doc. The original ADR wording stays in git history — that's fine, the ADR moves forward.)
