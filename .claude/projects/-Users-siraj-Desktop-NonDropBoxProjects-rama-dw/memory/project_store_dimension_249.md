---
name: project_store_dimension_249
metadata: 
  node_type: memory
  type: project
  originSessionId: cc12c3c5-6b8b-4dd0-bb12-5f49080dd224
---

#249 standardizes the store dimension on the SAP plant code (**ADR 0032**: plant is canonical, store is the retail view). Part of [[project_mydb_migration]].

**Slice 1 MERGED** (PR #253 → main): `silver_core.plant_master` (all SAP plants from `bronze_sap.master.t001w`; plant_type/entity/region; **region from vkorg NOT regio** → border stores 1509 Tenkasi / 1514 Marthandam = KL), `silver_core.store` (retail view, 25 stores, full consumer contract preserved, zero gold.sales orphans), `plant_alias` seed (`(namespace,alias)→plant_code` for code-less sources) + 3 guards incl. a **hard-fail coverage test**, `plant_overrides` seed. `silver_zakya` repointed branch→code to plant_alias (mapping proven byte-identical); `zakya_branch_map` seed + table retired/dropped.

**Slice 2 IMPLEMENTED** (PR #264, branch issue-249-stylehr-recon): `plant_alias` got a **`stylehr_id`** namespace (27 rows) — keyed on StyleHR `store_store.id` NOT name (the brief said `stylehr_name`; data forced id: `store_code` corrupt for 1503 — id 423 "Enchakkal WH" carries store_code 1503 but is warehouse plant 9151, real store 1503 = blank-code "Enchakkal SPM" id 422; StyleHR facts FK on id; RB #235 xref keys on id). Corrected RB's xref: id 490 "Marlyns" = the KKM store 1512, the salon is the separate id 633 "Marlyns Beauty Studio". `silver_core.stylehr_plant_recon` view (130 raw→90 deduped→27 mapped/63 unmapped) labels discrepancies (1503 store/WH, 1509 Vallom→Courtallam, 1512 Marlyns→KKM, 1514 TN→KL); unmapped HR locations bucketed. Hard-fail `stylehr_retail_alias_coverage` test (KL 15xx block). All 22 dbt nodes pass. **Remaining slices:** AOP budget seed, vendor dim (#228), sales marts (ex-#194); slice 3 RB 🔵s (lfl_class/store_group/bi_store label). See [[reference_sap_plant_master_t001w]].

**WORKTREE GOTCHA hit this session:** edits initially landed on the MAIN checkout (sitting on `main`) instead of the worktree — Read/Write used absolute MAIN paths. Always target the worktree path for code; MAIN abs-path is only for `.venv`/`rill/.env`/secrets.
