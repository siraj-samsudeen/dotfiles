---
name: feedback-propose-defaults-dont-gate
description: "When a design has tunable knobs, propose concrete defaults with rationale — never leave TODO(human) blocks asking the user to fill in numbers"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 163eab0a-8362-4548-90a6-6d1e8480a688
---

When drafting a design spec, issue body, or config doc that includes tunable thresholds / cadences / batch sizes, **propose concrete defaults with one-line rationale each**. Don't leave `TODO(human)` blocks asking the user to fill in numbers they may not have a strong opinion on yet.

**Why:** User said "Never force them to decide, because we may not know." Defaults that ship in a config file are not blocking — they can be overwritten later when reality teaches you a better number. But TODO(human) gates the work behind a decision the user often can't make in the abstract. Rejecting the Learning-style "Learn by Doing" prompt for threshold values, specifically — the pattern fits real design decisions (which approach, which library) but not tunables.

**How to apply:**
- For numeric thresholds, batch sizes, timeouts, retry counts, etc.: **always propose a value** with a one-line rationale tied to the workload.
- The phrase "this is overridable in [config file]" should appear next to the defaults block.
- Reserve "your call" / Learn-by-Doing requests for **architectural** decisions (transport choice, write strategy, data model) — not tunables.
- If you genuinely don't know enough to propose a default, say "I'd propose X based on [reasoning]; sanity check?" rather than "TBD".

Related: [[feedback-curation-no-mechanical-defaults]] (different direction — for curation decisions, *don't* default mechanically; analyze per item).
