---
name: project_mydb_migration
description: "my_db→DW migration REFRAMED 2026-07-02: dive-driven, gold-only consumer layer; epic #191 + phases #300/#347-350"
metadata:
  node_type: memory
  type: project
  originSessionId: cc12c3c5-6b8b-4dd0-bb12-5f49080dd224
---

**REFRAMED 2026-07-02 (approved by Siraj).** Goal is NOT migrating my_db's 62 tables 1:1. It is moving the CEO's **~143 MotherDuck dives** onto a **gold-only consumer layer** — every dive attaches ONLY `gold` (never bronze, never my_db/jrpl shares, ideally not silver). `gold` = **conformed star** (signed facts + conformed dim VIEWS surfaced in gold, physically in silver_core). Demand-driven: build in gold only what a live dive needs → repoint → drop orphans.

**Evidence (dive reference map, 137/142 dives parsed):** 71 read bronze, 52 silver, 29 my_db/jrpl, only **1 gold-only**. gold today = sales family only. Subject demand: sales 89, item_master 43, vendor 35, governance 35, procurement 34, finance 33, inventory 32, forecast 27, customer 11, hr 9.

**GitHub:** epic **#191** = [EPIC] (rewritten; RB's original 21-table spec preserved as a comment). Phases: **#300**=Phase 0 (gold conformed star + native Zakya SKU + diagnose sales gap + gold dim VIEWS, subsumes #283, + ADR); **#347**=P1 off-my_db (29 dives); **#348**=P2 kill bronze (71); **#349**=P3 silver→gold-only (52); **#350**=P4 guardrail dive-lint. **#228 CLOSED** (LFA1 loaded). First slice = chip **task_6321b416** (Zakya sales diagnosis + native SKU).

**Key unblocks (my_db lineage profiling):** `sap_latest_cost` = `bronze_sap.inventory.mbew.verpr` (moving-avg, 99.98%); **LFA1 IS loaded** (`bronze_sap.master.lfa1`); item masters are sales-derived (GoFrugal/Zakya have no master feed); most my_db objects (`kat_*`, `kl_dive_*`, `kl_store_rain*`, all `vw_*`, `store_targets`, `store_closures`, `xref_pos_counter`, `daily_flash_log`) are EPHEMERAL scratch → **drop not migrate**. Genuine governed: item masters, item_cost/purchase, vendor_item_stock_cost, tn_category_sales, vendor bridge, budget/AOP seeds, org/season/kpi seeds, rca_action_tracker (P0 upsert), TN/KL P&L seeds.

**Coupling debt (from #366 session, now folded into #347/Phase 1):** 4 gold dbt models hardcode `my_db.main.sap_vendor_sku_stock` but **nothing attaches the share AS `my_db`** (dbt on-run-start only CREATEs silver/gold DBs). So `gold.saree_sku_snapshot`/`gold_saree_sales` don't build (`Catalog "my_db" does not exist`). Proper fix = build `gold.vendor_item_stock_cost` from SAP bronze (lfa1+mbew.verpr+ekbe) and repoint these gold models = exactly the Phase-1 vendor-mart work.

**my_db share provenance (catalog, 2026-07-02):** ONE share, NOT 3 copies — jrpl/jrpl_db/jrpl_mydb/mydb_share all → `_share/JRPL_DB/eb9219d1-0394-422b-ab6b-1bf8f4bbcb77`, owner **rbchandran@jeyarama.com**, created 2026-06-26, **UNRESTRICTED+DISCOVERABLE**. This account owns NO copy. Cutover = **DETACH the 3 aliases (not drop)**. RB live on my_db as of 2026-07-01 (Dives app + Claude MCP). Provenance via `md_information_schema.main.{shared_with_me, owned_shares, query_history}`.

**Zakya sales-fact RED FLAG (gates 89 dives):** gold.sales(zakya) runs ~1.5× value / 3–5× SKU-count vs my_db.zakya_sku_sales_daily (store 1501 / 2026-06-18: gold qty 32,448 vs 8,740). Prime suspect = **bronze 3-day re-poll dup rows not deduped in the gold zakya path** ([[reference_control_plane_query_model]]). gold.sales also lacks native Zakya SKU (only item_code_sap). = Phase 0 first slice.

**Detailed artifacts committed to repo `docs/migration/`** (dive reference map + 62-object build-specs). See [[project_store_dimension_249]] (Done: store dim), [[project_category_master_261]], [[reference_motherduck_mcp_routing]], [[reference_rama_dw_local_dbt]].
