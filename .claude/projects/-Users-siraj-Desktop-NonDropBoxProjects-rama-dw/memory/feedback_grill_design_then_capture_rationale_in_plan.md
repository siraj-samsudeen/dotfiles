---
name: feedback_grill_design_then_capture_rationale_in_plan
description: "Grill the DESIGN decisions (alternatives + why) before writing a plan, and capture that reasoning IN the plan — never rush to a bare decisions-only plan"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 5ce1b284-9a38-4cb2-a88b-6b2335138942
---

Before writing an implementation plan, **walk the design decisions as a grill** — one at a time,
each with the real alternatives, their enabling/disabling behaviour, the trade-offs, and a
recommendation — and then **write that reasoning into the plan**, not just the settled choice. A
plan that records only "we chose X" is half a plan; the *why-not-Y* and the workflow-by-workflow
consequences are what a future reader (or the user, encountering new territory) actually needs.

**Why:** RB said the deploy-model design questions (rsync-vs-git deploy; deploy-while-a-load-runs;
lease-vs-flock single-writer scopes; liveness authority) were "totally new territory for me and even
for anyone coming in the future." Rushing to a bare plan throws away the most valuable artifact —
the structured reasoning that lets a human course-correct and lets the next agent not re-derive it.
This is the #215 lesson (2026-06-29): the grill *is* the deliverable; the plan captures it.

**How to apply:** for **genuinely design-shaping work** (new data models, naming, architecture,
business rules — per global CLAUDE.md §6), (1) enumerate the genuinely-open decisions; (2) grill
each (alternatives → enabling/disabling behaviour → trade-offs/risks → recommendation), one question
at a time; (3) write a **Design rationale / decision log** section in the plan that records, per
decision: the options considered, what each enables or forbids, the risks, and why the chosen one
won. Do this even under time pressure — especially when the area is new to the user.

**SCOPE (refined 2026-07-10):** this applies when open design decisions actually exist (the
design-shaping category of global CLAUDE.md §6 — the single definition of the gate). For
execution-type work, do NOT manufacture a grill — note which prior decisions the plan reuses and
proceed straight through. Relates to
[[feedback_always_file_issue_and_plan_before_coding]],
[[feedback_write_interpretation_not_just_facts]], [[feedback_grill_batch_all_questions]]. This is
team-durable — worth promoting into the repo's `issue → grill → plan` process (CLAUDE.md), not just
per-user memory.
