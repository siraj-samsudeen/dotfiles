---
name: gotcha_gold_only_dive_materialize_wide_as_table
description: A MotherDuck Dive on a gold VIEW auto-requires the silver shares behind it (incl. PII); materialize the _wide as a TABLE to keep the Dive gold-only
metadata: 
  node_type: memory
  type: reference
  originSessionId: 7230f41b-ea58-4964-a0d5-7a1359667ddf
---

**Trap:** MotherDuck derives a Dive's `REQUIRED_DATABASES` from the *lineage* of whatever it queries. If a Dive reads a gold **view** (e.g. `gold.sales_wide`, `gold.tender_lines_wide`) that computes over silver at query time, the tooling adds the underlying **silver shares** (e.g. `silver_zakya`, `silver_core`) to the Dive's required shares — so a viewer needs those silver shares too, exposing everything in them (including `invoice_lines` customer **PII**). Setting `REQUIRED_DATABASES` to gold-only by hand does NOT stick — the next save re-introspects the view lineage and re-adds them.

**Fix (used in #180):** materialize the `_wide` flatten as a **TABLE** (store attributes baked in), not a view. Then the Dive's only lineage is the gold table → it needs **only the `gold` share**. This diverges from ADR 0042 (which keeps `_wide` a view for zero-copy) — a justified exception for **external/least-privilege viewers** who must not see silver/PII. Make it `incremental` (delete+insert on the grain key + `loaded_at` watermark) so the gate isn't rebuilding the whole table each run; caveat = dim attributes freeze at load time (fine for stable dims like store).

**When it bites:** any time you repoint a bronze/silver-reading Dive onto gold for a viewer who only holds the `gold` share (the #348 "kill bronze in 71 dives" migration will hit this repeatedly). Verify after saving the Dive: re-read it and confirm `REQUIRED_DATABASES` stayed gold-only. Related: [[project_zakya_tenderwise_payment_dive]], [[reference_motherduck_mcp_routing]].
