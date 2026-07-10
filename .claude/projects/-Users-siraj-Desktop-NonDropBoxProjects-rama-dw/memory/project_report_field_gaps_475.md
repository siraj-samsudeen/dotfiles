---
name: project_report_field_gaps_475
description: "#475 report-driven field-gap program — 1,130 HTML dashboards inventoried; gaps 4/5 (SKU master + AR/AP aging) LIVE on main, HR gap 2 in #480, others routed"
metadata: 
  node_type: memory
  type: project
  originSessionId: 2660b1f9-f50f-410f-909d-c1b774435247
---

Epic **#475**: inventoried RB's **1,130 HTML dashboards** (PR #468 consolidation) → classified each (skeleton-extract → Haiku fan-out) → diffed vs the live warehouse → found the field gaps. Ref doc on main: `docs/migration/report-field-gaps.md`. Plan: `docs/plans/issue_476_hr_sku_arap_batch.md`.

**Headline finding:** ~94% of dashboards run on hand-uploaded CSVs (810 baked · 248 csv · 68 live). Most "gaps" are DERIVED (computable from existing facts) — only a handful are genuine base-data gaps, and 6 of 8 are silver/gold **modelling** gaps on data already in bronze/silver (NOT ingestion): acdoca has BS rows (glaccount_type='X'), bseg has AR/AP open items (koart D/K), bronze_stylehr has punch/shift/PFA, mbew=cost, mara.brand_id, stock_movements 551=scrapping/dump.

**Built + LIVE on main (PR #486, dbt-tested):**
- `silver_core.item_master` (~980k active SKUs; cost 99.5% / vendor 55% / brand 5.7% / launch 100%; **MRP + season NULL** v1 — no source)
- `silver_sap.finance.{ap,ar}_open_items` (bseg koart K/D, open = augbl empty, netdt DQ-cleaned, `is_special_gl` advances flag) + `gold.ap_ar_aging` (unified line-grain, buckets; **net AP ~₹123 Cr all-in / ₹237 Cr trade-only ex-advances**; AR is advances-dominated)

**Routed, not built:** gap 2 HR → **#480** (full spec; build on #465 `attendance_punches` for breaks; is_late 5min configurable var). gap 1 target/YoY → #105/#469. gap 3 dead-stock/dump → #438/#248. gap 6 financials/BS → #360/#471/#407. gaps 7/8 (competitor/footfall) deferred.

**GOTCHA — reuse the #347/#348 conformed dims, don't duplicate:** while building I collided with PR #485 which landed `silver_core.vendor`, `silver_sap.inventory.item_cost` (mbew÷peinh), `sap/purchase/{po_header,po_line,po_history}`, GL/CC/PC masters, `gold.{gl,trial_balance,procurement,inventory_soh,dim_vendor}`, and **mrp on gold.sales (#351)**. Had to drop my duplicate `supplier` and refactor `item_master` to `ref()` their models. **Before building new silver/gold, check main for conformed dims first.** See [[reference_rama_dw_local_dbt]], [[project_demand_side_gold_build_191]], [[project_mydb_migration]].

**Registry:** #478 report-rationalization — HTML rows seeded into `docs/reports/report_registry.csv` on main (1,130 rows, 890 keep / 240 retire across 131 name-family duplicate groups; 32% of reports are serial rebuilds e.g. HR ControlTower TVM ×24).
