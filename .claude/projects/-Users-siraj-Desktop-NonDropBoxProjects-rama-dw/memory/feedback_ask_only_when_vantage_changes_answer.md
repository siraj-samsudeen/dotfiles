---
name: feedback_ask_only_when_vantage_changes_answer
description: "Decide obvious low-consequence things yourself; only ask when genuine risk + the human's different vantage could change the answer"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 1521391f-829c-465a-8f00-ff8e44122bcd
---

Don't ask about obvious things you can decide without much consequence — just decide and proceed.
**Ask only when there is a genuine design decision that carries real risk or requires
knowledge/judgment where the human might give different input because they see something you can't**
(business context, source-system reality, downstream use). The test isn't "is this a decision?" —
it's "could Siraj's different vantage point change the answer, and does getting it wrong matter?"

**Why:** during the StyleHR silver walkthrough (#385) I over-gated — asking to lock obvious low-stakes
calls and offering multi-choice menus for things I should just decide. Siraj corrected this twice.

**How to apply:** settle obvious/mechanical/low-consequence calls silently with a one-line rationale
and move on. Reserve questions for forks where (a) the downside of a wrong call is real AND (b) his
business/domain knowledge could legitimately override my data-driven default (e.g. "are agency staff
paid outside StyleHR payroll?" — a completeness fact only he knows). Prefer one sharp plain-text
question over a menu. Related: [[feedback_propose_defaults_dont_gate]], [[feedback_tableau_rule_defaults]],
[[feedback_no_askuserquestion_when_reading]].
