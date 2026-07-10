---
name: project-report-rationalization-478
metadata: 
  node_type: memory
  type: project
  originSessionId: 9096bac0-c027-420f-8de8-3c0ad98d9388
---

#478 Report Rationalization: ONE registry at `docs/reports/report_registry.csv` on main — **1,281 rows = 1,130 HTML reports** (built by containers, mapped by a separate agent via PR #479) **+ 151 MotherDuck dives** (added this session, PR #483). 15-col shared schema: `report_id` (`dive:<uuid>` / `html:<path>`), `report_type`, `title`, `owner`, `region`(''/KL/TN), `subject`, `current_version`, `updated_at`, `sources`, `source_tier`(baked/csv_upload/live_warehouse), `duplicate_group`(`grp-<slug>`), `is_canonical`(Y/N), `disposition`(keep/retire), `ceo_decision`(pending), `notes`.

Dedup method (same both sides): canonical = highest version / latest updated within a name-family. Dive side = **143 keep / 8 retire** across 7 groups (Saree×3, GODMODE, Malkist, Vendor-Dedup, Men's-Buyer, Store×Item + the fa702076→bd605fae supersession); fuzzy families (AR-recon, cashier, F&V, budget) left `keep` for the analysis agent. **Every row `ceo_decision=pending` → CEO approves.**

Dive counts: **151 total, 130 by rbchandran (CEO)**, 17 simiyon, 2 jerosa, 1 hareesh, 1 siraj. Versions are NOT counted as separate dives (`current_version` is per-id; some dives edited 25–45×). Related [[project_layer_access_474]], #436/#452 (HTML report server epic).
