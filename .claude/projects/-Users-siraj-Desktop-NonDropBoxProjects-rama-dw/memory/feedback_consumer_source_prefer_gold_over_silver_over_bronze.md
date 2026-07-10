---
name: feedback_consumer_source_prefer_gold_over_silver_over_bronze
description: A consumer (dive/report/model) should read from the highest available layer — gold > silver > bronze; never point at bronze if the same fact exists higher
metadata: 
  node_type: memory
  type: feedback
  originSessionId: f8438068-2573-47a7-baef-39ed7e4079ec
---

When deciding where a consumer (a Dive, report, or downstream model) should read a fact from,
**prefer the highest layer that carries it: gold first, then silver, then bronze only as a last
resort.** Never point a consumer at a bronze table if the same data is already modelled in gold or
silver.

**Why:** Siraj, on the #537 PTP catch-tables decision (2026-07-09): "Ideally, we should not point
anything to bronze — if the same data is available in silver and gold, preference is gold then
silver. If it is not possible, then we move to bronze as a last resort." Bronze is source-faithful
raw; a consumer reading it bypasses all the conforming/DQ/naming done in silver+gold and couples the
consumer to raw source quirks.

**How to apply:** before wiring or repointing a consumer, check gold then silver for an equivalent
fact and reconcile that the numbers tie (e.g. #537 proved 100% of `bronze_ptp.sap_data_stn` material
docs are already in `silver_sap.inventory.stock_movements` → repoint to silver, not keep on bronze).
If nothing higher carries it, that's a signal to **build the silver/gold fact**, not to settle for
bronze. See [[project_ptp_bronze_curation_537.md]], [[feedback_model_atomic_fact_rewrite_consumer.md]], [[feedback_silver_fixes_dq_not_gold.md]].
