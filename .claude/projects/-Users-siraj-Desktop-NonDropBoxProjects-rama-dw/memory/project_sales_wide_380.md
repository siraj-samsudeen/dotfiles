---
name: sales-wide-380
description: "gold.sales_wide (was sales_enriched) — named merch hierarchy live on CEO Rill dashboard; bill_key/#356 fix; sales fact rework landed"
metadata: 
  node_type: memory
  type: project
  originSessionId: 9030781e-4fe4-4715-b7fa-a9974b68cb63
---

**#380 LANDED** (2026-07-03, merged to main via PR #381). `gold.sales_enriched` renamed →
**`gold.sales_wide`** (ADR 0042 tier grammar: atomic fact `gold.sales` · flatten `_wide` · summary
marts; **the `_wide` flatten introduces NO column** — degenerate keys/discriminators live on the
atomic fact, consumer ratios in Rill). The CEO Rill "Sales" dashboard now slices by the **named**
merch hierarchy (Fashion / Grocery / Home / Lifestyle → subdivision/category/subcategory from
[[project_category_master_261]]'s `category_hierarchy`, joined on `material_group`). The
`product_hierarchy` (PRDHA, <1% populated) + `division` (SPART, degenerate) **traps are retired**.

Fact adds on `gold.sales`: **`bill_key = source|store|sale_date|sale_invoice_no`** (#356 FIXED —
GoFrugal recycles `invoice_no` across dates → was 3.65× Bills undercount; verified exact 11,985,683);
`sale_invoice_no`/`sale_invoice_date` **basket keys** (rows self-identify — `invoice_no` = own doc;
basket key links a sale to its returns, D13); `customer_type` (B2B/B2C from Zakya `gst_treatment`,
GoFrugal walk-in → B2C); `customer_id`, `counter`, `last_modified_at`. **`business_date` KEPT** (it's
the conformed gold date across posted/recon/saree/replenishment — NOT renamed to `invoice_date`;
renaming would break conformance across ~6 models).

Method is codified as the **`design-silver-layer` skill**; full column audit + decision provenance at
`docs/plans/issue_380_sales_wide_decisions.md` (D1–D21) + `_lineage.csv`. Follow-ups open: #375/#376
(GoFrugal discount under-capture — real ₹ sits in bill-level `bill_disc`, not the carried
`item_disc_amt`; analysis → RB), #378 (salesman cleanup), #379 (customer master + PII), #382 (Zakya
`branch_name` historical backfill).

**GOTCHA (also proposed → docs/agents/gotchas/):** a single-transaction dbt `--full-refresh` of a
68M/76M-row silver table over MotherDuck **hit the time-based lease limit and rolled back**. For a
column **rename/drop** on a big incremental table, use metadata-only **`ALTER … RENAME/DROP COLUMN`**
(instant, no rewrite) — dbt's `on_schema_change: append_new_columns` adds but never drops. Chunk any
real backfill. See [[reference_md_load_chunking_from_box]].
