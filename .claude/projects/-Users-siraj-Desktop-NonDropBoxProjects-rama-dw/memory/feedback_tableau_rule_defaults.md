---
name: feedback_tableau_rule_defaults
description: "The \"tableau rule\" — decide with intelligent defaults + easy power-user override; reuse prior decisions; only ask when genuinely in doubt"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 15843b3a-71fa-449e-817c-ca06df5864ca
---

Make decisions the way Tableau ships features: **an intelligent default that handles ~80% of cases,
with an easy, discoverable way to drill in and override the details when something goes wrong.**
Don't gate on the user for choices a sensible default covers.

**Why:** the user buys into the process and wants momentum, not a quiz. Re-asking settled questions
wastes their time; over-engineering knobs nobody touches wastes effort. The 80/20 default + override
gives both speed and a safety valve.

**How to apply:**
- **Reuse prior decisions.** If a choice was already agreed or used in an earlier context (an ADR, a
  previous slice, an established pattern), assume the same unless I'm genuinely in doubt — don't
  re-litigate. E.g. for SAP cycle slices, reuse the #82 stack: typed columns, merge-on-DDIC-key,
  ADR-0009 watermarks, ADR-0010 data-driven curation, count gate, on-prem cron.
- **Pick the default, state it, move on.** Implement the 80% choice; make it overridable via config/
  env/flag where cheap; mention what I chose and how to override.
- **Ask only on genuine doubt** — a real fork where the wrong default is costly/hard-to-reverse and I
  can't resolve it from the code, the data, or precedent. Resolve fact-questions by checking metadata/
  data myself, not by asking.

Generalises [[feedback_propose_defaults_dont_gate]]. Batch any genuine questions per
[[feedback_grill_batch_all_questions]].
