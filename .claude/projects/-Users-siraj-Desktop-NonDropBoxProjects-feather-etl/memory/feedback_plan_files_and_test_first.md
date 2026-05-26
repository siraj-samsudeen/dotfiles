---
name: feedback-plan-files-and-test-first
description: "openspec-siraj-execute-task mini-plans live on disk under openspec/changes/<change>/plans/<N>-<slug>.md and lead with the test list, not impl deliverables"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: e4d75b8a-b7a9-4f37-9640-5a4ec13d4ba5
---

Two locked rules for `openspec-siraj-execute-task` mini-plans:

1. **Plans are files, not chat text.** Each commit's mini-plan goes to `openspec/changes/<change>/plans/<N>-<slug>.md`. Chat carries a ≤15-line Preflight that points at the file. The file is the user's reviewable artifact (opened in editor); the Preflight is the altitude pointer.

2. **Plans are test-first.** `docs/testing.md §2` locks the cadence (write tests → RED → impl → GREEN → coverage). The plan file leads with the test list (function names, given/when/then, spec refs). Impl deliverables follow as "what the tests force into existence." Verification commands sit at the bottom.

**Why:** Matches the existing pattern from [[feedback_preflight_as_md]] — in-chat Preflight stays light; full design detail goes to a file the user reviews in an editor. And listing impl-first reads as "tests are an afterthought" — which testing.md §2 explicitly rejects.

**How to apply:** Before writing any code under this skill, write the plan file. Then print a Preflight in chat pointing at it. The plan file leads with tests, not impl. If the user objects to the path convention (e.g., wants flat `docs/plans/PLAN0001-*`), accept and update; default is the scoped form under the change folder so plans survive `opsx:archive` with the rest of the change.

Skill file patched 2026-05-20 to encode both rules (new "Plan persistence" + "Test-first ordering" subsections under Step 1, plus two new anti-pattern rows).

Related: [[feedback_user_execute_default]] · [[feedback_preflight_as_md]] · [[feedback_plan_preflight]]
