---
name: project_ptp_conform_386
description: "silver_ptp.conform (#386) — 65-table faithful 3-instance PTP conform LIVE on main; ADR 0043"
metadata: 
  node_type: memory
  type: project
  originSessionId: 42213d56-e0f3-42ed-a75b-16719c2e036b
---

**#386 LANDED to main (PR #390, 2026-07-03).** `silver_ptp.conform.<table>` = faithful cross-instance
conform of all 65 non-SAP-mirror PTP base tables (33 facts + 32 masters) across the 3 regional
instances (TN `bronze_ptp`→JCT, KL `bronze_ptp_kerala`→RCT, Kannammal `bronze_ptp_kannammal`→Kannammal).
Purpose = decision **2a**: conform in the warehouse first as the feasibility study + transform map for
the eventual physical "one server" consolidation (the merge lives *above* bronze; bronze stays 3
mirrors per ADR 0039).

**Shape (D6):** one generated model per table — `UNION ALL BY NAME` across present instances,
`SELECT * EXCLUDE(drop-list) REPLACE(drift-casts)`, `source`/`entity` stamped from **provenance**
(each instance = one entity, 1:1 — so entity is gap-free, no plant join). Materialized `table` (PTP
small). **DQ fixed IN SILVER** (not gold — [[feedback_silver_fixes_dq_not_gold]]): 34 casts (drift +
data-verified VARCHAR measures) TRY_CAST junk→NULL; `region` resolved via `plant_master` for 20
plant-key tables (`__unmapped__` sentinel = the 33 #387 blank-plant rows; entity stays gap-free).
Regenerate via `docs/plans/issue_386_gen_conform_models.py` (v2 auto-detects drift/measures/plant-keys).

**Decisions:** `docs/plans/issue_386_ptp_conform_{scope,decisions,lineage.csv}` + **ADR 0043**
(unresolved dimension keys: resolve-or-sentinel-never-drop, 3-tier ladder — resolve-in-model /
governed override seed `plant_alias` #307 / `__unmapped__` sentinel+test; measure junk → NULL+test).
Only 11 columns drift in type across all 62 non-spine tables (mechanical). Existing #260
`silver_ptp.procurement.p2p_invoice_timeline` (TN-only) untouched.

**Excluded (22):** 5 SAP mirrors (`sap_data*`/`sap_payments`/`sap_results`/`complete_sap_data` →
reconcile vs bronze_sap #211) + 17 plumbing (drafts/counters/logs/config/`tat_metrics`).

**Open DQ follow-ups (Kannan):** [[project_sales_wide_380]]-style — #387 blank-plant / Kannammal
`2100` (org) vs plant `2101`; #388 VARCHAR-measure junk (invoice_qty). Related: design-silver-layer
skill produced this; see [[feedback_show_dq_details_never_bury]].

**Catalog names — the TN one was RENAMED, and the old name still misleads (2026-08-20, #2468).**
The three live catalogs are `bronze_ptp_kerala`, **`bronze_ptp_tamilnadu`**, `bronze_ptp_kannammal`.
The TN instance was once plain **`bronze_ptp`** (as this note said above); that catalog **no longer
exists**. Querying it returns `Catalog "bronze_ptp" does not exist!`, which reads like PTP is
missing rather than renamed — it cost a wrong diagnosis in the 2026-08-20 daily-loading sweep.
Always enumerate with `show databases` before concluding a PTP catalog is absent
([[feedback_absence_claims_need_positive_control]]).

**#2468 LANDED (2026-08-20, PR #2470).** `daily-loading`'s `MD_CONTROL` swept only
`bronze_ptp_tamilnadu`, so Kerala and Kannammal were **unmonitored** — including the "silence is the
alarm" no-runs check, which only ever asked TN whether it had fired. Now one entry per instance
(own dedup key, own no-runs check). Same fix corrected `reachability` from `local` to **`cloud`**:
PTP moved to Railway in #517, so a PTP fix never needs box SSH/VPN, and the old tag would have sent
whoever picked it up hunting for access they don't need. Dedup keys are now `ptp_<instance>/control/*`.

