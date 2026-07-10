---
name: feedback_grill_batch_all_questions
description: "When grilling, follow the skill default — ONE question at a time (each with a recommendation). Do not batch; reversed from the earlier batch-all/grouped guidance"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 055afca2-b724-479f-93ac-39ff07e7cde5
---

When running a grill skill (`grill-me`, `grill-with-docs`, or any interview-style design session), **follow the skill's default: ask ONE question at a time**, each with its recommended answer, and wait for the answer before the next. Do **not** batch questions — neither the whole tree at once nor topic-grouped chunks. Still keep [[feedback_grill_question_format]] (A/B/C or y/n, one-keystroke answers) and resolve in the docs anything answerable without asking.

**Why:** This preference flip-flopped and Siraj has now settled it on the skill default. "All at once" (2026-06-06, #67 zakya) → "topic-grouped batches of ~5-7" (2026-06-15, #81 SAP-bronze) → **"one at a time, skill default" (2026-06-24)**, after a single 8-question dump in the #202 gold-freshness grill. The one-at-a-time cadence lets him steer each branch and keeps later questions contingent on earlier answers — which is the whole point of a depth-first grill.

**How to apply:** After grounding in the docs, ask Q1 (with recommendation) → wait → Q2 → … Do not pre-emptively list the tree. Part of the impl workflow in [[feedback_always_file_issue_and_plan_before_coding]].
