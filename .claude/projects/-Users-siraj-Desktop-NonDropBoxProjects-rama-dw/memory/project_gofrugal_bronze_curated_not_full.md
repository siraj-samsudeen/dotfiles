---
name: project_gofrugal_bronze_curated_not_full
description: "CORRECTED 2026-08-27 — the 2026-05 curate-at-bronze DECISION was never applied: bronze_gofrugal lands the FULL JSON payload, so any field can be pulled into silver with no re-extract"
metadata: 
  node_type: memory
  type: project
  originSessionId: f483cd10-b16a-4ad6-9ecf-f4caae6fb48a
---

**⚠️ CORRECTED 2026-08-27 (#2524). Read this first — the decision below did NOT ship.**

`bronze_gofrugal.landing.sales_item_wise` stores the **entire API response as JSON in `_payload`**
(the source yml says so: "Raw GoFrugal JSON-as-column landing tables (#41)"). Verified by listing
payload keys: ~90 keys present, INCLUDING every field the walkthrough marked drop — `manufacturer`,
`free_mtr_qty`, `commodity_code`, `item_disc`, and the whole blank address block. So the keep-list
lives as DOCUMENTATION (`gofrugal_api_probe/field_review.html`, keep/drop + reason per field) and is
applied when a silver model extracts — not at ingestion.

**Consequences that matter:**
- Adding a GoFrugal column to silver is a **one-line `js()` extraction, never a re-extract**. Do not
  quote "bronze is curated" as a reason a field needs re-ingestion (I did, and was wrong — #2524).
- The claim below that **`sold_mtr_qty == sold_qty` is an exact duplicate is FALSE.** It diverges on
  **4.12% of 7.82 crore rows** (by quarter: 2.86 / 3.21 / 6.77 / 7.75 / 1.39 / 1.84 %). GoFrugal's
  `units` is a NUMBER (measure per piece), and `sold_mtr_qty = sold_qty * units` on 100% of rows —
  so it is the MEASURED quantity (metres of fabric, kg of loose grocery) where `sold_qty` counts
  pieces/cuts. Shipped as `sold_measured_qty` (#2524). The 6-sample probe that called it a duplicate
  simply never hit a divergent row.
- The lesson generalises: a **6-sample "identical" verdict is not evidence of duplication.** Its
  sibling `free_mtr_qty` was dropped on the same basis and may deserve a re-check.

Original decision, kept for context:

Decision (2026-05-29, during the #48 field walkthrough): the GoFrugal `restAdapter` feeds will be **field-curated at the Bronze layer** — we will NOT land every field. `sales_item_wise` alone is ~42 MB / 20k rows for ONE outlet for ONE day, and it carries many structurally-present-but-unpopulated columns (constants like `commodity_code`=0, `manufacturer`=NA, `item_disc`=0; 100%-blank address/shelf fields; and exact duplicate columns like `sold_mtr_qty`==`sold_qty`). Landing all of it across many outlets × full history blows up storage for no analytic value.

**Why:** data size is the binding constraint; faithful-mirror is not worth the cost when a large fraction of columns are dead.

**How to apply:** when building the #41 GoFrugal dlt pipeline, apply an explicit keep-list per feed (the take/ignore verdicts from the #48 walkthrough), not dlt's infer-everything default.

This REVERSES the earlier stance in `HANDOFF_gofrugal.md` ("Bronze is a faithful raw mirror... don't pre-decide redundancy; the silver layer can"). The walkthrough on #48 supersedes it. Related: [[project_feather_etl_smoke_2026_05_16]].
