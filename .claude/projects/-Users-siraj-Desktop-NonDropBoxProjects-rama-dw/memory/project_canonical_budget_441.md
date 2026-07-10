---
name: project_canonical_budget_441
metadata: 
  node_type: memory
  type: project
  originSessionId: 2ccf3111-77fc-466e-a145-e5782301dc3f
---

#441 LANDED to main (PR #449, 2026-07-07): RB's `TN & Kerala Budget FY2627 (New Hierarchy).xlsx` is
the **single canonical budget**; old TN-only seed + all `mydb_share` budget tables discarded (#347,
share not dropped).

- **Seed** `silver_core.budget_fy2627` (187,829 rows, 23 stores, **₹2,461.8 Cr** = TN ₹1,542 + KL
  ₹920; RB confirmed **₹920 Cr KL canonical**, the ₹728 note superseded). Built by
  `scripts/build_budget_seed.py` (regenerate when #442 fixes the source). cal_year/cal_month derived
  from Month (xlsx `Year` discarded); KL residue folded (FOOD COURT→Food Court, Fashion N Lifestyle→
  Fashion/Womenswear/Topwear); 192 null-hierarchy rows sentinelled (ADR 0043).
- **Silver** `silver_core.sales_target` (realizes #105 fact_target). **Grain = store × cal_year ×
  cal_month × FULL 4-level path** (division/subdivision/category/subcategory) — NOT subcategory alone,
  which isn't globally unique (shorts/leggings sit under 2 paths). 187,781 rows.
- **Gold** `gold.sales_budget_vs_actuals` — budget FULL-OUTER-JOIN `sales_wide` actuals; replaces the
  broken `mydb_share.vw_store_sales_vs_budget`; unblocks #437 (MOT 1507) + #440 (KAT 1515). MTD target
  phases the monthly budget via a **last-year (FY2526) region×month×day cumulative curve**; table is
  materialized so the "as-of today" advances only on the nightly rebuild.
- **Basis = EX-GST / PRE-GST — CONFIRMED by RB (2026-07-07)** for BOTH the budget value and actuals
  (`amount_before_tax`), per ADR 0018 / RB's RBS-001. Client corrected an initial `amount_after_tax`
  pick. Gross carried as `actual_inr_incl_gst` reference-only, NEVER in achievement/ranking. Verified:
  KAT actuals tie to ADR 0018's documented ex-GST Net Sales to the rupee.
- **Store short_code** established (28 stores, 1:1 with store_code): 23 from budget labels + 5
  provisional (EXH/GTN/GRN/GTB/MRT) pending RB. On `store_attributes` + surfaced on `silver_core.store`;
  raw labels in `plant_alias` namespace `budget_label`. Connects [[project_store_dimension_249]].
- GOTCHA: a schema-changed seed with live view-dependents (store_attributes→store→sales_wide) fails
  the incremental seed with MotherDuck "Conflict on tuple deletion" under Rill load → use
  `dbt seed --full-refresh` (docs/agents/gotchas/dbt-seed-schema-change-needs-full-refresh.md).

RESOLVED: budget basis is pre-GST (RB confirmed 2026-07-07) and magnitude ₹920 Cr KL confirmed — no
restatement. Remaining minor: 5 provisional short_codes await RB blessing. #442 tracks the permanent
source-side hierarchy fix (lets DQ tighten to zero-tolerance). Feeds [[project_sales_wide_380]]
consumers. (Committed code comments still say "provisional pending RB" — cosmetically stale but
harmless; the `sales_target_basis_sanity` tripwire remains a useful floor.)
