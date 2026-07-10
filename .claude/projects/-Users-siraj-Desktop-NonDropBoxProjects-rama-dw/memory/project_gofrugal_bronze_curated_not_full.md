---
name: project_gofrugal_bronze_curated_not_full
description: "GoFrugal bronze ingestion is field-curated, NOT a faithful full-mirror — drop useless fields at bronze to control data size"
metadata: 
  node_type: memory
  type: project
  originSessionId: f483cd10-b16a-4ad6-9ecf-f4caae6fb48a
---

Decision (2026-05-29, during the #48 field walkthrough): the GoFrugal `restAdapter` feeds will be **field-curated at the Bronze layer** — we will NOT land every field. `sales_item_wise` alone is ~42 MB / 20k rows for ONE outlet for ONE day, and it carries many structurally-present-but-unpopulated columns (constants like `commodity_code`=0, `manufacturer`=NA, `item_disc`=0; 100%-blank address/shelf fields; and exact duplicate columns like `sold_mtr_qty`==`sold_qty`). Landing all of it across many outlets × full history blows up storage for no analytic value.

**Why:** data size is the binding constraint; faithful-mirror is not worth the cost when a large fraction of columns are dead.

**How to apply:** when building the #41 GoFrugal dlt pipeline, apply an explicit keep-list per feed (the take/ignore verdicts from the #48 walkthrough), not dlt's infer-everything default.

This REVERSES the earlier stance in `HANDOFF_gofrugal.md` ("Bronze is a faithful raw mirror... don't pre-decide redundancy; the silver layer can"). The walkthrough on #48 supersedes it. Related: [[project_feather_etl_smoke_2026_05_16]].
