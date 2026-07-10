---
name: feedback_model_atomic_fact_rewrite_consumer
description: "When a report needs data, model the proper lowest-grain reusable fact and rewrite the report onto it — never shape a gold model to one report's grain"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 7230f41b-ea58-4964-a0d5-7a1359667ddf
---

When a specific report/dive needs data that isn't in gold yet, **build the proper lowest-grain, reusable fact at gold and rewrite the consumer onto it** — do NOT build a gold model shaped to that one report's grain (e.g. a daily × branch × tender aggregate). Siraj, #180 (2026-07-04): "Let's build a proper model, not one that is only for this query. Build the proper lowest grain model at the gold layer, and then we rewrite the query to use that rather than trying to make it fit this report's grain."

**Why:** a report-shaped gold table serves one consumer and rots; an atomic fact (`gold.tender_lines` = one payment-application × invoice) serves collections, tender-mix, AR, cash-recon, and the report — the report just does its own GROUP BY on top. This is ADR 0017 (gold atomic, no pre-aggregation) as a working habit.

**How to apply:** when scoping gold for a report ask "what is the lowest grain of this process?" and model that, source-discriminated for later cross-source union (like `gold.sales`). Push report-specific rollups/pivots into the consumer (Dive/Rill), not gold. Related: [[project_zakya_tenderwise_payment_dive]], [[project_sales_wide_380]], [[feedback_silver_fixes_dq_not_gold]].
