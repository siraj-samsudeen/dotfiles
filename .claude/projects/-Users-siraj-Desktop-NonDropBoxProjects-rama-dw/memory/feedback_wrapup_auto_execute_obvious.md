---
name: feedback-wrapup-auto-execute-obvious
description: "Wrap-up: auto-execute obviously-beneficial zero-risk saves (fact-recording issue comments, doc syncs to shipped reality) and inform; gate ONLY items where Siraj might genuinely disagree"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: d40a4dc0-e026-4503-992a-d74e086dd11a
---

Siraj found it annoying to approve wrap-up items that were obviously beneficial and risk-free
(2026-07-08, #450 wrap-up: issue status comments + stale-doc syncs). The gate exists for
disagreement, not for ceremony.

**Why:** Approval requests have a cost — his attention. Spending it on items with no plausible
"no" answer trains him to rubber-stamp, which devalues the gates that matter (live-behavior
changes, outward comms, scope judgments).

**How to apply:** In /wrap-up (and generally): two tiers.
- **Auto + inform:** memory writes; issue comments that record what verifiably happened
  (evidence, status, traceability); closing an issue whose own acceptance criteria are met with
  evidence; doc edits that sync a doc to shipped, verifiable reality; commit+push+PR of such
  docs-only syncs; merged-branch/worktree hygiene ([[feedback-cleanup-merged-branches]]).
- **Gate:** anything changing live behavior (prod vars/deploys/DNS/schedules); outward comms to
  humans (Bala, RB); judgment calls (closing epics, declaring scope obsolete, priorities); new
  interpretation/generalization in ADRs or CONTEXT.md; destructive ops
  ([[feedback-destructive-ops-and-recoverable-design]]). Plan→implementation stays a hard gate
  ([[feedback-plan-approval-hard-gate]]) — this preference is about *records of finished work*,
  not about starting work.

Boundary cases settled 2026-07-08 — all three are AUTO: (1) filing follow-up issues for narrow
technical gaps with in-session context (report the link at wrap-up); (2) ADR/CONTEXT entries
recording decisions Siraj explicitly made — and when a new decision contradicts an old ADR,
never leave the inconsistency: rewrite it or mark it superseded with a pointer, agent's choice;
(3) shared-skill edits that encode an explicit instruction. Agent-inferred generalizations in
any of these stay gated. Encoded in the repo wrap-up skill's approval model.


**SUPERSEDED in part, 28-Aug-2026 (#2841).** The auto-execute principle stands, but the *format* changed: `/wrap-up` no longer reports housekeeping at all. A priority test splits DECISION (breaks/costs/blocks/rots if he never sees it — needs his authority or vantage) from HOUSEKEEPING (memory, fact-recording issue comments, criteria-met closes, doc syncs, narrow follow-up filings). Housekeeping executes silently and collapses to ONE count line. Decisions — max 4, severity-first — are asked via the `AskUserQuestion` tool as 2–4-option picks, recommendation first.

**Why:** Siraj ignores most wrap-up content; listing memory writes and issue comments costs attention without earning a decision. "Nothing needs you" is a valid wrap-up.

**How to apply:** if an option would read "yes, do the obvious thing" with no plausible no, it is not a decision — just do it. Headers name the work, never the sink.
