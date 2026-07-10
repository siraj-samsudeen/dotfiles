---
name: feedback_always_file_issue_and_plan_before_coding
description: Implementation workflow — file issue, grill-with-docs to surface design issues, THEN write the plan; never jump to editing code
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 055afca2-b724-479f-93ac-39ff07e7cde5
---

For any implementation task, follow this chain BEFORE touching code:

1. **File the GitHub issue** (`/file-issue-and-plan` → `file-issue`), posted to GitHub not local MD ([[feedback_post_to_github_not_local]]).
2. **Run `grill-with-docs`** to surface ALL design issues first — stress the approach against the domain model (CONTEXT.md / docs/adr), sharpen terminology, resolve open decisions. Do this BEFORE writing the plan, not after.
3. **Write the implementation plan** (`docs/plans/issue_<N>_<slug>.md`) only once grilling has settled the design.

Do not start editing files even after exploring and presenting a plan inline — the issue + grilled design + plan artifacts must exist first.

**Why:** Siraj buys into the *process*, not just the output (global CLAUDE.md rule 1). Grilling the design against the documented domain catches contradictions and unanchored choices before they calcify into a plan; an issue + written plan is the durable, reviewable record. Ad-hoc inline plans + immediate edits skip the tracking and the design scrutiny he relies on. Caught me 2026-06-06 mid-edit on the zakya crash-logging task — I had explored, presented a plan, and started editing without filing or grilling anything.

**How to apply:** When a task is "implement X now," call Skill `file-issue-and-plan` (which calls `file-issue`), then Skill `grill-with-docs`, then write the plan. Exploration/reading to inform the issue is fine; code edits are not, until the plan exists. Pairs with [[feedback_propose_defaults_dont_gate]] (propose, don't gate, inside the plan).

**REFINED 2026-07-10:** the chain is plan-*first*, not approval-*always*. What happens after the plan commit is governed solely by global CLAUDE.md §6 (design & risk gate — the single definition; not restated here). The old always-stop hard gate was deleted at Siraj's request — do not resurrect it.
