---
name: feedback_show_dq_details_never_bury
description: "When a probe finds a DQ tail/exception, show the actual rows+codes inline, never compress it to a vague \"follow-up\" line"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 42213d56-e0f3-42ed-a75b-16719c2e036b
---

When profiling surfaces a data-quality tail, unmatched keys, or an exception bucket, **show the
concrete details inline** — the actual codes, row counts, and time window — and don't collapse it to
a one-line "→ DQ follow-up". Burying it hides exactly what someone needs to act, and the summary
guess is often wrong (e.g. "2 unmatched plants, likely godowns" turned out to be 33 rows with a
*blank* `plant` string — a source-entry gap, not a master gap; the detail flipped the interpretation).

**Why:** Siraj acts on the specifics, not the headline; a deferred opaque follow-up is where real
defects go to die.

**How to apply:** On any exception/unmatched/tail finding, print the breakdown (values + counts +
dates) before proposing what to do about it. Then still carry a DQ test so it stays visible. Pairs
with [[feedback_write_interpretation_not_just_facts]].
