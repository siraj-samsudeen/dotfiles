---
name: project_category_master_261
description: "silver_core.category_master built from SAP t023t — MATKL 4-level decode, MC=Subdivision, SPART trap"
metadata: 
  node_type: memory
  type: project
  originSessionId: 48334ae9-870f-49e8-8176-6f942a53fd15
---

`silver_core.main.category_master` is LIVE (#261, closed 2026-06-27; commits 6054791 model, 6427de7 ADR/CONTEXT). Decodes SAP `MATKL` (`bronze_sap.master.t023t`, EN only) into a 4-level merch hierarchy. dbt model at `dbt_runner/dbt/models/core/category_master.sql`; `core/` models materialize to `silver_core.main` (table) per dbt_project.yml.

**Hierarchy (ADR 0033):** `Division (2-dig) → Subdivision (4) → Category (6) → Subcategory (9-dig leaf)`. Grain = one row per 9-digit leaf; codes are cumulative prefixes; `material_group` PK = full 9-digit = subcategory code. Filter `matkl similar to '[0-9]{9}'` → 1,514 clean. 8 divisions (01 Fashion N Lifestyle, 02 Home, 03 Grocery, 04 Food Court, 06 Services, 07 Consumable, 80/90 internal).

**#366 UPDATE (2026-07-02, LANDED to main — commits 08b4308 bronze, 667e4f2 silver):** the old "only the leaf is named; intermediate `*_label` cols are code-fallback" claim is **FALSE and gone**. SAP names **all four levels** in the classification layer (class type **026**, tables `bronze_sap.master.klah` = nodes / `swor` = names, read by MCH view t-code `ZVK11` → FM `MERCHANDISE_GROUP_HIER_ART_SEL`). category_master now sources `division_name_sap`/`subdivision_name_sap`/`category_name_sap` from KLAH/SWOR (join `klah.clint=swor.clint AND swor.spras='E' AND swor.klpos='01'`, `klah.klart='026'`; code-fallback for 5 orphan leaves); `subcategory_name`=`wgbez` still. `*_label` cols REMOVED → downstream repointed to `*_code`/`*_name_sap` (replenishment_base, both saree models). `KSSK` (edges) deliberately NOT loaded (mixes characteristic classes; structure = prefix decode). klah/swor added to `sap_bronze/config.py` (weekly full_reload), synced to box + loaded (2,579 rows client-200 each).

**NEW model `silver_core.category_hierarchy` (#366/#277):** business-facing view = category_master (SAP-pure) + `category_business_map` seed (1,235 leaf-grain rows keyed on `material_group`, derived from `docs/taxonomy/*_crosswalk.csv` by `discovery/issue_366_mch/build_category_business_map.py`). The CEO's #277 taxonomy **RE-CUTS** the SAP tree (div 01→Fashion+Lifestyle, 02→Home+Furniture, 6 subdivisions split e.g. Furniture→5 rooms) → single-valued only at the leaf → overlay is leaf-grain, NOT per-level. 279 unmapped leaves (zero-sales/internal) pass through SAP name; 1 exception (cattle feed) in `docs/taxonomy/taxonomy_map_exceptions.csv`. **Dashboards/gold slice by category_hierarchy `business_*` names; category_master is SAP verbatim.** Regenerate the seed after crosswalk edits via the discovery script.

**Load-bearing terminology:** business/CEO calls the L2 Subdivision level **"Main Category" (MC)** — MC = Main Category = Subdivision. Recorded in ADR 0033 + CONTEXT.md "Material group" + #261 comment.

**Traps:** (1) SAP `PRDHA` is NOT the hierarchy (<1% populated) — use MATKL. (2) SAP `SPART` (surfaced as `core/item.division`) is a degenerate near-constant `'10'`, NOT the merch Division — `item.division` is misnamed (→ #267 rename to `sales_division`). (3) GoFrugal POS `category_l1/l2/l3` is a SEPARATE classification system; SAP owns the unqualified Category/Subcategory words (SoR).

This is the buildable-today SAP/MATKL slice of [[project_sap_silver_inventory]]'s sibling epic #184. Follow-ups: #266 **CLOSED/superseded by #366** (Excel overlay no longer needed — names come from SAP); #267 (item.division→sales_division, still open); **#367** (productionize HSN audit → Rill + alerts; owns the `division_labels` seed fate — untouched by #366); **#368** (move `gold.replenishment_base` out of gold, repoint its labels to `category_hierarchy`). Consumers: #256 replenishment, #184. See [[project_mydb_migration]] (saree models that consume category_master are my_db-coupled + not building).
