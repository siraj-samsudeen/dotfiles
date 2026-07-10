---
name: project_ptp_bronze_curation_537
description: "PTP bronze is now a curated 36-table merge-only allow-list, NOT a full mirror (ADR-537 supersedes ADR 0039"
metadata: 
  node_type: memory
  type: project
  originSessionId: f8438068-2573-47a7-baef-39ed7e4079ec
---

#537 (PR #544, branch `issue-537-ptp-bronze-curation`) re-curated PTP bronze from a **full
base-table mirror** into an explicit **36-table `config.KEEP_TABLES` allow-list**, merge-only.
**Do NOT re-expand to a full mirror** — ADR-537 supersedes ADR 0039 #2/#3 (its
database-consolidation-diff justification was never intended; the replace-only tail was
destructive-on-failure in MotherDuck — a lease-expired `replace` wiped ~60 tables 2026-07-08).

**Why / key facts:**
- `ptp_extract` `discovery.py` now keeps a table iff it's in `KEEP_TABLES` and present in that
  instance; `source.py` is **merge-only** (`write_disposition="merge"` always; `--refresh` = full-read
  merge, never `replace`). A keyless kept table raises at discovery (extends ADR 0034 → no destructive replace).
- Dropped 51 tables: 3 no-consumer SAP mirrors (`sap_data`/`sap_results`/`complete_sap_data`), 20 junk,
  28 empty/tiny stubs. Physical `DROP TABLE` is **post-deploy** (`ptp_extract/scripts/drop_decommissioned_ptp_tables.py`, dry-run default) — the #517 chip runs it after the Railway deploy so tonight's old cron doesn't reload them.
- `silver_ptp` conform (#386) pruned in lockstep: 65 → 34 models (the 5 gold-feeding + timeline sources survive). See [[project_ptp_conform_386.md]].
- **2 SAP-mirror catches kept under protest** (`sap_payments` → #260 timeline; `sap_data_stn` → Stationery Dive) — merge cleanly, no gold/silver home yet. Repoints filed as follow-ups.
- **Only TN (`bronze_ptp`) has consumers**; KL/KN feed only the conform union. `report_server` P2P dashboards are csv_upload/baked (no live warehouse dep).

**How to apply:** for any PTP bronze work, treat `config.KEEP_TABLES` as the source of truth; add a
table + backfill on demand only when a named consumer needs it. Parent **#517 (PTP→Railway) is being
completed in a separate session** (chip task_3fdfca14) — merge #544 → deploy → wipe → verify merge-only
cron → fix `docking_transactions.created` NULL-cursor drop. Decision grid:
`docs/plans/issue_537_ptp_curation_grid.html`. See [[reference_rama_dw_deployment_topology.md]], [[project_stylehr_railway_413.md]].
