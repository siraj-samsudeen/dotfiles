---
name: project_demand_side_gold_build_191
description: Demand-side gold-only build (epic
metadata: 
  node_type: memory
  type: project
  originSessionId: 585e6ecc-6c64-4d91-8914-9f8094f31efc
---

Demand-side build of epic #191 (my_db→gold-only) LANDED on main 2026-07-08 via **PR #485** (single consolidated PR; branch issue-347-gold-shared-dims). Built gold + curated silver for **all 5 systems** so the CEO's dives become gold-*satisfiable*. Full `dbt build` of merged gold + new silver = 150 pass, 0 errors; everything reconciles to source.

**New gold**: `gold.dim_item` (view, 1.38M), `gold.dim_vendor` (←new `silver_core.vendor`/lfa1, 10,858), `gold.store/date/category` (views), `gold.inventory_soh` (←new `silver_sap.inventory.item_cost`/mbew; 2.75M, 99.3% costed, ~₹420 Cr), `gold.procurement` (SAP ekko/ekpo/ekbe 7.38M **+ PTP leg** 222.9k; received ties exactly to ekbe), `gold.gl` (VIEW over 144M acdoca) + `gold.trial_balance` (←new `silver_sap.master.{gl_account,cost_center,profit_center}`; ties exactly to acdoca), native Zakya SKU on `gold.sales` (item_code_zakya/zakya_sku/zakya_item_name/zakya_hsn + mrp; ties exactly to silver), `gold.tn_category_sales` (GoFrugal TN), HR star `gold.{dim_employee,dim_section,hr_attendance,hr_payroll}` (#259). New silver schemas: `silver_sap.purchase.*`, `silver_sap.master.*`.

**Method**: built shared dims + SAP + Zakya myself in one coherent dbt graph (worktree sweet-bell-094151); fanned StyleHR/GoFrugal/PTP to parallel sub-agents (verified each). Foundation was reconstructed from [[project_mydb_migration]] `docs/migration/mydb-gold-dive-migration.md` — the audit CSV/ADR-0047/reconcile-script named in the task do NOT exist yet (they're unbuilt #474 deliverables).

**Deliberately NOT done** (per AFK instruction): no dive repointed (dives live in RB's MotherDuck app, not repo), no share flipped, no bronze disconnect — enforcement stays with #474 / ADR 0048.

**Flagged follow-ups**: (1) GoFrugal raw gold.sales < legacy my_db for closed months — **RESOLVED/REFUTED in #492**: NOT a bronze gap. Bronze early-2025 rows/bills/qty/value ≈ recent months (control.grid all ok), gold ties bronze ~99%; the legacy **my_db baseline is INFLATED ~2–3.6× in early months** (fan-out in frozen legacy ETL), decaying to parity by ~2026-04. No backfill; TN GoFrugal dives CAN cut over onto gold for history; do NOT reconcile gold UP to my_db. Residual: spot-check vs GoFrugal source .62 as tie-breaker. (2) 2 impossible ₹2,003 Cr rows in `silver_ptp.conform.invoicedata` guarded in silver (nulled >=₹100 Cr) — root-cause upstream (#386/#387/#388). (3) `gold.season` deferred — needs business-authored season calendar, not fabricated. Related: [[project_canonical_budget_441]], [[feedback_silver_fixes_dq_not_gold]].
