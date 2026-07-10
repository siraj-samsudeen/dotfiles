---
name: project-reference-data-teable-307
metadata: 
  node_type: memory
  type: project
  originSessionId: e4d90a40-8d43-41ab-a38b-b8cc95a3b5a8
---

**#307** = a humane editing surface for hand-curated **reference data** (see CONTEXT.md term) — the
dbt seed masters that a steward should edit without touching git. Reframed from "plant_alias pilot"
to "stand up reference data in Teable" after the pilot succeeded.

- **Tool: Teable Cloud** (chosen for speed; NocoDB is the swappable fallback since data is portable).
  Base `bsel9E8xTO9V3ZrOxmV`. Long-term platform is React+Convex — the editing tool is deliberately
  swappable, the durable contract is the eventual MotherDuck publish.
- **Live tables (built via REST API, 2026-06-30):** `store_attributes` (28), `plant` lookup (54, from
  `silver_core.plant_master`), `plant_alias` (19, `plant_code`→link to `plant`), `plant_overrides` (4).
- **Field types are classified per table** (numbers/dates/single-selects/links), never dumped as text.
  A Teable link can't be a primary field → `plant_overrides.plant_code` is plain text.
- **Remaining Group-A** to onboard: `division_labels` (8), `gst_chapter_rates` (84). **Excluded** (eng
  config, stay as seeds): `freshness_targets`, `sap_load_config`. **Deferred** (diff domain, ~1,237
  rows): the 5 `docs/taxonomy/*_crosswalk.csv`.
- **Step 2 (separate issue, not yet filed):** publish each table → MotherDuck `mdm.*` via a Railway
  cron on the REST API; repoint the two Zakya models (zakya_invoice_lines, zakya_return_lines) from
  `ref('plant_alias')` seed to `source('mdm','plant_alias')`; keep seeds as fallback until verified.
  The throwaway build script graduates into `mdm_sync/` there.
- **Sharing:** invite named collaborators (per-user record history = the audit trail), not a public
  link. Only Editor+ seats are billed (~$10/seat Pro); Viewer/Commenter are free. Keep Owner/Creator
  to the operator so stewards can edit data but not break schema.

Plan: `docs/plans/issue_307_ref_data_editing_surface.md` (on main). API access: [[reference-teable-api-access]].
